import 'package:flutter/material.dart';
import 'resource_summary_card.dart';
import 'resource_detail_section.dart';
import 'resource_detail_row.dart';

String _fmt(num v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

class ResourceResultsSection extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResourceResultsSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final resource = result['resource'] as Map<String, dynamic>? ?? {};
    final calc = result['calculation'] as Map<String, dynamic>? ?? {};
    final execSummary =
        calc['executive_summary'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        const SizedBox(height: 8),
        // You'll need to import AnimatedCardWrapper or adjust this
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resource Requirements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Calculated',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ResourceSummaryCard(
                  title: 'POPULATION',
                  value: execSummary['total_population'] != null
                      ? _fmt(execSummary['total_population'] as num)
                      : _fmt(resource['affected_population'] as num? ?? 0),
                  subtitle: 'People to serve',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResourceSummaryCard(
                  title: 'HOUSEHOLDS',
                  value: execSummary['total_households'] != null
                      ? _fmt(execSummary['total_households'] as num)
                      : _fmt(resource['households'] as num? ?? 0),
                  subtitle: 'Units covered',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ResourceSummaryCard(
                  title: 'WATER',
                  value: resource['water_liters'] != null
                      ? '${_fmt(resource['water_liters'] as num)} L'
                      : '—',
                  subtitle: 'Total litres',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResourceSummaryCard(
                  title: 'FOOD',
                  value: resource['food_tons'] != null
                      ? '${_fmt(resource['food_tons'] as num)} T'
                      : '—',
                  subtitle: 'Total tonnes',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildShelterNFI(resource),
        const SizedBox(height: 12),
        _buildHealthSanitation(resource),
        const SizedBox(height: 12),
        _buildLogistics(resource),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildShelterNFI(Map<String, dynamic> resource) {
    final rows = <Widget>[];

    if ((resource['shelter'] as Map?)?.containsKey('tents') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.home,
          label: 'Tents',
          value: _fmt((resource['shelter'] as Map)['tents'] as num? ?? 0),
        ),
      );

    if ((resource['shelter'] as Map?)?.containsKey('tarpaulins') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.layers,
          label: 'Tarpaulins',
          value: _fmt((resource['shelter'] as Map)['tarpaulins'] as num? ?? 0),
        ),
      );

    if ((resource['nfi'] as Map?)?.containsKey('kitchen_sets') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.kitchen,
          label: 'Kitchen Sets',
          value: _fmt((resource['nfi'] as Map)['kitchen_sets'] as num? ?? 0),
        ),
      );

    if ((resource['nfi'] as Map?)?.containsKey('jerry_cans') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.water,
          label: 'Jerry Cans',
          value: _fmt((resource['nfi'] as Map)['jerry_cans'] as num? ?? 0),
        ),
      );

    if ((resource['nfi'] as Map?)?.containsKey('blankets') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.bed,
          label: 'Blankets',
          value: _fmt((resource['nfi'] as Map)['blankets'] as num? ?? 0),
        ),
      );

    if ((resource['nfi'] as Map?)?.containsKey('plastic_mats') == true) {
      rows.add(
        ResourceDetailRow(
          icon: Icons.grid_view,
          label: 'Plastic Mats',
          value: _fmt((resource['nfi'] as Map)['plastic_mats'] as num? ?? 0),
        ),
      );
    }
    return ResourceDetailSection(
      icon: Icons.home_work_outlined,
      title: 'Shelter & NFI',
      rows: rows,
    );
  }

  Widget _buildHealthSanitation(Map<String, dynamic> resource) {
    final rows = <Widget>[];

    if ((resource['health'] as Map?)?.containsKey('iehk_kits') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.medical_services,
          label: 'IEHK Health Kits',
          value: _fmt((resource['health'] as Map)['iehk_kits'] as num? ?? 0),
        ),
      );

    if ((resource['sanitation'] as Map?)?.containsKey('latrines') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.wc,
          label: 'Latrines',
          value: _fmt((resource['sanitation'] as Map)['latrines'] as num? ?? 0),
        ),
      );

    return ResourceDetailSection(
      icon: Icons.local_hospital_outlined,
      title: 'Health & Sanitation',
      rows: rows,
    );
  }

  Widget _buildLogistics(Map<String, dynamic> resource) {
    final rows = <Widget>[];

    if ((resource['logistics'] as Map?)?.containsKey('trucks_required') == true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.airport_shuttle,
          label: 'Trucks Required',
          value: _fmt(
            (resource['logistics'] as Map)['trucks_required'] as num? ?? 0,
          ),
        ),
      );

    if ((resource['logistics'] as Map?)?.containsKey('storage_space_sqft') ==
        true)
      rows.add(
        ResourceDetailRow(
          icon: Icons.warehouse,
          label: 'Storage (sqft)',
          value: _fmt(
            (resource['logistics'] as Map)['storage_space_sqft'] as num? ?? 0,
          ),
        ),
      );

    return ResourceDetailSection(
      icon: Icons.local_shipping_outlined,
      title: 'Logistics',
      rows: rows,
    );
  }
}
