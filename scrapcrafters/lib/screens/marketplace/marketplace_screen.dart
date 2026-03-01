import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
        ? 3
        : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: products.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No products available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Artists haven\'t listed products yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => products.fetchProducts(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.products.length,
                itemBuilder: (context, i) {
                  final product = products.products[i];
                  return _ProductCard(product: product);
                },
              ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: _getTypeColor(
                  product['scrap_type_used'],
                ).withOpacity(0.15),
                child: Center(
                  child: Icon(
                    _getTypeIcon(product['scrap_type_used']),
                    size: 48,
                    color: _getTypeColor(product['scrap_type_used']),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product['profiles']?['name'] ?? 'Artist',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product['price_coins']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'iron':
        return Colors.grey;
      case 'plastic':
        return Colors.blue;
      case 'copper':
        return Colors.orange;
      case 'glass':
        return Colors.teal;
      case 'ewaste':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'iron':
        return Icons.hardware;
      case 'plastic':
        return Icons.water_drop;
      case 'copper':
        return Icons.electric_bolt;
      case 'glass':
        return Icons.wine_bar;
      case 'ewaste':
        return Icons.devices;
      default:
        return Icons.palette;
    }
  }

  void _showProductDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Product icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getTypeColor(
                        product['scrap_type_used'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getTypeIcon(product['scrap_type_used']),
                      size: 60,
                      color: _getTypeColor(product['scrap_type_used']),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  product['name'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${product['profiles']?['name'] ?? 'Artist'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                if (product['description'] != null)
                  Text(
                    product['description'],
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                const SizedBox(height: 16),

                if (product['scrap_type_used'] != null)
                  Chip(
                    avatar: Icon(
                      _getTypeIcon(product['scrap_type_used']),
                      size: 18,
                      color: _getTypeColor(product['scrap_type_used']),
                    ),
                    label: Text(
                      'Made from ${product['scrap_type_used'].toString().toUpperCase()}',
                    ),
                  ),
                const SizedBox(height: 24),

                // Price and buy
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product['price_coins']} Scrap Coins',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _purchaseProduct(context),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy with Scrap Coins'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _purchaseProduct(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    try {
      await context.read<ProductProvider>().purchaseProduct(
        productId: product['id'],
        buyerId: auth.userId!,
        payWithCoins: true,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product purchased!'),
          backgroundColor: Colors.green,
        ),
      );
      await auth.refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
