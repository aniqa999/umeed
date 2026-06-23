import 'package:flutter/material.dart';

class GenderDistributionCard extends StatelessWidget {
  final int malePopulation;
  final int femalePopulation;
  final int totalPopulation;
  final AnimationController? animationController;

  const GenderDistributionCard({
    super.key,
    required this.malePopulation,
    required this.femalePopulation,
    required this.totalPopulation,
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
    String malePercentage = totalPopulation > 0
        ? ((malePopulation / totalPopulation) * 100).toStringAsFixed(1)
        : '50.7';
    String femalePercentage = totalPopulation > 0
        ? ((femalePopulation / totalPopulation) * 100).toStringAsFixed(1)
        : '49.3';

    int maleFlex = totalPopulation > 0
        ? (malePopulation / 1000000).round()
        : 507;
    int femaleFlex = totalPopulation > 0
        ? (femalePopulation / 1000000).round()
        : 493;

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
            'GENDER DISTRIBUTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Men $malePercentage%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPopulationNumber(malePopulation),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sex Ratio: 102.7',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 70, color: Colors.grey[300]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Women $femalePercentage%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPopulationNumber(femalePopulation),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transgender: 20k+',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: animationController ?? const AlwaysStoppedAnimation(1),
            builder: (context, child) {
              return Row(
                children: [
                  Expanded(
                    flex: maleFlex,
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width:
                              double.infinity *
                              (animationController?.value ?? 1.0),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Men',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: femaleFlex,
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width:
                              double.infinity *
                              (animationController?.value ?? 1.0),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Women',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
