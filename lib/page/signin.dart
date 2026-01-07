import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/page/dashboard.dart';
import 'package:todo_app/page/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final bool _isLoading = false;

  Box? _userBox;

  String? _emailError;
  String? _passwordError;
  String? _isLogin;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _userBox = await Hive.openBox('user_box');
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FF), Color(0xFFFDFDFF), Color(0xFFF0F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    "Welcome Back!",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Đăng nhập để tiếp tục",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Input Email
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                        ),
                        icon: Icon(
                          Icons.email_outlined,
                          color: const Color(0xFF6F4BFF),
                        ),
                      ),
                    ),
                  ),

                  // Validate Email
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 6),
                      child: Text(
                        _emailError!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  //Input Password
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                        ),
                        icon: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF6F4BFF),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Validate Password
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 6),
                      child: Text(
                        _passwordError!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _emailError = null;
                        _passwordError = null;
                        _isLogin = null;

                        if (_emailController.text.isEmpty) {
                          _emailError = "Vui lòng nhập email";
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(
                              _emailController.text.trim(),
                            ) &&
                            _emailError == null) {
                          _emailError = "Định dạng email không đúng";
                        }
                        if (_passwordController.text.isEmpty) {
                          _passwordError = "Vui lòng nhập mật khẩu";
                        }

                        if (_emailError == null && _passwordError == null) {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          final user = _userBox!.get(email);

                          if (user == null) {
                            _isLogin = "Email hoặc mật khẩu không đúng";
                            return;
                          }

                          if (user['password'] != password) {
                            _isLogin = "Email hoặc mật khẩu không đúng";
                            return;
                          }

                          // Cập nhật trạng thái hoạt động của tk
                          user['isActive'] = true;
                          _userBox!.put(email, user);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DashboardScreen(), // sau này đổi sang Home
                            ),
                          );
                        }
                      });
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6F4BFF), Color(0xFF8A6CFF)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                _isLoading ? "Đang đăng nhập..." : "Đăng nhập",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Validate Password
                  if (_isLogin != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _isLogin!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn chưa có tài khoản? ",
                        style: GoogleFonts.poppins(),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUp()),
                        ),
                        child: Text(
                          "Đăng ký",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6F4BFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
