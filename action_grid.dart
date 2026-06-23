import 'package:flutter/material.dart';
import 'action_card.dart';
import '../model/card_data_model.dart';
import 'disaster_type.dart';

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = <CardData>[
      CardData(Icons.radar_rounded, 'Impact\nPrediction', Color(0xFF7A1C1C), '/predict'),
      CardData(Icons.groups_outlined, 'NGO\nDirectory', Color(0xFF1D6ED8), '/ngo'),
      CardData(Icons.people_alt_outlined, 'Population\nIndex', Color(0xFF0D9488), '/population'),
      CardData(Icons.inventory_rounded, 'Resource\nCalculation', Color(0xFF00897B), '/resource-calculation'),
      CardData(Icons.history_rounded, 'Prediction\nHistory', Color(0xFF6B7280), '/impact-reports'),
      CardData(Icons.volunteer_activism_rounded, 'Recovery\nResources', Color(0xFF388E3C), '/recovery-resources'),
    ];

    Widget row(int start) => Row(
          children: List.generate(3, (i) {
            final c = cards[start + i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                child: ActionCard(
                  cardData: c,
                  onTap: () {
                    if (c.route == '/predict') {
                      showDisasterTypeSelector(context);
                    } else {
                      Navigator.pushNamed(context, c.route);
                    }
                  },
                ),
              ),
            );
          }),
        );

    return Column(children: [row(0), const SizedBox(height: 10), row(3)]);
  }
}