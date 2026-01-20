import 'package:flutter/material.dart';
import 'alerts_page.dart';
import 'widgets/app_footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Index for Profile tab

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
        // Navigate to Resources page
        Navigator.pushReplacementNamed(context, '/resources');
        break;
      case 3:
        // Navigate to Reports page
        Navigator.pushReplacementNamed(context, '/reports');
        break;
      case 4:
        // Already on Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // User Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'user@example.com',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Action Buttons Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    color: const Color(0xFF4A90E2),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.notifications_active,
                    label: 'Alerts',
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlertsPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.help_outline,
                    label: 'FAQs',
                    color: const Color(0xFF50C878),
                    onTap: () {
                      // Navigate to FAQs
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.history,
                    label: 'History',
                    color: const Color(0xFFFFA500),
                    onTap: () {
                      // Navigate to history
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.info_outline,
                    label: 'About',
                    color: const Color(0xFF9B59B6),
                    onTap: () {
                      // Navigate to about
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    color: const Color(0xFF757575),
                    onTap: () {
                      // Handle logout
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTap,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
