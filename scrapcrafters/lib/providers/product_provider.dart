import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  }) async {
    await _supabase.from('products').insert({
      'artist_id': artistId,
      'name': name,
      'description': description,
      'price_coins': priceCoins,
      'price_money': priceMoney,
      'scrap_type_used': scrapTypeUsed,
      'is_available': true,
    });
    await fetchProducts();
  }

  Future<void> purchaseProduct({
    required String productId,
    required String buyerId,
    required bool payWithCoins,
  }) async {
    final product = await _supabase
        .from('products')
        .select('*')
        .eq('id', productId)
        .single();

    if (payWithCoins) {
      final buyer = await _supabase
          .from('profiles')
          .select('scrap_coins')
          .eq('id', buyerId)
          .single();

      if (buyer['scrap_coins'] < product['price_coins']) {
        throw Exception('Insufficient Scrap Coins');
      }

      final newBalance = buyer['scrap_coins'] - product['price_coins'];
      await _supabase
          .from('profiles')
          .update({'scrap_coins': newBalance})
          .eq('id', buyerId);

      await _supabase.from('transactions').insert({
        'user_id': buyerId,
        'amount': -(product['price_coins'] as int),
        'type': 'purchase',
        'reference_id': productId,
        'description':
            "Purchased '${product['name']}' for ${product['price_coins']} Scrap Coins",
      });
    }

    await _supabase
        .from('products')
        .update({'is_available': false})
        .eq('id', productId);
    await fetchProducts();
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
