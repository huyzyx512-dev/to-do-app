// lib/shared/widgets/app_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const List<String> _routers = [
    "/dashboard",
    "/today-tasks",
    "/stats",
    "/profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, "Trang chủ", 0),
          _navItem(Icons.calendar_month_rounded, "Tasks", 1),
          const SizedBox(width: 60), // chỗ cho FAB
          _navItem(Icons.folder_rounded, "Thông kê", 2),
          _navItem(Icons.person_rounded, "Cá nhân", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = widget.currentIndex == index;
    final Color activeColor = const Color(0xFF6F4BFF);

    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        Navigator.pushNamed(context, _routers[index]);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: isActive ? activeColor : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isActive ? activeColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _bottomNav() {
//   int selectedBottomNavIndex = 1; // Calendar tab
//   final icons = [
//     Icons.home_rounded,
//     Icons.calendar_month_rounded,
//     null,
//     Icons.bar_chart_rounded,
//     Icons.person_rounded,
//   ];
//   final labels = ["Home", "Tasks", "", "Stats", "Profile"];

//   return Container(
//     height: 80,
//     decoration: const BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: icons.asMap().entries.map((entry) {
//         int idx = entry.key;
//         IconData? icon = entry.value;
//         if (icon == null) return const SizedBox(width: 60);

//         bool isActive = selectedBottomNavIndex == idx;

//         return GestureDetector(
//           onTap: () => setState(() => selectedBottomNavIndex = idx),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 30,
//                 color: isActive ? const Color(0xFF6F4BFF) : Colors.grey,
//               ),
//               Text(
//                 labels[idx],
//                 style: GoogleFonts.poppins(
//                   fontSize: 10,
//                   color: isActive ? const Color(0xFF6F4BFF) : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     ),
//   );
// }
