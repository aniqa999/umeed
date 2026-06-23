import 'package:flutter/material.dart';
import 'disaster_info_row.dart';
import 'preloaded_disaster_card.dart';

class SelectedDisasterCard extends StatelessWidget {
  final Map<String, dynamic> disaster;

  const SelectedDisasterCard({
    super.key,
    required this.disaster,
  });

  String _fmt(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A0D0D).withOpacity(0.06),
            const Color(0xFF7A1C1C).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4A0D0D).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severityColor(
                    disaster['severity'] ?? '',
                  ).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (disaster['severity'] ?? 'Unknown')
                      .toString()
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: severityColor(disaster['severity'] ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A0D0D).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (disaster['status'] ?? 'Ongoing').toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A0D0D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DisasterInfoRow(
            icon: Icons.category_outlined,
            label: 'Type',
            value: disaster['disasterType']?.toString() ?? '—',
          ),
          DisasterInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Province',
            value: disaster['province']?.toString() ?? '—',
          ),
          if ((disaster['impact'] as Map?)?.containsKey('affected_population') == true)
            DisasterInfoRow(
              icon: Icons.groups,
              label: 'Affected',
              value: _fmt(disaster['impact']['affected_population'] as num? ?? 0),
            ),
        ],
      ),
    );
  }
}