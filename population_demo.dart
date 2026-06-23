import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/population_header.dart';
import 'widgets/population_map_section.dart';
import 'widgets/gender_distribution_card.dart';
import 'widgets/age_structure_card.dart';
import 'widgets/socio_economic_card.dart';
import 'widgets/population_stats_card.dart';
import 'widgets/additional_stats_card.dart';
import 'widgets/lifestyle_vitals_card.dart';

class WorldBankService {
  static const String baseUrl =
      'https://api.worldbank.org/v2/country/PK/indicator/SP.POP.TOTL?format=json';

  Future<Map<String, dynamic>> fetchPopulationData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // data[0] contains metadata, data[1] contains the actual values
        final List<dynamic> populationList = data[1];

        // Filter out null values and map to a usable format
        List<Map<String, dynamic>> validEntries = [];
        for (var item in populationList) {
          if (item['value'] != null && item['value'].toString().isNotEmpty) {
            validEntries.add({
              'date': int.parse(item['date']),
              'value': int.parse(item['value'].toString().replaceAll(',', '')),
            });
          }
        }

        // Sort by date (oldest to newest)
        validEntries.sort((a, b) => a['date'].compareTo(b['date']));

        // Get the latest 10 years for trend analysis
        List<Map<String, dynamic>> recentYears = validEntries.length > 10
            ? validEntries.sublist(validEntries.length - 10)
            : validEntries;

        // Calculate growth rates
        Map<int, double> growthRates = {};
        for (int i = 1; i < validEntries.length; i++) {
          int prevYear = validEntries[i - 1]['date'];
          int currYear = validEntries[i]['date'];
          int prevValue = validEntries[i - 1]['value'];
          int currValue = validEntries[i]['value'];
          if (prevValue > 0) {
            growthRates[currYear] = ((currValue - prevValue) / prevValue * 100);
          }
        }

        return {
          'currentPopulation': validEntries.isNotEmpty
              ? validEntries.last['value']
              : 255200000,
          'currentYear': validEntries.isNotEmpty
              ? validEntries.last['date']
              : 2024,
          'populationHistory': validEntries,
          'recentYears': recentYears,
          'growthRates': growthRates,
          'latestGrowthRate': growthRates.isNotEmpty
              ? growthRates[validEntries.last['date']] ?? 2.23
              : 2.23,
        };
      } else {
        print('API Error: ${response.statusCode}');
        return _getFallbackData();
      }
    } catch (e) {
      print('Exception fetching population data: $e');
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    // Fallback data in case API fails
    return {
      'currentPopulation': 255200000,
      'currentYear': 2024,
      'populationHistory': [],
      'recentYears': [],
      'growthRates': {},
      'latestGrowthRate': 2.23,
    };
  }
}

class PopulationDemoGraphics extends StatefulWidget {
  const PopulationDemoGraphics({super.key});

  @override
  State<PopulationDemoGraphics> createState() => _PopulationDemoGraphicsState();
}

class _PopulationDemoGraphicsState extends State<PopulationDemoGraphics>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex =
      0; // 0: Overview, 1: Health Sector, 2: Education, 3: Labor Force

  // Population data from API
  Map<String, dynamic> _populationData = {};
  bool _isLoadingData = true;
  String _errorMessage = '';

  // Derived statistics
  int _totalPopulation = 0;
  int _currentYear = 0;
  double _growthRate = 0.0;
  int _malePopulation = 0;
  int _femalePopulation = 0;

  // Age distribution (percentages based on UN data for Pakistan)
  final Map<String, double> _ageDistribution = {
    '0-14': 37.0,
    '15-64': 58.0,
    '65+': 4.0,
  };

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _mapAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _genderBarAnimationController;
  late AnimationController _ageBarAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _mapFadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPopulationData();

    // Header animations
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

    // Map animations
    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _mapFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mapAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Stats animations
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Gender bar animation
    _genderBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Age bar animation
    _ageBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _mapAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _genderBarAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _ageBarAnimationController.forward();
    });
  }

  Future<void> _loadPopulationData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = '';
    });

    final service = WorldBankService();
    final data = await service.fetchPopulationData();

    setState(() {
      _populationData = data;
      _totalPopulation = data['currentPopulation'] ?? 0;
      _currentYear = data['currentYear'] ?? 2024;
      _growthRate = data['latestGrowthRate'] ?? 2.23;

      // Calculate gender distribution based on sex ratio 102.7 (men per 100 women)
      // Total = Male + Female, where Male = 1.027 * Female
      // So Total = 2.027 * Female => Female = Total / 2.027
      if (_totalPopulation > 0) {
        _femalePopulation = (_totalPopulation / 2.027).round();
        _malePopulation = _totalPopulation - _femalePopulation;
      } else {
        _malePopulation = 129300000;
        _femalePopulation = 125900000;
      }

      _isLoadingData = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _mapAnimationController.dispose();
    _statsAnimationController.dispose();
    _genderBarAnimationController.dispose();
    _ageBarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: PopulationHeader(currentYear: _currentYear),
              ),
            ),
            Expanded(
              child: _isLoadingData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF4A0D0D),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading population data from World Bank...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _mapFadeAnimation,
                            child: const PopulationMapSection(),
                          ),
                          GenderDistributionCard(
                            malePopulation: _malePopulation,
                            femalePopulation: _femalePopulation,
                            totalPopulation: _totalPopulation,
                            animationController: _genderBarAnimationController,
                          ),
                          const SizedBox(height: 12),
                          AgeStructureCard(
                            totalPopulation: _totalPopulation,
                            ageDistribution: _ageDistribution,
                            animationController: _ageBarAnimationController,
                          ),
                          const SizedBox(height: 12),
                          SocioEconomicCard(
                            selectedTabIndex: _selectedTabIndex,
                            onTabChanged: (index) {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          PopulationStatsCard(
                            totalPopulation: _totalPopulation,
                            growthRate: _growthRate,
                          ),
                          const SizedBox(height: 12),
                          const AdditionalStatsCard(),
                          const SizedBox(height: 12),
                          const LifestyleVitalsCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: AppFooter(
      //   currentIndex: _currentIndex,
      //   onTap: _onFooterTap,
      // ),
    );
  }
}
