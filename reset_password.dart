import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umeed_v0/screens/auth/widgets/gradient_button.dart';
import '../../../utils/authService.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  static const String routeName = '/reset-password';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _headerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _cardsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final Animation<double> _headerFade = CurvedAnimation(
    parent: _headerCtrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _headerSlide = Tween<Offset>(
    begin: const Offset(0, -0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

  // ── State ─────────────────────────────────────────────────────────────────
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Password strength
  double get _passwordStrength {
    final p = _newPasswordCtrl.text;
    if (p.isEmpty) return 0;
    double strength = 0;
    if (p.length >= 8) strength += 0.25;
    if (p.length >= 12) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) strength += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) strength += 0.2;
    return strength.clamp(0, 1);
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s < 0.4) return const Color(0xFFE53935);
    if (s < 0.7) return const Color(0xFFFB8C00);
    return const Color(0xFF388E3C);
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0) return '';
    if (s < 0.4) return 'Weak';
    if (s < 0.7) return 'Fair';
    return 'Strong';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _cardsCtrl.forward();
    });
    _newPasswordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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

  // ── API call ──────────────────────────────────────────────────────────────
  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final response = await http.patch(
        Uri.parse('http://localhost:8080/api/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': _currentPasswordCtrl.text.trim(),
          'newPassword': _newPasswordCtrl.text.trim(),
          'confirmPassword': _confirmPasswordCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _successMessage = 'Password reset successfully.';
          _isLoading = false;
        });
        _currentPasswordCtrl.text = '';
        _newPasswordCtrl.text = '';
        _confirmPasswordCtrl.text = '';

        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to reset password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Styled Header ────────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 44), // Spacer for balance
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a strong password to secure your account',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable form ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info banner ──────────────────────────────────
                    _staggered(begin: 0.0, end: 0.3, _InfoBanner()),

                    const SizedBox(height: 22),

                    // ── Password fields card ─────────────────────────
                    _staggered(
                      begin: 0.1,
                      end: 0.55,
                      _SectionCard(
                        children: [
                          // Current Password
                          _PasswordField(
                            controller: _currentPasswordCtrl,
                            label: 'Current Password',
                            hint: 'Enter your current password',
                            isVisible: _showCurrent,
                            onToggle: () =>
                                setState(() => _showCurrent = !_showCurrent),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Current password is required';
                              }
                              return null;
                            },
                            isFirst: true,
                          ),
                          const _FieldDivider(),

                          // New Password
                          _PasswordField(
                            controller: _newPasswordCtrl,
                            label: 'New Password',
                            hint: 'Min. 8 characters',
                            isVisible: _showNew,
                            onToggle: () =>
                                setState(() => _showNew = !_showNew),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'New password is required';
                              }
                              if (v.length < 8) {
                                return 'Must be at least 8 characters';
                              }
                              if (v == _currentPasswordCtrl.text) {
                                return 'New password must differ from current';
                              }
                              return null;
                            },
                          ),

                          // Strength indicator
                          if (_newPasswordCtrl.text.isNotEmpty)
                            _PasswordStrengthBar(
                              strength: _passwordStrength,
                              color: _strengthColor,
                              label: _strengthLabel,
                            ),

                          const _FieldDivider(),

                          // Confirm Password
                          _PasswordField(
                            controller: _confirmPasswordCtrl,
                            label: 'Confirm New Password',
                            hint: 'Re-enter your new password',
                            isVisible: _showConfirm,
                            onToggle: () =>
                                setState(() => _showConfirm = !_showConfirm),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _newPasswordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Error / Success messages ─────────────────────
                    if (_errorMessage != null)
                      _staggered(
                        begin: 0.0,
                        end: 0.4,
                        _StatusMessage(message: _errorMessage!, isError: true),
                      ),

                    if (_successMessage != null)
                      _staggered(
                        begin: 0.0,
                        end: 0.4,
                        _StatusMessage(
                          message: _successMessage!,
                          isError: false,
                        ),
                      ),

                    if (_errorMessage != null || _successMessage != null)
                      const SizedBox(height: 14),

                    // ── Submit button ────────────────────────────────
                    _staggered(
                      begin: 0.3,
                      end: 0.75,
                      GradientButton(
                        text: 'Reset Password',
                        icon: Icons.lock_reset_rounded,
                        isLoading: _isLoading,
                        onTap: _submitResetPassword,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Requirements ─────────────────────────────────
                    _staggered(
                      begin: 0.5,
                      end: 1.0,
                      const _PasswordRequirements(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D0D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF5C1919).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: Color(0xFF5C1919),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Choose a strong password you haven\'t used before. This will log you out of all active sessions.',
              style: TextStyle(
                color: Color(0xFF6A5050),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Color(0xFFF0F0F0),
      indent: 18,
      endIndent: 18,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isVisible,
    required this.onToggle,
    required this.validator,
    this.isFirst = false,
    this.isLast = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        style: const TextStyle(
          color: Color(0xFF2A2323),
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF9B8F8F),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: Color(0xFFCCC4C4), fontSize: 13.5),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFB7AFAF),
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.strength,
    required this.color,
    required this.label,
  });

  final double strength;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: const Color(0xFFF0ECEC),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F1) : const Color(0xFFF1FFF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError ? const Color(0xFFE53935) : const Color(0xFF388E3C),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFF1B5E20),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF5C1919)),
              SizedBox(width: 6),
              Text(
                'PASSWORD REQUIREMENTS',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Minimum 8 characters',
            'At least one uppercase letter (A–Z)',
            'At least one number (0–9)',
            'At least one special character (!@#\$...)',
          ].map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5C1919),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    req,
                    style: const TextStyle(
                      color: Color(0xFF6A6060),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header icon button (matches ProfilePage style) ────────────────────────────
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}
