import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orgNameController = TextEditingController();

  String _selectedRole = 'user';
  bool _obscurePassword = true;
  String? _error;

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'user',
      'label': 'User',
      'icon': Icons.person,
      'desc': 'Donate scrap & earn coins',
      'color': AppTheme.primary,
    },
    {
      'value': 'dealer',
      'label': 'Dealer',
      'icon': Icons.store,
      'desc': 'Collect & sell scrap',
      'color': AppTheme.secondary,
    },
    {
      'value': 'artist',
      'label': 'Artist',
      'icon': Icons.palette,
      'desc': 'Upcycle into products',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'value': 'industry',
      'label': 'Industry',
      'icon': Icons.factory,
      'desc': 'Buy bulk scrap',
      'color': AppTheme.accent,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        organizationName: _orgNameController.text.trim().isEmpty
            ? null
            : _orgNameController.text.trim(),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.shadow,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 32,
                      color: Colors.white,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  const Text(
                    'Join the circular economy',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),

                  // Role Selection
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'I am a',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _roles.map((role) {
                            final selected = _selectedRole == role['value'];
                            final color = role['color'] as Color;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRole = role['value']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? color.withValues(alpha: 0.1)
                                      : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selected
                                        ? color
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      role['icon'],
                                      size: 18,
                                      color: selected
                                          ? color
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      role['label'],
                                      style: TextStyle(
                                        color: selected
                                            ? color
                                            : AppTheme.textSecondary,
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
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 16),

                  // Form
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.danger,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.danger,
                                  fontSize: 13,
                                ),
                              ),
                            ).animate().shakeX(duration: 400.ms),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter name' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone (optional)',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_selectedRole == 'industry') ...[
                            TextFormField(
                              controller: _orgNameController,
                              decoration: const InputDecoration(
                                labelText: 'Organization Name',
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (v) =>
                                  _selectedRole == 'industry' &&
                                      (v == null || v.isEmpty)
                                  ? 'Enter org name'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _signup,
                              child: isLoading
                                  ? const SpinKitThreeBounce(
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppTheme.textMuted),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 550.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
