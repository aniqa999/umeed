import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PopulationMapSection extends StatelessWidget {
  const PopulationMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(30.3753, 69.3451),
                initialZoom: 5.2,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.umeed',
                ),
                CircleLayer(
                  circles: [
                    _buildHeatCircle(24.8607, 67.0011, 50, 0.9),
                    _buildHeatCircle(31.5497, 74.3436, 45, 0.85),
                    _buildHeatCircle(33.6844, 73.0479, 38, 0.75),
                    _buildHeatCircle(31.4504, 73.1350, 32, 0.65),
                    _buildHeatCircle(34.0151, 71.5249, 30, 0.6),
                    _buildHeatCircle(30.1798, 66.9750, 25, 0.5),
                    _buildHeatCircle(30.1575, 71.5249, 28, 0.55),
                    _buildHeatCircle(25.3792, 68.3683, 26, 0.52),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem('Urban (29%)', const Color(0xFFFF4444)),
                    const SizedBox(width: 12),
                    _buildLegendItem('Rural (71%)', const Color(0xFF4488FF)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CircleMarker _buildHeatCircle(
    double lat,
    double lon,
    double radius,
    double intensity,
  ) {
    return CircleMarker(
      point: LatLng(lat, lon),
      radius: radius,
      useRadiusInMeter: false,
      color: const Color(0xFFFF4444).withValues(alpha: 0.35 * intensity),
      borderColor: const Color(0xFFFF4444).withValues(alpha: 0.7 * intensity),
      borderStrokeWidth: 2,
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}