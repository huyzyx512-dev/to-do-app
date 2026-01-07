import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/page/signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final bool _isLoading = false;

  Box? _userBox;

  String? _passwordError;
  String? _emailError;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    Hive.openBox("user_box").then((_box) {
      setState(() {
        _userBox = _box;
      });
    });
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
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Tạo tài khoản",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tham gia ngay!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 50),

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
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Full Name",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                        ),
                        icon: Icon(
                          Icons.person_outline,
                          color: const Color(0xFF6F4BFF),
                        ),
                      ),
                    ),
                  ),
                  if (_nameError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 6),
                      child: Text(
                        _nameError!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
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

                  /// ERROR TEXT BÊN NGOÀI
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

                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _nameError = null;
                        _emailError = null;
                        _passwordError = null;

                        final email = _emailController.text
                            .trim()
                            .toLowerCase();

                        if (_nameController.text.isEmpty) {
                          _nameError = "Vui lòng nhập tên";
                        }
                        if (email.isEmpty) {
                          _emailError = "Vui lòng nhập email";
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(email) &&
                            _emailError == null) {
                          _emailError = "Định dạng email không đúng";
                        }
                        if (_passwordController.text.isEmpty) {
                          _passwordError = "Vui lòng nhập mật khẩu";
                        }
                         if (_passwordController.text.length < 6) {
                          _passwordError = "Mật khẩu phải có ít nhất 6 ký tự";
                        }

                        if (_nameError == null &&
                            _emailError == null &&
                            _passwordError == null) {
                          // Insert new user
                          _userBox!.put(email, {
                            'name': _nameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'password': _passwordController.text.trim(),
                            'isActive' : false
                          });
                          // "user1@gmail.com": {
                          //     "name": "Trần Thị B",
                          //     "email": "user1@gmail.com",
                          //     "password": "abc123",
                          //     "isActive": false
                          // },

                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const SignIn(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đăng ký thành công"),
                              backgroundColor: Colors.green,
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
                                _isLoading ? "Đang tạo..." : "Đăng ký",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Đã có tài khoản? ",
                        style: GoogleFonts.poppins(),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Đăng nhập",
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
