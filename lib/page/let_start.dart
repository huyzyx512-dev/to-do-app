import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/page/signin.dart';

class LetStartScreen extends StatelessWidget {
  const LetStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F7FF), Color(0xFFFFFFFF), Color(0xFFEFF6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Image.asset("assets/images/task_person.png", height: 260)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .moveY(begin: 30, curve: Curves.easeOut),

                const SizedBox(height: 30),

                // Title
                Text(
                  "Quản lý công việc",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 14),

                // Subtitle
                Text(
                  "Công cụ này được thiết kế để giúp bạn quản lý công việc của mình tốt hơn!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 50),

                // NÚT GRADIENT ĐẸP NHẤT 2025 (không cần package nào thêm)
                AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            // Navigator.pushReplacementNamed(context, '/todos');
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SignIn(),
                              ),
                            );
                          },
                          hoverColor: Colors.white.withOpacity(0.1),
                          child: Ink(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6F4BFF), Color(0xFF9D7EFF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6F4BFF,
                                  ).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Hãy bắt đầu",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.9, 0.9), // phóng to đồng đều từ tâm
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
