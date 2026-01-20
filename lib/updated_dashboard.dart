import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DisasterImpactAssessment extends StatelessWidget {
  DisasterImpactAssessment({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> cards = [
    {'icon': Icons.favorite, 'label': 'Loss Prediction'},
    {'icon': Icons.local_shipping, 'label': 'Resource Prediction'},
    {'icon': Icons.cloud, 'label': 'Weather Impacts'},
    {'icon': Icons.group, 'label': 'NGO Tracker'},
    {'icon': Icons.access_time, 'label': 'Previous Disasters'},
    {'icon': Icons.description, 'label': 'Reports Generated'},
  ];

  final List<Map<String, String>> miniStats = [
    {'title': 'Shelters', 'value': 'High'},
    {'title': 'Medical', 'value': 'High'},
    {'title': 'Food', 'value': 'High'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Animate(
           effects: [
  FadeEffect(duration: 600.ms),
  MoveEffect(
    begin: const Offset(0, 20), // start 20 pixels down
    end: const Offset(0, 0),    // end at original position
    duration: 600.ms,
  ),
],

            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7A2D2D), Color(0xFF9B4A4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "GOV-OFFICIAL",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            Icon(Icons.notifications, size: 18, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "DISASTER IMPACT ASSESSMENT",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Operational Forecasting & Risk Intelligence",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // Main Card: Active Event
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Animate(
                      effects: [
  FadeEffect(duration: 400.ms),
  MoveEffect(begin: const Offset(0, 20), end: const Offset(0, 0), duration: 600.ms),
  ScaleEffect(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 400.ms),
],

                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.cloud, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text("Regional Flood", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const Text(
                                  "ACTIVE EVENT",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text("OVERALL HUMAN IMPACT", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            const Text("Substantial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 0.7,
                                color: Colors.red[300],
                                backgroundColor: Colors.grey[200],
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Significant strain expected on housing and essential services in the low-lying eastern districts.",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            // Mini stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: miniStats
                                  .map((item) => Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                          ),
                                          child: Column(
                                            children: [
                                              Text(item['title']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(item['value']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cards
                          .map((item) => Animate(
                                effects: [FadeEffect(duration: 600.ms)],
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 64) / 3,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(item['icon'], size: 22, color: const Color(0xFF9B4A4A)),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['label'],
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
