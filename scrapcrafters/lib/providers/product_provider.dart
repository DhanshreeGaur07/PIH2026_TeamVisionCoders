import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('products')
          .select('*, profiles!products_artist_id_fkey(name)')
          .eq('is_available', true)
          .gt('stock_quantity', 0)
          .order('created_at', ascending: false);
      _products = List<Map<String, dynamic>>.from(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct({
    required String artistId,
    required String name,
    String? description,
    required int priceCoins,
    double priceMoney = 0,
    String? scrapTypeUsed,
    int stockQuantity = 1,
    Uint8List? imageBytes,
    String? imageExt,
  }) async {
    String? imageUrl;

    if (imageBytes != null && imageExt != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$imageExt';
      final path = 'products/$artistId/$fileName';

      await _supabase.storage.from('images').uploadBinary(path, imageBytes);
      imageUrl = _supabase.storage.from('images').getPublicUrl(path);
    }

    await _supabase.from('products').insert({
      'artist_id': artistId,
      'name': name,
      'description': description,
      'price_coins': priceCoins,
      'price_money': priceMoney,
      'scrap_type_used': scrapTypeUsed,
      'stock_quantity': stockQuantity,
      'is_available': stockQuantity > 0,
      'image_url': imageUrl,
    });
    await fetchProducts();
  }

  /// Purchase product via backend API (handles coin transfer to artist + stock)
  Future<Map<String, dynamic>> purchaseProduct({
    required String productId,
    required String buyerId,
    int quantity = 1,
    required bool payWithCoins,
  }) async {
    final response = await ApiService.post(
      '/products/$productId/purchase',
      body: {
        'buyer_id': buyerId,
        'quantity': quantity,
        'pay_with_coins': payWithCoins,
      },
    );
    await fetchProducts(); // Refresh product list (stock may have changed)
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchArtistProducts(
    String artistId,
  ) async {
    final data = await _supabase
        .from('products')
        .select('*')
        .eq('artist_id', artistId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
