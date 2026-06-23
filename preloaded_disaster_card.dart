import 'package:flutter/material.dart';
import 'disaster_info_row.dart';

Color severityColor(String severity) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return const Color(0xFFDC2626);
    case 'high':
      return const Color(0xFFEA580C);
    case 'medium':
      return const Color(0xFFCA8A04);
    default:
      return Colors.grey;
  }
}

class PreloadedDisasterCard extends StatelessWidget {
  final Map<String, dynamic> disaster;
  final VoidCallback onClear;

  const PreloadedDisasterCard({
    super.key,
    required this.disaster,
    required this.onClear,
  });

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                        color: severityColor(
                          disaster['severity'] ?? '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pre-loaded from Dashboard',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}