import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
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
      const _HomeTab(),
      const DonateScrapScreen(),
      const MarketplaceScreen(),
      const WalletScreen(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border, width: 2)),
        ),
        child: NavigationBar(
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
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final coins = context.watch<CoinProvider>();
    final scrap = context.watch<ScrapProvider>();
    final profile = auth.profile;
    final pad = AppTheme.responsivePadding(context);

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
        color: AppTheme.primary,
        onRefresh: () async {
          if (auth.userId != null) {
            await context.read<ScrapProvider>().fetchMyRequests(auth.userId!);
            await context.read<CoinProvider>().fetchBalance(auth.userId!);
          }
        },
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // ── Welcome Card ──
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${profile?['name'] ?? 'User'}! 👋',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Turn your scrap into value',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${coins.balance} Scrap Coins',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // ── Quick Stats ──
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (scrap.isLoading)
              const ShimmerGrid(
                itemCount: 3,
                crossAxisCount: 3,
                childAspectRatio: 0.85,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      icon: Icons.recycling,
                      value: '${scrap.myRequests.length}',
                      label: 'Donations',
                      iconColor: AppTheme.primary,
                    ).animate().fadeIn(delay: 100.ms),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassStatCard(
                      icon: Icons.check_circle,
                      value:
                          '${scrap.myRequests.where((r) => r['status'] == 'completed').length}',
                      label: 'Completed',
                      iconColor: AppTheme.secondary,
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassStatCard(
                      icon: Icons.pending,
                      value:
                          '${scrap.myRequests.where((r) => r['status'] == 'pending').length}',
                      label: 'Pending',
                      iconColor: AppTheme.accent,
                    ).animate().fadeIn(delay: 300.ms),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // ── Coin Rates ──
            const Text(
              'Scrap Coin Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _CoinRateTile('Iron', 30, Icons.hardware, Colors.blueGrey),
                  _CoinRateTile(
                    'Plastic',
                    20,
                    Icons.water_drop,
                    const Color(0xFF3B82F6),
                  ),
                  _CoinRateTile(
                    'Copper',
                    40,
                    Icons.electric_bolt,
                    AppTheme.accent,
                  ),
                  _CoinRateTile(
                    'Glass',
                    20,
                    Icons.wine_bar,
                    AppTheme.secondary,
                  ),
                  _CoinRateTile(
                    'E-waste',
                    50,
                    Icons.devices,
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),

            // ── Recent Donations ──
            const Text(
              'Recent Donations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (scrap.isLoading)
              const ShimmerList(itemCount: 3, itemHeight: 72)
            else if (scrap.myRequests.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.recycling,
                      size: 48,
                      color: AppTheme.borderLight,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No donations yet',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const Text(
                      'Start donating scrap to earn coins!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...scrap.myRequests.take(5).map((req) {
                final color = _getScrapColor(req['scrap_type'] ?? 'other');
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _getScrapIcon(req['scrap_type'] ?? 'other'),
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(req['scrap_type'] ?? 'other').toString().toUpperCase()} — ${req['weight_kg']}kg',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _StatusBadge(status: req['status'] ?? 'pending'),
                            ],
                          ),
                        ),
                        if (req['coins_awarded'] != null &&
                            req['coins_awarded'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.accent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '+${req['coins_awarded']}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Color _getScrapColor(String type) {
    switch (type) {
      case 'iron':
        return Colors.blueGrey;
      case 'plastic':
        return const Color(0xFF3B82F6);
      case 'copper':
        return AppTheme.accent;
      case 'glass':
        return AppTheme.secondary;
      case 'ewaste':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.textMuted;
    }
  }

  static IconData _getScrapIcon(String type) {
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed':
        color = AppTheme.success;
        break;
      case 'accepted':
        color = AppTheme.secondary;
        break;
      case 'pending':
        color = AppTheme.accent;
        break;
      default:
        color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.monetization_on, color: AppTheme.accent, size: 16),
          const SizedBox(width: 4),
          Text(
            '$rate / kg',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
