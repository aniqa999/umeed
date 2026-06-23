import 'package:flutter/material.dart';

class ImpactPredictionHeader extends StatelessWidget {
  final Animation<double> headerFadeAnimation;
  final Animation<Offset> headerSlideAnimation;
  final VoidCallback onHistoryTap;

  const ImpactPredictionHeader({
    super.key,
    required this.headerFadeAnimation,
    required this.headerSlideAnimation,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: headerFadeAnimation,
      child: SlideTransition(
        position: headerSlideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A0D0D), Color(0xFF7A1C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onHistoryTap,
                        icon: const Icon(Icons.history, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(
                      //     Icons.notifications_outlined,
                      //     color: Colors.white,
                      //   ),
                      //   padding: EdgeInsets.zero,
                      //   constraints: const BoxConstraints(),
                      // ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Impact Prediction',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate AI-powered disaster impact assessments',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
