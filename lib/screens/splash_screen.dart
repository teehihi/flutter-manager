import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

const _bgImageUrl =
    'https://images.unsplash.com/photo-1696215105730-fa23954dd164?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

const _teamMembers = [
  {
    'name': 'Nguyễn Nhật Thiên',
    'mssv': '23110153',
    'role': 'Project Lead, Strategy & UI/UX Design',
    'avatar': 'assets/images/NguyenNhatThien.png',
    'color1': Color(0xFFB45309),
    'color2': Color(0xFFEA580C),
  },
  {
    'name': 'Phạm Văn Hậu',
    'mssv': '23110098',
    'role': 'UX Research & Java Coding',
    'avatar': 'assets/images/PhamVanHau.jpg',
    'color1': Color(0xFFE11D48),
    'color2': Color(0xFFDB2777),
  },
  {
    'name': 'Trương Công Anh',
    'mssv': '23110075',
    'role': 'Backend Architecture',
    'avatar': 'assets/images/TruongCongAnh.png',
    'color1': Color(0xFF2563EB),
    'color2': Color(0xFF0891B2),
  },
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0;
  int _activeIndex = 0;
  final List<bool> _showMembers = [false, false, false];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _cardController;

  Timer? _progressTimer;
  Timer? _rotateTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      setState(() {
        _progress += 1;
        if (_progress >= 100) t.cancel();
      });
    });

    for (int i = 0; i < _teamMembers.length; i++) {
      Future.delayed(Duration(milliseconds: 1000 + i * 1200), () {
        if (mounted) setState(() => _showMembers[i] = true);
      });
    }

    _rotateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _cardController.forward(from: 0);
      setState(() => _activeIndex = (_activeIndex + 1) % _teamMembers.length);
    });

    _navTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _rotateTimer?.cancel();
    _navTimer?.cancel();
    _fadeController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _bgImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(),
              errorWidget: (context, url, error) => Container(color: const Color(0xFF0A0A0A)),
            ),
          ),
          // Gradient overlays
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB30A0A0A),
                    Color(0x800A0A0A),
                    Color(0xE60A0A0A),
                  ],
                ),
              ),
            ),
          ),
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
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  Expanded(child: _buildTeamSection()),
                  _buildLoadingSection(),
                  const SizedBox(height: 8),
                  _buildFooter(),
                  const SizedBox(height: 16),
                ],
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
        // Logo
        SizedBox(
          width: 200,
          height: 60,
          child: Image.asset('assets/images/logo.webp', fit: BoxFit.contain),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              Color(0xFFF59E0B),
              Colors.transparent,
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CULINARY HERITAGE',
          style: GoogleFonts.inter(
            color: const Color(0xCCFDE68A),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 1024) {
      return _buildDesktopGrid();
    }
    return _buildMobileCarousel();
  }

  Widget _buildMobileCarousel() {
    final member = _teamMembers[_activeIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(anim), child: child),
            ),
            child: _showMembers[_activeIndex]
                ? _MemberCard(
                    key: ValueKey(_activeIndex),
                    name: member['name'] as String,
                    mssv: member['mssv'] as String,
                    role: member['role'] as String,
                    avatarAsset: member['avatar'] as String,
                    color1: member['color1'] as Color,
                    color2: member['color2'] as Color,
                  )
                : const SizedBox(height: 300),
          ),
          const SizedBox(height: 16),
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_teamMembers.length, (i) {
              return GestureDetector(
                onTap: () => setState(() => _activeIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _activeIndex ? 28 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _activeIndex
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF404040),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_teamMembers.length, (i) {
          final m = _teamMembers[i];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedOpacity(
                opacity: _showMembers[i] ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedSlide(
                  offset: _showMembers[i] ? Offset.zero : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  child: _MemberCard(
                    name: m['name'] as String,
                    mssv: m['mssv'] as String,
                    role: m['role'] as String,
                    avatarAsset: m['avatar'] as String,
                    color1: m['color1'] as Color,
                    color2: m['color2'] as Color,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'LOADING EXPERIENCE',
            style: GoogleFonts.inter(
              color: const Color(0xFF737373),
              fontSize: 11,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return _PulsingDot(delay: Duration(milliseconds: i * 200));
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 2,
              backgroundColor: const Color(0xFF262626),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Đại học Công nghệ Kỹ thuật TP.HCM',
          style: GoogleFonts.inter(
            color: const Color(0xFF525252),
            fontSize: 10,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Web Development  •  2026  •  v1.0',
          style: GoogleFonts.inter(
            color: const Color(0xFF404040),
            fontSize: 9,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ── Member Card ──────────────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  const _MemberCard({
    super.key,
    required this.name,
    required this.mssv,
    required this.role,
    required this.avatarAsset,
    required this.color1,
    required this.color2,
  });

  final String name;
  final String mssv;
  final String role;
  final String avatarAsset;
  final Color color1;
  final Color color2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55404040)),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF262626),
                    child: const Icon(Icons.person, color: Colors.white38, size: 60),
                  ),
                ),
                // Bottom fade
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0D0D0D)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Container(
            width: double.infinity,
            color: const Color(0xFF0D0D0D),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MSSV: $mssv',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFD4D4D4),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: const Color(0xCCF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing Dot ───────────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.delay});
  final Duration delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: const BoxDecoration(
          color: Color(0xFFF59E0B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
