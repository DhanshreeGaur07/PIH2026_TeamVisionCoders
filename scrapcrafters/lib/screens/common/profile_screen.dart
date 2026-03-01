import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      setState(() => _editing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
        return const Color(0xFF2E7D32);
      case 'dealer':
        return const Color(0xFF37474F);
      case 'artist':
        return const Color(0xFF6A1B9A);
      case 'industry':
        return const Color(0xFF0D47A1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final roleColor = _getRoleColor(profile?['role']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: roleColor,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & role
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [roleColor, roleColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (profile?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?['name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getRoleLabel(profile?['role']),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile?['scrap_coins'] ?? 0} Scrap Coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _editing
                        ? Column(
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
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: roleColor,
                                  ),
                                  child: const Text('Save Changes'),
                                ),
                              ),
                            ],
                          )
                        : Column(
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
              ),
            ),
            const SizedBox(height: 16),

            // Sign out
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
