import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import 'signup_screen.dart';
import '../home/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;
  bool showPassword = false;
  bool _pressed = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  late AnimationController _bubbleController;
  late Animation<double> _bubble1;
  late Animation<double> _bubble2;

  late AnimationController _buttonGlowController;
  late Animation<double> _buttonGlowAnim;

  @override
  void initState() {
    super.initState();

    // Fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // Floating bubbles
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bubble1 = Tween<double>(begin: -60, end: 20).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );
    _bubble2 = Tween<double>(begin: -80, end: -40).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );

    // Button neon glow
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _buttonGlowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _buttonGlowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bubbleController.dispose();
    _buttonGlowController.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _email.text.trim(),
            password: _pass.text.trim(),
          );

      String uid = userCredential.user!.uid;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: uid)),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login error")));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset("assets/bg_gate.jpg", fit: BoxFit.cover),
          ),
          // Subtle gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.15),
                    Colors.purple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Light dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          // Floating bubbles
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: _bubble1.value,
                    left: -20,
                    child: _glassBubble(120),
                  ),
                  Positioned(
                    bottom: _bubble2.value,
                    right: -30,
                    child: _glassBubble(150),
                  ),
                ],
              );
            },
          ),
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Hero(
                      tag: 'logo',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Image.asset("assets/logo1.png"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "GCWUF OneHub",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Welcome back! Login to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 35),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Column(
                            children: [
                              _neonInput("Email", _email),
                              const SizedBox(height: 16),
                              _neonInput("Password", _pass, isPass: true),
                              const SizedBox(height: 26),
                              AnimatedBuilder(
                                animation: _buttonGlowAnim,
                                builder: (_, __) {
                                  return GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _pressed = true),
                                    onTapUp: (_) {
                                      setState(() => _pressed = false);
                                      if (!loading) login();
                                    },
                                    onTapCancel: () =>
                                        setState(() => _pressed = false),
                                    child: AnimatedScale(
                                      scale: _pressed ? 0.95 : 1,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary.withOpacity(
                                                _buttonGlowAnim.value,
                                              ),
                                              AppColors.primary,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.6),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: loading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _glassBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 40),
        ],
      ),
    );
  }

  Widget _neonInput(
    String hint,
    TextEditingController controller, {
    bool isPass = false,
  }) {
    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: FocusScope.of(context).hasFocus
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(
                FocusScope.of(context).hasFocus ? 0.6 : 0.3,
              ),
              blurRadius: FocusScope.of(context).hasFocus ? 20 : 12,
              spreadRadius: FocusScope.of(context).hasFocus ? 2 : 1,
            ),
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPass && !showPassword,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              isPass ? Icons.lock : Icons.email,
              color: AppColors.primary,
            ),
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.primary,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  )
                : null,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 14,
            ),
          ),
        ),
      ),
    );
  }
}
