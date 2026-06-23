import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umeed_v0/screens/auth/widgets/app_branding.dart';
import 'package:umeed_v0/screens/auth/widgets/app_snackbar.dart';
import 'package:umeed_v0/screens/auth/widgets/gradient_button.dart';
import '../../utils/authService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScale;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  String _getDashboardRoute(String role) {
    switch (role) {
      case 'ngo':
        return '/dashboard';
      case 'government':
      default:
        return '/dashboard';
    }
  }

  Future<void> _storeAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Store token
      await _secureStorage.write(key: 'auth_token', value: token);

      // Store user data as JSON string
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));

      // Store user role separately for quick access
      await _secureStorage.write(
        key: 'user_role',
        value: userData['role'] ?? 'government',
      );

      // Store user email
      await _secureStorage.write(
        key: 'user_email',
        value: userData['email'] ?? '',
      );

      // Store user full name
      await _secureStorage.write(
        key: 'user_name',
        value: userData['fullName'] ?? 'User',
      );

      // Set login timestamp
      await _secureStorage.write(
        key: 'login_timestamp',
        value: DateTime.now().toIso8601String(),
      );

      debugPrint('Auth data stored securely');
    } catch (e) {
      debugPrint('Error storing auth data: $e');
    }
  }

  Future<void> _clearPreviousAuthData() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
      await _secureStorage.delete(key: 'user_role');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_name');
      await _secureStorage.delete(key: 'login_timestamp');
      debugPrint('Previous auth data cleared');
    } catch (e) {
      debugPrint('Error clearing previous auth data: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackBar.show(
        context,
        'Please enter your email and password.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    await _buttonAnimController.forward();
    await _buttonAnimController.reverse();

    if (!mounted) return;

    final url = Uri.parse('http://localhost:8080/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final String token =
            data['token'] ?? data['accessToken'] ?? data['access_token'] ?? '';
        final Map<String, dynamic> userData =
            (data['user'] as Map<String, dynamic>?) ?? {};

        await _clearPreviousAuthData();
        await _storeAuthData(token, userData);

        AuthService.instance.saveAuth(token: token, userData: userData);

        final String userRole = userData['role'] ?? 'government';
        final String userName = userData['fullName'] ?? 'User';
        final String dashboardRoute = _getDashboardRoute(userRole);

        if (!mounted) return;
        AppSnackBar.show(context, 'Welcome back, $userName!', isSuccess: true);

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          dashboardRoute,
          arguments: userData,
        );
      } else {
        final errorMsg = data['message'] ?? 'Login failed. Please try again.';
        AppSnackBar.show(context, errorMsg, isError: true);
      }
    } catch (e) {
      AppSnackBar.show(context, 'Connection failed. Check your network.');
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 52),
                AppBranding(subtitle: 'Disaster Impact Prediction'),
                const SizedBox(height: 40),
                _buildFormCard(),
                const SizedBox(height: 20),
                _buildSignupRow(),
                const SizedBox(height: 32),
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C0A0A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInputLabel('Official Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: 'officer@ndma.gov.pk',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 20),

            _buildInputLabel('Password'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF7A1C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            GradientButton(
              text: 'Sign In',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onTap: _handleLogin,
            ),
            const SizedBox(height: 20),
            _buildAuthorizedAccessNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4A0D0D).withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/signup'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A1C1C), Color(0xFF4A0D0D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A1C1C).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Request Access',
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
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE8E4), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFB8B5B0), fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            size: 18,
            color: const Color(0xFFB8B5B0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE8E4), width: 1),
      ),
      child: TextField(
        controller: _passwordController,
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

  Widget _buildAuthorizedAccessNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A0D0D).withOpacity(0.05),
        border: Border.all(
          color: const Color(0xFF4A0D0D).withOpacity(0.15),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 17,
            color: Color(0xFF7A1C1C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Authorized access only. Accounts must be approved by an administrator before sign-in.',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4A0D0D).withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Version 2.0.4 • UMEED Systems',
      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
    );
  }

  Future<void> _sendForgotPasswordRequest(String email) async {
    final url = Uri.parse('http://localhost:8080/api/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return; // success
    } else if (response.statusCode == 404) {
      throw Exception(data['message'] ?? 'No account found with that email.');
    } else {
      throw Exception(
        data['message'] ?? 'Something went wrong. Please try again.',
      );
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailCtrl = TextEditingController();
    bool isSending = false;
    bool isSent = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: isSent
                    ? _buildForgotSuccessState(
                        emailCtrl.text.trim(),
                        dialogContext,
                      )
                    : _buildForgotFormState(
                        emailCtrl: emailCtrl,
                        isSending: isSending,
                        dialogContext: dialogContext,
                        onSend: () async {
                          final email = emailCtrl.text.trim();
                          if (email.isEmpty) return;

                          setDialogState(() => isSending = true);
                          try {
                            await _sendForgotPasswordRequest(email);
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              isSending = false;
                              isSent = true;
                            });
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (!mounted) return;
                            AppSnackBar.show(
                              context,
                              e.toString().replaceAll('Exception: ', ''),
                              isError: true,
                            );
                          }
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForgotFormState({
    required TextEditingController emailCtrl,
    required bool isSending,
    required BuildContext dialogContext,
    required VoidCallback onSend,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A1C1C), Color(0xFF3A0A0A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_open_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C0A0A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your registered official email address. We\'ll send you a secure reset link.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 20),
        const Text(
          'Official Email',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAE8E4)),
          ),
          child: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
            decoration: const InputDecoration(
              hintText: 'officer@ndma.gov.pk',
              hintStyle: TextStyle(color: Color(0xFFB8B5B0), fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
                size: 18,
                color: Color(0xFFB8B5B0),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF4A0D0D).withOpacity(0.05),
            border: Border.all(
              color: const Color(0xFF4A0D0D).withOpacity(0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: Color(0xFF7A1C1C),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The reset link expires in 1 hour. Check your spam folder if you don\'t see the email.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4A0D0D).withOpacity(0.72),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEAE8E4)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isSending ? null : onSend,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B2020), Color(0xFF4A0D0D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A1C1C).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotSuccessState(String email, BuildContext dialogContext) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF2E7D32),
            size: 26,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reset Link Sent!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C0A0A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A password reset link has been sent to\n$email\n\nPlease check your inbox.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2020), Color(0xFF4A0D0D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A1C1C).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Back to Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
