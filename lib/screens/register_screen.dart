import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendRegistrationOTP(
        email: _emailCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim(),
      );
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: _emailCtrl.text.trim(),
              username: _usernameCtrl.text.trim(),
              password: _passwordCtrl.text,
              fullName: _fullNameCtrl.text.trim(),
              phoneNumber: _phoneCtrl.text.trim(),
              purpose: OtpPurpose.register,
            ),
          ),
        );
      } else {
        _showError(_extractError(result));
      }
    } catch (e) {
      _showError('Không thể kết nối đến server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractError(Map<String, dynamic> result) {
    if (result['errors'] != null && (result['errors'] as List).isNotEmpty) {
      return result['errors'][0]['message'] as String;
    }
    return result['message'] as String? ?? 'Đã có lỗi xảy ra';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF09090B), Color(0xFF18181B), Color(0xFF461901)],
                ),
              ),
            ),
          ),
          // Glow blobs
          Positioned(
            top: 60, right: -60,
            child: Container(
              width: 330, height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE17100).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -80, left: -100,
            child: Container(
              width: 385, height: 385,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF54900).withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios_new, color: Color(0x99FFFFFF), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Quay lại đăng nhập',
                                style: GoogleFonts.inter(
                                  color: const Color(0x99FFFFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0x0DFFFFFF),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0x1AFFFFFF)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 50,
                                    offset: Offset(0, 25),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo
                                      Center(
                                        child: Image.asset(
                                          'assets/images/logo.webp',
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Title
                                      Text(
                                        'Đăng Ký Tài Khoản',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cormorantGaramond(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Tham gia cùng chúng tôi khám phá ẩm thực Việt',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: const Color(0x99FFFFFF),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Fields
                                      _buildField(
                                        label: 'Email',
                                        icon: Icons.email_outlined,
                                        controller: _emailCtrl,
                                        hint: 'example@email.com',
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                                          if (!v.contains('@')) return 'Email không hợp lệ';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildField(
                                        label: 'Họ và Tên',
                                        icon: Icons.person_outline,
                                        controller: _fullNameCtrl,
                                        hint: 'Nguyễn Văn A',
                                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildField(
                                        label: 'Số Điện Thoại',
                                        icon: Icons.phone_outlined,
                                        controller: _phoneCtrl,
                                        hint: '0912345678',
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildField(
                                        label: 'Tên Đăng Nhập',
                                        icon: Icons.badge_outlined,
                                        controller: _usernameCtrl,
                                        hint: 'username',
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Vui lòng nhập tên đăng nhập';
                                          if (v.length < 3) return 'Tối thiểu 3 ký tự';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPasswordField(
                                        label: 'Mật Khẩu',
                                        controller: _passwordCtrl,
                                        show: _showPassword,
                                        onToggle: () => setState(() => _showPassword = !_showPassword),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                                          if (v.length < 6) return 'Tối thiểu 6 ký tự';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPasswordField(
                                        label: 'Xác Nhận Mật Khẩu',
                                        controller: _confirmCtrl,
                                        show: _showConfirm,
                                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                                          if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      // Submit
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _handleSendOTP,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: _isLoading
                                                  ? null
                                                  : const LinearGradient(
                                                      colors: [Color(0xFFE17100), Color(0xFFF54900)],
                                                    ),
                                              color: _isLoading ? const Color(0x80E17100) : null,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: _isLoading
                                                  ? Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(
                                                          width: 16, height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text('Đang xử lý...', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
                                                      ],
                                                    )
                                                  : Text(
                                                      'Đăng Ký',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Login link
                                      Center(
                                        child: RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 14),
                                            children: [
                                              const TextSpan(text: 'Đã có tài khoản? '),
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: () => Navigator.pop(context),
                                                  child: Text(
                                                    'Đăng nhập ngay',
                                                    style: GoogleFonts.inter(
                                                      color: const Color(0xFFFE9A00),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xCCFFFFFF), size: 14),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(color: const Color(0xCCFFFFFF), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
          decoration: _inputDeco(hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xCCFFFFFF), size: 14),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(color: const Color(0xCCFFFFFF), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !show,
          style: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
          decoration: _inputDeco('••••••••').copyWith(
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF737373),
                size: 18,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
      filled: true,
      fillColor: const Color(0x0DFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x80FE9A00)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}
