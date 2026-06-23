import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/app_footer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umeed_v0/widgets/shared/form_widgets.dart';
import 'widgets/resource_calc_header.dart';
import 'widgets/disaster_selector_card.dart';
import 'widgets/resource_results_section.dart';

const String _kApiBaseUrl = 'http://localhost:8080';

class ResourceCalculationPage extends StatefulWidget {
  const ResourceCalculationPage({super.key});

  @override
  State<ResourceCalculationPage> createState() =>
      _ResourceCalculationPageState();
}

class _ResourceCalculationPageState extends State<ResourceCalculationPage>
    with TickerProviderStateMixin {
  // NGO footer: 0=Home 1=Alerts 2=Resources(current) 3=Weather 4=Reports 5=Profile
  int _currentIndex = 3;

  // ── Disaster selection ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _pendingDisasters = [];
  String? _selectedDisasterId;
  Map<String, dynamic>? _selectedDisaster;
  bool _loadingDisasters = true;
  String? _disasterLoadError;
  bool _hasLoadedPassedDisaster = false;

  // ── Form fields ─────────────────────────────────────────────────────────────
  final _affectedPopController = TextEditingController();
  final _injuredController = TextEditingController();
  final _housesDamagedController = TextEditingController();
  final _housesDemolishedController = TextEditingController();
  final _durationDaysController = TextEditingController(text: '7');
  String _selectedProvince = 'Punjab';

  static const List<String> _provinces = [
    'Punjab',
    'Sindh',
    'KPK',
    'Balochistan',
    'GB',
    'AJK',
  ];

  // ── State ───────────────────────────────────────────────────────────────────
  bool _isCalculating = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;
  String? _savedResourceId;

  // ── Expandable sections ─────────────────────────────────────────────────────
  bool _disasterExpanded = true;
  bool _populationExpanded = true;
  bool _housingExpanded = true;

  // ── Animations ──────────────────────────────────────────────────────────────
  late AnimationController _headerAnimCtrl;
  late AnimationController _formAnimCtrl;
  late AnimationController _resultsAnimCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _headerAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOutCubic),
        );

    _formAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formAnimCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _formAnimCtrl, curve: Curves.easeOutCubic),
        );

    _resultsAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formAnimCtrl.forward();
    });

    _loadPendingDisasters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedPassedDisaster) {
      _loadPassedDisaster();
    }
  }

  void _loadPassedDisaster() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('disasterId')) {
      final disasterId = args['disasterId'] as String?;

      // Check if this disaster exists in pending disasters
      final existsInPending =
          disasterId != null &&
          _pendingDisasters.any((d) => d['_id'].toString() == disasterId);

      // Pre-populate with the passed disaster
      setState(() {
        if (existsInPending) {
          // If disaster exists in pending list, select it in dropdown
          _selectedDisasterId = disasterId;
          _selectedDisaster = _pendingDisasters.firstWhere(
            (d) => d['_id'].toString() == disasterId,
          );
        } else {
          // If not in pending list, store the ID but don't set dropdown value
          _selectedDisasterId = disasterId;
          _selectedDisaster = {
            '_id': disasterId,
            'disasterType': args['disasterType'],
            'severity': args['severity'],
            'province': args['province'],
            'impact': args['impact'],
          };
        }

        final impact = args['impact'] as Map<String, dynamic>? ?? {};
        _affectedPopController.text = (impact['affected_population'] ?? '')
            .toString();
        _injuredController.text = (impact['injured'] ?? '').toString();
        _housesDamagedController.text = (impact['houses_damaged'] ?? '0')
            .toString();
        _housesDemolishedController.text = (impact['houses_demolished'] ?? '0')
            .toString();

        if (args['province'] != null && _provinces.contains(args['province'])) {
          _selectedProvince = args['province'] as String;
        }

        // Mark that we've loaded the passed disaster
        _hasLoadedPassedDisaster = true;
      });
    }
  }

  @override
  void dispose() {
    _affectedPopController.dispose();
    _injuredController.dispose();
    _housesDamagedController.dispose();
    _housesDemolishedController.dispose();
    _durationDaysController.dispose();
    _headerAnimCtrl.dispose();
    _formAnimCtrl.dispose();
    _resultsAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPendingDisasters() async {
    setState(() {
      _loadingDisasters = true;
      _disasterLoadError = null;
    });
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final resp = await http
          .get(
            Uri.parse('$_kApiBaseUrl/api/resources/disasters/pending'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        setState(() {
          _pendingDisasters = List<Map<String, dynamic>>.from(
            body['data'] ?? [],
          );
          _loadingDisasters = false;
        });
        if (!_hasLoadedPassedDisaster) {
          _loadPassedDisaster();
        }
      } else {
        setState(() {
          _disasterLoadError = 'Failed to load disasters (${resp.statusCode})';
          _loadingDisasters = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _disasterLoadError = 'Connection failed: $e';
        _loadingDisasters = false;
      });
    }
  }

  void _onDisasterSelected(String? id) {
    if (id == null) return;

    setState(() {
      _selectedDisasterId = id;
      _selectedDisaster = _pendingDisasters.firstWhere(
        (d) => d['_id'].toString() == id,
      );

      final impact =
          _selectedDisaster!['impact'] as Map<String, dynamic>? ?? {};
      _affectedPopController.text = (impact['affected_population'] ?? '')
          .toString();
      _injuredController.text = (impact['injured'] ?? '').toString();
      _housesDamagedController.text = (impact['houses_damaged'] ?? '0')
          .toString();
      _housesDemolishedController.text = (impact['houses_demolished'] ?? '0')
          .toString();
      _selectedProvince = _selectedDisaster!['province'] ?? 'Punjab';
      if (!_provinces.contains(_selectedProvince)) _selectedProvince = 'Punjab';
      _result = null;
      _savedResourceId = null;
      _errorMessage = null;

      _hasLoadedPassedDisaster = true;
    });
  }

  void _onClearPreloaded() {
    setState(() {
      _selectedDisasterId = null;
      _selectedDisaster = null;
      _affectedPopController.text = '';
      _injuredController.text = '';
      _housesDamagedController.text = '';
      _housesDemolishedController.text = '';
      _hasLoadedPassedDisaster = true;
    });
  }

  Future<void> _calculateAndSave() async {
    FocusScope.of(context).unfocus();

    final disasterId =
        _selectedDisasterId ?? _selectedDisaster?['_id'] as String?;

    if (disasterId == null) {
      setState(() => _errorMessage = 'Please select a disaster first.');
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
      _result = null;
      _savedResourceId = null;
    });

    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final body = {
        'disasterId': disasterId,
        'affected_population': int.tryParse(_affectedPopController.text) ?? 0,
        'injured': int.tryParse(_injuredController.text) ?? 0,
        'houses_damaged': int.tryParse(_housesDamagedController.text) ?? 0,
        'houses_demolished':
            int.tryParse(_housesDemolishedController.text) ?? 0,
        'duration_days': int.tryParse(_durationDaysController.text) ?? 7,
        'province': _selectedProvince,
      };

      final resp = await http
          .post(
            Uri.parse('$_kApiBaseUrl/api/resources/calculate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _result = data;
          _savedResourceId =
              (data['resource'] as Map<String, dynamic>?)?['_id'] as String?;
        });
        _resultsAnimCtrl.forward(from: 0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resources saved (ID: ${_savedResourceId?.substring(0, 8)}…)',
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
        final detail = (() {
          try {
            final d = jsonDecode(resp.body);
            return d['error'] ?? d['message'] ?? 'Unknown error';
          } catch (_) {
            return resp.body;
          }
        })();
        setState(() => _errorMessage = 'API Error ${resp.statusCode}: $detail');
      }
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Connection failed: $e');
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  // ── Footer tap — unified nav ─────────────────────────────────────────────
  // 0=Home 1=Weather 2=Predict 3=Resources(here) 4=Reports 5=Profile
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
        Navigator.pushReplacementNamed(context, '/predict');
        break;
      case 3:
        break; // already on Resources
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
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: ResourceCalcHeader(
                  selectedDisaster: _selectedDisaster,
                  selectedDisasterId: _selectedDisasterId,
                  onBackPressed: () => Navigator.pop(context),
                  onRefresh: _loadPendingDisasters,
                ),
              ),
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
                              ExpandableCard(
                                title: 'Select Disaster',
                                icon: Icons.warning_amber_rounded,
                                expanded: _disasterExpanded,
                                onToggle: () => setState(
                                  () => _disasterExpanded = !_disasterExpanded,
                                ),
                                child: DisasterSelectorCard(
                                  loadingDisasters: _loadingDisasters,
                                  disasterLoadError: _disasterLoadError,
                                  pendingDisasters: _pendingDisasters,
                                  selectedDisaster: _selectedDisaster,
                                  selectedDisasterId: _selectedDisasterId,
                                  hasLoadedPassedDisaster:
                                      _hasLoadedPassedDisaster,
                                  onRetry: _loadPendingDisasters,
                                  onDisasterSelected: _onDisasterSelected,
                                  onClearPreloaded: _onClearPreloaded,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ExpandableCard(
                                title: 'Population Impact',
                                icon: Icons.people_outline,
                                expanded: _populationExpanded,
                                onToggle: () => setState(
                                  () => _populationExpanded =
                                      !_populationExpanded,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LabeledField(
                                            'Affected Population',
                                            _affectedPopController,
                                            '450000',
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: LabeledField(
                                            'Injured',
                                            _injuredController,
                                            '12000',
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
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
                                    LabeledField(
                                      'Duration (days)',
                                      _durationDaysController,
                                      '7',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ExpandableCard(
                                title: 'Housing Damage',
                                icon: Icons.home_outlined,
                                expanded: _housingExpanded,
                                onToggle: () => setState(
                                  () => _housingExpanded = !_housingExpanded,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LabeledField(
                                        'Houses Damaged',
                                        _housesDamagedController,
                                        '15000',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: LabeledField(
                                        'Houses Demolished',
                                        _housesDemolishedController,
                                        '3000',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_errorMessage != null)
                                ErrorBanner(_errorMessage!),
                              if (_savedResourceId != null)
                                SuccessBanner(
                                  'Resources saved  •  ID: ${_savedResourceId!.substring(0, 16)}…',
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isCalculating
                                      ? null
                                      : _calculateAndSave,
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
                                  child: _isCalculating
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.calculate_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Calculate & Save Resources',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_result != null)
                      ResourceResultsSection(result: _result!),
                    const SizedBox(height: 28),
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
}
