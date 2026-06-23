import 'package:flutter/material.dart';

class NgoMetaTag extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const NgoMetaTag({super.key, required this.label, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF0E8E8) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlight ? const Color(0xFFD4AAAA) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isHighlight ? const Color(0xFF7A1C1C) : Colors.grey[700],
          fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
