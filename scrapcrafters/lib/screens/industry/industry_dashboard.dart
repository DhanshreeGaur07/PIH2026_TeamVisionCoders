import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/industry_provider.dart';
import '../../providers/coin_provider.dart';
import '../common/profile_screen.dart';
import '../user/wallet_screen.dart';

class IndustryDashboard extends StatefulWidget {
  const IndustryDashboard({super.key});
  @override
  State<IndustryDashboard> createState() => _IndustryDashboardState();
}

class _IndustryDashboardState extends State<IndustryDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      context.read<IndustryProvider>().fetchRequirements(
        industryId: auth.userId,
      );
      context.read<CoinProvider>().fetchBalance(auth.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final industry = context.watch<IndustryProvider>();
    final coins = context.watch<CoinProvider>();
    final profile = auth.profile;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Dashboard'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRequirement,
        icon: const Icon(Icons.add),
        label: const Text('Add Requirement'),
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _loadData(),
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
                    '${profile?['organization_name'] ?? profile?['name'] ?? 'Industry'} 🏭',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your scrap requirements',
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
                          icon: Icons.list_alt,
                          value: '${industry.requirements.length}',
                          label: 'Total',
                          iconColor: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.pending,
                          value:
                              '${industry.requirements.where((r) => r['status'] != 'closed').length}',
                          label: 'Open',
                          iconColor: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassStatCard(
                          icon: Icons.check_circle,
                          value:
                              '${industry.requirements.where((r) => r['status'] == 'closed').length}',
                          label: 'Closed',
                          iconColor: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),

            // Coin Balance
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.monetization_on,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scrap Coins Balance',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${coins.balance}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showBuyCoinsDialog(context),
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Buy'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // Requirements
            const Text(
              'My Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (industry.isLoading)
              const ShimmerList(itemCount: 3, itemHeight: 120)
            else if (industry.requirements.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: const Column(
                  children: [
                    Icon(Icons.factory, size: 48, color: AppTheme.borderLight),
                    SizedBox(height: 12),
                    Text(
                      'No requirements posted',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    Text(
                      'Tap + to post your first requirement',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...industry.requirements.map((req) {
                final required = double.parse(req['required_kg'].toString());
                final fulfilled = double.parse(req['fulfilled_kg'].toString());
                final progress = required > 0 ? fulfilled / required : 0.0;
                final isClosed = req['status'] == 'closed';
                final statusColor = isClosed
                    ? AppTheme.success
                    : AppTheme.primary;

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
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.recycling,
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${req['scrap_type'].toString().toUpperCase()} — ${required.toStringAsFixed(1)}kg',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isClosed
                                      ? AppTheme.textMuted
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                req['status']
                                    .toString()
                                    .toUpperCase()
                                    .replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (req['description'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            req['description'],
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: AppTheme.surfaceLight,
                            color: statusColor,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${fulfilled.toStringAsFixed(1)} / ${required.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ],
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
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddRequirement() {
    String scrapType = 'iron';
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final qty = double.tryParse(qtyCtrl.text) ?? 0;
          final price = double.tryParse(priceCtrl.text) ?? 0;
          final totalCost = (qty * price).toInt();
          final currentCoins = context.read<CoinProvider>().balance;
          final hasEnough = totalCost == 0 || currentCoins >= totalCost;

          return AlertDialog(
            title: const Text('Post Scrap Requirement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: scrapType,
                    decoration: const InputDecoration(labelText: 'Scrap Type'),
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Required Quantity (kg)',
                      suffixText: 'kg',
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price per kg (coins)',
                      prefixText: '💰 ',
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  if (totalCost > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (hasEnough ? AppTheme.primary : AppTheme.danger)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              (hasEnough ? AppTheme.primary : AppTheme.danger)
                                  .withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total cost:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '$totalCost coins',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: hasEnough
                                      ? AppTheme.primary
                                      : AppTheme.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your balance:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                '$currentCoins coins',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (!hasEnough) ...[
                            const SizedBox(height: 8),
                            Text(
                              '⚠️ Need ${totalCost - currentCoins} more coins.',
                              style: const TextStyle(
                                color: AppTheme.danger,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (!hasEnough && totalCost > 0)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showBuyCoinsDialog(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Buy Coins'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ElevatedButton(
                onPressed: (qty <= 0 || (!hasEnough && totalCost > 0))
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        try {
                          await context
                              .read<IndustryProvider>()
                              .createRequirement(
                                industryId: context
                                    .read<AuthProvider>()
                                    .userId!,
                                scrapType: scrapType,
                                requiredKg: qty,
                                pricePerKg: price > 0 ? price : null,
                                description: descCtrl.text.isEmpty
                                    ? null
                                    : descCtrl.text,
                              );
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Requirement posted!'),
                              ),
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
                child: const Text('Post'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBuyCoinsDialog(BuildContext context) {
    final amountCtrl = TextEditingController(text: '1000');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final inr = double.tryParse(amountCtrl.text) ?? 0;
          final dialogCoins = (inr * 10).toInt();
          return AlertDialog(
            title: const Text('Buy Scrap Coins'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '1 Scrap Coin = ₹0.10 (₹1 = 10 Coins)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount in INR (₹)',
                    prefixText: '₹ ',
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You will get:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$dialogCoins Coins',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: dialogCoins > 0
                    ? () {
                        Navigator.pop(ctx);
                        _processPayment(inr, dialogCoins);
                      }
                    : null,
                child: const Text('Pay with Razorpay'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processPayment(double inr, int payCoins) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCube(color: AppTheme.primary, size: 36),
            SizedBox(height: 16),
            Text(
              'Processing payment securely...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
      final auth = context.read<AuthProvider>();
      if (auth.userId != null) {
        try {
          await context.read<CoinProvider>().purchaseCoins(
            auth.userId!,
            inr,
            payCoins,
          );
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment successful! $payCoins coins added.'),
              ),
            );
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: $e'),
                backgroundColor: AppTheme.danger,
              ),
            );
        }
      }
    }
  }
}
