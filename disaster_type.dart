import 'package:flutter/material.dart';

/// Call this from your dashboard / action grid wherever you previously did:
///   Navigator.pushNamed(context, '/predict')
///
///   showDisasterTypeSelector(context);
void showDisasterTypeSelector(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 420),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => const _DisasterTypeSelectorDialog(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main dialog widget
// ─────────────────────────────────────────────────────────────────────────────
class _DisasterTypeSelectorDialog extends StatefulWidget {
  const _DisasterTypeSelectorDialog();

  @override
  State<_DisasterTypeSelectorDialog> createState() =>
      _DisasterTypeSelectorDialogState();
}

class _DisasterTypeSelectorDialogState
    extends State<_DisasterTypeSelectorDialog>
    with TickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _shimmerController;

  static const _accentDark = Color(0xFF2E0606);
  static const _accentMid = Color(0xFF4A0D0D);
  static const _accentPrimary = Color(0xFF7A1C1C);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _select(BuildContext context, int index) {
    Navigator.of(context).pop();
    if (index == 0) {
      Navigator.pushNamed(context, '/predict');
    } else {
      Navigator.pushNamed(context, '/predict-tech');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3F3),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _accentDark.withValues(alpha: 0.35),
                blurRadius: 50,
                offset: const Offset(0, 18),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header with gradient ─────────────────────────────────────
                _buildHeader(),
                // ── Cards ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  child: Column(
                    children: [
                      _buildTypeCard(
                        index: 0,
                        icon: Icons.water_drop_outlined,
                        filledIcon: Icons.water_drop,
                        title: 'Natural Disaster',
                        subtitle: 'Floods · Earthquakes · Droughts · Heatwaves',
                        tags: ['ML Forecast', 'Geo-Spatial', 'Impact AI'],
                        gradientColors: [
                          const Color(0xFF1A4971),
                          const Color(0xFF2D7D9A),
                        ],
                        accentColor: const Color(0xFF2D7D9A),
                      ),
                      const SizedBox(height: 14),
                      _buildTypeCard(
                        index: 1,
                        icon: Icons.directions_car_outlined,
                        filledIcon: Icons.directions_car,
                        title: 'Technological Disaster',
                        subtitle:
                            'Road Accidents · Collisions · Transport Incidents',
                        tags: ['Predictive AI', 'Risk Score', 'Response'],
                        gradientColors: [
                          const Color(0xFF6B2D0A),
                          const Color(0xFFB85A1A),
                        ],
                        accentColor: const Color(0xFFB85A1A),
                      ),
                      const SizedBox(height: 20),
                      // ── Cancel ──────────────────────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentDark, _accentPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative icon row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      'AI-POWERED PREDICTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Prediction\nModule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of disaster to generate\nan AI impact assessment report.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Type Card ─────────────────────────────────────────────────────────────
  Widget _buildTypeCard({
    required int index,
    required IconData icon,
    required IconData filledIcon,
    required String title,
    required String subtitle,
    required List<String> tags,
    required List<Color> gradientColors,
    required Color accentColor,
  }) {
    final isHovered = _hoveredIndex == index;

    return GestureDetector(
      onTap: () => _select(context, index),
      onTapDown: (_) => setState(() => _hoveredIndex = index),
      onTapUp: (_) => setState(() => _hoveredIndex = null),
      onTapCancel: () => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, isHovered ? -3.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHovered
                ? accentColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.15),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? accentColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isHovered ? 24 : 10,
              offset: Offset(0, isHovered ? 8 : 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // ── Left: gradient icon block ──────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.last.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle pattern
                    Positioned.fill(
                      child: CustomPaint(painter: _DotPatternPainter()),
                    ),
                    Center(
                      child: Icon(
                        isHovered ? filledIcon : icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ── Right: text ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isHovered
                                ? accentColor
                                : accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: isHovered ? Colors.white : accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dot pattern painter ───────────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    const spacing = 6.0;
    const radius = 1.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}