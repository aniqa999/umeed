import 'package:flutter/material.dart';

class AppBranding extends StatelessWidget {
  final String? subtitle;
  final double logoSize;

  const AppBranding({super.key, this.subtitle, this.logoSize = 66.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: logoSize + 14,
              height: logoSize + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A1414).withOpacity(0.1),
              ),
            ),
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A1C1C), Color(0xFF3A0A0A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A1C1C).withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'UMEED',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C0A0A),
            letterSpacing: 5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}
