import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_screen.dart';
import '../../providers.dart';
import '../../services/device_token_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      client.setAccessToken(response['access_token'] as String);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _anonymousLogin() async {
    setState(() => _loading = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.anonymousStart(
        deviceHash: 'device-${DateTime.now().millisecondsSinceEpoch}',
      );

      client.setAccessToken(response['token'] as String);

      // Register device token after anonymous login
      try {
        final deviceTokenService = DeviceTokenService(client);
        await deviceTokenService.registerDeviceToken();
      } catch (e) {
        // Don't fail login if device token registration fails
        debugPrint('Device token registration failed: $e');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anonymous login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'TalkAm',
                  style: AppTheme.heading1.copyWith(
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account to continue',
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Tab Bar
                TabBar(
                  indicatorColor: AppTheme.primary,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.mutedForeground,
                  labelStyle: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Log in'),
                    Tab(text: 'Sign up'),
                  ],
                ),
                const SizedBox(height: 24),
                // Tab Bar View
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _buildLoginTab(),
                      _buildSignupTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+231700000000',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Phone number required' : null,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: _obscurePassword,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Password required' : null,
              ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              if (_phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your phone number first')),
                );
                return;
              }

              try {
                final client = ref.read(apiClientProvider);
                final response = await client.forgotPassword(
                  phone: _phoneController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] as String? ?? 'Reset link sent'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Forget password?'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A), // Deep Lagoon
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Log in',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _loading ? null : _anonymousLogin,
            child: const Text('Anonymous mode'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Full name required' : null,
        ),
        const SizedBox(height: AppTheme.spacing16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+231700000000',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Phone number required' : null,
        ),
        const SizedBox(height: AppTheme.spacing16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppTheme.spacing16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: _obscurePassword,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Password required' : null,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Sign up',
          onPressed: _loading ? null : _register,
          isLoading: _loading,
          size: ButtonSize.large,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _loading ? null : _anonymousLogin,
            child: Text(
              'Continue as Guest',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.register(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      client.setAccessToken(response['access_token'] as String);

      // Register device token after registration
      try {
        final deviceTokenService = DeviceTokenService(client);
        await deviceTokenService.registerDeviceToken();
      } catch (e) {
        // Don't fail registration if device token registration fails
        debugPrint('Device token registration failed: $e');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
