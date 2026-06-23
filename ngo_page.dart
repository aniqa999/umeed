import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'widgets/ngo_page_header.dart';
import 'widgets/area_coverage_card.dart';
import 'widgets/active_ngos_section.dart';

class NgoPage extends StatefulWidget {
  const NgoPage({super.key});

  @override
  State<NgoPage> createState() => _NgoPageState();
}

class _NgoPageState extends State<NgoPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedFilter = 'All';
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isLoading = true;
  List<Map<String, dynamic>> _ngos = [];
  List<Map<String, dynamic>> _areaCoverage = [];

  // Cache for calculated totals to avoid recalculation
  int _cachedTotalNgos = 0;
  int _cachedTotalBeneficiaries = 0;
  int _cachedTotalProjects = 0;

  static const _accent = Color(0xFF4A0D0D);

  final List<String> _filters = [
    'All',
    'Health',
    'Education',
    'WASH',
    'Relief',
    'Climate',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    _loadExcelData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _determineStatus(String endDate) {
    try {
      final format = DateFormat('M/d/yyyy');
      final parsedDate = format.parse(endDate);      

      if (parsedDate.isAfter(DateTime.now())) {
        return 'Active';
      } else {
        return 'Completed';
      }
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<void> _loadExcelData() async {
    try {
      final csvString = await rootBundle.loadString('/ngo_data_resave.csv');

      final csv = Csv();

      final List<List<dynamic>> rows = csv.decode(csvString);

      final List<Map<String, dynamic>> projects = [];
      final Map<String, Map<String, dynamic>> ngoMap = {};

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.isEmpty) continue;

        final projectData = {
          'sno': row[0]?.toString() ?? '',
          'donor': row[1]?.toString() ?? 'Unknown',
          'projectCode': row[2]?.toString() ?? '',
          'modality': row[3]?.toString() ?? '',
          'projectTitle': row[4]?.toString() ?? '',
          'projectOwner': row[5]?.toString() ?? '',
          'ownerType': row[6]?.toString() ?? '',
          'implementingPartner': row[7]?.toString() ?? '',
          'ipType': row[8]?.toString() ?? '',
          'sector': row[9]?.toString() ?? '',
          'activityDropdown': row[10]?.toString() ?? '',
          'activityReported': row[11]?.toString() ?? '',
          'activityDesc': row[12]?.toString() ?? '',
          'startDate': row[13]?.toString() ?? '',
          'endDate': row[14]?.toString() ?? '',
          'province': row[15]?.toString() ?? '',
          'district': row[16]?.toString() ?? '',
          'pcode': row[17]?.toString() ?? '',
          'x': row[18]?.toString() ?? '',
          'y': row[19]?.toString() ?? '',
          'tehsil': row[20]?.toString() ?? '',
          'unionCouncil': row[21]?.toString() ?? '',
          'village': row[22]?.toString() ?? '',
          'target': row[23]?.toString() ?? '0',
          'achieved': row[24]?.toString() ?? '0',
          'activityUnit': row[25]?.toString() ?? '',
          'women': int.tryParse(row[26]?.toString() ?? '0') ?? 0,
          'men': int.tryParse(row[27]?.toString() ?? '0') ?? 0,
          'boys': int.tryParse(row[28]?.toString() ?? '0') ?? 0,
          'girl': int.tryParse(row[29]?.toString() ?? '0') ?? 0,
          'children': int.tryParse(row[30]?.toString() ?? '0') ?? 0,
          'adult': int.tryParse(row[31]?.toString() ?? '0') ?? 0,
          'male': int.tryParse(row[32]?.toString() ?? '0') ?? 0,
          'female': int.tryParse(row[33]?.toString() ?? '0') ?? 0,
          'totalBeneficiaries': int.tryParse(row[34]?.toString() ?? '0') ?? 0,
        };

        projects.add(projectData);

        final ngoName = projectData['implementingPartner'] as String;
        final sector = projectData['sector'] as String;
        final province = projectData['province'] as String;
        final district = projectData['district'] as String;
        final totalBeneficiaries = projectData['totalBeneficiaries'] as int;

        if (ngoName.isNotEmpty && ngoName != 'Unknown') {
          if (!ngoMap.containsKey(ngoName)) {
            ngoMap[ngoName] = {
              'name': ngoName,
              'type': _determineNgoType(projectData['ipType'] as String),
              'status': _determineStatus(projectData['endDate'] as String),
              'areas': <String>{},
              'funding': _extractFunding(projectData['donor'] as String),
              'sector': sector,
              'totalBeneficiaries': 0,
              'projects': 0,
            };
          }

          final ngo = ngoMap[ngoName]!;

          ngo['areas'].add(province);

          if (district.isNotEmpty) {
            ngo['areas'].add(district);
          }

          ngo['totalBeneficiaries'] =
              (ngo['totalBeneficiaries'] as int) + totalBeneficiaries;

          ngo['projects'] = (ngo['projects'] as int) + 1;
        }
      }

      _ngos = ngoMap.values.map((ngo) {
        final Set<String> uniqueAreas = Set.from(ngo['areas']);

        return {
          'name': ngo['name'],
          'type': ngo['type'],
          'status': ngo['status'],
          'areas': uniqueAreas.take(3).toList(),
          'funding': ngo['funding'],
          'sector': ngo['sector'],
          'totalBeneficiaries': ngo['totalBeneficiaries'],
          'projects': ngo['projects'],
        };
      }).toList();

      _cachedTotalNgos = _ngos.length;

      _cachedTotalBeneficiaries = _ngos.fold<int>(
        0,
        (sum, ngo) => sum + (ngo['totalBeneficiaries'] as int),
      );

      _cachedTotalProjects = _ngos.fold<int>(
        0,
        (sum, ngo) => sum + (ngo['projects'] as int),
      );

      _calculateAreaCoverage(projects);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('CSV loading error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _loadMockData();
      }
    }
  }

  String _determineNgoType(String ipType) {
    if (ipType.contains('INGO')) return 'INGO';
    if (ipType.contains('Local')) return 'Local NGO';
    return 'NGO';
  }

  String _extractFunding(String donor) {
    if (donor.contains('USAID')) return 'USAID funded';
    if (donor.contains('UN')) return 'UN Agencies funded';
    if (donor.contains('FCDO')) return 'FCDO funded';
    if (donor.contains('EU')) return 'EU funded';
    if (donor.isEmpty || donor == 'Unknown') return 'Various donors';
    return donor;
  }

  void _calculateAreaCoverage(List<Map<String, dynamic>> projects) {
    final Map<String, int> areaCount = {};

    for (var project in projects) {
      final province = project['province'] as String;
      if (province.isNotEmpty && province != 'Unknown') {
        areaCount[province] = (areaCount[province] ?? 0) + 1;
      }
    }

    final total = areaCount.values.fold(0, (sum, count) => sum + count);
    final colors = [
      const Color(0xFFE74C3C),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFF607D8B),
    ];

    _areaCoverage =
        areaCount.entries.map((entry) {
            return {
              'city': entry.key,
              'count': entry.value,
              'fraction': total > 0 ? entry.value / total : 0,
              'color': colors[entry.key.hashCode % colors.length],
            };
          }).toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    if (_areaCoverage.length > 6) {
      _areaCoverage = _areaCoverage.sublist(0, 6);
    }
  }

  void _loadMockData() {
    _ngos = [
      {
        'name': 'HANDS Pakistan',
        'type': 'Local NGO · Health & Nutrition',
        'status': 'Active',
        'areas': ['Karachi', 'Hyderabad', 'Sukkur'],  
        'funding': 'PKR 2.4B funding',
        'sector': 'Health',
        'totalBeneficiaries': 1250000,
        'projects': 45,
      },
      {
        'name': 'Aga Khan Foundation',
        'type': 'INGO · Education · WASH',
        'status': 'Active',
        'areas': ['Gilgit-Baltistan', 'Chitral', 'Islamabad'],
        'funding': 'FCDO · EU funded',
        'sector': 'Education',
        'totalBeneficiaries': 890000,
        'projects': 32,
      },
      {
        'name': 'Edhi Foundation',
        'type': 'Local NGO · Emergency Relief',
        'status': 'Active',
        'areas': ['Karachi', 'Lahore', 'Quetta'],
        'funding': 'Nationwide',
        'sector': 'Relief',
        'totalBeneficiaries': 2500000,
        'projects': 60,
      },
      {
        'name': 'Save the Children',
        'type': 'INGO · Education · Health',
        'status': 'Review Pending',
        'areas': ['Peshawar', 'Mardan'],
        'funding': 'USAID funded',
        'sector': 'Education',
        'totalBeneficiaries': 450000,
        'projects': 18,
      },
      {
        'name': 'Oxfam Pakistan',
        'type': 'INGO · Climate · WASH',
        'status': 'Active',
        'areas': ['Sindh', 'Balochistan'],
        'funding': 'UN Agencies funded',
        'sector': 'Climate',
        'totalBeneficiaries': 680000,
        'projects': 24,
      },
      {
        'name': 'WWF Pakistan',
        'type': 'Local NGO · Climate & Environment',
        'status': 'Audit Due',
        'areas': ['Lahore', 'Islamabad', 'Thar'],
        'funding': 'Corporate CSR',
        'sector': 'Climate',
        'totalBeneficiaries': 320000,
        'projects': 15,
      },
      {
        'name': 'UNICEF Pakistan',
        'type': 'INGO · Health · WASH',
        'status': 'Active',
        'areas': ['Islamabad', 'Lahore', 'Karachi'],
        'funding': 'UN funded',
        'sector': 'Health',
        'totalBeneficiaries': 3100000,
        'projects': 78,
      },
      {
        'name': 'Developments in Literacy',
        'type': 'Local NGO · Education',
        'status': 'Active',
        'areas': ['Lahore', 'Faisalabad', 'Multan'],
        'funding': 'USAID · Private donors',
        'sector': 'Education',
        'totalBeneficiaries': 180000,
        'projects': 12,
      },
    ];

    // Calculate cached totals for mock data
    _cachedTotalNgos = _ngos.where((n) => n['status'] == 'Active').length;
    _cachedTotalBeneficiaries = _ngos.fold<int>(
      0,
      (sum, ngo) => sum + (ngo['totalBeneficiaries'] as int),
    );
    _cachedTotalProjects = _ngos.fold<int>(
      0,
      (sum, ngo) => sum + (ngo['projects'] as int),
    );

    _areaCoverage = [
      {
        'city': 'Karachi',
        'count': 1240,
        'fraction': 0.78,
        'color': const Color(0xFFE74C3C),
      },
      {
        'city': 'Lahore',
        'count': 980,
        'fraction': 0.63,
        'color': const Color(0xFFFF9800),
      },
      {
        'city': 'Islamabad',
        'count': 740,
        'fraction': 0.48,
        'color': const Color(0xFF9C27B0),
      },
      {
        'city': 'Peshawar',
        'count': 520,
        'fraction': 0.35,
        'color': const Color(0xFF2196F3),
      },
      {
        'city': 'Quetta',
        'count': 380,
        'fraction': 0.26,
        'color': const Color(0xFF4CAF50),
      },
      {
        'city': 'Other regions',
        'count': 340,
        'fraction': 0.22,
        'color': const Color(0xFF607D8B),
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredNgos => _selectedFilter == 'All'
      ? _ngos
      : _ngos
            .where((n) => (n['sector'] as String).contains(_selectedFilter))
            .toList();

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
        Navigator.pushReplacementNamed(context, '/predict');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      NgoPageHeader(
                        cachedTotalNgos: _cachedTotalNgos,
                        cachedTotalBeneficiaries: _cachedTotalBeneficiaries,
                        cachedTotalProjects: _cachedTotalProjects,
                        onBackPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              if (_areaCoverage.isNotEmpty)
                                AreaCoverageCard(
                                  areaCoverage: _areaCoverage,
                                ),
                              const SizedBox(height: 16),
                              ActiveNgosSection(
                                selectedFilter: _selectedFilter,
                                filters: _filters,
                                filteredNgos: _filteredNgos,
                                onFilterChanged: (filter) {
                                  setState(() => _selectedFilter = filter);
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

}
