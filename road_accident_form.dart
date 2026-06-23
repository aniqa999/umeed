import 'package:flutter/material.dart';
import 'package:umeed_v0/widgets/shared/form_widgets.dart';

class RoadAccidentForm extends StatelessWidget {
  // Expandable section states
  final bool incidentExpanded;
  final bool technicalExpanded;
  final bool collisionExpanded;
  final bool humanExpanded;
  final bool emergencyExpanded;
  
  // Dropdown values
  final String selectedContext;
  final String dayOfWeek;
  final String season;
  final String locationType;
  final String weatherCondition;
  final String visibilityLevel;
  final String subjectType;
  final String brakeStatus;
  final String maintenanceStatus;
  final String collisionType;
  final String pointOfImpact;
  final String roadSurface;
  final String trafficDensity;
  final String driverBehavior;
  final String distractionLevel;
  final String safetyTraining;
  final String firstAid;
  
  // Controllers
  final TextEditingController subjectAgeCtrl;
  final TextEditingController safetyRatingCtrl;
  final TextEditingController speedCtrl;
  final TextEditingController passengersCtrl;
  final TextEditingController shiftHourCtrl;
  final TextEditingController experienceCtrl;
  final TextEditingController responseTimeCtrl;
  final TextEditingController distHospitalCtrl;
  
  // Dropdown options
  final List<String> contexts;
  final List<String> daysOfWeek;
  final List<String> seasons;
  final List<String> locationTypes;
  final List<String> weatherConditions;
  final List<String> visibilityLevels;
  final List<String> subjectTypes;
  final List<String> brakeStatuses;
  final List<String> maintenanceStatuses;
  final List<String> collisionTypes;
  final List<String> pointsOfImpact;
  final List<String> roadSurfaces;
  final List<String> trafficDensities;
  final List<String> driverBehaviors;
  final List<String> distractionLevels;
  final List<String> safetyTrainingLevels;
  final List<String> firstAidAvailabilities;
  
  // Callbacks
  final Function(String?) onContextChanged;
  final Function(String?) onDayOfWeekChanged;
  final Function(String?) onSeasonChanged;
  final Function(String?) onLocationTypeChanged;
  final Function(String?) onWeatherConditionChanged;
  final Function(String?) onVisibilityLevelChanged;
  final Function(String?) onSubjectTypeChanged;
  final Function(String?) onBrakeStatusChanged;
  final Function(String?) onMaintenanceStatusChanged;
  final Function(String?) onCollisionTypeChanged;
  final Function(String?) onPointOfImpactChanged;
  final Function(String?) onRoadSurfaceChanged;
  final Function(String?) onTrafficDensityChanged;
  final Function(String?) onDriverBehaviorChanged;
  final Function(String?) onDistractionLevelChanged;
  final Function(String?) onSafetyTrainingChanged;
  final Function(String?) onFirstAidChanged;
  final VoidCallback onIncidentToggle;
  final VoidCallback onTechnicalToggle;
  final VoidCallback onCollisionToggle;
  final VoidCallback onHumanToggle;
  final VoidCallback onEmergencyToggle;

  const RoadAccidentForm({
    super.key,
    required this.incidentExpanded,
    required this.technicalExpanded,
    required this.collisionExpanded,
    required this.humanExpanded,
    required this.emergencyExpanded,
    required this.selectedContext,
    required this.dayOfWeek,
    required this.season,
    required this.locationType,
    required this.weatherCondition,
    required this.visibilityLevel,
    required this.subjectType,
    required this.brakeStatus,
    required this.maintenanceStatus,
    required this.collisionType,
    required this.pointOfImpact,
    required this.roadSurface,
    required this.trafficDensity,
    required this.driverBehavior,
    required this.distractionLevel,
    required this.safetyTraining,
    required this.firstAid,
    required this.subjectAgeCtrl,
    required this.safetyRatingCtrl,
    required this.speedCtrl,
    required this.passengersCtrl,
    required this.shiftHourCtrl,
    required this.experienceCtrl,
    required this.responseTimeCtrl,
    required this.distHospitalCtrl,
    required this.contexts,
    required this.daysOfWeek,
    required this.seasons,
    required this.locationTypes,
    required this.weatherConditions,
    required this.visibilityLevels,
    required this.subjectTypes,
    required this.brakeStatuses,
    required this.maintenanceStatuses,
    required this.collisionTypes,
    required this.pointsOfImpact,
    required this.roadSurfaces,
    required this.trafficDensities,
    required this.driverBehaviors,
    required this.distractionLevels,
    required this.safetyTrainingLevels,
    required this.firstAidAvailabilities,
    required this.onContextChanged,
    required this.onDayOfWeekChanged,
    required this.onSeasonChanged,
    required this.onLocationTypeChanged,
    required this.onWeatherConditionChanged,
    required this.onVisibilityLevelChanged,
    required this.onSubjectTypeChanged,
    required this.onBrakeStatusChanged,
    required this.onMaintenanceStatusChanged,
    required this.onCollisionTypeChanged,
    required this.onPointOfImpactChanged,
    required this.onRoadSurfaceChanged,
    required this.onTrafficDensityChanged,
    required this.onDriverBehaviorChanged,
    required this.onDistractionLevelChanged,
    required this.onSafetyTrainingChanged,
    required this.onFirstAidChanged,
    required this.onIncidentToggle,
    required this.onTechnicalToggle,
    required this.onCollisionToggle,
    required this.onHumanToggle,
    required this.onEmergencyToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Incident Metadata ──────────────────────────
        ExpandableCard(
          title: 'Incident Metadata',
          icon: Icons.info_outline,
          expanded: incidentExpanded,
          onToggle: onIncidentToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel('Context'),
              const SizedBox(height: 6),
              FormDropdown(
                value: selectedContext,
                items: contexts,
                onChanged: onContextChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Day of Week'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: dayOfWeek,
                          items: daysOfWeek,
                          onChanged: onDayOfWeekChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Season'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: season,
                          items: seasons,
                          onChanged: onSeasonChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FormLabel('Location Type'),
              const SizedBox(height: 6),
              FormDropdown(
                value: locationType,
                items: locationTypes,
                onChanged: onLocationTypeChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Weather'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: weatherCondition,
                          items: weatherConditions,
                          onChanged: onWeatherConditionChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Visibility'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: visibilityLevel,
                          items: visibilityLevels,
                          onChanged: onVisibilityLevelChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Technical Factors ──────────────────────────
        ExpandableCard(
          title: 'Technical Factors',
          icon: Icons.settings_outlined,
          expanded: technicalExpanded,
          onToggle: onTechnicalToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Subject Type'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: subjectType,
                          items: subjectTypes,
                          onChanged: onSubjectTypeChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Brake Status'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: brakeStatus,
                          items: brakeStatuses,
                          onChanged: onBrakeStatusChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FormLabel('Equipment Maintenance Status'),
              const SizedBox(height: 6),
              FormDropdown(
                value: maintenanceStatus,
                items: maintenanceStatuses,
                onChanged: onMaintenanceStatusChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Vehicle Age (yrs)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          subjectAgeCtrl,
                          '9',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Safety Rating (1–5)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          safetyRatingCtrl,
                          '3',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Speed at Impact (KPH)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          speedCtrl,
                          '70',
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
                        FormLabel('Passengers Onboard'),
                        const SizedBox(height: 6),
                        FormTextField(
                          passengersCtrl,
                          '28',
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
        const SizedBox(height: 12),

        // ── Collision Characteristics ──────────────────
        ExpandableCard(
          title: 'Collision Characteristics',
          icon: Icons.car_crash_outlined,
          expanded: collisionExpanded,
          onToggle: onCollisionToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Collision Type'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: collisionType,
                          items: collisionTypes,
                          onChanged: onCollisionTypeChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Point of Impact'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: pointOfImpact,
                          items: pointsOfImpact,
                          onChanged: onPointOfImpactChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Road Surface'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: roadSurface,
                          items: roadSurfaces,
                          onChanged: onRoadSurfaceChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Traffic Density'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: trafficDensity,
                          items: trafficDensities,
                          onChanged: onTrafficDensityChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Human Factors ──────────────────────────────
        ExpandableCard(
          title: 'Human Factors',
          icon: Icons.person_outline,
          expanded: humanExpanded,
          onToggle: onHumanToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel('Driver / Worker Behavior'),
              const SizedBox(height: 6),
              FormDropdown(
                value: driverBehavior,
                items: driverBehaviors,
                onChanged: onDriverBehaviorChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Distraction Level'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: distractionLevel,
                          items: distractionLevels,
                          onChanged: onDistractionLevelChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Safety Training'),
                        const SizedBox(height: 6),
                        FormDropdown(
                          value: safetyTraining,
                          items: safetyTrainingLevels,
                          onChanged: onSafetyTrainingChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Shift Hour (0–23)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          shiftHourCtrl,
                          '7',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Experience (yrs)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          experienceCtrl,
                          '6',
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
        const SizedBox(height: 12),

        // ── Emergency Response ─────────────────────────
        ExpandableCard(
          title: 'Emergency Response',
          icon: Icons.local_hospital_outlined,
          expanded: emergencyExpanded,
          onToggle: onEmergencyToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel('First Aid Availability'),
              const SizedBox(height: 6),
              FormDropdown(
                value: firstAid,
                items: firstAidAvailabilities,
                onChanged: onFirstAidChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel('Response Time (min)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          responseTimeCtrl,
                          '12',
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
                        FormLabel('Dist. to Hospital (km)'),
                        const SizedBox(height: 6),
                        FormTextField(
                          distHospitalCtrl,
                          '6',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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