import 'package:flutter/material.dart';
import '../model/stat_model.dart';

class DashboardStatsBanner extends StatelessWidget {
  static const Color _accent = Color(0xFF7A1C1C);

  final bool isLoading;
  final int disasterCount;
  final int resourceCount;

  const DashboardStatsBanner({
    super.key,
    required this.isLoading,
    required this.disasterCount,
    required this.resourceCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final stats = [
      Stat(disasterCount.toString(), 'MY PREDICTIONS'),
      Stat(resourceCount.toString(), 'RESOURCE RECORDS'),
      Stat(
        disasterCount > 0
            ? '${(resourceCount / disasterCount * 100).round()}%'
            : '0%',
        'COVERAGE RATE',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: List.generate(5, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 30,
              color: Colors.grey.withValues(alpha: 0.18),
            );
          }
          final s = stats[i ~/ 2];
          return Expanded(
            child: Column(
              children: [
                Text(
                  s.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}