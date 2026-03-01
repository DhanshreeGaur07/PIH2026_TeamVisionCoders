import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      _nameController.text = profile['name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _locationController.text = profile['location'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
          })
          .eq('id', auth.userId!);
      await auth.refreshProfile();
      setState(() {
        _editing = false;
        _saving = false;
      });
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
    } catch (e) {
      setState(() => _saving = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'user':
        return '🧍 User';
      case 'dealer':
        return '🤝 Scrap Dealer';
      case 'artist':
        return '🎨 Artist';
      case 'industry':
        return '🏭 Industry';
      default:
        return 'User';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'user':
        return AppTheme.primary;
      case 'dealer':
        return AppTheme.secondary;
      case 'artist':
        return const Color(0xFF8B5CF6);
      case 'industry':
        return const Color(0xFF3B82F6);
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final roleColor = _getRoleColor(profile?['role']);
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          children: [
            // Avatar & role
            GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: roleColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadow,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (profile?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          color: roleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile?['name'] ?? 'User',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: roleColor, width: 1.5),
                    ),
                    child: Text(
                      _getRoleLabel(profile?['role']),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${profile?['scrap_coins'] ?? 0} Scrap Coins',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // Profile fields
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_editing)
                    Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveProfile,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _InfoTile(
                          icon: Icons.email,
                          label: 'Email',
                          value: profile?['email'] ?? '',
                        ),
                        _InfoTile(
                          icon: Icons.person,
                          label: 'Name',
                          value: profile?['name'] ?? '',
                        ),
                        _InfoTile(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: profile?['phone'] ?? 'Not set',
                        ),
                        _InfoTile(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: profile?['location'] ?? 'Not set',
                        ),
                        if (profile?['organization_name'] != null)
                          _InfoTile(
                            icon: Icons.business,
                            label: 'Organization',
                            value: profile!['organization_name'],
                          ),
                      ],
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Sign out
            GlassCard(
              onTap: () {
                context.read<AuthProvider>().signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppTheme.danger, size: 22),
                  SizedBox(width: 14),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
