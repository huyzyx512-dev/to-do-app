// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/widget/_bottomNav.dart';
import 'package:todo_app/widget/_fab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  Map<String, dynamic>? _currentUser;

  Box? _userBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _userBox = await Hive.openBox('user_box');
    // tìm user đang đăng nhập
    for (var key in _userBox!.keys) {
      final user = _userBox!.get(key);
      if (user is Map && user['isActive'] == true) {
        _currentUser = Map<String, dynamic>.from(user);
        break;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FF), Color(0xFFFDFDFF), Color(0xFFF0F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "My Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Avatar + Info
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage("assets/profile.jpg"),
                        onBackgroundImageError: (_, __) => null,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?['name'] ?? 'No name',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentUser?['email'] ?? 'No email',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 70),

                      // Nút Sign Out
                      _buildGradientButton(
                        text: "Sign Out",
                        onTap: () async {
                          final String? email =
                              _currentUser!['email'] as String?;

                          if (email != null &&
                              email.isNotEmpty &&
                              _userBox != null) {
                            final user = _userBox?.get(email);

                            if (user is Map) {
                              // Tạo bản copy và set isActive = false
                              final updated = Map<String, dynamic>.from(user);
                              updated['isActive'] = false;

                              // Lưu lại
                              await _userBox!.put(email, updated);
                            }
                          }
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/signin',
                            (route) => false,
                          );
                        },
                      ),

                      const SizedBox(
                        height: 100,
                      ), // khoảng trống cho FAB + BottomNav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabButton(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ), // Profile tab
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6F4BFF), Color(0xFF8A6CFF)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
