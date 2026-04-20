import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kPrimaryColor,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('User data unavailable.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Email', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(user.email, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                if (user.email == kAdminEmail)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kAccentColor.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Admin access enabled. Manage order statuses from Order Status screen.',
                    ),
                  ),
                const Spacer(),
                PrimaryButton(
                  label: 'Logout',
                  onPressed: () async {
                    await authProvider.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, AppRoutes.auth);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
