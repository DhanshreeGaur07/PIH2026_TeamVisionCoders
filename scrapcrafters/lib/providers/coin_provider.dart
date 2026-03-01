import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class CoinProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _coinsChannel;

  int _balance = 0;
  int _pendingCoins = 0;
  int _acceptedCoins = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  int get balance => _balance + _acceptedCoins;
  int get pendingCoins => _pendingCoins;
  int get earnedBalance => _balance;
  int get acceptedCoins => _acceptedCoins;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchBalance(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('scrap_coins')
          .eq('id', userId)
          .single();
      _balance = data['scrap_coins'] ?? 0;
      notifyListeners();

      _setupRealtime(userId);
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  void _setupRealtime(String userId) {
    _coinsChannel?.unsubscribe();

    _coinsChannel =
        _supabase
            .channel('public:coins_$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'profiles',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: userId,
              ),
              callback: (payload) {
                fetchBalance(userId);
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'transactions',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (payload) {
                fetchTransactions(userId);
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'scrap_requests',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (payload) {
                fetchPendingCoins(userId);
              },
            )
          ..subscribe();
  }

  Future<void> fetchPendingCoins(String userId) async {
    try {
      final data = await _supabase
          .from('scrap_requests')
          .select('scrap_type, weight_kg, status')
          .eq('user_id', userId)
          .inFilter('status', const ['pending', 'accepted']);

      int totalPending = 0;
      int totalAccepted = 0;

      const multipliers = {
        'iron': 30,
        'plastic': 20,
        'copper': 40,
        'glass': 20,
        'ewaste': 50,
        'other': 10,
      };

      for (var req in data) {
        final type = req['scrap_type'] as String;
        final weight = (req['weight_kg'] as num).toDouble();
        final status = req['status'] as String;
        final multiplier = multipliers[type] ?? 10;
        final coins = (weight * multiplier).floor();

        if (status == 'accepted') {
          totalAccepted += coins;
        } else {
          totalPending += coins;
        }
      }

      debugPrint(
        'Coins for $userId: accepted=$totalAccepted, pending=$totalPending from ${data.length} requests',
      );

      _acceptedCoins = totalAccepted;
      _pendingCoins = totalPending;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching pending coins: $e');
    }
  }

  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      _transactions = List<Map<String, dynamic>>.from(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchaseCoins(
    String userId,
    double amountInr,
    int coinsToBuy,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post(
        '/coins/purchase',
        body: {
          'user_id': userId,
          'amount_inr': amountInr,
          'coins_purchased': coinsToBuy,
        },
      );
      await fetchBalance(userId);
      await fetchTransactions(userId);
    } catch (e) {
      debugPrint('Error purchasing coins: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _coinsChannel?.unsubscribe();
    super.dispose();
  }
}
