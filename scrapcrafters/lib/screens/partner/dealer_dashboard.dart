import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';
import '../../providers/industry_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../common/profile_screen.dart';

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({super.key});

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DealerHome(),
      const _PickupRequests(),
      const _IndustryRequirements(),
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
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Pickups',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Industry',
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

class _DealerHome extends StatefulWidget {
  const _DealerHome();

  @override
  State<_DealerHome> createState() => _DealerHomeState();
}

class _DealerHomeState extends State<_DealerHome> {
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _acceptedRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      final inv = await context.read<ScrapProvider>().fetchDealerInventory(
        auth.userId!,
      );
      final accepted = await context
          .read<ScrapProvider>()
          .fetchAcceptedRequests(auth.userId!);
      if (mounted) {
        setState(() {
          _inventory = inv;
          _acceptedRequests = accepted;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
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
            // Welcome
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF37474F), Color(0xFF546E7A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${profile?['name'] ?? 'Dealer'}! 🚛',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your scrap collections',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Active Pickups',
                        value: '${_acceptedRequests.length}',
                        icon: Icons.local_shipping,
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        label: 'Scrap Types',
                        value: '${_inventory.length}',
                        icon: Icons.inventory_2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Inventory
            Text(
              'My Inventory',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_inventory.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No inventory yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Text('Accept pickup requests to build inventory'),
                    ],
                  ),
                ),
              )
            else
              ..._inventory.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.blueGrey,
                      ),
                    ),
                    title: Text(item['scrap_type'].toString().toUpperCase()),
                    trailing: Text(
                      '${item['quantity_kg']} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Active pickups
            Text(
              'Active Pickups',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_acceptedRequests.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No active pickups',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._acceptedRequests.map(
                (req) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.recycling)),
                    title: Text(
                      '${req['scrap_type'].toString().toUpperCase()} - ${req['weight_kg']}kg',
                    ),
                    subtitle: Text(req['profiles']?['name'] ?? 'User'),
                    trailing: ElevatedButton(
                      onPressed: () => _completePickup(req),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _completePickup(Map<String, dynamic> req) async {
    try {
      final result = await context.read<ScrapProvider>().completeRequest(
        req['id'],
        context.read<AuthProvider>().userId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pickup completed! User earned ${result['coins_earned']} coins',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
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
  @override
  void initState() {
    super.initState();
    context.read<ScrapProvider>().fetchAvailableRequests();
  }

  @override
  Widget build(BuildContext context) {
    final scrap = context.watch<ScrapProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Requests')),
      body: RefreshIndicator(
        onRefresh: () => scrap.fetchAvailableRequests(),
        child: scrap.isLoading
            ? const Center(child: CircularProgressIndicator())
            : scrap.availableRequests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No pending requests',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: scrap.availableRequests.length,
                itemBuilder: (context, i) {
                  final req = scrap.availableRequests[i];
                  final user = req['profiles'] as Map<String, dynamic>?;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade50,
                                child: const Icon(
                                  Icons.recycling,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${req['scrap_type'].toString().toUpperCase()} - ${req['weight_kg']}kg',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'From: ${user?['name'] ?? 'Unknown'} • ${user?['location'] ?? ''}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (req['description'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              req['description'],
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                          if (req['pickup_address'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  req['pickup_address'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _accept(req['id']),
                              icon: const Icon(Icons.check),
                              label: const Text('Accept Pickup'),
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

  Future<void> _accept(String requestId) async {
    try {
      await context.read<ScrapProvider>().acceptRequest(
        requestId,
        context.read<AuthProvider>().userId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _IndustryRequirements extends StatefulWidget {
  const _IndustryRequirements();

  @override
  State<_IndustryRequirements> createState() => _IndustryRequirementsState();
}

class _IndustryRequirementsState extends State<_IndustryRequirements> {
  List<Map<String, dynamic>> _requirements = [];
  List<Map<String, dynamic>> _inventory = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final reqs = await context.read<IndustryProvider>().fetchOpenRequirements();
    final inv = await context.read<ScrapProvider>().fetchDealerInventory(
      auth.userId!,
    );
    if (mounted) {
      setState(() {
        _requirements = reqs;
        _inventory = inv;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Industry Requirements')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _requirements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.factory,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No open requirements',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requirements.length,
                      itemBuilder: (context, i) {
                        final req = _requirements[i];
                        final industry =
                            req['profiles'] as Map<String, dynamic>?;
                        final required = double.parse(
                          req['required_kg'].toString(),
                        );
                        final fulfilled = double.parse(
                          req['fulfilled_kg'].toString(),
                        );
                        final remaining = required - fulfilled;
                        final progress = fulfilled / required;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.factory,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        industry?['organization_name'] ??
                                            industry?['name'] ??
                                            'Industry',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        req['status'].toString().toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: req['status'] == 'open'
                                          ? Colors.green
                                          : Colors.orange,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Need: ${req['scrap_type'].toString().toUpperCase()} — ${remaining.toStringAsFixed(1)}kg remaining',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.green,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${fulfilled.toStringAsFixed(1)} / ${required.toStringAsFixed(1)} kg fulfilled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (req['price_per_kg'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${req['price_per_kg']}/kg',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showFulfillDialog(req),
                                    icon: const Icon(Icons.send),
                                    label: const Text('Fulfill'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                    ),
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

  void _showFulfillDialog(Map<String, dynamic> req) {
    final qtyController = TextEditingController();
    final scrapType = req['scrap_type'] as String;
    final invItem = _inventory
        .where((i) => i['scrap_type'] == scrapType)
        .toList();
    final availableKg = invItem.isNotEmpty
        ? double.parse(invItem[0]['quantity_kg'].toString())
        : 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fulfill Requirement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your $scrapType inventory: ${availableKg.toStringAsFixed(1)}kg',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Quantity (kg)',
                suffixText: 'kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(qtyController.text);
              if (qty == null || qty <= 0) return;
              Navigator.pop(context);
              try {
                await context.read<IndustryProvider>().fulfillRequirement(
                  requirementId: req['id'],
                  dealerId: context.read<AuthProvider>().userId!,
                  quantityKg: qty,
                );
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fulfillment submitted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
