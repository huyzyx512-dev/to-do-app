import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/page/add_task.dart';
import 'package:todo_app/page/dashboard.dart';
import 'package:todo_app/page/let_start.dart';
import 'package:todo_app/page/profile.dart';
import 'package:todo_app/page/signin.dart';
import 'package:todo_app/page/signup.dart';
import 'package:todo_app/page/stat.dart';
import 'package:todo_app/page/today_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
      initialRoute: '/',
      routes: {
        '/signin': (_) => const SignIn(),
        '/signup': (_) => const SignUp(),
        '/': (_) => const LetStartScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/add-tasks': (_) => const AddTaskScreen(),
        '/today-tasks': (_) => const TodaysTasksScreen(),
        '/stats': (_) => const StatsScreen(),
      },
      //TODO:xem lại kỹ bài để hỏi thi
    );
  }
}


