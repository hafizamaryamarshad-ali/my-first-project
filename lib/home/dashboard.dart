import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart';
import 'courses_screen.dart';
import 'notifications_screen.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GCWUFTheme.backgroundColor,
                    GCWUFTheme.primaryColor.withOpacity(0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Floating Blobs Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double value = _animationController.value;
              return Stack(
                children: [
                  _FloatingBlob(
                    top: 50 - value * 25,
                    left: 20,
                    size: 180,
                    color: GCWUFTheme.primaryColor.withOpacity(0.08),
                  ),
                  _FloatingBlob(
                    bottom: 120 + value * 40,
                    right: 50,
                    size: 150,
                    color: GCWUFTheme.primaryColor.withOpacity(0.06),
                  ),
                  _FloatingBlob(
                    top: 250 - value * 15,
                    right: 100,
                    size: 120,
                    color: GCWUFTheme.primaryColor.withOpacity(0.05),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Modern AppBar/Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              GCWUFTheme.primaryColor.withOpacity(0.95),
                              GCWUFTheme.primaryColor.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: GCWUFTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String name = 'User';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              Map<String, dynamic>? data =
                                  snapshot.data!.data()
                                      as Map<String, dynamic>?;
                              if (data != null && data['name'] != null)
                                name = data['name'];
                            }
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileScreen(
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.25),
                                        child: Icon(
                                          Icons.person,
                                          color: GCWUFTheme.primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                _CircleIconButton(
                                  icon: Icons.notifications,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NotificationsScreen(
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _CircleIconButton(
                                  icon: Icons.settings,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cards Scrollable (overflow fixed)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ModernCard(
                                  icon: Icons.calendar_month,
                                  title: 'Attendance',
                                  progress: 0.75,
                                  route: AttendanceScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ModernCard(
                                  icon: Icons.book,
                                  title: 'Courses',
                                  progress: 0.6,
                                  route: CoursesScreen(userId: widget.userId),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ModernCard(
                                  icon: Icons.grade,
                                  title: 'Results',
                                  progress: 0.8,
                                  route: ResultsScreen(userId: widget.userId),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ModernCard(
                                  icon: Icons.notifications,
                                  title: 'Notifications',
                                  progress: 0.4,
                                  route: NotificationsScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

// Floating blobs for background animation
class _FloatingBlob extends StatelessWidget {
  final double? top, bottom, left, right, size;
  final Color color;

  const _FloatingBlob({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.size = 100,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// Modern Card without fixed height (responsive)
class _ModernCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final Widget route;

  const _ModernCard({
    required this.icon,
    required this.title,
    required this.progress,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
              child: Icon(icon, color: GCWUFTheme.primaryColor, size: 46),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(GCWUFTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

// Circular Icon Button
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: GCWUFTheme.primaryColor, size: 26),
      ),
    );
  }
}
