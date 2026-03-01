import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';
import '../../providers/product_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../common/profile_screen.dart';
import '../user/wallet_screen.dart';

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
      ),
    );
  }
}

// ─── ARTIST HOME ───────────────────────────────
class _ArtistHome extends StatefulWidget {
  const _ArtistHome();
  @override
  State<_ArtistHome> createState() => _ArtistHomeState();
}

class _ArtistHomeState extends State<_ArtistHome> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myProducts = [];
  List<Map<String, dynamic>> _contracts = [];
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
      final prods = await context.read<ProductProvider>().fetchArtistProducts(
        auth.userId!,
      );
      final accepted = await context
          .read<ScrapProvider>()
          .fetchAcceptedRequests(auth.userId!);
      final contracts = await _supabase
          .from('artist_contracts')
          .select('*, user:profiles!artist_contracts_user_id_fkey(name)')
          .eq('artist_id', auth.userId!)
          .order('created_at', ascending: false);
      if (mounted)
        setState(() {
          _myProducts = prods;
          _acceptedRequests = accepted;
          _contracts = List<Map<String, dynamic>>.from(contracts);
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Studio'),
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
        color: AppTheme.secondary,
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${auth.profile?['name'] ?? 'Artist'}! 🎨',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create beauty from scrap',
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
                          icon: Icons.palette,
                          value: '${_myProducts.length}',
                          label: 'Products',
                          iconColor: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.local_shipping,
                          value: '${_acceptedRequests.length}',
                          label: 'Pickups',
                          iconColor: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.description,
                          value: '${_contracts.length}',
                          label: 'Contracts',
                          iconColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
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
            if (_loading)
              const ShimmerList(itemCount: 2, itemHeight: 60)
            else if (_acceptedRequests.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'No active pickups. Accept from Pickups tab!',
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
                                  errorBuilder: (_, __, ___) => _avatar(),
                                )
                              : _avatar(),
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

            // Contracts
            const Text(
              'My Contracts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const ShimmerList(itemCount: 2, itemHeight: 60)
            else if (_contracts.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'No contracts yet',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            else
              ..._contracts.map((c) {
                final statusColor = _getStatusColor(c['status']);
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
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Icon(
                            Icons.description,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['description'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'From: ${c['user']?['name'] ?? 'User'} • ${c['status']}',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (c['status'] == 'pending')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: AppTheme.success,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _updateContract(c['id'], 'accepted'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppTheme.danger,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _updateContract(c['id'], 'rejected'),
                              ),
                            ],
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

  Widget _avatar() => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: AppTheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppTheme.secondary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: const Icon(Icons.recycling, color: AppTheme.secondary, size: 24),
  );

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.accent;
      case 'accepted':
        return AppTheme.success;
      case 'in_progress':
        return AppTheme.secondary;
      case 'completed':
        return AppTheme.primary;
      case 'rejected':
        return AppTheme.danger;
      default:
        return AppTheme.textMuted;
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
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
    }
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

// ─── PICKUP REQUESTS (ARTIST) ──────────────────
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
      appBar: AppBar(title: const Text('Scrap Pickups')),
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
                                ? AppTheme.secondary.withValues(alpha: 0.1)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.secondary
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
                                  ? AppTheme.secondary
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
              color: AppTheme.secondary,
              onRefresh: () => scrap.fetchAvailableRequests(
                context.read<AuthProvider>().userId!,
              ),
              child: scrap.isLoading
                  ? const Center(
                      child: SpinKitFadingCube(
                        color: AppTheme.secondary,
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
                            style: TextStyle(color: AppTheme.textMuted),
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
                                                  _icon(),
                                            )
                                          : _icon(),
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
                                            'From: ${user?['name'] ?? 'Unknown'}',
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

  Widget _icon() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppTheme.secondary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: const Icon(Icons.recycling, color: AppTheme.secondary),
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
        ).showSnackBar(const SnackBar(content: Text('Request accepted!')));
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

// ─── MY PRODUCTS ──────────────────────────────
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
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: _loading
          ? const Center(
              child: SpinKitFadingCube(color: AppTheme.secondary, size: 36),
            )
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.palette,
                    size: 56,
                    color: AppTheme.borderLight,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No products yet',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const Text(
                    'Create your first upcycled product!',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppTheme.secondary,
              onRefresh: _loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: p['image_url'] != null
                                ? Image.network(
                                    p['image_url'],
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _prodIcon(),
                                  )
                                : _prodIcon(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                if (p['description'] != null)
                                  Text(
                                    p['description'],
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${p['price_coins']} 🪙',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (p['is_available']
                                              ? AppTheme.success
                                              : AppTheme.danger)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: p['is_available']
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  p['is_available'] ? 'Available' : 'Sold',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: p['is_available']
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _prodIcon() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppTheme.secondary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: const Icon(Icons.shopping_bag, color: AppTheme.secondary),
  );

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '1');
    String scrapType = 'iron';
    Uint8List? selectedImageBytes;
    String? selectedImageExt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      final ext = picked.path.split('.').last;
                      setDialogState(() {
                        selectedImageBytes = bytes;
                        selectedImageExt = ext;
                      });
                    }
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderLight, width: 2),
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 36,
                                color: AppTheme.textMuted,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap to add image',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
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
                  decoration: const InputDecoration(labelText: 'Price (Coins)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Qty',
                    suffixText: 'units',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: scrapType,
                  decoration: const InputDecoration(
                    labelText: 'Scrap Type Used',
                  ),
                  items:
                      ['iron', 'plastic', 'copper', 'glass', 'ewaste', 'other']
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setDialogState(() => scrapType = v!),
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
                    stockQuantity: int.tryParse(stockCtrl.text) ?? 1,
                    scrapTypeUsed: scrapType,
                    imageBytes: selectedImageBytes,
                    imageExt: selectedImageExt,
                  );
                  _loadProducts();
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
