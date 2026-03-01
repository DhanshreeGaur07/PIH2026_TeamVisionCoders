import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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

  // Static cache: persists across screen rebuilds so GPS isn't re-fetched
  static LatLng? _cachedLocation;
  static bool _locationFetched = false;

  String _selectedScrapType = 'iron';
  bool _submitted = false;
  XFile? _imageFile;
  LatLng? _selectedLocation;
  bool _isLocating = false;
  final MapController _mapController = MapController();

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
  void initState() {
    super.initState();
    // Restore cached location if available, otherwise auto-fetch once
    if (_cachedLocation != null) {
      _selectedLocation = _cachedLocation;
    } else if (!_locationFetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _getCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        // Fallback for emulators or spots where getting a fix hangs
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw 'Location unavailable. Make sure GPS is enabled and mocked on emulator.';
      }

      final pt = LatLng(position.latitude, position.longitude);
      // Cache for future screen visits
      _cachedLocation = pt;
      _locationFetched = true;
      setState(() {
        _selectedLocation = pt;
        _isLocating = false;
      });
      try {
        _mapController.move(pt, 15.0);
      } catch (_) {}
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    }
  }

  int get _estimatedCoins {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final type = _scrapTypes.firstWhere(
      (t) => t['value'] == _selectedScrapType,
    );
    return (weight * (type['coins'] as int)).floor();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pickup location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    try {
      Uint8List? imageBytes;
      String? imageExt;

      if (_imageFile != null) {
        imageBytes = await _imageFile!.readAsBytes();
        imageExt = _imageFile!.name.split('.').last;
      }

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
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        imageBytes: imageBytes,
        imageExt: imageExt,
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
      _imageFile = null;
      _selectedLocation = null;
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
              const SizedBox(height: 24),

              Text(
                'Pickup Location (Required)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _selectedLocation ??
                              const LatLng(28.6139, 77.2090),
                          initialZoom: 13.0,
                          onTap: (tapPosition, point) {
                            setState(() => _selectedLocation = point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.scrapcrafters',
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.blueAccent,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FloatingActionButton(
                          mini: true,
                          heroTag: 'map_fab',
                          backgroundColor: Colors.white,
                          child: _isLocating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                  color: Colors.blueAccent,
                                ),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      if (_selectedLocation == null)
                        IgnorePointer(
                          child: Container(
                            color: Colors.black26,
                            child: const Center(
                              child: Text(
                                'Tap map to drop pin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Address (Flat no, Street)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Add Photo (Optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _imageFile!.path,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, _) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        setState(() => _imageFile = null),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload image',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

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
