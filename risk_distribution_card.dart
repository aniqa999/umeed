import 'package:flutter/material.dart';
import 'tech_risk_bar.dart';

class RiskDistributionCard extends StatelessWidget {
  final int fatalities;
  final int injuries;

  const RiskDistributionCard({
    super.key,
    required this.fatalities,
    required this.injuries,
  });

  @override
  Widget build(BuildContext context) {
    final fatalitiesDouble = fatalities.toDouble();
    final injuriesDouble = injuries.toDouble();
    final total = fatalitiesDouble + injuriesDouble;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1C1C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.donut_small_outlined,
                  size: 18,
                  color: Color(0xFF7A1C1C),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Casualty Distribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TechRiskBar(
            label: 'Fatality Risk',
            progress: (fatalitiesDouble / total).clamp(0.0, 1.0),
            color: const Color(0xFFE74C3C),
          ),
          const SizedBox(height: 14),
          TechRiskBar(
            label: 'Injury Risk',
            progress: (injuriesDouble / total).clamp(0.0, 1.0),
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}
