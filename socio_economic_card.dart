import 'package:flutter/material.dart';

class SocioEconomicCard extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  const SocioEconomicCard({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOCIO-ECONOMIC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCategoryTab('Overview', 0),
              const SizedBox(width: 4),
              _buildCategoryTab('Education', 1),
              const SizedBox(width: 4),
              _buildCategoryTab('Labor', 2),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index) {
    bool isActive = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4A0D0D) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isActive ? 0.12 : 0.05),
                blurRadius: isActive ? 12 : 8,
                offset: Offset(0, isActive ? 4 : 2),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedTabIndex) {
      case 1:
        return _buildEducationContent();
      case 2:
        return _buildLaborForceContent();
      default:
        return _buildDefaultSocioEconomic();
    }
  }

  Widget _buildDefaultSocioEconomic() {
    return Row(
      key: const ValueKey('default'),
      children: [
        Expanded(
          child: _buildSocioEconomicCard(
            'Literacy Rate',
            '61%',
            'M: 68%, F: 53%',
            const Color(0xFF4A0D0D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocioEconomicCard(
            'Out of School',
            '25.3M',
            'Ages 5-16',
            const Color(0xFFE74C3C),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationContent() {
    return Column(
      key: const ValueKey('education'),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSocioEconomicCard(
                'Literacy Rate',
                '61%',
                'M: 68%, F: 53%',
                const Color(0xFF4A0D0D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocioEconomicCard(
                'Out of School',
                '25.3M',
                'Ages 5-16',
                const Color(0xFFE74C3C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Primary Enrollment',
          '71%',
          'Secondary: 45%',
          const Color(0xFF3498DB),
        ),
      ],
    );
  }

  Widget _buildLaborForceContent() {
    return Column(
      key: const ValueKey('labor'),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSocioEconomicCard(
                'Labor Force',
                '72.5M',
                'Active Workers',
                const Color(0xFF27AE60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocioEconomicCard(
                'Unemployment',
                '6.3%',
                'Youth: 9.2%',
                const Color(0xFFE67E22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Agriculture',
          '38%',
          'Services: 53%, Industry: 9%',
          const Color(0xFF9B59B6),
        ),
      ],
    );
  }

  Widget _buildSocioEconomicCard(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
