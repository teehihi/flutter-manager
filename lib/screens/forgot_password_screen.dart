import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendPasswordResetOTP(email: _emailCtrl.text.trim());
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: _emailCtrl.text.trim(),
              purpose: OtpPurpose.forgotPassword,
              newPassword: _newPasswordCtrl.text,
            ),
          ),
        );
      } else {
        _showError(result['message'] as String? ?? 'Đã có lỗi xảy ra');
      }
    } catch (e) {
      _showError('Không thể kết nối đến server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
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
                              'Quay lại',
                              style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0x0DFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0x1AFFFFFF)),
                              boxShadow: const [
                                BoxShadow(color: Color(0x40000000), blurRadius: 50, offset: Offset(0, 25)),
                              ],
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Logo
                                  Center(
                                    child: Image.asset('assets/images/logo.webp', height: 80, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Quên Mật Khẩu',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cormorantGaramond(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Nhập email và mật khẩu mới, chúng tôi sẽ gửi OTP xác thực',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 13),
                                  ),
                                  const SizedBox(height: 24),
                                  // Email
                                  _buildLabel('Email', Icons.email_outlined),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
                                    decoration: _inputDeco('example@email.com'),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                                      if (!v.contains('@')) return 'Email không hợp lệ';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // New password
                                  _buildLabel('Mật Khẩu Mới', Icons.lock_outline),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _newPasswordCtrl,
                                    obscureText: !_showPassword,
                                    style: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
                                    decoration: _inputDeco('••••••••').copyWith(
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() => _showPassword = !_showPassword),
                                        child: Icon(
                                          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: const Color(0xFF737373), size: 18,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                                      if (v.length < 6) return 'Tối thiểu 6 ký tự';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Confirm password
                                  _buildLabel('Xác Nhận Mật Khẩu', Icons.lock_outline),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    obscureText: !_showConfirm,
                                    style: GoogleFonts.inter(color: const Color(0x4DFFFFFF), fontSize: 15),
                                    decoration: _inputDeco('••••••••').copyWith(
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() => _showConfirm = !_showConfirm),
                                        child: Icon(
                                          _showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: const Color(0xFF737373), size: 18,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                                      if (v != _newPasswordCtrl.text) return 'Mật khẩu không khớp';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),
                                  // Submit
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleSendOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: _isLoading
                                              ? null
                                              : const LinearGradient(colors: [Color(0xFFE17100), Color(0xFFF54900)]),
                                          color: _isLoading ? const Color(0x80E17100) : null,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20, height: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                )
                                              : Text(
                                                  'Gửi Mã OTP',
                                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        'Quay lại đăng nhập',
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
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xCCFFFFFF), size: 14),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(color: const Color(0xCCFFFFFF), fontSize: 13, fontWeight: FontWeight.w500)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0x1AFFFFFF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0x1AFFFFFF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0x80FE9A00))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEF4444))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEF4444))),
    );
  }
}
