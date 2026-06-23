import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../../utils/authService.dart';
import 'widgets/user/user_detail_section.dart';
import 'widgets/user/user_detail_top_button.dart';
import 'widgets/user/user_status_badge.dart';
import 'widgets/user/user_detail_loader.dart';
import 'widgets/user/user_detail_error.dart';
import 'widgets/user/editable_field_row.dart';
import 'widgets/user/province_dropdown_row.dart';
import 'widgets/user/read_only_field_row.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, this.initialUser});

  final Map<String, dynamic>? initialUser;
  static const String routeName = '/user-detail';

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _enterCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _enterFade = CurvedAnimation(
    parent: _enterCtrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _enterSlide = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

  // ── State ──────────────────────────────────────────────────────────────────
  Map<String, dynamic> _user = {};
  bool _loading = true;
  String? _error;
  bool _editing = false;
  bool _saving = false;
  String? _saveError;

  // ── Image picker ───────────────────────────────────────────────────────────
  ImagePicker? _picker;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  // ── Controllers for every editable field ───────────────────────────────────
  final Map<String, TextEditingController> _ctrl = {};
  String? _editingProvince;

  static const List<String?> _provinces = [
    null,
    'Punjab',
    'Sindh',
    'KPK',
    'Balochistan',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];

  static const List<String> _editableFields = [
    'fullName',
    'phone',
    'organization',
    'designation',
    'department',
    'websiteLink',
    'experience',
    'cnic',
    'country',
    'province',
    'district',
    'city',
    'area',
    'currentAddress',
  ];

  static const Map<String, String> _fieldLabel = {
    'fullName': 'Full Name',
    'phone': 'Phone',
    'organization': 'Organisation',
    'designation': 'Designation',
    'department': 'Department',
    'websiteLink': 'Website',
    'experience': 'Experience',
    'cnic': 'CNIC',
    'country': 'Country',
    'province': 'Province',
    'district': 'District',
    'city': 'City',
    'area': 'Area',
    'currentAddress': 'Current Address',
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    for (final f in _editableFields.where((f) => f != 'province')) {
      _ctrl[f] = TextEditingController();
    }
    if (widget.initialUser != null) {
      _user = Map<String, dynamic>.from(widget.initialUser!);
      _loading = false;
      _syncControllers();
      _enterCtrl.forward();
    } else {
      _fetchUser();
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _syncControllers() {
    for (final f in _editableFields.where((f) => f != 'province')) {
      _ctrl[f]!.text = _user[f]?.toString() ?? '';
    }
    _editingProvince = _user['province'] as String?;
  }

  Future<void> _fetchUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await AuthService.instance.getMe();
      if (!mounted) return;
      setState(() {
        _user = result;
        _loading = false;
      });
      _syncControllers();
      _enterCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggleEdit() {
    if (_editing) {
      _saveChanges();
    } else {
      _syncControllers();
      setState(() {
        _editing = true;
        _saveError = null;
        _selectedImage = null;
        _selectedImageBytes = null;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _editing = false;
      _saveError = null;
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  Future<void> _pickImage() async {
    if (!_editing) return;

    // Ensure picker is initialized
    if (_picker == null) {
      _picker = ImagePicker();
    }

    try {
      final XFile? image = await _picker!.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Read bytes for web compatibility
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      final token = await AuthService.instance.secureStorage.read(
        key: 'auth_token',
      );

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${AuthService.baseUrl}/api/auth/update-profile'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      for (final f in _editableFields.where((f) => f != 'province')) {
        final val = _ctrl[f]!.text.trim();
        if (val.isNotEmpty) request.fields[f] = val;
      }
      if (_editingProvince != null)
        request.fields['province'] = _editingProvince!;

      // Add image if selected
      if (_selectedImage != null && _selectedImageBytes != null) {
        final mimeType = lookupMimeType(_selectedImage!.path);
        final mimeTypeParts = mimeType?.split('/');

        request.files.add(
          http.MultipartFile.fromBytes(
            'profileImage',
            _selectedImageBytes!,
            filename: _selectedImage!.name,
            contentType: mimeTypeParts != null
                ? MediaType(mimeTypeParts[0], mimeTypeParts[1])
                : null,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        if (!mounted) return;

        final updatedUser = body['user'] as Map<String, dynamic>;

        // Update AuthService immediately
        AuthService.instance.user = updatedUser;

        setState(() {
          _user = updatedUser;
          _editing = false;
          _saving = false;
          _selectedImage = null;
          _selectedImageBytes = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF5C1919),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception(body['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveError = e.toString();
        _saving = false;
      });
    }
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  String get _fullName => _user['fullName'] ?? 'NDMA Official';
  String get _status => _user['status'] ?? '—';
  bool get _emailVerified => _user['isEmailVerified'] == true;
  String? get _profileImage => _user['profileImage'] as String?;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _loading
          ? const UserDetailLoader()
          : _error != null
          ? UserDetailError(message: _error!, onRetry: _fetchUser)
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Header gradient
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 260,
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

        SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    UserDetailTopButton(
                      icon: _editing
                          ? Icons.close_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      onTap: _editing
                          ? _cancelEdit
                          : () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _editing ? 'EDITING' : 'MY PROFILE',
                        key: ValueKey(_editing),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _saving
                        ? const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : UserDetailTopButton(
                            icon: _editing
                                ? Icons.check_rounded
                                : Icons.edit_outlined,
                            onTap: _toggleEdit,
                          ),
                  ],
                ),
              ),

              // ── Avatar + name ────────────────────────────────────────────
              FadeTransition(
                opacity: _enterFade,
                child: SlideTransition(
                  position: _enterSlide,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _editing ? _pickImage : null,
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(child: _buildAvatar()),
                            ),
                            if (_editing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF5C1919),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_emailVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      UserStatusBadge(status: _status),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Save error banner ────────────────────────────────────────
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8D8D8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFF5C1919),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _saveError!,
                            style: const TextStyle(
                              color: Color(0xFF5C1919),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Scrollable cards ─────────────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _enterFade,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        UserDetailSection(
                          icon: Icons.badge_outlined,
                          title: 'PERSONAL INFO',
                          children: [
                            _buildFieldRow('fullName'),
                            _divider(),
                            _buildReadOnlyRow(
                              'Email',
                              _user['email']?.toString() ?? '—',
                            ),
                            _divider(),
                            _buildFieldRow('phone'),
                            _divider(),
                            _buildFieldRow('cnic'),
                            _divider(),
                            _buildFieldRow('experience'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        UserDetailSection(
                          icon: Icons.business_outlined,
                          title: 'ORGANISATION',
                          children: [
                            _buildFieldRow('organization'),
                            _divider(),
                            _buildFieldRow('designation'),
                            _divider(),
                            _buildFieldRow('department'),
                            _divider(),
                            _buildFieldRow('websiteLink'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        UserDetailSection(
                          icon: Icons.location_on_outlined,
                          title: 'LOCATION',
                          children: [
                            _buildFieldRow('country'),
                            _divider(),
                            _buildProvinceRow(),
                            _divider(),
                            _buildFieldRow('district'),
                            _divider(),
                            _buildFieldRow('city'),
                            _divider(),
                            _buildFieldRow('area'),
                            _divider(),
                            _buildFieldRow('currentAddress', multiLine: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        UserDetailSection(
                          icon: Icons.manage_accounts_outlined,
                          title: 'ACCOUNT',
                          children: [
                            _buildReadOnlyRow(
                              'Role',
                              _user['role']?.toString() ?? '—',
                            ),
                            _divider(),
                            _buildReadOnlyRow(
                              'Email Verified',
                              _emailVerified ? 'Yes ✓' : 'No',
                            ),
                            _divider(),
                            _buildReadOnlyRow('Status', _status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Avatar builder ─────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8E8E8),
            child: const Icon(Icons.person, size: 52, color: Color(0xFF9A9A9A)),
          );
        },
      );
    }

    if (_profileImage != null && _profileImage!.isNotEmpty) {
      return Image.network(
        _profileImage!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFE8E8E8),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF5C1919)),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8E8E8),
            child: const Icon(Icons.person, size: 52, color: Color(0xFF9A9A9A)),
          );
        },
      );
    }

    // Show default person icon
    return Container(
      color: const Color(0xFFE8E8E8),
      child: const Icon(Icons.person, size: 52, color: Color(0xFF9A9A9A)),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    color: Color(0xFFF0F0F0),
    indent: 18,
    endIndent: 18,
  );

  Widget _buildFieldRow(String key, {bool multiLine = false}) {
    final label = _fieldLabel[key] ?? key;
    final value = _user[key]?.toString() ?? '';

    if (!_editing) return _buildReadOnlyRow(label, value.isEmpty ? '—' : value);

    return EditableFieldRow(
      label: label,
      controller: _ctrl[key]!,
      multiLine: multiLine,
    );
  }

  Widget _buildProvinceRow() {
    if (!_editing) {
      return _buildReadOnlyRow(
        'Province',
        _user['province']?.toString() ?? '—',
      );
    }
    return ProvinceDropdownRow(
      provinces: _provinces,
      initialValue: _editingProvince,
      onChanged: (v) => setState(() => _editingProvince = v),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return ReadOnlyFieldRow(label: label, value: value);
  }
}
