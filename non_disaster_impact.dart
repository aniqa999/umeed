import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/app_footer.dart';
import 'widgets/tech_disaster/tech_disaster_header.dart';
import 'widgets/tech_disaster/severity_banner.dart';
import 'widgets/tech_disaster/tech_result_card.dart';
import 'widgets/tech_disaster/score_row.dart';
import 'widgets/tech_disaster/risk_distribution_card.dart';
import 'widgets/tech_disaster/road_accident_form.dart';
import 'widgets/tech_disaster/bombing_form.dart';

const String _kNodeApiBaseUrl = 'http://localhost:8080';

class TechImpactPredictionPage extends StatefulWidget {
  const TechImpactPredictionPage({super.key});

  @override
  State<TechImpactPredictionPage> createState() =>
      _TechImpactPredictionPageState();
}

class _TechImpactPredictionPageState extends State<TechImpactPredictionPage>
    with TickerProviderStateMixin {
  int _currentIndex = 2;

  // ── Theme ─────────────────────────────────────────────────────────────────
  static const _accentDark = Color(0xFF2E0606);
  static const _accentMid = Color(0xFF4A0D0D);
  static const _accentPrimary = Color(0xFF7A1C1C);

  // ── Disaster Type Toggle ──────────────────────────────────────────────────
  bool _isBombingMode = false;

  // ── Expandable section state ───────────────────────────────────────────────
  bool _incidentExpanded = true;
  bool _technicalExpanded = true;
  bool _collisionExpanded = true;
  bool _humanExpanded = true;
  bool _emergencyExpanded = true;

  // ─────────────────────────────────────────────────────────────────────────
  // Dropdown options - Road Accidents
  // ─────────────────────────────────────────────────────────────────────────
  static const List<String> _contexts = [
    'Vehicle',
    'Industrial',
    'Aviation',
    'Maritime',
    'Construction',
  ];
  static const List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  static const List<String> _locationTypes = [
    'Urban',
    'Suburban',
    'Rural',
    'Highway',
    'Industrial Zone',
  ];
  static const List<String> _weatherConditions = [
    'Clear',
    'Rain',
    'Fog',
    'Snow',
    'Storm',
    'Cloudy',
  ];
  static const List<String> _visibilityLevels = ['High', 'Moderate', 'Low'];
  static const List<String> _subjectTypes = [
    'Bus',
    'Car',
    'Truck',
    'Motorcycle',
    'Van',
    'Bicycle',
  ];
  static const List<String> _brakeStatuses = [
    'Functional',
    'Faulty',
    'Partially Functional',
  ];
  static const List<String> _maintenanceStatuses = [
    'Good',
    'Average',
    'Poor',
    'Under Maintenance',
  ];
  static const List<String> _collisionTypes = [
    'Side Collision',
    'Rear-End',
    'Head-On',
    'Rollover',
    'Single Vehicle',
    'Multi-Vehicle',
  ];
  static const List<String> _pointsOfImpact = [
    'Left Side',
    'Right Side',
    'Front',
    'Rear',
    'Top',
  ];
  static const List<String> _roadSurfaces = [
    'Dry',
    'Wet',
    'Icy',
    'Gravel',
    'Under Construction',
  ];
  static const List<String> _trafficDensities = ['Low', 'Moderate', 'High'];
  static const List<String> _driverBehaviors = [
    'Over Speeding',
    'Distracted',
    'Drunk Driving',
    'Normal',
    'Reckless',
    'Fatigued',
  ];
  static const List<String> _distractionLevels = [
    'None',
    'Low',
    'Moderate',
    'High',
  ];
  static const List<String> _safetyTrainingLevels = [
    'None',
    'Basic',
    'Intermediate',
    'Advanced',
  ];
  static const List<String> _firstAidAvailabilities = [
    'None',
    'Bystander',
    'On-site Medic',
    'Ambulance',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Dropdown options - Bombing/Drone Attacks
  // ─────────────────────────────────────────────────────────────────────────
  static const List<String> _bombingProvinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'FATA',
    'Islamabad',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];
  static const List<String> _bombingCities = [
    'Karachi',
    'Lahore',
    'Peshawar',
    'Quetta',
    'North Waziristan',
    'South Waziristan',
    'Mir Ali',
    'Dera Ismail Khan',
    'Rawalpindi',
    'Islamabad',
    'Swat',
    'Bajaur',
    'Mohmand',
    'Khyber',
    'Orakzai',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // State: selected dropdown values - Road Accidents
  // ─────────────────────────────────────────────────────────────────────────
  String _context = 'Vehicle';
  String _dayOfWeek = 'Saturday';
  String _season = 'Spring';
  String _locationType = 'Urban';
  String _weatherCondition = 'Clear';
  String _visibilityLevel = 'High';
  String _subjectType = 'Bus';
  String _brakeStatus = 'Functional';
  String _maintenanceStatus = 'Average';
  String _collisionType = 'Side Collision';
  String _pointOfImpact = 'Left Side';
  String _roadSurface = 'Dry';
  String _trafficDensity = 'High';
  String _driverBehavior = 'Over Speeding';
  String _distractionLevel = 'Moderate';
  String _safetyTraining = 'Basic';
  String _firstAid = 'Bystander';

  // ─────────────────────────────────────────────────────────────────────────
  // State: selected dropdown values - Bombing Attacks
  // ─────────────────────────────────────────────────────────────────────────
  String _bombingProvince = 'Punjab';
  String _bombingCity = 'Karachi';
  final String _bombingLocation = 'Market';

  // ─────────────────────────────────────────────────────────────────────────
  // Numeric controllers - Road Accidents
  // ─────────────────────────────────────────────────────────────────────────
  final _subjectAgeCtrl = TextEditingController(text: '9');
  final _safetyRatingCtrl = TextEditingController(text: '3');
  final _speedCtrl = TextEditingController(text: '70');
  final _passengersCtrl = TextEditingController(text: '28');
  final _shiftHourCtrl = TextEditingController(text: '7');
  final _experienceCtrl = TextEditingController(text: '6');
  final _responseTimeCtrl = TextEditingController(text: '12');
  final _distHospitalCtrl = TextEditingController(text: '6');

  // ─────────────────────────────────────────────────────────────────────────
  // Numeric controllers - Bombing Attacks
  // ─────────────────────────────────────────────────────────────────────────
  final _noOfStrikesCtrl = TextEditingController(text: '1');
  final _temperatureCtrl = TextEditingController(text: '25');
  final _hourOfDayCtrl = TextEditingController(text: '14');

  // ─────────────────────────────────────────────────────────────────────────
  // State: result / loading
  // ─────────────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // Animations
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _formAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _formAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnim,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formAnim, curve: Curves.easeOutCubic));

    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formAnim.forward();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _subjectAgeCtrl,
      _safetyRatingCtrl,
      _speedCtrl,
      _passengersCtrl,
      _shiftHourCtrl,
      _experienceCtrl,
      _responseTimeCtrl,
      _distHospitalCtrl,
      _noOfStrikesCtrl,
      _temperatureCtrl,
      _hourOfDayCtrl,
    ]) {
      c.dispose();
    }
    _headerAnim.dispose();
    _formAnim.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build request body - Road Accidents
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _buildRoadAccidentBody() => {
    "Incident_Metadata_Context": _context,
    "Incident_Metadata_Day_of_Week": _dayOfWeek,
    "Incident_Metadata_Season": _season,
    "Incident_Metadata_Location_Type": _locationType,
    "Incident_Metadata_Weather_Condition": _weatherCondition,
    "Incident_Metadata_Visibility_Level": _visibilityLevel,
    "Technical_Factors_Subject_Type": _subjectType,
    "Technical_Factors_Brake_Status": _brakeStatus,
    "Technical_Factors_Equipment_Maintenance_Status": _maintenanceStatus,
    "Technical_Factors_Collision_Characteristics_Collision_Type":
        _collisionType,
    "Technical_Factors_Collision_Characteristics_Point_of_Impact":
        _pointOfImpact,
    "Technical_Factors_Collision_Characteristics_Road_Surface_Condition":
        _roadSurface,
    "Technical_Factors_Collision_Characteristics_Traffic_Density":
        _trafficDensity,
    "Human_Factors_Driver_Worker_Behavior": _driverBehavior,
    "Human_Factors_Distraction_Level": _distractionLevel,
    "Human_Factors_Safety_Training_Level": _safetyTraining,
    "Emergency_Response_First_Aid_Availability": _firstAid,
    "Technical_Factors_Subject_Age_Years":
        double.tryParse(_subjectAgeCtrl.text) ?? 9,
    "Technical_Factors_Safety_Rating_Score":
        double.tryParse(_safetyRatingCtrl.text) ?? 3,
    "Technical_Factors_Speed_at_Impact_KPH":
        double.tryParse(_speedCtrl.text) ?? 70,
    "Technical_Factors_Total_Passengers_Onboard":
        double.tryParse(_passengersCtrl.text) ?? 28,
    "Human_Factors_Shift_Hour": double.tryParse(_shiftHourCtrl.text) ?? 7,
    "Human_Factors_Experience_Level_Years":
        double.tryParse(_experienceCtrl.text) ?? 6,
    "Emergency_Response_Response_Time_Minutes":
        double.tryParse(_responseTimeCtrl.text) ?? 12,
    "Emergency_Response_Distance_to_Hospital_KM":
        double.tryParse(_distHospitalCtrl.text) ?? 6,
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Build request body - Bombing Attacks
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _buildBombingBody() => {
    "location": _bombingLocation,
    "city": _bombingCity,
    "province": _bombingProvince,
    "no_of_strikes": int.tryParse(_noOfStrikesCtrl.text) ?? 1,
    "temperature_c": double.tryParse(_temperatureCtrl.text) ?? 25,
    "hour_of_day": int.tryParse(_hourOfDayCtrl.text) ?? 14,
  };

  // ─────────────────────────────────────────────────────────────────────────
  // API call
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _generatePrediction() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (_isBombingMode) {
        // ── Bombing Attack Prediction ──────────────────────────────────────
        final bombingBody = _buildBombingBody();

        // Save to Node backend
        final saveBody = {
          ...bombingBody,
          'disasterType': 'Bombing/Terrorist',
          'province': _bombingProvince,
        };

        final saveResponse = await http
            .post(
              Uri.parse(
                '$_kNodeApiBaseUrl/api/tech-disasters/predict-and-save',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(saveBody),
            )
            .timeout(const Duration(seconds: 30));

        // Call Python ML API for actual prediction
        final mlResponse = await http
            .post(
              Uri.parse('http://localhost:8091/predict'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(bombingBody),
            )
            .timeout(const Duration(seconds: 30));

        if (mlResponse.statusCode == 200) {
          final mlData = jsonDecode(mlResponse.body) as Map<String, dynamic>;
          setState(
            () => _result = {
              'predicted_fatalities': (mlData['killed_prediction'] as num)
                  .round(),
              'predicted_injuries': (mlData['injured_prediction'] as num)
                  .round(),
              'raw_scores': {
                'fatalities': mlData['killed_prediction'] as num,
                'injuries': mlData['injured_prediction'] as num,
              },
              'model_used': mlData['model_used'] ?? 'Random Forest',
            },
          );

          if (mounted && saveResponse.statusCode == 201) {
            final saveData =
                jsonDecode(saveResponse.body) as Map<String, dynamic>;
            final id = (saveData['disaster']?['_id'] as String?) ?? '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saved to database (ID: ${id.substring(0, id.length.clamp(0, 8))}…)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF27AE60),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          setState(
            () => _errorMessage = 'ML API Error ${mlResponse.statusCode}',
          );
        }
      } else {
        // ── Road Accident Prediction ────────────────────────────────────────
        final body = {
          ..._buildRoadAccidentBody(),
          'disasterType': 'Road Accident',
          'province': 'Punjab',
        };

        final response = await http
            .post(
              Uri.parse(
                '$_kNodeApiBaseUrl/api/tech-disasters/predict-and-save',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          setState(() => _result = data['predictions'] as Map<String, dynamic>);

          if (mounted) {
            final id = (data['disaster']?['_id'] as String?) ?? '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saved to database (ID: ${id.substring(0, id.length.clamp(0, 8))}…)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF27AE60),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          final detail =
              jsonDecode(response.body)['message'] ??
              jsonDecode(response.body)['detail'] ??
              'Unknown error';
          setState(
            () => _errorMessage = 'API Error ${response.statusCode}: $detail',
          );
        }
      }
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Connection failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onFooterTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/alerts');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/resource-calculation');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/reports');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Severity helpers
  // ─────────────────────────────────────────────────────────────────────────
  Color _severityColor(int fatalities, int injuries) {
    if (fatalities >= 5 || injuries >= 20) return const Color(0xFFE74C3C);
    if (fatalities >= 2 || injuries >= 10) return const Color(0xFFFF9800);
    if (fatalities >= 1 || injuries >= 5) return const Color(0xFFF1C40F);
    return const Color(0xFF27AE60);
  }

  String _severityLabel(int fatalities, int injuries) {
    if (fatalities >= 5 || injuries >= 20) return 'CRITICAL';
    if (fatalities >= 2 || injuries >= 10) return 'HIGH';
    if (fatalities >= 1 || injuries >= 5) return 'MODERATE';
    return 'LOW';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            TechDisasterHeader(
              headerFade: _headerFade,
              headerSlide: _headerSlide,
              isBombingMode: _isBombingMode,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // ── Type badge ─────────────────────────────────
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF6B2D0A,
                                      ).withValues(alpha: 0.08),
                                      const Color(
                                        0xFFB85A1A,
                                      ).withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFB85A1A,
                                    ).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6B2D0A),
                                            Color(0xFFB85A1A),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _isBombingMode
                                            ? Icons.warning_amber_rounded
                                            : Icons.directions_car,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Technological Disaster Module',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF6B2D0A),
                                          ),
                                        ),
                                        Text(
                                          _isBombingMode
                                              ? 'Bombing · Drone Attacks · Terrorism'
                                              : 'Road Accidents · Transport Incidents · Collisions',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // ── Disaster Type Toggle ──────────────────────
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _isBombingMode = false;
                                          _result = null;
                                          _errorMessage = null;
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: !_isBombingMode
                                                ? _accentPrimary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.directions_car,
                                                size: 16,
                                                color: !_isBombingMode
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Road Accident',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: !_isBombingMode
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _isBombingMode = true;
                                          _result = null;
                                          _errorMessage = null;
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isBombingMode
                                                ? _accentPrimary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 16,
                                                color: _isBombingMode
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Bombing/Attack',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _isBombingMode
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // ── Conditional Forms ─────────────────────────
                              if (!_isBombingMode) ...[
                                RoadAccidentForm(
                                  incidentExpanded: _incidentExpanded,
                                  technicalExpanded: _technicalExpanded,
                                  collisionExpanded: _collisionExpanded,
                                  humanExpanded: _humanExpanded,
                                  emergencyExpanded: _emergencyExpanded,
                                  selectedContext: _context,
                                  dayOfWeek: _dayOfWeek,
                                  season: _season,
                                  locationType: _locationType,
                                  weatherCondition: _weatherCondition,
                                  visibilityLevel: _visibilityLevel,
                                  subjectType: _subjectType,
                                  brakeStatus: _brakeStatus,
                                  maintenanceStatus: _maintenanceStatus,
                                  collisionType: _collisionType,
                                  pointOfImpact: _pointOfImpact,
                                  roadSurface: _roadSurface,
                                  trafficDensity: _trafficDensity,
                                  driverBehavior: _driverBehavior,
                                  distractionLevel: _distractionLevel,
                                  safetyTraining: _safetyTraining,
                                  firstAid: _firstAid,
                                  subjectAgeCtrl: _subjectAgeCtrl,
                                  safetyRatingCtrl: _safetyRatingCtrl,
                                  speedCtrl: _speedCtrl,
                                  passengersCtrl: _passengersCtrl,
                                  shiftHourCtrl: _shiftHourCtrl,
                                  experienceCtrl: _experienceCtrl,
                                  responseTimeCtrl: _responseTimeCtrl,
                                  distHospitalCtrl: _distHospitalCtrl,
                                  contexts: _contexts,
                                  daysOfWeek: _daysOfWeek,
                                  seasons: _seasons,
                                  locationTypes: _locationTypes,
                                  weatherConditions: _weatherConditions,
                                  visibilityLevels: _visibilityLevels,
                                  subjectTypes: _subjectTypes,
                                  brakeStatuses: _brakeStatuses,
                                  maintenanceStatuses: _maintenanceStatuses,
                                  collisionTypes: _collisionTypes,
                                  pointsOfImpact: _pointsOfImpact,
                                  roadSurfaces: _roadSurfaces,
                                  trafficDensities: _trafficDensities,
                                  driverBehaviors: _driverBehaviors,
                                  distractionLevels: _distractionLevels,
                                  safetyTrainingLevels: _safetyTrainingLevels,
                                  firstAidAvailabilities:
                                      _firstAidAvailabilities,
                                  onContextChanged: (v) =>
                                      setState(() => _context = v!),
                                  onDayOfWeekChanged: (v) =>
                                      setState(() => _dayOfWeek = v!),
                                  onSeasonChanged: (v) =>
                                      setState(() => _season = v!),
                                  onLocationTypeChanged: (v) =>
                                      setState(() => _locationType = v!),
                                  onWeatherConditionChanged: (v) =>
                                      setState(() => _weatherCondition = v!),
                                  onVisibilityLevelChanged: (v) =>
                                      setState(() => _visibilityLevel = v!),
                                  onSubjectTypeChanged: (v) =>
                                      setState(() => _subjectType = v!),
                                  onBrakeStatusChanged: (v) =>
                                      setState(() => _brakeStatus = v!),
                                  onMaintenanceStatusChanged: (v) =>
                                      setState(() => _maintenanceStatus = v!),
                                  onCollisionTypeChanged: (v) =>
                                      setState(() => _collisionType = v!),
                                  onPointOfImpactChanged: (v) =>
                                      setState(() => _pointOfImpact = v!),
                                  onRoadSurfaceChanged: (v) =>
                                      setState(() => _roadSurface = v!),
                                  onTrafficDensityChanged: (v) =>
                                      setState(() => _trafficDensity = v!),
                                  onDriverBehaviorChanged: (v) =>
                                      setState(() => _driverBehavior = v!),
                                  onDistractionLevelChanged: (v) =>
                                      setState(() => _distractionLevel = v!),
                                  onSafetyTrainingChanged: (v) =>
                                      setState(() => _safetyTraining = v!),
                                  onFirstAidChanged: (v) =>
                                      setState(() => _firstAid = v!),
                                  onIncidentToggle: () => setState(
                                    () =>
                                        _incidentExpanded = !_incidentExpanded,
                                  ),
                                  onTechnicalToggle: () => setState(
                                    () => _technicalExpanded =
                                        !_technicalExpanded,
                                  ),
                                  onCollisionToggle: () => setState(
                                    () => _collisionExpanded =
                                        !_collisionExpanded,
                                  ),
                                  onHumanToggle: () => setState(
                                    () => _humanExpanded = !_humanExpanded,
                                  ),
                                  onEmergencyToggle: () => setState(
                                    () => _emergencyExpanded =
                                        !_emergencyExpanded,
                                  ),
                                ),
                              ] else ...[
                                _buildBombingForm(),
                              ],

                              const SizedBox(height: 20),

                              // ── Error banner ───────────────────────────────
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE74C3C,
                                      ).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Color(0xFFE74C3C),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFE74C3C),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // ── Generate Button ────────────────────────────
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _generatePrediction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accentMid,
                                    disabledBackgroundColor: _accentMid
                                        .withValues(alpha: 0.6),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Generate Prediction',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ══ RESULTS ═════════════════════════════════════════════
                    if (_result != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // ── Severity banner ──────────────────────────────
                            SeverityBanner(
                              fatalities:
                                  _result!['predicted_fatalities'] as int,
                              injuries: _result!['predicted_injuries'] as int,
                              fatalityScore:
                                  (_result!['raw_scores']['fatalities'] as num)
                                      .toDouble(),
                            ),
                            const SizedBox(height: 14),
                            // ── Main result cards ────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: TechResultCard(
                                    title: 'FATALITIES',
                                    value: _result!['predicted_fatalities']
                                        .toString(),
                                    subtitle: 'Estimated Deaths',
                                    icon: Icons.person_off_outlined,
                                    color: const Color(0xFFE74C3C),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TechResultCard(
                                    title: 'INJURIES',
                                    value: _result!['predicted_injuries']
                                        .toString(),
                                    subtitle: 'Estimated Injured',
                                    icon: Icons.local_hospital_outlined,
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // ── Raw scores card ──────────────────────────────
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _accentPrimary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.bar_chart_rounded,
                                          size: 18,
                                          color: _accentPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Raw Model Scores',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ScoreRow(
                                    icon: Icons.warning_amber_rounded,
                                    label: 'Fatality Score',
                                    value:
                                        (_result!['raw_scores']['fatalities']
                                                as num)
                                            .toStringAsFixed(4),
                                    color: const Color(0xFFE74C3C),
                                  ),
                                  const SizedBox(height: 10),
                                  ScoreRow(
                                    icon: Icons.healing,
                                    label: 'Injury Score',
                                    value:
                                        (_result!['raw_scores']['injuries']
                                                as num)
                                            .toStringAsFixed(4),
                                    color: const Color(0xFFFF9800),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // ── Risk distribution ────────────────────────────
                            RiskDistributionCard(
                              fatalities:
                                  _result!['predicted_fatalities'] as int,
                              injuries: _result!['predicted_injuries'] as int,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              _isBombingMode
                                  ? Icons.warning_amber_outlined
                                  : Icons.directions_car_outlined,
                              size: 52,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Fill in the details above and\ntap Generate Prediction',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTap,
      ),
    );
  }

  Widget _buildBombingForm() {
    return BombingForm(
      incidentExpanded: _incidentExpanded,
      technicalExpanded: _technicalExpanded,
      bombingProvince: _bombingProvince,
      bombingCity: _bombingCity,
      bombingLocation: _bombingLocation,
      noOfStrikesCtrl: _noOfStrikesCtrl,
      temperatureCtrl: _temperatureCtrl,
      hourOfDayCtrl: _hourOfDayCtrl,
      locationController: TextEditingController(text: _bombingLocation),
      bombingProvinces: _bombingProvinces,
      bombingCities: _bombingCities,
      onBombingProvinceChanged: (v) => setState(() => _bombingProvince = v!),
      onBombingCityChanged: (v) => setState(() => _bombingCity = v!),
      onIncidentToggle: () =>
          setState(() => _incidentExpanded = !_incidentExpanded),
      onTechnicalToggle: () =>
          setState(() => _technicalExpanded = !_technicalExpanded),
    );
  }
}
