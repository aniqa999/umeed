import 'package:flutter/material.dart';

class SeverityBanner extends StatelessWidget {
  final int fatalities;
  final int injuries;
  final double fatalityScore;

  const SeverityBanner({
    super.key,
    required this.fatalities,
    required this.injuries,
    required this.fatalityScore,
  });

  Color _severityColor(int fatalities, int injuries) {
    if (fatalities >= 5 || injuries >= 20) return const Color(0xFFE74C3C);
    if (fatalities >= 2 || injuries >= 10) return const Color(0xFFFF9800);
    if (fatalities >= 1 || injuries >= 5) return const Color(0xFFF1C40F);
    return const Color(0xFF27AE60);
  }

  String _severityLabel(int fatalities, int injuries) {
    if (fatalities >= 5 || injuries >= 20) return 'CRITICAL';
    if (fatalities >= 2 || injuries >= 10) return 'HIGH';
    if (fatalities >= 1 || injuries >= 5) return 'MODERATE';
    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(fatalities, injuries);
    final label = _severityLabel(fatalities, injuries);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.crisis_alert_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEVERITY LEVEL',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[500],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  '${(fatalityScore / (fatalities == 0 ? 1 : fatalities) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  'Risk Score',
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
