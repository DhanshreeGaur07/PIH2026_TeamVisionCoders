import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coin_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      context.read<CoinProvider>().fetchBalance(auth.userId!);
      context.read<CoinProvider>().fetchPendingCoins(auth.userId!);
      context.read<CoinProvider>().fetchTransactions(auth.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<CoinProvider>();
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scrap Wallet')),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // ── Balance Card ──
            GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 28,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Total Scrap Coins',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${coins.balance + coins.pendingCoins}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderLight, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BalanceSection(
                          icon: Icons.check_circle,
                          value: '${coins.balance}',
                          label: 'Earned',
                          color: AppTheme.success,
                        ),
                        Container(
                          width: 2,
                          height: 36,
                          color: AppTheme.borderLight,
                        ),
                        _BalanceSection(
                          icon: Icons.hourglass_empty,
                          value: '${coins.pendingCoins}',
                          label: 'Pending',
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // ── Buy Coins ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showBuyCoinsDialog(context),
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: const Text('Buy Scrap Coins'),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // ── Transactions ──
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (coins.isLoading)
              const ShimmerList(itemCount: 5, itemHeight: 68)
            else if (coins.transactions.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: const Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: AppTheme.borderLight,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...coins.transactions.map((t) {
                final isEarning = (t['amount'] as int) > 0;
                final color = isEarning ? AppTheme.success : AppTheme.danger;
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
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Icon(
                            isEarning
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['description'] ?? t['type'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(t['created_at']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isEarning ? '+' : ''}${t['amount']}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
              const SnackBar(content: Text('Payment successful! Coins added.')),
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

class _BalanceSection extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _BalanceSection({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
