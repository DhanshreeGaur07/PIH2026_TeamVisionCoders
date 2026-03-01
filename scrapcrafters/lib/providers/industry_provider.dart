import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // Get requirement
    final req = await _supabase
        .from('industry_requirements')
        .select('*')
        .eq('id', requirementId)
        .single();

    final remaining =
        double.parse(req['required_kg'].toString()) -
        double.parse(req['fulfilled_kg'].toString());
    final actualQty = quantityKg > remaining ? remaining : quantityKg;

    // Check inventory
    final inventory = await _supabase
        .from('dealer_inventory')
        .select('*')
        .eq('dealer_id', dealerId)
        .eq('scrap_type', req['scrap_type']);

    if ((inventory as List).isEmpty ||
        double.parse(inventory[0]['quantity_kg'].toString()) < actualQty) {
      throw Exception('Insufficient inventory');
    }

    // Create fulfillment
    await _supabase.from('requirement_fulfillments').insert({
      'requirement_id': requirementId,
      'dealer_id': dealerId,
      'quantity_kg': actualQty,
      'status': 'completed',
    });

    // Update inventory
    final newInvQty =
        double.parse(inventory[0]['quantity_kg'].toString()) - actualQty;
    await _supabase
        .from('dealer_inventory')
        .update({'quantity_kg': newInvQty})
        .eq('id', inventory[0]['id']);

    // Update requirement
    final newFulfilled =
        double.parse(req['fulfilled_kg'].toString()) + actualQty;
    final newStatus =
        newFulfilled >= double.parse(req['required_kg'].toString())
        ? 'closed'
        : 'partially_fulfilled';

    await _supabase
        .from('industry_requirements')
        .update({'fulfilled_kg': newFulfilled, 'status': newStatus})
        .eq('id', requirementId);

    notifyListeners();
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
