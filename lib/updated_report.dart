import 'package:flutter/material.dart';
import 'widgets/app_footer.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 3;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> reports = [
    {
      'title': 'Flood Damage Assessment 2024',
      'subtitle': 'Sindh Region',
      'date': 'Oct 12, 2024',
      'badge': 'High Priority',
      'badgeColor': const Color(0xFFFF9800),
      'iconColor': const Color(0xFFE74C3C),
      'downloaded': true,
      'starred': true,
      'offline': true,
    },
    {
      'title': 'Daily Operations Summary: North Zone',
      'subtitle': 'KP Province',
      'date': 'Oct 11, 2024',
      'badge': 'Situation Report',
      'badgeColor': const Color(0xFF2196F3),
      'iconColor': const Color(0xFF2196F3),
      'downloaded': true,
      'starred': false,
      'offline': false,
      'fileSize': 'PDF (2MB)',
    },
    {
      'title': 'Medical Supplies Distribution Log',
      'subtitle': 'Balochistan',
      'date': 'Oct 10, 2024',
      'badge': 'Resource Audit',
      'badgeColor': const Color(0xFF9C27B0),
      'iconColor': const Color(0xFF9C27B0),
      'downloaded': false,
      'starred': false,
      'offline': false,
      'fileSize': 'PDF (850KB)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFooterTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/predict');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/resources');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  List<Map<String, dynamic>> _filteredReports(String type) {
    return reports.where((r) {
      final searchMatch =
          r['title'].toLowerCase().contains(_searchQuery.toLowerCase());

      if (type == 'downloaded') {
        return r['downloaded'] && searchMatch;
      } else if (type == 'starred') {
        return r['starred'] && searchMatch;
      }
      return searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 12),

            _buildTabBar(),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReportList('recent'),
                  _buildReportList('downloaded'),
                  _buildReportList('starred'),
                ],
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

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A0D0D), Color(0xFF7A1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Operational Forecasting & Risk Intelligence',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search reports...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= TAB BAR =================

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Recent'),
          Tab(text: 'Downloaded'),
          Tab(text: 'Starred'),
        ],
      ),
    );
  }

  // ================= REPORT LIST =================

  Widget _buildReportList(String type) {
    final data = _filteredReports(type);

    if (data.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final r = data[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReportCard(r),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No reports found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ================= CARD =================

  Widget _buildReportCard(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: r['iconColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: r['iconColor'],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r['badgeColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  r['badge'],
                  style: TextStyle(
                    fontSize: 10,
                    color: r['badgeColor'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r['title'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${r['subtitle']} • ${r['date']}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (r['offline'] == true)
                const Text(
                  'Available Offline',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                )
              else if (r['fileSize'] != null)
                Text(
                  r['fileSize'],
                  style: const TextStyle(color: Colors.grey),
                ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A0D0D),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
