import 'package:flutter/material.dart';

class AgeStructureCard extends StatelessWidget {
  final int totalPopulation;
  final Map<String, double> ageDistribution;
  final AnimationController? animationController;

  const AgeStructureCard({
    super.key,
    required this.totalPopulation,
    required this.ageDistribution,
    this.animationController,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AGE STRUCTURE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: animationController ?? const AlwaysStoppedAnimation(1),
            builder: (context, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAgeBar(
                    '${ageDistribution['0-14']!.toInt()}%',
                    'Child\n0-14',
                    Colors.grey[600]!,
                    37,
                    0.0,
                  ),
                  _buildAgeBar(
                    '${ageDistribution['15-64']!.toInt()}%',
                    'Work\n15-64',
                    const Color(0xFFE74C3C),
                    58,
                    0.2,
                  ),
                  _buildAgeBar(
                    '${ageDistribution['65+']!.toInt()}%',
                    'Senior\n65+',
                    Colors.grey[600]!,
                    4,
                    0.4,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Youth (15-29): ${_formatPopulationNumber((totalPopulation * 0.258).round())} Active',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeBar(
    String percentage,
    String label,
    Color color,
    int value,
    double delay,
  ) {
    final animation = CurvedAnimation(
      parent: animationController ?? const AlwaysStoppedAnimation(1),
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Text(
              percentage,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: value * 2.0 * animation.value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
