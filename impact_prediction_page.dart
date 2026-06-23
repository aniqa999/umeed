import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/app_footer.dart';
import '../reports/disaster_reports.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umeed_v0/widgets/shared/form_widgets.dart';
import 'widgets/impact_prediction/impact_prediction_header.dart';
import 'widgets/impact_prediction/impact_summary_card.dart';
import 'widgets/impact_prediction/impact_detail_row.dart';
import 'widgets/impact_prediction/risk_bar.dart';
import 'widgets/impact_prediction/impact_results_section.dart';
import 'widgets/impact_prediction/impact_prediction_header.dart';
import 'widgets/impact_prediction/impact_results_section.dart';

const String _kApiBaseUrl = 'http://localhost:8080';

class ImpactPredictionPage extends StatefulWidget {
  const ImpactPredictionPage({super.key});

  @override
  State<ImpactPredictionPage> createState() => _ImpactPredictionPageState();
}

class _ImpactPredictionPageState extends State<ImpactPredictionPage>
    with TickerProviderStateMixin {
  int _currentIndex = 2;

  String _selectedDisasterType = 'Flood (Riverine)';

  static const Map<String, String> _subtypeMap = {
    'Flood (Riverine)': 'Riverine flood',
    'Flood (Flash)': 'Flash flood',
    'Earthquake': 'Ground movement',
    'Drought': 'Drought',
    'Cold Wave': 'Cold wave',
    'Heat Wave': 'Heat Wave',
  };
  static const Map<String, String> _disasterTypeMap = {
    'Flood (Riverine)': 'Flood',
    'Flood (Flash)': 'Flood',
    'Earthquake': 'Earthquake',
    'Drought': 'Drought',
    'Cold Wave': 'Extreme Temperature',
    'Heat Wave': 'Extreme Temperature',
  };

  bool _locationExpanded = true;
  bool _weatherExpanded = true;
  bool _seismicExpanded = false;
  bool _socioExpanded = true;
  bool _agriExpanded = true;

  final _locationController = TextEditingController(text: 'Dadu, Sindh');
  final _latitudeController = TextEditingController(text: '26.73');
  final _longitudeController = TextEditingController(text: '67.78');
  final _elevationController = TextEditingController(text: '50.0');
  final _slopeController = TextEditingController(text: '1.5');
  String _selectedProvince = 'Sindh';
  static const List<String> _provinces = [
    'Sindh',
    'Punjab',
    'KPK',
    'Balochistan',
    'GB',
    'AJK',
  ];

  String _selectedSeason = 'Summer';
  static const List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  final _yearController = TextEditingController(text: '2024');
  final _monthController = TextEditingController(text: '7');

  final _tempAvgController = TextEditingController(text: '30.0');
  final _tempMaxController = TextEditingController(text: '38.0');
  final _humidityController = TextEditingController(text: '65.0');
  final _heatIndexController = TextEditingController(text: '42.0');
  final _rainfallController = TextEditingController(text: '120.0');
  final _distRiverController = TextEditingController(text: '2.5');
  final _riverDischargeController = TextEditingController(text: '85000.0');
  final _floodDepthController = TextEditingController(text: '1.5');

  final _magnitudeController = TextEditingController(text: '0.0');
  final _eqDepthController = TextEditingController(text: '0.0');
  final _distEpicenterController = TextEditingController(text: '0.0');
  final _pgaController = TextEditingController(text: '0.0');

  final _populationController = TextEditingController(text: '450000');
  final _urbanRatioController = TextEditingController(text: '0.35');
  final _householdsController = TextEditingController(text: '75000');
  final _povertyRateController = TextEditingController(text: '0.38');
  final _buildingsController = TextEditingController(text: '90000');
  final _housingQualityController = TextEditingController(text: '0.45');
  String _selectedBuildingMaterial = 'Mud/Adobe';
  static const List<String> _buildingMaterials = [
    'Mud/Adobe',
    'Brick',
    'Concrete',
    'Wood',
    'Stone',
  ];

  final _farmlandController = TextEditingController(text: '12000.0');
  final _livestockController = TextEditingController(text: '35000.0');

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _predictions;

  // ── Saved DB ids returned by the backend ────────────────────────────────────
  String? _savedDisasterId;
  String? _savedResourceId;

  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _impactAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _impactAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _impactAnimationController.forward();
    });
  }

  @override
  void dispose() {
    // Dispose TextEditingControllers
    for (final c in [
      _locationController,
      _latitudeController,
      _longitudeController,
      _elevationController,
      _slopeController,
      _yearController,
      _monthController,
      _tempAvgController,
      _tempMaxController,
      _humidityController,
      _heatIndexController,
      _rainfallController,
      _distRiverController,
      _riverDischargeController,
      _floodDepthController,
      _magnitudeController,
      _eqDepthController,
      _distEpicenterController,
      _pgaController,
      _populationController,
      _urbanRatioController,
      _householdsController,
      _povertyRateController,
      _buildingsController,
      _housingQualityController,
      _farmlandController,
      _livestockController,
    ]) {
      c.dispose();
    }

    // Dispose AnimationControllers separately
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    _impactAnimationController.dispose();

    super.dispose();
  }

  // ── Build the request body for POST /api/disasters/predict-and-save ─────────
  Map<String, dynamic> _buildRequestBody() => {
    // ── ML features ──────────────────────────────────────────────────────────
    "province": _selectedProvince,
    "latitude": double.tryParse(_latitudeController.text) ?? 26.73,
    "longitude": double.tryParse(_longitudeController.text) ?? 67.78,
    "elevation": double.tryParse(_elevationController.text) ?? 50.0,
    "slope": double.tryParse(_slopeController.text) ?? 1.5,
    "year": int.tryParse(_yearController.text) ?? 2024,
    "month": int.tryParse(_monthController.text) ?? 7,
    "season": _selectedSeason,
    "disaster_type": _disasterTypeMap[_selectedDisasterType] ?? 'Flood',
    "disaster_subtype": _subtypeMap[_selectedDisasterType] ?? 'Riverine flood',
    "temperature_avg": double.tryParse(_tempAvgController.text) ?? 30.0,
    "temperature_max": double.tryParse(_tempMaxController.text) ?? 38.0,
    "humidity": double.tryParse(_humidityController.text) ?? 65.0,
    "heat_index": double.tryParse(_heatIndexController.text) ?? 42.0,
    "rainfall_7d_mm": double.tryParse(_rainfallController.text) ?? 120.0,
    "distance_to_river_km": double.tryParse(_distRiverController.text) ?? 2.5,
    "river_discharge_cusecs":
        double.tryParse(_riverDischargeController.text) ?? 85000.0,
    "flood_depth_m": double.tryParse(_floodDepthController.text) ?? 1.5,
    "magnitude": double.tryParse(_magnitudeController.text) ?? 0.0,
    "earthquake_depth_km": double.tryParse(_eqDepthController.text) ?? 0.0,
    "distance_to_epicenter_km":
        double.tryParse(_distEpicenterController.text) ?? 0.0,
    "pga_g": double.tryParse(_pgaController.text) ?? 0.0,
    "population_total": double.tryParse(_populationController.text) ?? 450000.0,
    "urban_ratio": double.tryParse(_urbanRatioController.text) ?? 0.35,
    "households": double.tryParse(_householdsController.text) ?? 75000.0,
    "poverty_rate": double.tryParse(_povertyRateController.text) ?? 0.38,
    "buildings_total": double.tryParse(_buildingsController.text) ?? 90000.0,
    "housing_quality_index":
        double.tryParse(_housingQualityController.text) ?? 0.45,
    "building_material": _selectedBuildingMaterial,
    "farmland_area_hectares":
        double.tryParse(_farmlandController.text) ?? 12000.0,
    "livestock_count": double.tryParse(_livestockController.text) ?? 35000.0,

    // ── Extra DB fields ───────────────────────────────────────────────────────
    "startDate": DateTime.now().toIso8601String(),
    "duration_days": 7,
  };

  // ── Call Node backend (which proxies to Python and saves to DB) ─────────────
  Future<void> _generatePrediction() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _predictions = null;
      _savedDisasterId = null;
      _savedResourceId = null;
    });

    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      final response = await http
          .post(
            Uri.parse('$_kApiBaseUrl/api/disasters/predict-and-save'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(_buildRequestBody()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _predictions = data['predictions'] as Map<String, dynamic>;
          _savedDisasterId = data['disaster']?['_id'] as String?;
          _savedResourceId = data['resources']?['_id'] as String?;
        });

        // ── Show a brief "Saved" snack ────────────────────────────────────────
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prediction saved to database (ID: ${_savedDisasterId?.substring(0, 8)}…)',
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
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Connection failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Formatting helpers ───────────────────────────────────────────────────────
  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  double _riskProgress(String cat) {
    if (_predictions == null) {
      return const {
            'Housing': 0.8,
            'Livestock': 0.5,
            'Utilities': 0.3,
            'Health': 0.9,
          }[cat] ??
          0.5;
    }
    final pop = double.tryParse(_populationController.text) ?? 450000;
    switch (cat) {
      case 'Housing':
        return ((_predictions!['houses_damaged'] as num).toDouble() / (pop / 5))
            .clamp(0.0, 1.0);
      case 'Livestock':
        return (_predictions!['crop_area_damaged'] as num) > 5000 ? 0.7 : 0.4;
      case 'Utilities':
        return (_predictions!['houses_demolished'] as num) > 500 ? 0.6 : 0.3;
      case 'Health':
        return ((_predictions!['injured'] as num).toDouble() / (pop * 0.05))
            .clamp(0.0, 1.0);
      default:
        return 0.5;
    }
  }

  String _riskLabel(double p) {
    if (p >= 0.8) return 'Crit';
    if (p >= 0.6) return 'High';
    if (p >= 0.4) return 'Med';
    return 'Low';
  }

  Color _riskColor(double p) {
    if (p >= 0.6) return const Color(0xFFE74C3C);
    if (p >= 0.4) return const Color(0xFFFF9800);
    return Colors.grey;
  }

  void _onFooterTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/weather');
        break;
      case 2:
        break; // already on Predict
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            ImpactPredictionHeader(
              headerFadeAnimation: _headerFadeAnimation,
              headerSlideAnimation: _headerSlideAnimation,
              onHistoryTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisasterReportsHub()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _formFadeAnimation,
                      child: SlideTransition(
                        position: _formSlideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // ── Disaster Classification ──────────────────
                              _plainCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CardSectionHeader(
                                      Icons.warning_amber_rounded,
                                      'Disaster Classification',
                                    ),
                                    const SizedBox(height: 14),
                                    FormLabel('Disaster Type'),
                                    const SizedBox(height: 6),
                                    FormDropdown<String>(
                                      value: _selectedDisasterType,
                                      items: _subtypeMap.keys.toList(),
                                      onChanged: (v) => setState(() {
                                        _selectedDisasterType = v!;
                                        if (v != 'Earthquake') {
                                          _magnitudeController.text = '0.0';
                                          _eqDepthController.text = '0.0';
                                          _distEpicenterController.text = '0.0';
                                          _pgaController.text = '0.0';
                                          _seismicExpanded = false;
                                        } else {
                                          _seismicExpanded = true;
                                        }
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Year'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _yearController,
                                                '2024',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Month (1–12)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _monthController,
                                                '7',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    FormLabel('Season'),
                                    const SizedBox(height: 6),
                                    FormDropdown<String>(
                                      value: _selectedSeason,
                                      items: _seasons,
                                      onChanged: (v) =>
                                          setState(() => _selectedSeason = v!),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Location & Geography ─────────────────────
                              ExpandableCard(
                                title: 'Location & Geography',
                                icon: Icons.location_on_outlined,
                                expanded: _locationExpanded,
                                onToggle: () => setState(
                                  () => _locationExpanded = !_locationExpanded,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormLabel('Location Name'),
                                    const SizedBox(height: 6),
                                    FormTextField(
                                      _locationController,
                                      'Dadu, Sindh',
                                      suffix: const Icon(
                                        Icons.search,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    FormLabel('Province'),
                                    const SizedBox(height: 6),
                                    FormDropdown<String>(
                                      value: _selectedProvince,
                                      items: _provinces,
                                      onChanged: (v) => setState(
                                        () => _selectedProvince = v!,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Latitude'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _latitudeController,
                                                '26.73',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                      signed: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Longitude'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _longitudeController,
                                                '67.78',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                      signed: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Elevation (m)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _elevationController,
                                                '50.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Slope (°)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _slopeController,
                                                '1.5',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
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
                              const SizedBox(height: 12),

                              // ── Weather & Hydrology ──────────────────────
                              ExpandableCard(
                                title: 'Weather & Hydrology',
                                icon: Icons.water_drop_outlined,
                                expanded: _weatherExpanded,
                                onToggle: () => setState(
                                  () => _weatherExpanded = !_weatherExpanded,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Avg Temp (°C)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _tempAvgController,
                                                '30.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Max Temp (°C)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _tempMaxController,
                                                '38.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Humidity (%)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _humidityController,
                                                '65.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Heat Index'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _heatIndexController,
                                                '42.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    FormLabel('Rainfall — 7-day total (mm)'),
                                    const SizedBox(height: 6),
                                    FormTextField(
                                      _rainfallController,
                                      '120.0',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Dist. to River (km)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _distRiverController,
                                                '2.5',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel(
                                                'River Discharge (cusecs)',
                                              ),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _riverDischargeController,
                                                '85000.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    FormLabel('Flood Depth (m)'),
                                    const SizedBox(height: 6),
                                    FormTextField(
                                      _floodDepthController,
                                      '1.5',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Seismic Data ─────────────────────────────
                              ExpandableCard(
                                title: 'Seismic Data',
                                icon: Icons.crisis_alert_outlined,
                                badge: _selectedDisasterType != 'Earthquake'
                                    ? 'Auto-zeroed for non-EQ'
                                    : null,
                                expanded: _seismicExpanded,
                                onToggle: () => setState(
                                  () => _seismicExpanded = !_seismicExpanded,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Magnitude'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _magnitudeController,
                                                '0.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('EQ Depth (km)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _eqDepthController,
                                                '0.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel(
                                                'Dist. to Epicenter (km)',
                                              ),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _distEpicenterController,
                                                '0.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('PGA (g)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _pgaController,
                                                '0.0',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
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
                              const SizedBox(height: 12),

                              // ── Socio-Economic ───────────────────────────
                              ExpandableCard(
                                title: 'Socio-Economic',
                                icon: Icons.people_outline,
                                expanded: _socioExpanded,
                                onToggle: () => setState(
                                  () => _socioExpanded = !_socioExpanded,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Population'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _populationController,
                                                '450000',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Households'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _householdsController,
                                                '75000',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Urban Ratio (0–1)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _urbanRatioController,
                                                '0.35',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Poverty Rate (0–1)'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _povertyRateController,
                                                '0.38',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel('Buildings Total'),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _buildingsController,
                                                '90000',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FormLabel(
                                                'Housing Quality (0–1)',
                                              ),
                                              const SizedBox(height: 6),
                                              FormTextField(
                                                _housingQualityController,
                                                '0.45',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    FormLabel('Building Material'),
                                    const SizedBox(height: 6),
                                    FormDropdown<String>(
                                      value: _selectedBuildingMaterial,
                                      items: _buildingMaterials,
                                      onChanged: (v) => setState(
                                        () => _selectedBuildingMaterial = v!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Agriculture ──────────────────────────────
                              ExpandableCard(
                                title: 'Agriculture',
                                icon: Icons.agriculture_outlined,
                                expanded: _agriExpanded,
                                onToggle: () => setState(
                                  () => _agriExpanded = !_agriExpanded,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FormLabel('Farmland (hectares)'),
                                          const SizedBox(height: 6),
                                          FormTextField(
                                            _farmlandController,
                                            '12000.0',
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FormLabel('Livestock Count'),
                                          const SizedBox(height: 6),
                                          FormTextField(
                                            _livestockController,
                                            '35000.0',
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Error banner ─────────────────────────────
                              if (_errorMessage != null)
                                ErrorBanner(_errorMessage!),

                              // ── Saved-to-DB banner (shown after success) ──
                              if (_savedDisasterId != null)
                                SuccessBanner(
                                  'Saved to database  •  Disaster ID: ${_savedDisasterId!.substring(0, 16)}…',
                                ),

                              // ── Generate Button ──────────────────────────
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _generatePrediction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A0D0D),
                                    disabledBackgroundColor: const Color(
                                      0xFF4A0D0D,
                                    ).withValues(alpha: 0.6),
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
                                          'Generate & Save Prediction',
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

                    // Results
                    ImpactResultsSection(
                      predictions: _predictions,
                      riskProgress: _riskProgress,
                      riskLabel: _riskLabel,
                      riskColor: _riskColor,
                      fmt: _fmt,
                      animatedCardWrapper:
                          ({required int delay, required Widget child}) {
                            return AnimatedCardWrapper(
                              delay: delay,
                              child: child,
                            );
                          },
                    ),
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

  // ════════════════════════════════════════════════════════
  //  WIDGET HELPERS  (unchanged from original)
  // ════════════════════════════════════════════════════════

  Widget _plainCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
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
    child: child,
  );
}
