import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/industry_provider.dart';
import '../common/profile_screen.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final industry = context.watch<IndustryProvider>();
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Dashboard'),
        backgroundColor: const Color(0xFF0D47A1),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRequirement,
        icon: const Icon(Icons.add),
        label: const Text('Add Requirement'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile?['organization_name'] ?? profile?['name'] ?? 'Industry'} 🏭',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your scrap requirements',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: '${industry.requirements.length}',
                        color: Colors.white24,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Open',
                        value:
                            '${industry.requirements.where((r) => r['status'] != 'closed').length}',
                        color: Colors.greenAccent.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Closed',
                        value:
                            '${industry.requirements.where((r) => r['status'] == 'closed').length}',
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'My Requirements',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (industry.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (industry.requirements.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.factory, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No requirements posted',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      const Text('Tap + to post your first scrap requirement'),
                    ],
                  ),
                ),
              )
            else
              ...industry.requirements.map((req) {
                final required = double.parse(req['required_kg'].toString());
                final fulfilled = double.parse(req['fulfilled_kg'].toString());
                final progress = required > 0 ? fulfilled / required : 0.0;
                final isClosed = req['status'] == 'closed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.recycling,
                              color: isClosed ? Colors.grey : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${req['scrap_type'].toString().toUpperCase()} — ${required.toStringAsFixed(1)}kg',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isClosed ? Colors.grey : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isClosed
                                    ? Colors.green.shade50
                                    : req['status'] == 'open'
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                req['status']
                                    .toString()
                                    .toUpperCase()
                                    .replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isClosed
                                      ? Colors.green
                                      : req['status'] == 'open'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (req['description'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            req['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: isClosed ? Colors.green : Colors.blue,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${fulfilled.toStringAsFixed(1)} / ${required.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isClosed ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (req['price_per_kg'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Offering: ₹${req['price_per_kg']}/kg',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Post Scrap Requirement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setDialogState) =>
                    DropdownButtonFormField<String>(
                      value: scrapType,
                      decoration: const InputDecoration(
                        labelText: 'Scrap Type',
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
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price per kg (₹)',
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 2,
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
              if (qtyCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await context.read<IndustryProvider>().createRequirement(
                  industryId: context.read<AuthProvider>().userId!,
                  scrapType: scrapType,
                  requiredKg: double.parse(qtyCtrl.text),
                  pricePerKg: priceCtrl.text.isEmpty
                      ? null
                      : double.parse(priceCtrl.text),
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Requirement posted!'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
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
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
