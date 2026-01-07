import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/page/add_task.dart';
import 'package:todo_app/widget/_bottomNav.dart';
import 'package:todo_app/widget/_fab.dart';

class TodaysTasksScreen extends StatefulWidget {
  const TodaysTasksScreen({super.key});

  @override
  State<TodaysTasksScreen> createState() => _TodaysTasksScreenState();
}

class _TodaysTasksScreenState extends State<TodaysTasksScreen> {
  DateTime selectedDate = DateTime.now();
  int selectedFilterIndex = 0;
  int _currentIndex = 1; // Calendar tab

  Box? _taskBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _taskBox = await Hive.openBox('task_box');
    setState(() {});
  }

  // Lấy ngày hiện tại
  DateTime get today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Công việc hôm nay",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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

                  // Lọc tasks có deadline là hôm nay
                  final todayTasks = box.values.where((task) {
                    final map = task as Map<dynamic, dynamic>;
                    final deadlineStr = map['deadline'] as String?;
                    if (deadlineStr == null) return false;

                    final deadline = DateTime.tryParse(deadlineStr);
                    if (deadline == null) return false;

                    // So sánh chỉ năm-tháng-ngày
                    return deadline.year == today.year &&
                        deadline.month == today.month &&
                        deadline.day == today.day;
                  }).toList();

                  if (todayTasks.isEmpty) {
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

                  //
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Danh sách công việc",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "(${todayTasks.length})",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayTasks.length,
                          itemBuilder: (context, index) {
                            final task =
                                todayTasks[index] as Map<dynamic, dynamic>;
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
                                    await box.putAt(
                                      box.values.toList().indexOf(task),
                                      {...task, 'done': value ?? false},
                                    );
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
                                                deadline.isBefore(
                                                  DateTime.now(),
                                                )
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
                                      onPressed: () => _editTask(
                                        context,
                                        task,
                                        box.values.toList().indexOf(task),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () => _deleteTask(
                                        context,
                                        box,
                                        box.values.toList().indexOf(task),
                                        title,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabButton(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
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
