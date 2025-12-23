import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _programController = TextEditingController();
  final _semesterController = TextEditingController();

  bool _loading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    setState(() {
      _imageUrl = userData?['photoUrl'];
      _nameController.text = userData?['name'] ?? '';
      _studentIdController.text = userData?['studentId'] ?? '';
      _emailController.text = userData?['email'] ?? '';
      _programController.text = userData?['program'] ?? '';
      _semesterController.text = userData?['semester'] ?? '';
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Wrap(
          spacing: 20,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (pickedFile != null) _uploadImage(File(pickedFile.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (pickedFile != null) _uploadImage(File(pickedFile.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(File image) async {
    setState(() => _loading = true);
    String fileName = "profile_${widget.userId}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child(
      'profile_images/$fileName',
    );
    await ref.putFile(image);
    String url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'photoUrl': url});
    setState(() {
      _imageFile = image;
      _imageUrl = url;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
          'name': _nameController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'email': _emailController.text.trim(),
          'program': _programController.text.trim(),
          'semester': _semesterController.text.trim(),
        });
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GCWUFTheme.backgroundColor,
                    GCWUFTheme.primaryColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Animated floating circles
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              double value = _animController.value * 20;
              return Stack(
                children: [
                  _FloatingCircle(
                    top: -60 + value,
                    left: -40,
                    size: 140,
                    opacity: 0.05,
                  ),
                  _FloatingCircle(
                    bottom: -50 - value,
                    right: -30,
                    size: 160,
                    opacity: 0.07,
                  ),
                  _FloatingCircle(
                    top: 180 - value,
                    right: 80,
                    size: 100,
                    opacity: 0.06,
                  ),
                  _FloatingCircle(
                    bottom: 200 + value,
                    left: 70,
                    size: 90,
                    opacity: 0.05,
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Modern AppBar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
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
                  ),

                  const SizedBox(height: 30),

                  // Profile Avatar with glass effect
                  GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: GCWUFTheme.primaryColor
                                .withOpacity(0.2),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_imageUrl != null && _imageUrl!.isNotEmpty
                                      ? NetworkImage(_imageUrl!)
                                      : null),
                            child:
                                (_imageFile == null &&
                                    (_imageUrl == null || _imageUrl!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: GCWUFTheme.primaryColor,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Fields inside scrollable expanded to avoid bottom overflow
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _editableField("Name", _nameController),
                          _editableField("Student ID", _studentIdController),
                          _editableField("Email", _emailController),
                          _editableField("Program", _programController),
                          _editableField("Semester", _semesterController),
                          const SizedBox(height: 25),

                          // Save button
                          GestureDetector(
                            onTap: _loading ? null : _saveProfile,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    GCWUFTheme.primaryColor,
                                    GCWUFTheme.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: GCWUFTheme.primaryColor.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Save Profile",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
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

  Widget _editableField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

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
