import 'package:flutter/material.dart';
import 'ngo_meta_tag.dart';

class NgoCard extends StatelessWidget {
  final Map<String, dynamic> ngo;

  const NgoCard({
    super.key,
    required this.ngo,
  });

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final status = ngo['status'] as String;
    final (statusColor, statusBg) = switch (status) {
      'Active' => (const Color(0xFF3B6D11), const Color(0xFFEAF3DE)),
      'Review Pending' => (const Color(0xFF854F0B), const Color(0xFFFAEEDA)),
      _ => (const Color(0xFF185FA5), const Color(0xFFE6F1FB)),
    };
    final areas = ngo['areas'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ngo['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ngo['type'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (ngo.containsKey('projects') && ngo['projects'] > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${ngo['projects']} projects · ${_formatNumber(ngo['totalBeneficiaries'])} beneficiaries',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...areas.take(3).map((area) => NgoMetaTag(label: area)),
              NgoMetaTag(label: ngo['funding'] as String, isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }
}