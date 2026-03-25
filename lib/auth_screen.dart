import 'package:flutter/material.dart';
import 'package:intro/home.dart';
import 'package:intro/service/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInLogo;
  late Animation<double> _fadeInText;
  late Animation<double> _fadeInButton;
  late Animation<Offset> _slideButton;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeInLogo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _fadeInText = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _fadeInButton = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _slideButton = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
// 1. Instantiate the service inside your State class
  final GoogleAuthService _authService = GoogleAuthService();

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    // 2. Call the real authentication logic
    final user = await _authService.signInWithGoogle();

    // 3. Always check if mounted before doing UI updates or navigation after an async gap
    if (!mounted) return;

    setState(() => _isLoading = false);

    // 4. If user is NOT null, authentication was successful
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            // Pass the actual Firebase user data, with safe fallbacks
            userName: user.displayName ?? 'Unknown User',
            userEmail: user.email ?? 'No email provided',
            userImageUrl: user.photoURL ?? 'https://via.placeholder.com/150',
          ),
        ),
      );
    } else {
      // 5. If user IS null, they canceled the modal or an error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in canceled or failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Subtle radial glow behind logo
          Positioned(
            top: size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4285F4).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.12),

                  // App logo / wordmark
                  FadeTransition(
                    opacity: _fadeInLogo,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF4285F4),
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeInText,
                    child: Text(
                      'Sign in to continue to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.45),
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Google Sign-In Button ───────────────────────────────
                  FadeTransition(
                    opacity: _fadeInButton,
                    child: SlideTransition(
                      position: _slideButton,
                      child: _GoogleSignInButton(
                        isLoading: _isLoading,
                        onPressed: _handleGoogleSignIn,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms
                  FadeTransition(
                    opacity: _fadeInButton,
                    child: Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.25),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google Sign-In Button ────────────────────────────────────────────────────

class _GoogleSignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: _pressed ? Colors.white.withOpacity(0.88) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.08 : 0.18),
                blurRadius: _pressed ? 8 : 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4285F4),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google logo fetched from network
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 24,
                        color: Color(0xFF4285F4),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4285F4),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
