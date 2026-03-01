import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';
import '../../providers/product_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../common/profile_screen.dart';

class ArtistDashboard extends StatefulWidget {
  const ArtistDashboard({super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _ArtistHome(),
      const _PickupRequests(),
      const _MyProducts(),
      const MarketplaceScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.recycling_outlined),
            selectedIcon: Icon(Icons.recycling),
            label: 'Pickups',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}

class _ArtistHome extends StatefulWidget {
  const _ArtistHome();

  @override
  State<_ArtistHome> createState() => _ArtistHomeState();
}

class _ArtistHomeState extends State<_ArtistHome> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myProducts = [];
  List<Map<String, dynamic>> _contracts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      final prods = await context.read<ProductProvider>().fetchArtistProducts(
        auth.userId!,
      );
      final contracts = await _supabase
          .from('artist_contracts')
          .select('*, user:profiles!artist_contracts_user_id_fkey(name)')
          .eq('artist_id', auth.userId!)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myProducts = prods;
          _contracts = List<Map<String, dynamic>>.from(contracts);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Studio'),
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${auth.profile?['name'] ?? 'Artist'}! 🎨',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create beauty from scrap',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Stat(label: 'Products', value: '${_myProducts.length}'),
                      const SizedBox(width: 12),
                      _Stat(label: 'Contracts', value: '${_contracts.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'My Contracts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_contracts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No contracts yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._contracts.map(
                (c) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(
                        c['status'],
                      ).withOpacity(0.1),
                      child: Icon(
                        Icons.description,
                        color: _getStatusColor(c['status']),
                      ),
                    ),
                    title: Text(
                      c['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'From: ${c['user']?['name'] ?? 'User'} • ${c['status']}',
                    ),
                    trailing: c['status'] == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _updateContract(c['id'], 'accepted'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _updateContract(c['id'], 'rejected'),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateContract(String contractId, String status) async {
    try {
      await _supabase
          .from('artist_contracts')
          .update({'status': status})
          .eq('id', contractId);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupRequests extends StatefulWidget {
  const _PickupRequests();
  @override
  State<_PickupRequests> createState() => _PickupRequestsState();
}

class _PickupRequestsState extends State<_PickupRequests> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Fetch requests passing the current user (partner) ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScrapProvider>().fetchAvailableRequests(
          context.read<AuthProvider>().userId!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scrap = context.watch<ScrapProvider>();

    final filteredRequests = _selectedFilter == 'all'
        ? scrap.availableRequests
        : scrap.availableRequests
              .where((r) => r['scrap_type'] == _selectedFilter)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrap Pickups'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children:
                  [
                    'all',
                    'iron',
                    'plastic',
                    'copper',
                    'glass',
                    'ewaste',
                    'other',
                  ].map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(type.toUpperCase()),
                        selected: _selectedFilter == type,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = type);
                        },
                        selectedColor: const Color(0xFF6A1B9A).withOpacity(0.2),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: scrap.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No pending requests for this filter',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => scrap.fetchAvailableRequests(
                      context.read<AuthProvider>().userId!,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, i) {
                        final req = filteredRequests[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.recycling),
                            ),
                            title: Text(
                              '${req['scrap_type'].toString().toUpperCase()} - ${req['weight_kg']}kg',
                            ),
                            subtitle: Text(req['profiles']?['name'] ?? 'User'),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await scrap.acceptRequest(
                                  req['id'],
                                  context.read<AuthProvider>().userId!,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request accepted!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyProducts extends StatefulWidget {
  const _MyProducts();
  @override
  State<_MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<_MyProducts> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      final prods = await context.read<ProductProvider>().fetchArtistProducts(
        auth.userId!,
      );
      if (mounted)
        setState(() {
          _products = prods;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.palette, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No products yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Text('Create your first upcycled product!'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.purple,
                        ),
                      ),
                      title: Text(p['name']),
                      subtitle: Text(p['description'] ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${p['price_coins']} 🪙',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p['is_available'] ? 'Available' : 'Sold',
                            style: TextStyle(
                              fontSize: 11,
                              color: p['is_available']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String scrapType = 'iron';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (Scrap Coins)',
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setDialogState) =>
                    DropdownButtonFormField<String>(
                      value: scrapType,
                      decoration: const InputDecoration(
                        labelText: 'Scrap Type Used',
                      ),
                      items:
                          [
                                'iron',
                                'plastic',
                                'copper',
                                'glass',
                                'ewaste',
                                'other',
                              ]
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.toUpperCase()),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setDialogState(() => scrapType = v!),
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await context.read<ProductProvider>().createProduct(
                  artistId: context.read<AuthProvider>().userId!,
                  name: nameCtrl.text,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  priceCoins: int.parse(priceCtrl.text),
                  scrapTypeUsed: scrapType,
                );
                _loadProducts();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
