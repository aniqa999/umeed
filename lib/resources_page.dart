import 'package:flutter/material.dart';
import 'widgets/app_footer.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  int _currentIndex = 2; // Index for Resources tab
  String _selectedRegion = 'Dadu, Sindh';

  void _onFooterTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 0:
        // Navigate to Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        // Navigate to Impact Prediction
        Navigator.pushReplacementNamed(context, '/predict');
        break;
      case 2:
        // Already on Resources
        break;
      case 3:
        // Navigate to Reports page
        Navigator.pushReplacementNamed(context, '/reports');
        break;
      case 4:
        // Navigate to Profile page
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Resource Needs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Region Selector Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRegion,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: [
                            'Dadu, Sindh',
                            'Karachi, Sindh',
                            'Lahore, Punjab',
                            'Peshawar, KPK',
                          ]
                              .map((region) => DropdownMenuItem(
                                    value: region,
                                    child: Text(
                                      'Region: $region',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRegion = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Resource Cards
                _buildResourceCard(
                  icon: Icons.restaurant_outlined,
                  title: 'Food Packs',
                  status: 'CRITICAL SHORTAGE',
                  statusColor: const Color(0xFFE74C3C),
                  required: '25,000',
                  available: '8,500',
                  availableColor: const Color(0xFFE74C3C),
                  progress: 0.34,
                  progressColor: const Color(0xFFE74C3C),
                ),
                const SizedBox(height: 16),

                _buildResourceCard(
                  icon: Icons.home_outlined,
                  title: 'Shelter Tents',
                  status: 'LOW STOCK',
                  statusColor: const Color(0xFFFF9800),
                  required: '5,000',
                  available: '3,100',
                  availableColor: const Color(0xFFFF9800),
                  progress: 0.62,
                  progressColor: const Color(0xFFFF9800),
                ),
                const SizedBox(height: 16),

                _buildResourceCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Medical Kits',
                  status: 'STOCK AVAILABLE',
                  statusColor: const Color(0xFF27AE60),
                  required: '1,200',
                  available: '1,500',
                  availableColor: const Color(0xFF27AE60),
                  progress: 1.0,
                  progressColor: const Color(0xFF27AE60),
                ),
                const SizedBox(height: 16),

                _buildResourceCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Clean Water (L)',
                  status: 'STOCK AVAILABLE',
                  statusColor: const Color(0xFF27AE60),
                  required: '50,000',
                  available: '55,000',
                  availableColor: const Color(0xFF27AE60),
                  progress: 1.0,
                  progressColor: const Color(0xFF27AE60),
                ),
                const SizedBox(height: 24),

                // Export Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Export Logistics Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTap,
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String required,
    required String available,
    required Color availableColor,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Required and Available Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      required,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      available,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: availableColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
