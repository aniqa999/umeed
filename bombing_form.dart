import 'package:flutter/material.dart';
import 'package:umeed_v0/widgets/shared/form_widgets.dart';

class BombingForm extends StatelessWidget {
  final bool incidentExpanded;
  final bool technicalExpanded;
  final String bombingProvince;
  final String bombingCity;
  final String bombingLocation;
  final TextEditingController noOfStrikesCtrl;
  final TextEditingController temperatureCtrl;
  final TextEditingController hourOfDayCtrl;
  final TextEditingController locationController;
  final List<String> bombingProvinces;
  final List<String> bombingCities;
  final Function(String?) onBombingProvinceChanged;
  final Function(String?) onBombingCityChanged;
  final VoidCallback onIncidentToggle;
  final VoidCallback onTechnicalToggle;

  const BombingForm({
    super.key,
    required this.incidentExpanded,
    required this.technicalExpanded,
    required this.bombingProvince,
    required this.bombingCity,
    required this.bombingLocation,
    required this.noOfStrikesCtrl,
    required this.temperatureCtrl,
    required this.hourOfDayCtrl,
    required this.locationController,
    required this.bombingProvinces,
    required this.bombingCities,
    required this.onBombingProvinceChanged,
    required this.onBombingCityChanged,
    required this.onIncidentToggle,
    required this.onTechnicalToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandableCard(
          title: 'Attack Location',
          icon: Icons.location_on_outlined,
          expanded: incidentExpanded,
          onToggle: onIncidentToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel('Province'),
              const SizedBox(height: 6),
              FormDropdown(
                value: bombingProvince,
                items: bombingProvinces,
                onChanged: onBombingProvinceChanged,
              ),
              const SizedBox(height: 14),
              FormLabel('City'),
              const SizedBox(height: 6),
              FormDropdown(
                value: bombingCity,
                items: bombingCities,
                onChanged: onBombingCityChanged,
              ),
              const SizedBox(height: 14),
              FormLabel('Specific Location'),
              const SizedBox(height: 6),
              FormTextField(locationController, 'Market, Mosque, School, etc.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ExpandableCard(
          title: 'Attack Details',
          icon: Icons.warning_amber_rounded,
          expanded: technicalExpanded,
          onToggle: onTechnicalToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel('Number of Strikes / Bombs'),
              const SizedBox(height: 6),
              FormTextField(
                noOfStrikesCtrl,
                '1',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Temperature (°C)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          temperatureCtrl,
                          '25',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Hour of Day (0–23)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          hourOfDayCtrl,
                          '14',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
