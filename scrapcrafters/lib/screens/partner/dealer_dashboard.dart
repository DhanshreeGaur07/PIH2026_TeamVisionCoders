import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';
import '../../providers/industry_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../common/profile_screen.dart';
import '../user/wallet_screen.dart';

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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border, width: 2)),
        ),
        child: NavigationBar(
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
      ),
    );
  }
}

// ─── DEALER HOME ───────────────────────────────
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
      if (mounted)
        setState(() {
          _inventory = inv;
          _acceptedRequests = accepted;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Wallet',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
          ),
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
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // Welcome
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${profile?['name'] ?? 'Dealer'}! 🚛',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your scrap collections',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.local_shipping,
                          value: '${_acceptedRequests.length}',
                          label: 'Active Pickups',
                          iconColor: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.inventory_2,
                          value: '${_inventory.length}',
                          label: 'Scrap Types',
                          iconColor: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // Inventory
            const Text(
              'My Inventory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const ShimmerList(itemCount: 3, itemHeight: 60)
            else if (_inventory.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 40,
                      color: AppTheme.borderLight,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No inventory yet',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    Text(
                      'Accept pickups to build inventory',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ..._inventory.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blueGrey.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Colors.blueGrey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item['scrap_type'].toString().toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${item['quantity_kg']} kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Active Pickups
            const Text(
              'Active Pickups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_acceptedRequests.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: const Text(
                  'No active pickups',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            else
              ..._acceptedRequests.map(
                (req) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: req['image_url'] != null
                              ? Image.network(
                                  req['image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _scrapAvatar(),
                                )
                              : _scrapAvatar(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${req['scrap_type'].toString().toUpperCase()} — ${req['weight_kg']}kg',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                req['profiles']?['name'] ?? 'User',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _completePickup(req),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text(
                            'Complete',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _scrapAvatar() => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: AppTheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppTheme.primary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: const Icon(Icons.recycling, color: AppTheme.primary, size: 24),
  );

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
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
    }
  }
}

// ─── PICKUP REQUESTS ───────────────────────────
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        context.read<ScrapProvider>().fetchAvailableRequests(
          context.read<AuthProvider>().userId!,
        );
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
      appBar: AppBar(title: const Text('Pickup Requests')),
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
                    final selected = _selectedFilter == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.borderLight,
                              width: 2,
                            ),
                            boxShadow: selected
                                ? [
                                    const BoxShadow(
                                      color: AppTheme.shadow,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => scrap.fetchAvailableRequests(
                context.read<AuthProvider>().userId!,
              ),
              child: scrap.isLoading
                  ? const Center(
                      child: SpinKitFadingCube(
                        color: AppTheme.primary,
                        size: 36,
                      ),
                    )
                  : filteredRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox,
                            size: 56,
                            color: AppTheme.borderLight,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No pending requests',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, i) {
                        final req = filteredRequests[i];
                        final user = req['profiles'] as Map<String, dynamic>?;
                        final coinCost =
                            ((req['weight_kg'] as num) *
                                    (ScrapProvider
                                            .coinMultipliers[req['scrap_type']] ??
                                        10))
                                .floor();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: req['image_url'] != null
                                          ? Image.network(
                                              req['image_url'],
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _scrapIcon(),
                                            )
                                          : _scrapIcon(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${req['scrap_type'].toString().toUpperCase()} — ${req['weight_kg']}kg',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'From: ${user?['name'] ?? 'Unknown'} • ${user?['location'] ?? ''}',
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accent.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: AppTheme.accent,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              'Cost: $coinCost Coins',
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
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
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                if (req['pickup_address'] != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          req['pickup_address'],
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                    icon: const Icon(Icons.check, size: 18),
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
          ),
        ],
      ),
    );
  }

  Widget _scrapIcon() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppTheme.primary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: const Icon(Icons.recycling, color: AppTheme.primary),
  );

  Future<void> _accept(String requestId) async {
    try {
      await context.read<ScrapProvider>().acceptRequest(
        requestId,
        context.read<AuthProvider>().userId!,
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pickup accepted!')));
    } catch (e) {
      if (mounted) {
        final errMsg = e.toString().replaceAll('Exception: ', '');
        if (errMsg.toLowerCase().contains('insufficient')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber, color: AppTheme.accent, size: 28),
                  SizedBox(width: 8),
                  Text('Insufficient Balance'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errMsg, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  const Text(
                    'Buy more Scrap Coins from your Wallet.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet, size: 18),
                  label: const Text('Buy Coins'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errMsg'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }
}

// ─── INDUSTRY REQUIREMENTS ─────────────────────
class _IndustryRequirements extends StatefulWidget {
  const _IndustryRequirements();
  @override
  State<_IndustryRequirements> createState() => _IndustryRequirementsState();
}

class _IndustryRequirementsState extends State<_IndustryRequirements> {
  List<Map<String, dynamic>> _requirements = [];
  List<Map<String, dynamic>> _inventory = [];
  bool _loading = true;
  RealtimeChannel? _reqChannel;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealtime();
  }

  @override
  void dispose() {
    _reqChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    final supabase = Supabase.instance.client;
    _reqChannel = supabase
        .channel('industry_requirements_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'industry_requirements',
          callback: (payload) => _loadData(),
        )
        .subscribe();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final reqs = await context.read<IndustryProvider>().fetchOpenRequirements();
    final inv = await context.read<ScrapProvider>().fetchDealerInventory(
      auth.userId!,
    );
    if (mounted)
      setState(() {
        _requirements = reqs;
        _inventory = inv;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Industry Requirements')),
      body: _loading
          ? const Center(
              child: SpinKitFadingCube(color: AppTheme.primary, size: 36),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadData,
              child: _requirements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.factory,
                            size: 56,
                            color: AppTheme.borderLight,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No open requirements',
                            style: TextStyle(color: AppTheme.textMuted),
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
                        final isClosed = remaining <= 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.blueGrey.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.factory,
                                        color: Colors.blueGrey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        industry?['organization_name'] ??
                                            industry?['name'] ??
                                            'Industry',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isClosed
                                                    ? AppTheme.success
                                                    : AppTheme.primary)
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isClosed
                                              ? AppTheme.success
                                              : AppTheme.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        isClosed
                                            ? 'FULFILLED'
                                            : req['status']
                                                  .toString()
                                                  .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isClosed
                                              ? AppTheme.success
                                              : AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Need: ${req['scrap_type'].toString().toUpperCase()} — ${remaining.toStringAsFixed(1)}kg remaining',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    backgroundColor: AppTheme.surfaceLight,
                                    color: isClosed
                                        ? AppTheme.success
                                        : AppTheme.primary,
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${fulfilled.toStringAsFixed(1)} / ${required.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                if (req['price_per_kg'] != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: AppTheme.accent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${req['price_per_kg']} coins/kg',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: isClosed
                                        ? null
                                        : () => _showFulfillDialog(req),
                                    icon: Icon(
                                      isClosed
                                          ? Icons.check_circle
                                          : Icons.send,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isClosed
                                          ? 'Fully Supplied'
                                          : 'Supply Scrap',
                                    ),
                                    style: isClosed
                                        ? ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.surfaceLight,
                                            foregroundColor: AppTheme.textMuted,
                                          )
                                        : null,
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
              style: const TextStyle(color: AppTheme.textSecondary),
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
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fulfillment submitted!')),
                  );
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
