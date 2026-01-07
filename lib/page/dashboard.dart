import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/page/add_task.dart';
import 'package:todo_app/widget/_bottomNav.dart';
import 'package:todo_app/widget/_fab.dart';
import 'package:todo_app/widget/_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int selectedNavIndex = 0; // 0 = Home
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

  // Tính % hoàn thành hôm nay (giả lập)
  double get todayProgress => 0.85;
  int get todayDone => 17;
  int get todayTotal => 20;

  @override
  Widget build(BuildContext context) {
    if (_taskBox == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                AppHeader(name: _currentUser?['name'] ?? 'Guest'),
                const SizedBox(height: 25),
                _taskProgressCard(),
                const SizedBox(height: 50),
                _sectionTitle("Danh sách công việc", _taskBox!.length),
                const SizedBox(height: 20),
                // Phần danh sách task từ Hive - dùng ValueListenableBuilder
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
                            leading: Checkbox(
                              value: isDone,
                              activeColor: const Color(0xFF6F4BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (value) async {
                                await box.putAt(index, {
                                  ...task,
                                  'done': value ?? false,
                                });

                                if (mounted) {
                                  setState(() {});
                                }
                              },
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (desc.isNotEmpty)
                                  Text(
                                    desc,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
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
                                            deadline.isBefore(DateTime.now())
                                        ? Colors.redAccent
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blueGrey,
                                  ),
                                  tooltip: 'Chỉnh sửa',
                                  onPressed: () {
                                    _editTask(context, task, index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Xóa',
                                  onPressed: () =>
                                      _deleteTask(context, box, index, title),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 100),
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

  Widget _taskProgressCard() {
    // Tính toán tiến độ thực tế từ toàn bộ tasks trong box
    //TODO: phải cập nhật ngay sau khi nhấn checkbox
    final tasks = _taskBox?.values.toList() ?? [];
    final totalTasks = tasks.length;
    final doneTasks = tasks.where((task) {
      final map = task as Map<dynamic, dynamic>;
      return map['done'] == true;
    }).length;

    final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;
    final percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C5CFF), Color(0xFF9B7EFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFF).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Phần text bên trái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tổng quan công việc",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    totalTasks == 0
                        ? "Chưa có nhiệm vụ"
                        : "$doneTasks/$totalTasks hoàn thành",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Vòng tròn tiến độ
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 94,
                height: 94,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.18),
                ),
              ),
              SizedBox(
                width: 94,
                height: 94,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    totalTasks == 0 ? "-" : "$percent%",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "hoàn thành",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          "($count)",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black45),
        ),
      ],
    );
  }

  // Xóa task với confirm dialog
  Future<void> _deleteTask(
    BuildContext context,
    Box box,
    int index,
    String title,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa công việc:\n'$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await box.deleteAt(index);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đã xóa công việc")));
      }
    }
  }

  // Chuyển sang màn hình chỉnh sửa
  void _editTask(BuildContext context, Map<dynamic, dynamic> task, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          taskToEdit: task, // Truyền task hiện tại
          editIndex: index, // Truyền index để biết cần update ở vị trí nào
        ),
      ),
    );
  }
}
