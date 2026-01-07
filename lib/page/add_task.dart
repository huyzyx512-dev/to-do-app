import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/page/dashboard.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? taskToEdit;
  final int? editIndex;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
    this.editIndex,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  DateTime? _deadline;
  bool _isLoading = false;
  bool _isEditMode = false;

  Box? _taskBox;

  @override
  void initState() {
    super.initState();

    // Khởi tạo controllers
    _titleController = TextEditingController();
    _descController = TextEditingController();

    _isEditMode = widget.taskToEdit != null && widget.editIndex != null;

    // Điền dữ liệu nếu đang edit
    if (_isEditMode) {
      final task = widget.taskToEdit!;
      _titleController.text = task['title']?.toString() ?? '';
      _descController.text = task['desc']?.toString() ?? '';

      if (task['deadline'] != null) {  // sửa key từ 'deline' → 'deadline'
        try {
          _deadline = DateTime.parse(task['deadline'].toString());
        } catch (_) {
          _deadline = null;
        }
      }
    }

    _openBox();
  }

  Future<void> _openBox() async {
    _taskBox = await Hive.openBox('task_box');
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6F4BFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final taskData = {
      'title': _titleController.text.trim(),
      'desc': _descController.text.trim(),
      'deadline': _deadline?.toIso8601String(),
      'done': widget.taskToEdit?['done'] ?? false, // giữ trạng thái done nếu edit
    };

    try {
      if (_isEditMode) {
        // Update task hiện có
        await _taskBox?.putAt(widget.editIndex!, taskData);
      } else {
        // Thêm mới
        await _taskBox?.add(taskData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? "Đã cập nhật công việc!" : "Đã thêm công việc!"),
          backgroundColor: Colors.green,
        ),
      );

      // Quay về Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _textFieldCard(
                          title: "Tên công việc",
                          controller: _titleController,
                          hintText: "Ví dụ: Tập thể dục buổi sáng",
                          validator: (value) =>
                              value?.trim().isEmpty ?? true ? "Vui lòng nhập tên công việc" : null,
                        ),
                        const SizedBox(height: 20),
                        _textFieldCard(
                          title: "Mô tả",
                          controller: _descController,
                          hintText: "Chi tiết công việc...",
                          maxLines: 6,
                          height: 160,
                        ),
                        const SizedBox(height: 20),
                        _dateCard("Hạn hoàn thành", _deadline),
                        const SizedBox(height: 40),
                        _bottomButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                _isEditMode ? "Chỉnh sửa công việc" : "Thêm mới công việc",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Icon(Icons.notifications_none_rounded, size: 26),
        ],
      ),
    );
  }

  Widget _textFieldCard({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    double height = 120,
    String? Function(String?)? validator,
  }) {
    return _cardWrapper(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard(String label, DateTime? date) {
    return _cardWrapper(
      height: 90,
      child: GestureDetector(
        onTap: _pickDeadline,
        child: Row(
          children: [
            _iconBox(Icons.calendar_month, Colors.purple.shade400),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date != null
                        ? DateFormat('dd MMM, yyyy').format(date)
                        : "Chọn ngày",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: date != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveTask,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : const LinearGradient(colors: [Color(0xFF6F4BFF), Color(0xFF8A6CFF)]),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isEditMode ? "Cập nhật" : "Thêm công việc",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // Giữ nguyên các widget helper
  Widget _cardWrapper({required Widget child, double height = 110}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}