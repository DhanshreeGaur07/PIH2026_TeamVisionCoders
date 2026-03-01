import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic> _liveStats = {};
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveStats();
  }

  Future<void> _fetchLiveStats() async {
    try {
      final profiles = await _supabase
          .from('profiles')
          .select('id')
          .count(CountOption.exact);
      final scrapRequests = await _supabase
          .from('scrap_requests')
          .select('weight_kg, status');
      final products = await _supabase
          .from('products')
          .select('id')
          .count(CountOption.exact);
      final transactions = await _supabase
          .from('transactions')
          .select('amount');

      double totalKg = 0;
      int completedPickups = 0;
      for (final r in scrapRequests) {
        if (r['status'] == 'completed') {
          totalKg += (r['weight_kg'] as num?)?.toDouble() ?? 0;
          completedPickups++;
        }
      }
      int totalCoins = 0;
      for (final t in transactions) {
        final amt = (t['amount'] as num?) ?? 0;
        if (amt > 0) totalCoins += amt.toInt();
      }

      if (mounted)
        setState(() {
          _liveStats = {
            'users': profiles.count,
            'scrap_kg': totalKg,
            'pickups': completedPickups,
            'products': products.count,
            'coins': totalCoins,
          };
          _statsLoaded = true;
        });
    } catch (_) {
      if (mounted) setState(() => _statsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavBar(context, isMobile),
              _buildHero(context, isMobile),
              _buildLiveStats(context, isMobile),
              _buildHowItWorks(context, isMobile),
              _buildSDGSection(context, isMobile),
              if (kIsWeb) _buildDownloadSection(context, isMobile),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────── NAV BAR ──────────────────────
  Widget _buildNavBar(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 2),
        ),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border, width: 2),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ScrapCrafters',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  // ──────────────────── HERO ──────────────────────
  Widget _buildHero(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: 48,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.primary, width: 1.5),
            ),
            child: const Text(
              '🌍 AI-Powered Circular Economy Platform',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),
          const SizedBox(height: 24),
          Text(
                'Turn Your Scrap\nInto Value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 36 : 56,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            'Donate scrap, earn Scrap Coins, and contribute to a sustainable future.\nConnecting users, dealers, artists, and industries.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text('Start Recycling'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Sign In'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
        ],
      ),
    );
  }

  // ──────────────────── LIVE STATS ──────────────────────
  Widget _buildLiveStats(BuildContext context, bool isMobile) {
    final stats = [
      {
        'icon': Icons.people_alt,
        'value': '${_liveStats['users'] ?? 0}',
        'label': 'Active Users',
        'color': AppTheme.primary,
      },
      {
        'icon': Icons.recycling,
        'value': '${(_liveStats['scrap_kg'] ?? 0).toStringAsFixed(0)} kg',
        'label': 'Scrap Recycled',
        'color': AppTheme.secondary,
      },
      {
        'icon': Icons.local_shipping,
        'value': '${_liveStats['pickups'] ?? 0}',
        'label': 'Pickups Done',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.palette,
        'value': '${_liveStats['products'] ?? 0}',
        'label': 'Products Created',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.monetization_on,
        'value': '${_liveStats['coins'] ?? 0}',
        'label': 'Coins Circulated',
        'color': const Color(0xFFEA580C),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 64,
        vertical: 32,
      ),
      child: Column(
        children: [
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE FROM DATABASE',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn()
              .then()
              .fade(begin: 1, end: 0.5, duration: 1500.ms),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: stats
                .map(
                  (s) => SizedBox(
                    width: isMobile
                        ? (MediaQuery.of(context).size.width - 44) / 2
                        : 180,
                    child: GlassStatCard(
                      icon: s['icon'] as IconData,
                      value: s['value'] as String,
                      label: s['label'] as String,
                      iconColor: s['color'] as Color,
                    ),
                  ),
                )
                .toList(),
          ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
        ],
      ),
    );
  }

  // ──────────────────── HOW IT WORKS ──────────────────────
  Widget _buildHowItWorks(BuildContext context, bool isMobile) {
    final steps = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Donate Scrap',
        'desc':
            'Users list their scrap with type, weight, and pickup location.',
        'color': AppTheme.primary,
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Partner Pickup',
        'desc':
            'Dealers & artists accept nearby pickups using smart geo-matching.',
        'color': AppTheme.secondary,
      },
      {
        'icon': Icons.palette,
        'title': 'Craft & Sell',
        'desc':
            'Artists upcycle scrap into products. Dealers supply to industries.',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.monetization_on,
        'title': 'Earn Coins',
        'desc':
            'Everyone earns Scrap Coins — a real circular economy in action.',
        'color': AppTheme.accent,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 64,
        vertical: 40,
      ),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'From waste to value in 4 simple steps',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: steps.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return SizedBox(
                width: isMobile ? double.infinity : 250,
                child:
                    GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (s['color'] as Color).withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: s['color'] as Color,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      s['icon'] as IconData,
                                      color: s['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0${i + 1}',
                                    style: TextStyle(
                                      color: (s['color'] as Color).withValues(
                                        alpha: 0.25,
                                      ),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s['title'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (200 * i).ms)
                        .slideY(begin: 0.15),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────── SDG GOALS ──────────────────────
  Widget _buildSDGSection(BuildContext context, bool isMobile) {
    final sdgs = [
      {
        'num': '8',
        'title': 'Decent Work & Economic Growth',
        'desc':
            'Creating livelihoods for scrap dealers, artists, and local communities.',
        'color': const Color(0xFFA21942),
      },
      {
        'num': '9',
        'title': 'Industry, Innovation & Infrastructure',
        'desc':
            'AI-powered smart matching and circular supply chain infrastructure.',
        'color': const Color(0xFFFD6925),
      },
      {
        'num': '11',
        'title': 'Sustainable Cities & Communities',
        'desc':
            'Reducing urban waste through community-driven scrap management.',
        'color': const Color(0xFFF99D26),
      },
      {
        'num': '12',
        'title': 'Responsible Consumption & Production',
        'desc':
            'Promoting upcycling, reuse, and responsible material lifecycle.',
        'color': const Color(0xFFCF8D2A),
      },
      {
        'num': '13',
        'title': 'Climate Action',
        'desc':
            'Reducing landfill waste and lowering carbon footprint through recycling.',
        'color': const Color(0xFF48773C),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 64,
        vertical: 48,
      ),
      child: Column(
        children: [
          Text(
            'UN Sustainable Development Goals',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ScrapCrafters directly contributes to 5 SDGs',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: sdgs.asMap().entries.map((entry) {
              final i = entry.key;
              final sdg = entry.value;
              final color = sdg['color'] as Color;
              return SizedBox(
                width: isMobile ? double.infinity : 220,
                child:
                    GlassCard(
                          padding: const EdgeInsets.all(20),
                          borderColor: color,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color, width: 1.5),
                                ),
                                child: Text(
                                  'SDG ${sdg['num']}',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sdg['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sdg['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (150 * i).ms)
                        .slideX(begin: 0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────── DOWNLOAD SECTION ──────────────────────
  Widget _buildDownloadSection(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 64,
        vertical: 48,
      ),
      child: GlassCard(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.shadow,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_android,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Get the Mobile App',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For the best experience with real-time notifications,\nGPS tracking, and camera scanning — download our app!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildStoreBadge(Icons.android, 'Google Play', 'Download on'),
                _buildStoreBadge(Icons.apple, 'App Store', 'Available on'),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildStoreBadge(IconData icon, String store, String prefix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderLight, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textPrimary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prefix,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                store,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────── FOOTER ──────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderLight, width: 2)),
      ),
      child: const Text(
        '© 2026 ScrapCrafters — Team Vision Coders | Built for PAN INDIA Hackathon',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
      ),
    );
  }
}
