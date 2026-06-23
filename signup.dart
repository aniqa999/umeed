import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umeed_v0/screens/auth/widgets/app_branding.dart';
import 'dart:convert';

import 'package:umeed_v0/screens/auth/widgets/app_snackbar.dart';
import 'package:umeed_v0/screens/auth/widgets/gradient_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 – Account + Basic Info
  String? _selectedRole;
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Step 2 – Official Details
  final _organizationCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  // Step 3 – Location
  String? _selectedProvince;
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  // Step 4 – Contact & Verification
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isLoading = false;

  static const _provinces = [
    'Punjab',
    'Sindh',
    'KPK',
    'Balochistan',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];

  static const _cardTitles = [
    'Your Account',
    'Official Details',
    'Location',
    'Contact & Verification',
  ];

  static const _cardSubtitles = [
    'Select your role and enter your credentials',
    'Your organisation and professional information',
    'The province or region you operate in',
    'Your phone number and national ID',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _organizationCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    _websiteCtrl.dispose();
    _experienceCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();    
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedRole == null) {
          AppSnackBar.show(
            context,
            'Please select your account type.',
            isError: true,
          );
          return false;
        }
        if (_fullNameCtrl.text.trim().isEmpty) {
          AppSnackBar.show(
            context,
            'Please enter your full name.',
            isError: true,
          );
          return false;
        }
        final email = _emailCtrl.text.trim();
        if (email.isEmpty) {
          AppSnackBar.show(
            context,
            'Please enter your email address.',
            isError: true,
          );
          return false;
        }
        if (!RegExp(
          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email)) {
          AppSnackBar.show(
            context,
            'Please enter a valid email address.',
            isError: true,
          );
          return false;
        }
        if (_selectedRole == 'government' && !email.endsWith('.gov.pk')) {
          AppSnackBar.show(
            context,
            'Government officials must use an official government email (e.g. officer@ndma.gov.pk).',
            isError: true,
          );
          return false;
        }
        final pw = _passwordCtrl.text;
        if (pw.length < 8) {
          AppSnackBar.show(
            context,
            'Password must be at least 8 characters.',
            isError: true,
          );
          return false;
        }
        if (!pw.contains(RegExp(r'[A-Z]')) ||
            !pw.contains(RegExp(r'[a-z]')) ||
            !pw.contains(RegExp(r'[0-9]')) ||
            !pw.contains(
              RegExp(r'''[!@#$%^&*()\-_=+\[\]{};:'",.<>/?\\|`~]'''),
            )) {
          AppSnackBar.show(
            context,
            'Password must contain uppercase, lowercase, a number, and a special character.',
            isError: true,
          );
          return false;
        }
        return true;

      case 1:
        if (_organizationCtrl.text.trim().isEmpty) {
          AppSnackBar.show(context, 'Organization is required.', isError: true);
          return false;
        }
        final site = _websiteCtrl.text.trim();
        if (site.isNotEmpty &&
            !site.startsWith('http://') &&
            !site.startsWith('https://')) {
          AppSnackBar.show(
            context,
            'Website link must start with http:// or https://',
            isError: true,
          );
          return false;
        }
        return true;

      case 2:
        if (_selectedProvince == null) {
          AppSnackBar.show(context, 'Province is required.', isError: true);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goNext() {
    if (!_validateCurrentStep()) return;
    if (_currentStep == _totalSteps - 1) {
      _handleSignup();
      return;
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ── Signup API call ───────────────────────────────────────────────────────

  Future<void> _handleSignup() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      AppSnackBar.show(context, 'Contact number is required.', isError: true);
      return;
    }
    final cnic = _cnicCtrl.text.trim();
    if (cnic.isEmpty) {
      AppSnackBar.show(context, 'CNIC / ID number is required.', isError: true);
      return;
    }
    if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(cnic)) {
      AppSnackBar.show(
        context,
        'CNIC must be in the format XXXXX-XXXXXXX-X.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);    

    if (!mounted) return;

    try {
      final body = <String, dynamic>{
        'role': _selectedRole,
        'fullName': _fullNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'organization': _organizationCtrl.text.trim(),
        if (_designationCtrl.text.trim().isNotEmpty)
          'designation': _designationCtrl.text.trim(),
        if (_departmentCtrl.text.trim().isNotEmpty)
          'department': _departmentCtrl.text.trim(),
        if (_websiteCtrl.text.trim().isNotEmpty)
          'websiteLink': _websiteCtrl.text.trim(),
        if (_experienceCtrl.text.trim().isNotEmpty)
          'experience': _experienceCtrl.text.trim(),
        'province': _selectedProvince,
        if (_districtCtrl.text.trim().isNotEmpty)
          'district': _districtCtrl.text.trim(),
        if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
        if (_areaCtrl.text.trim().isNotEmpty) 'area': _areaCtrl.text.trim(),
        if (_addressCtrl.text.trim().isNotEmpty)
          'currentAddress': _addressCtrl.text.trim(),
        'phone': phone,
        'cnic': cnic,
      };

      if (!mounted) return;

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/pending-approval');
      } else {
        AppSnackBar.show(
          context,
          data['message'] ?? 'Signup failed. Please try again.',
          isError: true,
        );
      }
    } catch (_) {
      AppSnackBar.show(context, 'Connection failed. Check your network.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            AppBranding(subtitle: 'Request Official Access'),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepCard(index: 0, child: _buildStep1Content()),
                  _buildStepCard(index: 1, child: _buildStep2Content()),
                  _buildStepCard(index: 2, child: _buildStep3Content()),
                  _buildStepCard(index: 3, child: _buildStep4Content()),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // ── Step card wrapper ─────────────────────────────────────────────────────
  Widget _buildStepCard({required int index, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card heading with red accent bar
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A1C1C),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _cardTitles[index],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C0A0A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: Text(
                    _cardSubtitles[index],
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 22),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: Account Type + Basic Info ────────────────────────────────────

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Account Type *'),
        const SizedBox(height: 10),
        _buildRoleSelector(),
        const SizedBox(height: 20),
        _buildSectionDivider('CREDENTIALS'),
        const SizedBox(height: 18),
        _label('Full Name *'),
        const SizedBox(height: 8),
        _field(
          ctrl: _fullNameCtrl,
          hint: 'e.g. Ahmed Raza Khan',
          icon: Icons.person_outline_rounded,
          type: TextInputType.name,
        ),
        const SizedBox(height: 16),
        _label('Official Email *'),
        const SizedBox(height: 8),
        _field(
          ctrl: _emailCtrl,
          hint: _selectedRole == 'government'
              ? 'officer@ndma.gov.pk'
              : 'e.g. sara@edhi.org',
          icon: Icons.alternate_email_rounded,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _label('Password *'),
        const SizedBox(height: 8),
        _passwordField(),
        const SizedBox(height: 5),
        Text(
          'Min 8 chars · uppercase · lowercase · number · special character',
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey[400],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      {'value': 'government', 'label': 'Government Official', 'icon': '🏛️'},
      {'value': 'ngo', 'label': 'NGO Representative', 'icon': '🤝'},
    ];
    return Row(
      children: roles.map((role) {
        final isSelected = _selectedRole == role['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = role['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: role['value'] == 'government' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7A1C1C).withValues(alpha: 0.08)
                    : const Color(0xFFF8F7F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7A1C1C)
                      : const Color(0xFFEAE8E4),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(role['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    role['label']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF7A1C1C)
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A1C1C),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 2: Official Details ──────────────────────────────────────────────

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Organization *'),
        const SizedBox(height: 8),
        _field(
          ctrl: _organizationCtrl,
          hint: _selectedRole == 'government'
              ? 'e.g. NDMA, Provincial PDMA'
              : 'e.g. Edhi Foundation, IRC',
          icon: Icons.domain_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Designation'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _designationCtrl,
                    hint: 'e.g. Field Manager',
                    icon: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Department'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _departmentCtrl,
                    hint: 'e.g. Operations',
                    icon: Icons.business_outlined,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Website'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _websiteCtrl,
                    hint: 'https://...',
                    icon: Icons.link_rounded,
                    type: TextInputType.url,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Experience'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _experienceCtrl,
                    hint: 'e.g. 3-5 years',
                    icon: Icons.timeline_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Location ──────────────────────────────────────────────────────

  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEEA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDD9D4)),
          ),
          child: Row(
            children: [
              const Text('🇵🇰', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text(
                'Country: Pakistan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const Spacer(),
              Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _label('Province *'),
        const SizedBox(height: 8),
        _provinceDropdown(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('District'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _districtCtrl,
                    hint: 'e.g. South',
                    icon: Icons.location_city_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('City'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _cityCtrl,
                    hint: 'e.g. Karachi',
                    icon: Icons.apartment_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label('Area / Locality'),
        const SizedBox(height: 8),
        _field(
          ctrl: _areaCtrl,
          hint: 'e.g. Clifton, Block 4',
          icon: Icons.place_outlined,
        ),
      ],
    );
  }

  // ── Step 4: Contact & Verification ───────────────────────────────────────

  Widget _buildStep4Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Phone Number *'),
        const SizedBox(height: 8),
        _field(
          ctrl: _phoneCtrl,
          hint: '+92 300 1234567',
          icon: Icons.phone_outlined,
          type: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _label('CNIC / National ID *'),
        const SizedBox(height: 8),
        _field(
          ctrl: _cnicCtrl,
          hint: 'XXXXX-XXXXXXX-X',
          icon: Icons.credit_card_outlined,
          type: TextInputType.number,
        ),
        const SizedBox(height: 5),
        Text(
          'Format: 42101-1234567-9',
          style: TextStyle(fontSize: 10.5, color: Colors.grey[400]),
        ),
        const SizedBox(height: 16),
        _label('Current Address'),
        const SizedBox(height: 8),
        _field(
          ctrl: _addressCtrl,
          hint: 'Block 4, Clifton, Karachi',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 20),
        _buildNotice(),
      ],
    );
  }

  // ── Bottom section ────────────────────────────────────────────────────────

  Widget _buildBottomSection() {
    final isLast = _currentStep == _totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          GradientButton(
            text: isLast ? 'Submit Request' : 'Continue',
            icon: isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onTap: _goNext,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A1C1C), Color(0xFF4A0D0D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A1C1C).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2C3E50),
      letterSpacing: 0.2,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? type,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE8E4), width: 1),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB8B5B0), fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFFB8B5B0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE8E4), width: 1),
      ),
      child: TextField(
        controller: _passwordCtrl,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: Color(0xFFB8B5B0), fontSize: 15),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Color(0xFFB8B5B0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFB8B5B0),
              size: 19,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _provinceDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE8E4), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _selectedProvince,
            isExpanded: true,
            icon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFB8B5B0),
                size: 22,
              ),
            ),
            hint: Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: Color(0xFFB8B5B0),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select province (required)',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: _provinces
                .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => _selectedProvince = val),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFEEECE8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFEEECE8))),
      ],
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A0D0D).withValues(alpha: 0.05),
        border: Border.all(
          color: const Color(0xFF4A0D0D).withValues(alpha: 0.15),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xFF7A1C1C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Access requests are reviewed by system admins. You will be notified once your account is approved.',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4A0D0D).withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
