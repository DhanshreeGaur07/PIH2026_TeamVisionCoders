import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class IndustryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _requirements = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get requirements => _requirements;
  bool get isLoading => _isLoading;

  Future<void> fetchRequirements({String? industryId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase
          .from('industry_requirements')
          .select(
            '*, profiles!industry_requirements_industry_id_fkey(name, organization_name, location)',
          );

      if (industryId != null) {
        query = query.eq('industry_id', industryId);
      }

      final data = await query.order('created_at', ascending: false);
      _requirements = List<Map<String, dynamic>>.from(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequirement({
    required String industryId,
    required String scrapType,
    required double requiredKg,
    double? pricePerKg,
    String? description,
  }) async {
    await _supabase.from('industry_requirements').insert({
      'industry_id': industryId,
      'scrap_type': scrapType,
      'required_kg': requiredKg,
      'fulfilled_kg': 0,
      'price_per_kg': pricePerKg,
      'description': description,
      'status': 'open',
    });
    await fetchRequirements(industryId: industryId);
  }

  Future<void> fulfillRequirement({
    required String requirementId,
    required String dealerId,
    required double quantityKg,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post(
        '/industry/requirements/$requirementId/fulfill',
        body: {'dealer_id': dealerId, 'quantity_kg': quantityKg},
      );
      await fetchOpenRequirements(); // Refresh the list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchOpenRequirements() async {
    final data = await _supabase
        .from('industry_requirements')
        .select(
          '*, profiles!industry_requirements_industry_id_fkey(name, organization_name, location)',
        )
        .neq('status', 'closed')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
