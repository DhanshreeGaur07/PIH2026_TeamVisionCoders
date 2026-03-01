import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
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

  static LatLng? _cachedLocation;
  static bool _locationFetched = false;

  String _selectedScrapType = 'iron';
  bool _submitted = false;
  XFile? _imageFile;
  LatLng? _selectedLocation;
  bool _isLocating = false;
  bool _isSubmitting = false;
  GoogleMapController? _googleMapController;

  final List<Map<String, dynamic>> _scrapTypes = [
    {
      'value': 'iron',
      'label': 'Iron / Metal',
      'icon': Icons.hardware,
      'color': Colors.blueGrey,
      'coins': 30,
    },
    {
      'value': 'plastic',
      'label': 'Plastic',
      'icon': Icons.water_drop,
      'color': const Color(0xFF3B82F6),
      'coins': 20,
    },
    {
      'value': 'copper',
      'label': 'Copper',
      'icon': Icons.electric_bolt,
      'color': AppTheme.accent,
      'coins': 40,
    },
    {
      'value': 'glass',
      'label': 'Glass',
      'icon': Icons.wine_bar,
      'color': AppTheme.secondary,
      'coins': 20,
    },
    {
      'value': 'ewaste',
      'label': 'E-Waste',
      'icon': Icons.devices,
      'color': const Color(0xFF8B5CF6),
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
    _googleMapController?.dispose();
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
        if (permission == LocationPermission.denied)
          throw 'Location permissions denied';
      }
      if (permission == LocationPermission.deniedForever)
        throw 'Location permissions permanently denied.';
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) throw 'Location unavailable.';
      final pt = LatLng(position.latitude, position.longitude);
      _cachedLocation = pt;
      _locationFetched = true;
      setState(() {
        _selectedLocation = pt;
        _isLocating = false;
      });
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pt, zoom: 15.0)),
      );
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
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
    if (picked != null) setState(() => _imageFile = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pickup location on the map'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
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
      setState(() {
        _submitted = true;
        _isSubmitting = false;
      });
      context.read<ScrapProvider>().fetchMyRequests(auth.userId!);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
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
    final pad = AppTheme.responsivePadding(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donate Scrap')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: GlassCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 36,
                      color: Colors.white,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  const Text(
                    'Scrap Donated!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll earn ~$_estimatedCoins Coins when picked up',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'A nearby partner will pick it up soon.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Donate More'),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Donate Scrap')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // ── Scrap Type ──
            const Text(
              'Select Scrap Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _scrapTypes.map((t) {
                final selected = _selectedScrapType == t['value'];
                final color = t['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedScrapType = t['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.1)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? color : AppTheme.borderLight,
                        width: 2,
                      ),
                      boxShadow: selected
                          ? [
                              const BoxShadow(
                                color: AppTheme.shadow,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          t['icon'] as IconData,
                          size: 18,
                          color: selected ? color : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            color: selected ? color : AppTheme.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Weight + Coins ──
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'e.g. 5.0',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter weight';
                      final w = double.tryParse(v);
                      if (w == null || w <= 0) return 'Enter valid weight';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_estimatedCoins > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.accent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: AppTheme.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Estimated: $_estimatedCoins Coins',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Details ──
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Address (optional)',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Image Picker ──
            GlassCard(
              onTap: _pickImage,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (_imageFile != null
                                  ? AppTheme.success
                                  : AppTheme.textMuted)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _imageFile != null
                            ? AppTheme.success
                            : AppTheme.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _imageFile != null
                          ? Icons.check_circle
                          : Icons.camera_alt,
                      color: _imageFile != null
                          ? AppTheme.success
                          : AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _imageFile != null ? 'Image selected' : 'Add a photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _imageFile != null
                                ? AppTheme.success
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _imageFile != null
                              ? _imageFile!.name
                              : 'Tap to pick from gallery',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Google Map ──
            const Text(
              'Pickup Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target:
                              _selectedLocation ??
                              const LatLng(20.5937, 78.9629),
                          zoom: _selectedLocation != null ? 15.0 : 4.0,
                        ),
                        onMapCreated: (controller) =>
                            _googleMapController = controller,
                        onTap: (point) {
                          setState(() {
                            _selectedLocation = point;
                            _cachedLocation = point;
                          });
                        },
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('pickup_location'),
                                  position: _selectedLocation!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: 'Pickup Location',
                                  ),
                                ),
                              }
                            : {},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: true,
                        mapType: MapType.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedLocation != null
                                ? '📍 ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                                : 'Tap the map to set location',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLocating ? null : _getCurrentLocation,
                          icon: _isLocating
                              ? const SpinKitThreeBounce(
                                  color: AppTheme.primary,
                                  size: 14,
                                )
                              : const Icon(Icons.my_location, size: 16),
                          label: Text(_isLocating ? 'Locating...' : 'Use GPS'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SpinKitThreeBounce(color: Colors.white, size: 18)
                    : const Icon(Icons.send, size: 20),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Donation',
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
