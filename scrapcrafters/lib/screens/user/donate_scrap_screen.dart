import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scrap_provider.dart';

class DonateScrapScreen extends StatefulWidget {
  const DonateScrapScreen({super.key});

  @override
  State<DonateScrapScreen> createState() => _DonateScrapScreenState();
}

class _DonateScrapScreenState extends State<DonateScrapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedScrapType = 'iron';
  bool _submitted = false;

  final List<Map<String, dynamic>> _scrapTypes = [
    {
      'value': 'iron',
      'label': 'Iron / Metal',
      'icon': Icons.hardware,
      'color': Colors.grey,
      'coins': 30,
    },
    {
      'value': 'plastic',
      'label': 'Plastic',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'coins': 20,
    },
    {
      'value': 'copper',
      'label': 'Copper',
      'icon': Icons.electric_bolt,
      'color': Colors.orange,
      'coins': 40,
    },
    {
      'value': 'glass',
      'label': 'Glass',
      'icon': Icons.wine_bar,
      'color': Colors.teal,
      'coins': 20,
    },
    {
      'value': 'ewaste',
      'label': 'E-Waste',
      'icon': Icons.devices,
      'color': Colors.purple,
      'coins': 50,
    },
    {
      'value': 'other',
      'label': 'Other',
      'icon': Icons.category,
      'color': Colors.brown,
      'coins': 10,
    },
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int get _estimatedCoins {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final type = _scrapTypes.firstWhere(
      (t) => t['value'] == _selectedScrapType,
    );
    return (weight * (type['coins'] as int)).floor();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    try {
      await context.read<ScrapProvider>().donateScrap(
        userId: auth.userId!,
        scrapType: _selectedScrapType,
        weightKg: double.parse(_weightController.text),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        pickupAddress: _addressController.text.isEmpty
            ? null
            : _addressController.text,
      );

      setState(() => _submitted = true);

      // Refresh data
      context.read<ScrapProvider>().fetchMyRequests(auth.userId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _reset() {
    _weightController.clear();
    _descriptionController.clear();
    _addressController.clear();
    setState(() {
      _selectedScrapType = 'iron';
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donate Scrap')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Donation Submitted!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A partner will pick up your scrap soon.\nYou\'ll earn ~$_estimatedCoins Scrap Coins!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.add),
                  label: const Text('Donate More'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Donate Scrap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Scrap Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Scrap type grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _scrapTypes.length,
                itemBuilder: (context, i) {
                  final type = _scrapTypes[i];
                  final selected = _selectedScrapType == type['value'];
                  return GestureDetector(
                    onTap: () => setState(
                      () => _selectedScrapType = type['value'] as String,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? (type['color'] as Color).withOpacity(0.15)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? type['color'] as Color
                              : Colors.grey.shade200,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            color: type['color'] as Color,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            type['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${type['coins']}/kg',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.scale),
                  suffixText: 'kg',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter weight';
                  final w = double.tryParse(v);
                  if (w == null || w <= 0) return 'Enter valid weight';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Estimated coins
              if (_weightController.text.isNotEmpty &&
                  double.tryParse(_weightController.text) != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated reward: $_estimatedCoins Scrap Coins',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Consumer<ScrapProvider>(
                  builder: (context, sp, _) => ElevatedButton.icon(
                    onPressed: sp.isLoading ? null : _submit,
                    icon: sp.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.recycling),
                    label: const Text('Submit Donation'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
