import 'package:flutter/material.dart';
import 'package:umeed_v0/screens/auth/widgets/app_branding.dart';
import 'package:umeed_v0/screens/auth/widgets/gradient_button.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              AppBranding(),
              const SizedBox(height: 28),
              const Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C0A0A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your registration has been submitted for admin review. You will receive an email notification once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey[600],
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),
              // Steps card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What happens next',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C0A0A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _step(
                      '1',
                      'Admin reviews your application',
                      'Typically within 24–48 hours',
                    ),
                    const SizedBox(height: 14),
                    _step(
                      '2',
                      'You receive an email notification',
                      'Check your inbox and spam folder',
                    ),
                    const SizedBox(height: 14),
                    _step(
                      '3',
                      'Sign in to your approved account',
                      'Access all UMEED features and reports',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Back to login button
              GradientButton(
                text: 'Back to Sign In',
                icon: Icons.login_rounded,
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
              const SizedBox(height: 20),
              Text(
                'Version 2.0.4 • UMEED Systems',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF7A1C1C),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
