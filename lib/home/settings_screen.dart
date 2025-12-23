import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkThemeEnabled = false;

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic colors
    final bgGradientStart = darkThemeEnabled
        ? Colors.grey.shade900
        : GCWUFTheme.backgroundColor;
    final bgGradientEnd = darkThemeEnabled
        ? Colors.black87
        : GCWUFTheme.primaryColor.withOpacity(0.3);
    final cardColor = darkThemeEnabled
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.25);

    return Scaffold(
      body: Stack(
        children: [
          // ------------------ FULL SCREEN GRADIENT ------------------
          Positioned.fill(
            child: Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgGradientStart, bgGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ------------------ FLOATING SHAPES ------------------
          const _FloatingCircle(top: -50, left: -30, size: 120, opacity: 0.05),
          const _FloatingCircle(
            bottom: -40,
            right: -20,
            size: 140,
            opacity: 0.07,
          ),
          const _FloatingCircle(top: 200, right: 50, size: 100, opacity: 0.06),
          const _FloatingCircle(bottom: 150, left: 60, size: 90, opacity: 0.05),

          // ------------------ SCROLLABLE CONTENT ------------------
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------ APPBAR ------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: darkThemeEnabled
                              ? Colors.grey.shade800.withOpacity(0.95)
                              : GCWUFTheme.primaryColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------ SETTINGS CARDS ------------------
                    _SettingsCard(
                      icon: Icons.person,
                      iconColor: Colors.blueAccent,
                      title: "Profile",
                      subtitle: "View & edit profile",
                      cardColor: cardColor,
                      textColor: Colors.black,
                      onTap: () {
                        Navigator.pop(context); // Navigate to Profile
                      },
                    ),

                    _SettingsCard(
                      icon: Icons.notifications,
                      iconColor: Colors.orangeAccent,
                      title: "Notifications",
                      subtitle: notificationsEnabled ? "Enabled" : "Disabled",
                      cardColor: cardColor,
                      textColor: Colors.black,
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (val) {
                          setState(() {
                            notificationsEnabled = val;
                          });
                        },
                        activeThumbColor: GCWUFTheme.primaryColor,
                      ),
                      onTap: () {},
                    ),

                    _SettingsCard(
                      icon: Icons.brightness_6,
                      iconColor: Colors.yellowAccent,
                      title: "Dark Theme",
                      subtitle: darkThemeEnabled ? "Enabled" : "Disabled",
                      cardColor: cardColor,
                      textColor: Colors.black,
                      trailing: Switch(
                        value: darkThemeEnabled,
                        onChanged: (val) {
                          setState(() {
                            darkThemeEnabled = val;
                          });
                        },
                        activeThumbColor: GCWUFTheme.primaryColor,
                      ),
                      onTap: () {},
                    ),

                    _SettingsCard(
                      icon: Icons.logout,
                      iconColor: Colors.redAccent,
                      title: "Logout",
                      subtitle: "",
                      cardColor: cardColor,
                      textColor: Colors.black,
                      onTap: logout,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ SETTINGS CARD ------------------
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color cardColor;
  final Color textColor;

  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle = "",
    this.trailing,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.2),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.85),
                            shadows: const [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ FLOATING CIRCLE ------------------
class _FloatingCircle extends StatelessWidget {
  final double? top, bottom, left, right, size, opacity;
  const _FloatingCircle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.size = 100,
    this.opacity = 0.05,
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity!),
        ),
      ),
    );
  }
}
