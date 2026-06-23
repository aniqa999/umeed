import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umeed_v0/screens/auth/reset_password.dart';
import '../../widgets/app_footer.dart';
import '../../../utils/authService.dart';
import 'user_details.dart';
import 'widgets/profile/section_card.dart';
import 'widgets/profile/profile_info_row.dart';
import 'widgets/profile/profile_section_header.dart';
import 'widgets/profile/reset_password_button.dart';
import 'widgets/profile/activity_row.dart';
import 'model/activity_item.dart';
import 'widgets/profile/settings_row.dart';
import 'widgets/profile/logout_button.dart';
import 'widgets/profile/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.profileImageAsset});

  static const String routeName = '/profile';
  final String? profileImageAsset;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _headerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _avatarCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _cardsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _headerFade = CurvedAnimation(
    parent: _headerCtrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _headerSlide = Tween<Offset>(
    begin: const Offset(0, -0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

  late final Animation<double> _avatarScale = Tween<double>(
    begin: 0.7,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
  late final Animation<double> _avatarFade = CurvedAnimation(
    parent: _avatarCtrl,
    curve: Curves.easeOut,
  );

  // ── State ─────────────────────────────────────────────────────────────────
  bool _twoFactorEnabled = true;
  Map<String, dynamic> _user = {};

  int get _currentFooterIndex => 5;

  String get _userName =>
      _user['name'] ??
      _user['fullName'] ??
      _user['username'] ??
      'NDMA Official';
  String get _userEmail => _user['email'] ?? '';
  String get _userRole =>
      _user['role'] ?? _user['designation'] ?? 'Director Operations';
  String get _userDesignation => _user['designation'] ?? "Representative";
  String get _userDepartment =>
      _user['department'] ??
      _user['authority'] ??
      'Federal Authority • National';
  String get _userId =>
      _user['employeeId'] ?? _user['id']?.toString() ?? 'NDMA-HQ-0000';

  String get _userDistrict => _user['district'] ?? "Unknown";

  String get _userProvince => _user['province'] ?? "Unknown";

  String get _userLocation => '${_userDistrict}, ${_userProvince}';

  bool get _isGovernment =>
      (_user['role'] ?? '').toString().toLowerCase() == 'government';

  String get _userImage => _user['profileImage'] ?? '';

  List<ActivityItem> _activity = [];
  bool _isLoadingActivities = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchRecentActivities();
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _avatarCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _user = args;
    } else {
      _user = AuthService.instance.user ?? {};
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _avatarCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _staggered(Widget child, {double begin = 0.0, double end = 1.0}) {
    final interval = CurvedAnimation(
      parent: _cardsCtrl,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: interval,
      builder: (context, ch) => Opacity(
        opacity: interval.value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - interval.value)),
          child: ch,
        ),
      ),
      child: child,
    );
  }

  Future<void> _fetchRecentActivities() async {
    try {
      final token = await AuthService.instance.secureStorage.read(
        key: 'auth_token',
      );

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/users/recent-activities'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _activity = (data['data'] as List).map((item) {
              return ActivityItem(
                title: item['title'] ?? 'No description',
                subtitle: item['subtitle'] ?? 'Unknown time',
                emphasis: item['emphasis'] ?? false,
                category: item['category'] ?? 'general',
                action: item['action'] ?? 'Unknown action',
              );
            }).toList();
            _isLoadingActivities = false;
          });
        }
      } else {
        _showErrorSnackbar('Failed to load activities');
        _setDefaultActivity();
      }
    } catch (e) {
      print('Error fetching activities: $e');
      _setDefaultActivity();
    }
  }

  void _setDefaultActivity() {
    setState(() {
      _activity = [
        const ActivityItem(
          title: 'No recent activity',
          subtitle: 'Start using the app to see activity here',
          emphasis: false,
          category: "general",
          action: "None",
        ),
      ];
      _isLoadingActivities = false;
    });
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _openUserDetail() {
    print(_userImage);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => UserDetailPage(initialUser: _user),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        settings: const RouteSettings(name: '/me'),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final t = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return Transform.scale(
          scale: lerpDouble(0.96, 1.0, t.value)!,
          child: Opacity(
            opacity: t.value,
            child: Center(
              child: LogoutDialog(
                title: 'Confirm logout',
                message: 'Are you sure you want to securely log out?',
                primaryText: 'Logout',
                secondaryText: 'Cancel',
                onPrimary: () => Navigator.of(context).pop(true),
                onSecondary: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (result == true) {
      AuthService.instance.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1200),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  // ── Footer tap ───────────────────────────────────────────────────────────
  void _onFooterTap(int index) {
    if (index == _currentFooterIndex) return; // already on Profile
    // 0=Home 1=Weather 2=Predict 3=Resources 4=Reports 5=Profile
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushReplacementNamed('/dashboard', arguments: _user);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/weather');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/predict');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/resource-calculation');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/reports');
        break;
      case 5:
        break; // already on Profile
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Header background
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: FadeTransition(
              opacity: _headerFade,
              child: Container(
                height: 320,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C1919), Color(0xFF3D0F0F)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      child: SizedBox(height: 50),                     
                    ),
                  ),
                ),

                // Avatar
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: ScaleTransition(
                      scale: _avatarScale,
                      child: FadeTransition(
                        opacity: _avatarFade,
                        child: GestureDetector(
                          onTap: _openUserDetail,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20, bottom: 16),
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: (_userImage != '')
                                  ? Image.network(
                                      _userImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color(0xFF9A9A9A),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFFE8E8E8),
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color(0xFF9A9A9A),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // User Info
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _userRole.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userDepartment,
                          style: const TextStyle(
                            color: Color(0xFFE8D4D4),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        // ── Account Info card (new) ──────────────────────────
                        _staggered(
                          begin: 0.05,
                          end: 0.35,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProfileSectionHeader(
                                  icon: Icons.badge_outlined,
                                  title: 'ACCOUNT INFO',
                                ),
                                const SizedBox(height: 12),
                                SectionCard(
                                  children: [
                                    ProfileInfoRow(
                                      label: 'Email',
                                      value: _userEmail.isNotEmpty
                                          ? _userEmail
                                          : 'Not set',
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFF0F0F0),
                                      indent: 18,
                                      endIndent: 18,
                                    ),
                                    ProfileInfoRow(
                                      label: 'Location',
                                      value: _userLocation,
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFF0F0F0),
                                      indent: 18,
                                      endIndent: 18,
                                    ),
                                    ProfileInfoRow(
                                      label: 'Designation',
                                      value: _userDesignation,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Security ─────────────────────────────────────────
                        _staggered(
                          begin: 0.18,
                          end: 0.58,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProfileSectionHeader(
                                  icon: Icons.lock_outline,
                                  title: 'SECURITY',
                                ),
                                const SizedBox(height: 12),
                                SectionCard(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Password',
                                                  style: TextStyle(
                                                    color: Color(0xFF2A2323),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  'Last changed 30 days ago',
                                                  style: TextStyle(
                                                    color: Color(0xFF9B8F8F),
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ResetPasswordButton(
                                            onTap: () => {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const ResetPasswordPage(),
                                                ),
                                              ),
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Settings ──────────────────────────────────────────
                        _staggered(
                          begin: 0.46,
                          end: 0.86,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionCard(
                              children: const [
                                SettingsRow(
                                  label: 'Language',
                                  value: 'English',
                                  showChevron: false,
                                ),
                                Divider(
                                  height: 1,
                                  color: Color(0xFFF0F0F0),
                                  indent: 18,
                                  endIndent: 18,
                                ),
                                // _SettingsRow(
                                //   label: 'Notifications',
                                //   value: '',
                                //   showChevron: true,
                                // ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Recent Activity ───────────────────────────────────
                        _staggered(
                          begin: 0.32,
                          end: 0.72,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProfileSectionHeader(
                                  icon: Icons.history,
                                  title: 'RECENT ACTIVITY',
                                ),
                                const SizedBox(height: 12),
                                SectionCard(
                                  children: [
                                    if (_isLoadingActivities)
                                      const Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF5C1919),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else if (_activity.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No recent activity',
                                            style: TextStyle(
                                              color: Color(0xFF9B8F8F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      for (
                                        int i = 0;
                                        i < _activity.length;
                                        i++
                                      ) ...[
                                        ActivityRow(item: _activity[i]),
                                        if (i != _activity.length - 1)
                                          const Divider(
                                            height: 1,
                                            color: Color(0xFFF0F0F0),
                                            indent: 18,
                                            endIndent: 18,
                                          ),
                                      ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // const SizedBox(height: 18),

                        // ── Logout ────────────────────────────────────────────
                        _staggered(
                          begin: 0.58,
                          end: 1.0,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: LogoutButton(onTap: _confirmLogout),
                          ),
                        ),

                        const SizedBox(height: 18),

                        _staggered(
                          begin: 0.65,
                          end: 1.0,
                          const Center(
                            child: Text(
                              'App Version 4.2.0 • Secured by NADRA',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentFooterIndex,
        onTap: _onFooterTap,
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.93 : 1.0,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

