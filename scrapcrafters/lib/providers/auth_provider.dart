import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userId;
  String? _userRole;
  Map<String, dynamic>? _profile;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userRole => _userRole;
  Map<String, dynamic>? get profile => _profile;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _userId = session.user.id;
      _isLoggedIn = true;
      await _fetchProfile();
    }
    _isLoading = false;
    notifyListeners();

    // Listen for auth changes
    _supabase.auth.onAuthStateChange.listen((event) async {
      if (event.session != null) {
        _userId = event.session!.user.id;
        _isLoggedIn = true;
        await _fetchProfile();
      } else {
        _userId = null;
        _isLoggedIn = false;
        _userRole = null;
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchProfile() async {
    if (_userId == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', _userId!)
          .single();
      _profile = data;
      _userRole = data['role'];
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? location,
    String? organizationName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) throw Exception('Signup failed');

      final uid = authResponse.user!.id;

      final profileData = {
        'id': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'role': role,
        'scrap_coins': 0,
      };

      if (organizationName != null && organizationName.isNotEmpty) {
        profileData['organization_name'] = organizationName;
      }

      await _supabase.from('profiles').insert(profileData);

      _userId = uid;
      _isLoggedIn = true;
      _userRole = role;
      _profile = profileData;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) throw Exception('Login failed');

      _userId = response.user!.id;
      _isLoggedIn = true;
      await _fetchProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _userId = null;
    _isLoggedIn = false;
    _userRole = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _fetchProfile();
    notifyListeners();
  }
}
