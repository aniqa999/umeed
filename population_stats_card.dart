import 'package:flutter/material.dart';

class PopulationStatsCard extends StatelessWidget {
  final int totalPopulation;
  final double growthRate;

  const PopulationStatsCard({
    super.key,
    required this.totalPopulation,
    required this.growthRate,
  });

  String _formatPopulationNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatBox(
              'POPULATION',
              _formatPopulationNumber(totalPopulation),
              '${growthRate.toStringAsFixed(2)}%',
              const Color(0xFF9B59B6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatBox(
              'MEDIAN AGE',
              '21.6 Yrs',
              'Youth Bulge',
              const Color(0xFF3498DB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatBox(
              'DENSITY',
              '312',
              'per km²',
              const Color(0xFFE67E22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
