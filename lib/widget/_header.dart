// lib/shared/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget {
  final String name;

  const AppHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: const AssetImage("assets/profile.jpg"),
              onBackgroundImageError: (_, __) =>
                  const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Xin chào!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  name.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        // IconButton(
        //   icon: const Icon(Icons.notifications_none_rounded, size: 28),
        //   onPressed: () => ScaffoldMessenger.of(
        //     context,
        //   ).showSnackBar(const SnackBar(content: Text("No new notifications"))),
        // ),
      ],
    );
  }
}

