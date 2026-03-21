import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

const _bgImageUrl =
    'https://images.unsplash.com/photo-1694152362587-99d77d21793b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isLoading = false);
    // TODO: navigate to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _bgImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(),
              errorWidget: (context, url, error) => Container(color: const Color(0xFF0A0A0A)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xE60A0A0A),
                    Color(0xD90A0A0A),
                    Color(0xF20A0A0A),
                  ],
                ),
              ),
            ),
          ),
          // Top accent
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x4DF59E0B),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x99171717),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x80525252)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_outlined, color: Color(0xFFD4D4D4), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Splash',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4D4D4),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildCard(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/logo.webp', width: 180, fit: BoxFit.contain),
        const SizedBox(height: 16),
        Text(
          'SIGN IN TO CONTINUE',
          style: GoogleFonts.inter(
            color: const Color(0xFF737373),
            fontSize: 11,
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x66171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33404040)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Top accent line
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x80F59E0B),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('EMAIL ADDRESS'),
                  const SizedBox(height: 8),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildLabel('PASSWORD'),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildRememberForgot(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFF737373),
        fontSize: 10,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration('your.email@example.com'),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập email';
        if (!v.contains('@')) return 'Email không hợp lệ';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: !_showPassword,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration('Enter your password').copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _showPassword = !_showPassword),
          child: Icon(
            _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF737373),
            size: 20,
          ),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF404040), fontSize: 14),
      filled: true,
      fillColor: const Color(0x4D262626),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x80525252)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x80525252)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x80F59E0B)),
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

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _rememberMe ? const Color(0xFFF59E0B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: _rememberMe ? const Color(0xFFF59E0B) : const Color(0xFF525252),
                  ),
                ),
                child: _rememberMe
                    ? const Icon(Icons.check, size: 12, color: Color(0xFF0A0A0A))
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: GoogleFonts.inter(
                  color: const Color(0xFF737373),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Forgot?',
          style: GoogleFonts.inter(
            color: const Color(0xCCF59E0B),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: const Color(0xFF0A0A0A),
          disabledBackgroundColor: const Color(0x80F59E0B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0A0A0A),
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0x33404040))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              color: const Color(0xFF525252),
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0x33404040))),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            color: const Color(0xFF737373),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          children: const [
            TextSpan(text: 'Need an account? '),
            TextSpan(
              text: 'Contact Admin',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2026 Đặc Sản Việt. All rights reserved.',
      style: GoogleFonts.inter(
        color: const Color(0xFF404040),
        fontSize: 11,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
