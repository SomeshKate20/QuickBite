import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/utils/helpers.dart';
import 'package:quickbite/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider authProvider) async {
    if (!_loginFormKey.currentState!.validate()) return;
    final success = await authProvider.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );
    if (!success) {
      if (!mounted) return;
      Helpers.showSnackbar(
        context,
        authProvider.errorMessage ?? 'Login failed',
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> _signup(AuthProvider authProvider) async {
    if (!_signupFormKey.currentState!.validate()) return;
    final success = await authProvider.signup(
      _signupNameController.text.trim(),
      _signupEmailController.text.trim(),
      _signupPasswordController.text.trim(),
    );
    if (!success) {
      if (!mounted) return;
      Helpers.showSnackbar(
        context,
        authProvider.errorMessage ?? 'Signup failed',
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'QuickBite',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentColor.withAlpha((0.14 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'College Canteen',
                            style: TextStyle(color: kAccentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: kPrimaryColor,
                    tabs: [
                      Tab(text: 'Login'),
                      Tab(text: 'Signup'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLoginTab(authProvider),
                        _buildSignupTab(authProvider),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => value == null || value.length < 6
                  ? 'Password must be 6+ chars'
                  : null,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Login',
              loading: authProvider.isLoading,
              onPressed: () => _login(authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupTab(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupNameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => value == null || value.length < 6
                  ? 'Password must be 6+ chars'
                  : null,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Signup',
              loading: authProvider.isLoading,
              onPressed: () => _signup(authProvider),
            ),
          ],
        ),
      ),
    );
  }
}
