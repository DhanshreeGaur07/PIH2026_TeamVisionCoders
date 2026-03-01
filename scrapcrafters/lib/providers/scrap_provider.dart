import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScrapProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('scrap_requests').insert({
        'user_id': userId,
        'scrap_type': scrapType,
        'weight_kg': weightKg,
        'description': description,
        'pickup_address': pickupAddress,
        'status': 'pending',
      });
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('scrap_requests')
          .select(
            '*, profiles!scrap_requests_user_id_fkey(name, location, phone)',
          )
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      _availableRequests = List<Map<String, dynamic>>.from(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId, String partnerId) async {
    await _supabase
        .from('scrap_requests')
        .update({'partner_id': partnerId, 'status': 'accepted'})
        .eq('id', requestId);
    await fetchAvailableRequests();
  }

  Future<Map<String, dynamic>> completeRequest(
    String requestId,
    String partnerId,
  ) async {
    // Get request details
    final req = await _supabase
        .from('scrap_requests')
        .select('*')
        .eq('id', requestId)
        .single();

    final scrapType = req['scrap_type'] as String;
    final weightKg = double.parse(req['weight_kg'].toString());
    final userId = req['user_id'] as String;

    // Calculate coins
    final multiplier = coinMultipliers[scrapType] ?? 10;
    final coinsEarned = (weightKg * multiplier).floor();

    // Update request
    await _supabase
        .from('scrap_requests')
        .update({'status': 'completed', 'coins_awarded': coinsEarned})
        .eq('id', requestId);

    // Update user coins
    final profile = await _supabase
        .from('profiles')
        .select('scrap_coins')
        .eq('id', userId)
        .single();
    final newBalance = (profile['scrap_coins'] as int) + coinsEarned;

    await _supabase
        .from('profiles')
        .update({'scrap_coins': newBalance})
        .eq('id', userId);

    // Record transaction
    await _supabase.from('transactions').insert({
      'user_id': userId,
      'amount': coinsEarned,
      'type': 'donation_reward',
      'reference_id': requestId,
      'description':
          'Earned $coinsEarned coins for donating ${weightKg}kg of $scrapType',
    });

    // Update dealer inventory
    final existing = await _supabase
        .from('dealer_inventory')
        .select('*')
        .eq('dealer_id', partnerId)
        .eq('scrap_type', scrapType);

    if ((existing as List).isNotEmpty) {
      final newQty =
          double.parse(existing[0]['quantity_kg'].toString()) + weightKg;
      await _supabase
          .from('dealer_inventory')
          .update({'quantity_kg': newQty})
          .eq('id', existing[0]['id']);
    } else {
      await _supabase.from('dealer_inventory').insert({
        'dealer_id': partnerId,
        'scrap_type': scrapType,
        'quantity_kg': weightKg,
      });
    }

    return {'coins_earned': coinsEarned, 'new_balance': newBalance};
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
}
