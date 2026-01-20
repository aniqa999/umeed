import 'package:flutter/material.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {
              // Filter options
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today Section
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          _buildAlertCard(
            severity: 'CRITICAL',
            severityColor: const Color(0xFFFF4444),
            title: 'Flash Flood Warning Issued',
            location: 'Swat District, KP Province',
            actionTitle: 'ACTION REQUIRED',
            description:
                'Immediate evacuation ordered for riverside communities. Move to high ground designated zones.',
            tags: ['SMS Sent', 'Push Sent'],
            tagColors: [Colors.green.shade100, Colors.amber.shade100],
            tagTextColors: [Colors.green.shade700, Colors.amber.shade700],
            time: '12 mins ago',
            showLanguageButtons: true,
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            severity: 'CRITICAL',
            severityColor: const Color(0xFFFF4444),
            title: 'Severe Thunderstorm Alert',
            location: 'Lahore Division, Punjab',
            actionTitle: 'ADVISORY',
            description:
                'Flash floods. Heavy winds expected. Secure loose outdoor items. Power outages likely.',
            tags: ['Push Sent'],
            tagColors: [Colors.amber.shade100],
            tagTextColors: [Colors.amber.shade700],
            time: '2 hrs ago',
            showLanguageButtons: false,
          ),
          const SizedBox(height: 24),

          // Yesterday Section
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Yesterday',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          _buildAlertCard(
            severity: 'WARNING',
            severityColor: const Color(0xFFFFA500),
            title: 'Heatwave Advisory',
            location: 'Tharparkar, Sindh',
            actionTitle: 'PRECAUTION',
            description:
                'Temperatures expected to rise above 45°C. Ensure water supply logistics are active.',
            tags: ['SMS Sent', 'Push Sent'],
            tagColors: [Colors.green.shade100, Colors.amber.shade100],
            tagTextColors: [Colors.green.shade700, Colors.amber.shade700],
            time: 'Oct 12, 08:30 AM',
            showLanguageButtons: true,
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            severity: 'WARNING',
            severityColor: const Color(0xFFFFA500),
            title: 'Landslide Risk High',
            location: 'Muzaffarabad, AJK',
            actionTitle: 'NOTICE',
            description:
                'Heavy rockslides expected on N-75. Teams should prepare clearing equipment.',
            tags: [],
            tagColors: [],
            tagTextColors: [],
            time: 'Oct 11, 04:15 PM',
            showLanguageButtons: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String severity,
    required Color severityColor,
    required String title,
    required String location,
    required String actionTitle,
    required String description,
    required List<String> tags,
    required List<Color> tagColors,
    required List<Color> tagTextColors,
    required String time,
    required bool showLanguageButtons,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity badge and time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    severity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Title and Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Required Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actionTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Tags and Language Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tags
                if (tags.isNotEmpty)
                  Row(
                    children: List.generate(
                      tags.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tagColors[index],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                tags[index].contains('SMS')
                                    ? Icons.message
                                    : Icons.notifications,
                                size: 14,
                                color: tagTextColors[index],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tags[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tagTextColors[index],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Language Buttons
                if (showLanguageButtons)
                  Row(
                    children: [
                      _buildLanguageButton('EN'),
                      const SizedBox(width: 8),
                      _buildLanguageButton('UR'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        language,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
