import 'package:flutter/material.dart';
import 'ngo_stat_item.dart';

class NgoPageHeader extends StatelessWidget {
  final int cachedTotalNgos;
  final int cachedTotalBeneficiaries;
  final int cachedTotalProjects;
  final VoidCallback onBackPressed;

  const NgoPageHeader({
    super.key,
    required this.cachedTotalNgos,
    required this.cachedTotalBeneficiaries,
    required this.cachedTotalProjects,
    required this.onBackPressed,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E0606), Color(0xFF4A0D0D), Color(0xFF7A1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'NGO OVERSIGHT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'NGO Directory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NgoStatItem(
                label: 'ACTIVE NGOs',
                value: _formatNumber(cachedTotalNgos),
                subtitle: 'Implementing partners',
              ),
              NgoStatItem(
                label: 'TOTAL PROJECTS',
                value: _formatNumber(cachedTotalProjects),
                subtitle: 'Active projects',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NgoStatItem(
                label: 'COMPLIANCE SCORE',
                value: '88%',
                subtitle: 'Audit & tax deadlines',
              ),
              NgoStatItem(
                label: 'TOTAL BENEFICIARIES',
                value: _formatNumber(cachedTotalBeneficiaries),
                subtitle: 'Reached so far',
              ),
            ],
          ),
        ],
      ),
    );
  }
}