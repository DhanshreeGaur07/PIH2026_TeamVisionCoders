import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';
import '../../providers/coin_provider.dart';
import '../user/donate_scrap_screen.dart';
import '../user/wallet_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../common/profile_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.userId != null) {
        context.read<ScrapProvider>().fetchMyRequests(auth.userId!);
        context.read<CoinProvider>().fetchBalance(auth.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(),
      const DonateScrapScreen(),
      const MarketplaceScreen(),
      const WalletScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Donate',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final coins = context.watch<CoinProvider>();
    final scrap = context.watch<ScrapProvider>();
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrapCrafters'),
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
        onRefresh: () async {
          if (auth.userId != null) {
            await context.read<ScrapProvider>().fetchMyRequests(auth.userId!);
            await context.read<CoinProvider>().fetchBalance(auth.userId!);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${profile?['name'] ?? 'User'}! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Turn your scrap into value',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${coins.balance} Scrap Coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats cards
            Text(
              'Quick Stats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.recycling,
                    label: 'Donations',
                    value: '${scrap.myRequests.length}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value:
                        '${scrap.myRequests.where((r) => r['status'] == 'completed').length}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending,
                    label: 'Pending',
                    value:
                        '${scrap.myRequests.where((r) => r['status'] == 'pending').length}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Coin rates
            Text(
              'Scrap Coin Rates',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _CoinRateTile('Iron', 30, Icons.hardware, Colors.grey),
                  _CoinRateTile('Plastic', 20, Icons.water_drop, Colors.blue),
                  _CoinRateTile(
                    'Copper',
                    40,
                    Icons.electric_bolt,
                    Colors.orange,
                  ),
                  _CoinRateTile('Glass', 20, Icons.wine_bar, Colors.teal),
                  _CoinRateTile('E-waste', 50, Icons.devices, Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent donations
            Text(
              'Recent Donations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (scrap.myRequests.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.recycling, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No donations yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text('Start donating scrap to earn coins!'),
                    ],
                  ),
                ),
              )
            else
              ...scrap.myRequests
                  .take(5)
                  .map(
                    (req) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getScrapColor(
                            req['scrap_type'],
                          ).withOpacity(0.1),
                          child: Icon(
                            _getScrapIcon(req['scrap_type']),
                            color: _getScrapColor(req['scrap_type']),
                          ),
                        ),
                        title: Text(
                          '${req['scrap_type'].toString().toUpperCase()} - ${req['weight_kg']}kg',
                        ),
                        subtitle: Text('Status: ${req['status']}'),
                        trailing:
                            req['coins_awarded'] != null &&
                                req['coins_awarded'] > 0
                            ? Chip(
                                label: Text(
                                  '+${req['coins_awarded']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.amber[700],
                                padding: EdgeInsets.zero,
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

  Color _getScrapColor(String type) {
    switch (type) {
      case 'iron':
        return Colors.grey[700]!;
      case 'plastic':
        return Colors.blue;
      case 'copper':
        return Colors.orange;
      case 'glass':
        return Colors.teal;
      case 'ewaste':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getScrapIcon(String type) {
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
        return Icons.category;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinRateTile extends StatelessWidget {
  final String type;
  final int rate;
  final IconData icon;
  final Color color;

  const _CoinRateTile(this.type, this.rate, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(
            '$rate / kg',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
