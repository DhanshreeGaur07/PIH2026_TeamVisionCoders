import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() { super.initState(); context.read<ProductProvider>().fetchProducts(); }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final w = MediaQuery.of(context).size.width;
    final cols = w > 900 ? 4 : w > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: products.isLoading
        ? const Center(child: ShimmerGrid(itemCount: 6, crossAxisCount: 2))
        : products.products.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.store, size: 56, color: AppTheme.borderLight), const SizedBox(height: 12),
              const Text('No products available', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
              const Text('Artists haven\'t listed products yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]))
          : RefreshIndicator(color: AppTheme.primary,
              onRefresh: () => products.fetchProducts(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: products.products.length,
                itemBuilder: (context, i) => _ProductCard(product: products.products[i]).animate().fadeIn(delay: Duration(milliseconds: i * 50)),
              )),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final stock = product['stock_quantity'] ?? 0;
    final typeColor = _getTypeColor(product['scrap_type_used']);

    return GlassCard(onTap: () => _showProductDetail(context), padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: Stack(children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: product['image_url'] != null
              ? Image.network(product['image_url'], width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(typeColor))
              : _placeholder(typeColor)),
          Positioned(top: 8, right: 8, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: stock > 5 ? AppTheme.success : (stock > 0 ? AppTheme.accent : AppTheme.danger), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.border, width: 1.5)),
            child: Text(stock > 0 ? '$stock left' : 'Sold Out', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          )),
        ])),
        Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(product['profiles']?['name'] ?? 'Artist', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const Spacer(),
          Row(children: [
            const Icon(Icons.monetization_on, color: AppTheme.accent, size: 16), const SizedBox(width: 4),
            Text('${product['price_coins']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary)),
            const Text(' /unit', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ]),
        ]))),
      ]),
    );
  }

  Widget _placeholder(Color c) => Container(width: double.infinity, color: c.withValues(alpha: 0.08),
    child: Center(child: Icon(_getTypeIcon(product['scrap_type_used']), size: 40, color: c)));

  Color _getTypeColor(String? type) {
    switch (type) { case 'iron': return Colors.blueGrey; case 'plastic': return const Color(0xFF3B82F6); case 'copper': return AppTheme.accent; case 'glass': return AppTheme.secondary; case 'ewaste': return const Color(0xFF8B5CF6); default: return AppTheme.primary; }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) { case 'iron': return Icons.hardware; case 'plastic': return Icons.water_drop; case 'copper': return Icons.electric_bolt; case 'glass': return Icons.wine_bar; case 'ewaste': return Icons.devices; default: return Icons.palette; }
  }

  void _showProductDetail(BuildContext context) {
    final stock = product['stock_quantity'] ?? 0;
    int selectedQty = 1;

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        final unitPrice = product['price_coins'] ?? 0;
        final totalCost = unitPrice * selectedQty;

        return DraggableScrollableSheet(initialChildSize: 0.65, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
          builder: (context, scrollController) => SingleChildScrollView(controller: scrollController, padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Center(child: product['image_url'] != null
                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(product['image_url'], width: 200, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _detailPlaceholder()))
                : _detailPlaceholder()),
              const SizedBox(height: 20),
              Text(product['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('By ${product['profiles']?['name'] ?? 'Artist'}', style: const TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 12),
              if (product['description'] != null) Text(product['description'], style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Row(children: [
                if (product['scrap_type_used'] != null) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: _getTypeColor(product['scrap_type_used']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: _getTypeColor(product['scrap_type_used']), width: 1.5)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_getTypeIcon(product['scrap_type_used']), size: 16, color: _getTypeColor(product['scrap_type_used'])),
                    const SizedBox(width: 4),
                    Text(product['scrap_type_used'].toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _getTypeColor(product['scrap_type_used']))),
                  ])),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: (stock > 5 ? AppTheme.success : stock > 0 ? AppTheme.accent : AppTheme.danger).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: stock > 5 ? AppTheme.success : stock > 0 ? AppTheme.accent : AppTheme.danger, width: 1.5)),
                  child: Text('$stock in stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: stock > 5 ? AppTheme.success : stock > 0 ? AppTheme.accent : AppTheme.danger)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [const Icon(Icons.monetization_on, color: AppTheme.accent, size: 26), const SizedBox(width: 8),
                Text('$unitPrice coins/unit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))]),
              const SizedBox(height: 16),

              if (stock > 0) ...[
                GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                  const Text('Select Quantity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(onPressed: selectedQty > 1 ? () => setSheetState(() => selectedQty--) : null, icon: const Icon(Icons.remove_circle_outline), iconSize: 32, color: AppTheme.textSecondary),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.borderLight, width: 2)),
                      child: Text('$selectedQty', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
                    IconButton(onPressed: selectedQty < stock ? () => setSheetState(() => selectedQty++) : null, icon: const Icon(Icons.add_circle_outline), iconSize: 32, color: AppTheme.textSecondary),
                  ]),
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.accent, width: 1.5)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                      Text('$totalCost coins', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary)),
                    ])),
                ])),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: () => _purchaseProduct(context, selectedQty), icon: const Icon(Icons.shopping_cart, size: 20), label: Text('Buy $selectedQty × ${product['name']}'))),
              ] else Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.danger, width: 1.5)),
                child: const Text('❌ This product is sold out', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700, fontSize: 15))),
            ]),
          ),
        );
      }),
    );
  }

  Widget _detailPlaceholder() => Container(width: 120, height: 120,
    decoration: BoxDecoration(color: _getTypeColor(product['scrap_type_used']).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderLight, width: 2)),
    child: Icon(_getTypeIcon(product['scrap_type_used']), size: 60, color: _getTypeColor(product['scrap_type_used'])));

  void _purchaseProduct(BuildContext context, int quantity) async {
    final auth = context.read<AuthProvider>();
    try {
      final result = await context.read<ProductProvider>().purchaseProduct(productId: product['id'], buyerId: auth.userId!, quantity: quantity, payWithCoins: true);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Product purchased!')));
      await auth.refreshProfile();
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger)); }
  }
}
