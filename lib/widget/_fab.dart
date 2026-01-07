import 'package:flutter/material.dart';
import 'package:todo_app/page/add_task.dart';

class FabButton extends StatelessWidget {
  const FabButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        );
      },
      child: Container(
        height: 64,
        width: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF6F4BFF), Color(0xFF8A6CFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 34),
      ),
    );
  }
}