import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoinProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  int _balance = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  int get balance => _balance;
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
    } catch (e) {
      debugPrint('Error fetching balance: $e');
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
}
