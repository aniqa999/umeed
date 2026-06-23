import 'package:flutter/material.dart';
import 'impact_summary_card.dart';
import 'impact_detail_row.dart';
import 'risk_bar.dart';

class ImpactResultsSection extends StatelessWidget {
  final Map<String, dynamic>? predictions;
  final double Function(String) riskProgress;
  final String Function(double) riskLabel;
  final Color Function(double) riskColor;
  final String Function(double) fmt;

  // Animation-related parameters
  final Widget Function({required int delay, required Widget child})?
  animatedCardWrapper;

  const ImpactResultsSection({
    super.key,
    required this.predictions,
    required this.riskProgress,
    required this.riskLabel,
    required this.riskColor,
    required this.fmt,
    this.animatedCardWrapper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ══ RESULTS HEADER ══════════════════════════════════════════════
        _buildAnimatedWrapper(
          delay: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projected Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: predictions != null
                        ? const Color(0xFF27AE60)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    predictions != null ? '85% Confidence' : 'Awaiting Input',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ══ HUMAN IMPACT & DEATHS ════════════════════════════════════════
        _buildAnimatedWrapper(
          delay: 700,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ImpactSummaryCard(
                    title: 'HUMAN IMPACT',
                    value: predictions != null
                        ? fmt(
                            (predictions!['affected_population'] as num)
                                .toDouble(),
                          )
                        : '—',
                    subtitle: 'People Affected',
                    isLive: predictions != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImpactSummaryCard(
                    title: 'DEATHS',
                    value: predictions != null
                        ? fmt((predictions!['deaths'] as num).toDouble())
                        : '—',
                    subtitle: 'Estimated Fatalities',
                    isLive: predictions != null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ══ AGRI LOSS & HOUSES ══════════════════════════════════════════
        _buildAnimatedWrapper(
          delay: 800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ImpactSummaryCard(
                    title: 'AGRI LOSS',
                    value: predictions != null
                        ? '${fmt((predictions!['crop_area_damaged'] as num).toDouble())} ha'
                        : '—',
                    subtitle: 'Crop Area Damaged',
                    isLive: predictions != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImpactSummaryCard(
                    title: 'HOUSES',
                    value: predictions != null
                        ? fmt(
                            (predictions!['houses_damaged'] as num).toDouble(),
                          )
                        : '—',
                    subtitle: 'Damaged / Demolished',
                    isLive: predictions != null,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ══ DETAILED BREAKDOWN ══════════════════════════════════════════
        if (predictions != null) ...[
          const SizedBox(height: 20),
          _buildAnimatedWrapper(
            delay: 850,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detailed Predictions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ImpactDetailRow(
                    icon: Icons.people,
                    label: 'Deaths',
                    value: fmt((predictions!['deaths'] as num).toDouble()),
                  ),
                  ImpactDetailRow(
                    icon: Icons.local_hospital,
                    label: 'Injured',
                    value: fmt((predictions!['injured'] as num).toDouble()),
                  ),
                  ImpactDetailRow(
                    icon: Icons.groups,
                    label: 'Affected Population',
                    value: fmt(
                      (predictions!['affected_population'] as num).toDouble(),
                    ),
                  ),
                  ImpactDetailRow(
                    icon: Icons.home_work,
                    label: 'Houses Damaged',
                    value: fmt(
                      (predictions!['houses_damaged'] as num).toDouble(),
                    ),
                  ),
                  ImpactDetailRow(
                    icon: Icons.home,
                    label: 'Houses Demolished',
                    value: fmt(
                      (predictions!['houses_demolished'] as num).toDouble(),
                    ),
                  ),
                  ImpactDetailRow(
                    icon: Icons.agriculture,
                    label: 'Crop Area Damaged',
                    value:
                        '${fmt((predictions!['crop_area_damaged'] as num).toDouble())} ha',
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // ══ RISK SEVERITY DISTRIBUTION ══════════════════════════════════
        _buildAnimatedWrapper(
          delay: 900,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Risk Severity Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                for (final cat in [
                  'Housing',
                  'Livestock',
                  'Utilities',
                  'Health',
                ]) ...[
                  RiskBar(
                    label: cat,
                    progress: riskProgress(cat),
                    color: riskColor(riskProgress(cat)),
                    severity: riskLabel(riskProgress(cat)),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to wrap with animation or fallback
  Widget _buildAnimatedWrapper({required int delay, required Widget child}) {
    if (animatedCardWrapper != null) {
      return animatedCardWrapper!(delay: delay, child: child);
    }
    // Fallback without animation (shouldn't happen in practice)
    return child;
  }
}
