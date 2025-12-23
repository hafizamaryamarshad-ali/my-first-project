import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import '../home/dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  late AnimationController _bubbleController;
  late Animation<double> _bubble1;
  late Animation<double> _bubble2;

  late AnimationController _buttonGlowController;
  late Animation<double> _buttonGlowAnim;

  bool loading = false;
  bool showPassword = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // Floating bubbles animation
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

    // Button neon glow animation
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
    _confettiController.dispose();
    _fadeController.dispose();
    _bubbleController.dispose();
    _buttonGlowController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signupUser() async {
    setState(() => loading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      _confettiController.play();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully! 🎉")),
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(userId: uid)),
        );
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
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
          // Animated gradient overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.35),
                    Colors.purple.withOpacity(0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          // Floating bubbles
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: _bubble1.value,
                    left: -40,
                    child: _glassBubble(180),
                  ),
                  Positioned(
                    bottom: _bubble2.value,
                    right: -50,
                    child: _glassBubble(220),
                  ),
                ],
              );
            },
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 25,
              minBlastForce: 8,
              emissionFrequency: 0.04,
              numberOfParticles: 30,
            ),
          ),
          // Form content
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
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: Image.asset("assets/logo1.png"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 34,
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
                    const Text(
                      "Join GCWUF OneHub",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 35),
                    _glassCard(),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
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

  Widget _glassCard() {
    return ClipRRect(
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
              _neonInputField("Full Name", _nameController, Icons.person),
              const SizedBox(height: 16),
              _neonInputField("Email", _emailController, Icons.email),
              const SizedBox(height: 16),
              _neonPasswordField(),
              const SizedBox(height: 26),
              AnimatedBuilder(
                animation: _buttonGlowAnim,
                builder: (_, __) {
                  return GestureDetector(
                    onTapDown: (_) => setState(() => _pressed = true),
                    onTapUp: (_) {
                      setState(() => _pressed = false);
                      signupUser();
                    },
                    onTapCancel: () => setState(() => _pressed = false),
                    child: AnimatedScale(
                      scale: _pressed ? 0.95 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(
                                _buttonGlowAnim.value,
                              ),
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.6),
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
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.3,
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
    );
  }

  Widget _neonInputField(
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
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

  Widget _neonPasswordField() {
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
          controller: _passwordController,
          obscureText: !showPassword,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
            hintText: "Password",
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
