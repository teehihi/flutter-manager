import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

enum OtpPurpose { register, forgotPassword }

class OtpScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;

  // Register fields
  final String? username;
  final String? password;
  final String? fullName;
  final String? phoneNumber;

  // Forgot password - new password
  final String? newPassword;

  const OtpScreen({
    super.key,
    required this.email,
    required this.purpose,
    this.username,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.newPassword,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _countdown = 300; // 5 phút
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
        for (final c in _otpCtrls) {
          c.dispose();
        }
        for (final f in _focusNodes) {
          f.dispose();
        }
    super.dispose();
  }

  String get _otpCode => _otpCtrls.map((c) => c.text).join();

  String get _countdownText {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length < 6) {
      _showError('Vui lòng nhập đủ 6 chữ số');
      return;
    }
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> result;
      if (widget.purpose == OtpPurpose.register) {
        result = await ApiService.verifyRegistrationOTP(
          email: widget.email,
          otpCode: _otpCode,
          username: widget.username!,
          password: widget.password!,
          fullName: widget.fullName!,
          phoneNumber: widget.phoneNumber,
        );
      } else {
        result = await ApiService.resetPasswordWithOTP(
          email: widget.email,
          otpCode: _otpCode,
          newPassword: widget.newPassword!,
        );
      }

      if (!mounted) return;
      if (result['success'] == true) {
        if (widget.purpose == OtpPurpose.register) {
          // Lưu token nếu có
          final token = result['data']?['tokens']?['accessToken'];
          if (token != null) await ApiService.saveToken(token as String);
          if (!mounted) return;
          _showSuccess('Đăng ký thành công! Vui lòng đăng nhập.');
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          if (!mounted) return;
          _showSuccess('Đặt lại mật khẩu thành công! Vui lòng đăng nhập.');
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        _showError(result['message'] as String? ?? 'Mã OTP không hợp lệ');
      }
    } catch (e) {
      _showError('Không thể kết nối đến server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    if (_countdown > 0) return;
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> result;
      if (widget.purpose == OtpPurpose.register) {
        result = await ApiService.sendRegistrationOTP(
          email: widget.email,
          username: widget.username!,
          fullName: widget.fullName,
        );
      } else {
        result = await ApiService.sendPasswordResetOTP(email: widget.email);
      }
      if (!mounted) return;
      if (result['success'] == true) {
        _startCountdown();
        _showSuccess('Đã gửi lại mã OTP');
      } else {
        _showError(result['message'] as String? ?? 'Không thể gửi lại OTP');
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF22C55E),
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
                            child: Column(
                              children: [
                                // Icon
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0x33FE9A00),
                                    border: Border.all(color: const Color(0x80FE9A00)),
                                  ),
                                  child: const Icon(Icons.phone_android_outlined, color: Color(0xFFFE9A00), size: 28),
                                ),
                                const SizedBox(height: 16),
                                // Logo
                                Image.asset('assets/images/logo.webp', height: 60, fit: BoxFit.contain),
                                const SizedBox(height: 16),
                                Text(
                                  'Xác Thực OTP',
                                  style: GoogleFonts.cormorantGaramond(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mã OTP đã được gửi đến email của bạn',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.email,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(color: const Color(0xFFFE9A00), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 28),
                                // OTP inputs
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(6, (i) => _buildOtpBox(i)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nhập mã gồm 6 chữ số được gửi đến email của bạn',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(color: const Color(0x66FFFFFF), fontSize: 12),
                                ),
                                const SizedBox(height: 28),
                                // Verify button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleVerify,
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
                                                'Xác Thực',
                                                style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Resend
                                GestureDetector(
                                  onTap: _countdown == 0 ? _handleResend : null,
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 13),
                                      children: [
                                        const TextSpan(text: 'Không nhận được mã? '),
                                        TextSpan(
                                          text: _countdown > 0 ? 'Gửi lại sau $_countdownText' : 'Gửi lại',
                                          style: TextStyle(
                                            color: _countdown > 0 ? const Color(0x66FFFFFF) : const Color(0xFFFE9A00),
                                            fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 44,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(index == 0 ? 8 : index == 5 ? 8 : 12),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: TextFormField(
        controller: _otpCtrls[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}
