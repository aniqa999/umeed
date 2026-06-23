import 'package:flutter/material.dart';
import '../model/card_data_model.dart';

class ActionCard extends StatelessWidget {
  final CardData cardData;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.cardData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardData.color.withValues(alpha: 0.12),
                    cardData.color.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: cardData.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(cardData.icon, size: 24, color: cardData.color),
            ),
            const SizedBox(height: 12),
            Text(
              cardData.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.25,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}