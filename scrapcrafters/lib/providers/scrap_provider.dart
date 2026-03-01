import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class ScrapProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _requestsChannel;

  List<Map<String, dynamic>> _myRequests = [];
  List<Map<String, dynamic>> _availableRequests = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get myRequests => _myRequests;
  List<Map<String, dynamic>> get availableRequests => _availableRequests;
  bool get isLoading => _isLoading;

  // Coin multipliers
  static const Map<String, int> coinMultipliers = {
    'iron': 30,
    'plastic': 20,
    'copper': 40,
    'glass': 20,
    'ewaste': 50,
    'other': 10,
  };

  Future<void> donateScrap({
    required String userId,
    required String scrapType,
    required double weightKg,
    String? description,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    Uint8List? imageBytes,
    String? imageExt,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;

      if (imageBytes != null && imageExt != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$imageExt';
        final path = '$userId/$fileName';

        await _supabase.storage.from('images').uploadBinary(path, imageBytes);
        imageUrl = _supabase.storage.from('images').getPublicUrl(path);
      }

      await ApiService.post(
        '/scrap/donate?user_id=$userId',
        body: {
          'scrap_type': scrapType,
          'weight_kg': weightKg,
          'description': description,
          'pickup_address': pickupAddress,
          'latitude': latitude,
          'longitude': longitude,
          'image_url': imageUrl,
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRequests(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('scrap_requests')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      _myRequests = List<Map<String, dynamic>>.from(data);

      _setupRealtime(userId: userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableRequests(String partnerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/scrap/requests/available?partner_id=$partnerId',
      );
      _availableRequests = List<Map<String, dynamic>>.from(response);

      _setupRealtime(partnerId: partnerId, forPartners: true);
    } catch (e) {
      print('Error fetching requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId, String partnerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.put(
        '/scrap/requests/$requestId/accept',
        body: {'partner_id': partnerId},
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so the UI can show the error dialog
    }
  }

  Future<Map<String, dynamic>> completeRequest(
    String requestId,
    String partnerId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.put(
        '/scrap/requests/$requestId/complete',
        body: {'partner_id': partnerId},
      );
      return {
        'coins_earned': response['coins_earned'],
        'new_balance': response['new_balance'],
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchAcceptedRequests(
    String partnerId,
  ) async {
    final data = await _supabase
        .from('scrap_requests')
        .select(
          '*, profiles!scrap_requests_user_id_fkey(name, location, phone)',
        )
        .eq('partner_id', partnerId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchDealerInventory(
    String dealerId,
  ) async {
    final data = await _supabase
        .from('dealer_inventory')
        .select('*')
        .eq('dealer_id', dealerId);
    return List<Map<String, dynamic>>.from(data);
  }

  void _setupRealtime({
    String? userId,
    String? partnerId,
    bool forPartners = false,
  }) {
    _requestsChannel?.unsubscribe();

    _requestsChannel =
        _supabase
            .channel('public:scrap_requests')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'scrap_requests',
              callback: (payload) {
                if (userId != null) fetchMyRequests(userId);
                if (forPartners && partnerId != null)
                  fetchAvailableRequests(partnerId);
              },
            )
          ..subscribe();
  }

  @override
  void dispose() {
    _requestsChannel?.unsubscribe();
    super.dispose();
  }
}
