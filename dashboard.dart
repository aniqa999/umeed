import 'dart:convert';
import '../../utils/authService.dart';
import '../../widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umeed_v0/screens/dashboard/widgets/action_grid.dart';
import 'package:umeed_v0/screens/dashboard/widgets/dashboard_map.dart';
import 'package:umeed_v0/screens/dashboard/widgets/section_label.dart';
import 'package:umeed_v0/screens/dashboard/widgets/dashboard_header.dart';
import 'package:umeed_v0/screens/dashboard/widgets/active_event_card.dart';
import 'package:umeed_v0/screens/dashboard/widgets/dashboard_stats_banner.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  Map<String, dynamic> _user = {};

  // Stats
  int _disasterCount = 0;
  int _resourceCount = 0;
  bool _statsLoading = true;

  // Most recent disaster
  Map<String, dynamic>? _latestDisaster;
  bool _disasterLoading = true;

  static const String _baseUrl = 'http://localhost:8080';
  String? token;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _user = args;
    } else {
      _user = AuthService.instance.user ?? {};
    }
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadToken();
    if (token != null) {
      await Future.wait([_fetchStats(), _fetchLatestDisaster()]);
    } else {
      if (mounted) {
        setState(() {
          _statsLoading = false;
          _disasterLoading = false;
        });
      }
    }
  }

  Future<void> _loadToken() async {
    final String? savedToken = await _secureStorage.read(key: 'auth_token');
    token = savedToken;
  }

  String get _userName =>
      _user['fullName'] ?? _user['name'] ?? _user['username'] ?? 'Officer';

  // String? token = await _secureStorage.read(key: 'auth_token');

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> _fetchStats() async {
    try {      
      final results = await Future.wait([
        http.get(
          Uri.parse('$_baseUrl/api/disasters/my-disaster'),
          headers: _headers,
        ),
        http.get(Uri.parse('$_baseUrl/api/resources/my'), headers: _headers),
      ]);

      int disasters = 0;
      int resources = 0;

      final dRes = results[0];
      if (dRes.statusCode == 200) {
        final body = jsonDecode(dRes.body);
        disasters = (body['disasterCount'] ?? 0) as int;
      }

      final rRes = results[1];
      if (rRes.statusCode == 200) {
        final body = jsonDecode(rRes.body);
        resources = (body['resources'] ?? 0) as int;
      }

      if (mounted) {
        setState(() {
          _disasterCount = disasters;
          _resourceCount = resources;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _fetchLatestDisaster() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/disasters?limit=1&sort=createdAt'),
        headers: _headers,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? [];
        if (mounted) {
          setState(() {
            _latestDisaster = data.isNotEmpty
                ? Map<String, dynamic>.from(data.first)
                : null;
            _disasterLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _disasterLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _disasterLoading = false);
    }
  }

  void _onFooterTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/weather');
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
        Navigator.pushReplacementNamed(context, '/profile', arguments: _user);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(userName: _userName),
                const SizedBox(height: 10),
                 const SectionLabel(text: 'VISUALIZATION'),
                const SizedBox(height: 10),
                ActionGrid(),
                const SizedBox(height: 16),
                DashboardStatsBanner(
                  isLoading: _statsLoading,
                  disasterCount: _disasterCount,
                  resourceCount: _resourceCount,
                ),
                const SizedBox(height: 16),
                ActiveEventCard(
                  isLoading: _disasterLoading,
                  disasterCount: _disasterCount,
                  latestDisaster: _latestDisaster,
                ),
                const SizedBox(height: 16),
                 const SectionLabel(text: 'VISUALIZATION'),
                const SizedBox(height: 10),
                const DashboardMap(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTap,
      ),
    );
  }

}
