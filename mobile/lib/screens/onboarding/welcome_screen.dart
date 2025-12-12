import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../home_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'TalkAm',
                style: AppTheme.heading1.copyWith(
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Your voice matters. Report issues, verify reports, and build a better community together.',
                textAlign: TextAlign.center,
                style: AppTheme.body.copyWith(
                  color: AppTheme.mutedForeground,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              // Feature highlights
              _buildFeatureItem(
                icon: Icons.shield,
                text: 'Report civic issues safely and securely',
                color: AppTheme.primary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildFeatureItem(
                icon: Icons.people,
                text: 'Verify reports and help your community',
                color: AppTheme.secondary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildFeatureItem(
                icon: Icons.map,
                text: 'Track issues on an interactive map',
                color: AppTheme.primary,
              ),
              const Spacer(),
              // Buttons
              AppButton(
                label: 'Get Started',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                size: ButtonSize.large,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: AppTheme.spacing16),
              AppButton(
                label: 'Continue as Guest',
                onPressed: () {
                  // Set guest mode and navigate to dashboard
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
                variant: ButtonVariant.outline,
                size: ButtonSize.large,
              ),
              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppTheme.spacing16),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
