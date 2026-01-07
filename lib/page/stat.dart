import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/widget/_bottomNav.dart';
import 'package:todo_app/widget/_fab.dart';
import 'package:todo_app/widget/_header.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _currentIndex =
      2; // 2 = Stats (giả sử thứ tự: Home, Projects, Stats, Profile)

  Map<String, dynamic>? _currentUser;

  Box? _taskBox;
  Box? _userBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _taskBox = await Hive.openBox('task_box');
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

  int get totalTasks {
    if (_taskBox == null || _taskBox!.isEmpty) return 0;
    return _taskBox!.values.length;
  }

  int get completedTasks {
    if (_taskBox == null || _taskBox!.isEmpty) return 0;
    return _taskBox!.values.where((task) {
      final map = task as Map<dynamic, dynamic>?;
      return map?['done'] == true;
    }).length;
  }

  int get pendingTasks => totalTasks - completedTasks;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(name: _currentUser!['name']),
                const SizedBox(height: 25),

                // 3 Card tổng quan
                _overviewCards(),
                const SizedBox(height: 30),

                // Tiêu đề phần Category Stats
                _sectionTitle("Danh sách toàn bộ công việc"),
                const SizedBox(height: 20),

                // Danh sách các category
                ValueListenableBuilder<Box>(
                  valueListenable: _taskBox!.listenable(),
                  builder: (context, Box box, _) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            "Chưa có công việc nào.\nThêm ngay nhé!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    final tasks = box.values.toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index] as Map<dynamic, dynamic>;
                        final isDone = task['done'] ?? false;
                        final title = task['title'] ?? 'Không có tiêu đề';
                        final desc = task['desc'] ?? '';
                        final deadline = task['deadline'] != null
                            ? DateTime.parse(task['deadline'])
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // ← quan trọng để căn trên
                              children: [
                                // Phần bên trái (mô tả + ngày)
                                Flexible(
                                  // ← Cho phép co giãn, tự xuống hàng khi cần
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (desc.isNotEmpty)
                                        Text(
                                          desc,
                                          style: const TextStyle(fontSize: 13),
                                          maxLines:
                                              3, // Tăng lên 3 dòng nếu muốn
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        deadline != null
                                            ? DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(deadline)
                                            : 'Không có hạn',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              deadline != null &&
                                                  deadline.isBefore(
                                                    DateTime.now(),
                                                  )
                                              ? Colors.redAccent
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Phần bên phải (trạng thái hoàn thành)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                  ), // Khoảng cách nhỏ
                                  child: Text(
                                    isDone
                                        ? "Đã hoàn thành"
                                        : "Chưa hoàn thành",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDone
                                          ? Colors.green
                                          : const Color.fromARGB(
                                              255,
                                              255,
                                              124,
                                              114,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 100), // để tránh bị FAB che
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabButton(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _overviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _bigStatCard(
                title: "Tổng công việc",
                value: totalTasks.toString(),
                color: Colors.blueAccent,
                icon: Icons.list_alt_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bigStatCard(
                title: "Đã hoàn thành",
                value: completedTasks.toString(),
                color: Colors.greenAccent,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _bigStatCard(
          title: "Chưa hoàn thành",
          value: pendingTasks.toString(),
          color: Colors.orangeAccent,
          icon: Icons.hourglass_empty_rounded,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _bigStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }
}
