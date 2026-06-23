import 'package:flutter/material.dart';
import 'impact_metric_tile.dart';
import 'gov_action_button.dart';

class ActiveEventCard extends StatelessWidget {
  static const Color _accent = Color(0xFF7A1C1C);
  static const Color _accentDark = Color(0xFF2E0606);
  static const Color _accentMid = Color(0xFF4A0D0D);

  final bool isLoading;
  final int disasterCount;
  final Map<String, dynamic>? latestDisaster;

  const ActiveEventCard({
    super.key,
    required this.isLoading,
    required this.disasterCount,
    this.latestDisaster,
  });

  bool? get hasPredictions {
    if (isLoading) return null;
    return disasterCount > 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasPredictions = this.hasPredictions;

    // Still loading
    if (hasPredictions == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // No predictions — show disabled placeholder
    if (hasPredictions == false) {
      return _buildNoPredictionsPlaceholder();
    }

    // Has predictions — show most recent disaster info
    return _buildActiveDisasterCard(context);
  }

  Widget _buildNoPredictionsPlaceholder() {
    return Opacity(
      opacity: 0.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF555555), Color(0xFF888888)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY COMMAND',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No Predictions Yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Run an impact prediction to activate this panel.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_outline,
                color: Colors.white.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDisasterCard(BuildContext context) {
    final d = latestDisaster ?? {};
    final impact = (d['impact'] as Map<String, dynamic>?) ?? {};
    final disasterType = d['disasterType'] ?? 'Disaster';
    final province = d['province'] ?? '—';
    final severity = d['severity'] ?? 'Unknown';
    final status = d['status'] ?? 'Ongoing';
    final deaths = impact['deaths'] ?? 0;
    final injured = impact['injured'] ?? 0;
    final affected = impact['affected_population'] ?? 0;
    final housesDestroyed = impact['houses_demolished'] ?? 0;

    Color severityColor;
    switch (severity) {
      case 'High':
        severityColor = Colors.red;
        break;
      case 'Medium':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accentDark, _accentMid, _accent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.gavel,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMERGENCY COMMAND',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '$disasterType — $province',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.crisis_alert,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            severity.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MOST RECENT PREDICTION',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Impact metrics grid
                const Text(
                  'IMPACT SUMMARY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ImpactMetricTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'Deaths',
                        value: _formatNumber(deaths),
                        color: Colors.red[300]!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ImpactMetricTile(
                        icon: Icons.local_hospital_outlined,
                        label: 'Injured',
                        value: _formatNumber(injured),
                        color: Colors.orange[300]!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ImpactMetricTile(
                        icon: Icons.people_alt_outlined,
                        label: 'Affected',
                        value: _formatNumber(affected),
                        color: Colors.yellow[300]!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ImpactMetricTile(
                        icon: Icons.home_outlined,
                        label: 'Homes Lost',
                        value: _formatNumber(housesDestroyed),
                        color: Colors.blue[200]!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: GovActionButton(
          //           icon: Icons.send_rounded,
          //           label: 'Resources\nReport',
          //           onTap: () {
          //             Navigator.pushNamed(
          //               context,
          //               '/resource-calculation',
          //               arguments: {
          //                 'disasterId': latestDisaster?['_id'],
          //                 'disasterType': latestDisaster?['disasterType'],
          //                 'severity': latestDisaster?['severity'],
          //                 'province': latestDisaster?['province'],
          //                 'impact': latestDisaster?['impact'],
          //               },
          //             );
          //           },
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: GovActionButton(
          //           icon: Icons.groups_outlined,
          //           label: 'NGO\nDirectory',
          //           onTap: () => Navigator.pushNamed(context, '/ngo'),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: GovActionButton(
          //           icon: Icons.people_alt_rounded,
          //           label: 'Population\nIndex',
          //           onTap: () => Navigator.pushNamed(context, '/population'),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    final n = (value is int) ? value : int.tryParse(value.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}