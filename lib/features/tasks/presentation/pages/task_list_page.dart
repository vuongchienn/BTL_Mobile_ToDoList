import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/entities/task.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';
import 'package:intl/intl.dart';
import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../tags/data/models/tag_model.dart';
class TaskListPage extends StatefulWidget {
  final String title;
  final String type;

  const TaskListPage({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late GetTasksUseCase _getTasksUseCase;
  Map<String, List<TaskEntity>> _groupedTasks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final token = await AuthStorage.getToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final taskRemoteDataSource = TaskRemoteDataSource(dio);
      final taskRepository = TaskRepositoryImpl(taskRemoteDataSource);
      _getTasksUseCase = GetTasksUseCase(taskRepository);

      await _fetchTasks();
    } catch (e) {
      debugPrint('Init error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = widget.type == 'completed'
          ? await _getTasksUseCase.getCompletedTasks()
          : widget.type == 'deleted'
              ? await _getTasksUseCase.getDeletedTasks()
              : await _getTasksUseCase.call(widget.type);
      debugPrint('Fetched tasks: $tasks');
      setState(() {
        _groupedTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      setState(() {
        _groupedTasks = {};
        _isLoading = false;
      });
    }
  }
    Future<void> _showEditBottomSheet(TaskEntity task) async {
  final titleController = TextEditingController(text: task.title);
  final descriptionController =
      TextEditingController(text: task.description ?? '');
  DateTime? selectedDate =
      task.dueDate.isNotEmpty ? DateTime.tryParse(task.dueDate) : null;
  TagModel? selectedTag;

  // 🟢 Thêm biến priority
  int priority = task.priority ?? 0; // giả sử TaskEntity có priority, nếu chưa có thì mặc định = 0

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF6820)),
                        child: const Text(
                          'Hủy bỏ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Vui lòng điền đầy đủ thông tin')),
                            );
                            return;
                          }

                          try {
                            final formattedDate =
                                DateFormat('yyyy-MM-dd').format(selectedDate!);
                            final formattedTime = '00:00'; // vì task không có giờ
                            final tagIds =
                                selectedTag != null ? [selectedTag!.id] : [];

                            final updatedTask = await _getTasksUseCase.updateTask(
                              taskDetailId: task.id,
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              dueDate: formattedDate,
                              time: formattedTime,
                              tagIds: tagIds.cast<int>(),
                              priority: priority, // 🟢 gửi priority
                            );

                            if (updatedTask != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Cập nhật task thành công')),
                              );
                              Navigator.pop(context);
                              await _fetchTasks(); // reload danh sách
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Lỗi khi cập nhật: $e')),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF6820)),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tiêu đề',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🟡 Description + Icon Star
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ô mô tả chiếm phần lớn
                      Expanded(
                        child: TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Mô tả',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Icon ngôi sao
                      IconButton(
                        icon: Icon(
                          Icons.star,
                          color: priority == 1
                              ? Colors.red
                              : Colors.grey.shade400,
                        ),
                        onPressed: () {
                          setState(() {
                            priority = (priority == 1) ? 0 : 1;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000), // 👈 cho phép chọn từ năm 2000 trở đi
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                      if (selectedDate != null)
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate!),
                          style: const TextStyle(
                              color: Color(0xFFEF6820), fontSize: 15),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEF6820);
      String getTitle() {
    switch (widget.type) {
      case 'there_days':
        return '< 3 ngày tới';
      case 'completed':
        return 'Đã hoàn thành';
      case 'deleted':
        return 'Đã xóa';
      default:
        return widget.title;
    }
  }
    return Scaffold(
      appBar: AppBar(
                leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange),
          onPressed: () => context.go(AppRoutes.home), // quay về home
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: GestureDetector(
          onTap: () => context.go(AppRoutes.home), // bấm chữ cũng quay về home
          child: Text(
            getTitle(), // tiêu đề động theo type
            style: const TextStyle(
              color: Colors.orange, // màu cam
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEF6820)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedTasks.isEmpty
              ? EmptyTaskWidget(
                  accent: accent,
                  onCreatePressed: () {
                    // TODO: Thêm logic tạo task
                  },
                )
              : RefreshIndicator(
                  onRefresh: _fetchTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groupedTasks.length,
                    itemBuilder: (context, index) {
                      final groupEntry = _groupedTasks.entries.elementAt(index);
                      final groupName = groupEntry.key;
                      final tasks = groupEntry.value;
                      final taskCount = tasks.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    groupName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$taskCount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...tasks.map((task) => TaskItemWidget(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                dueDate: task.dueDate.isNotEmpty
                                    ? DateTime.tryParse(task.dueDate)
                                    : null,
                                isImportant: task.isImportant,
                                isRepeating: task.isRepeating,
                                tags: task.tags,
                                isDeleted: widget.type == 'deleted',
                                onEdit: () => _showEditBottomSheet(task),
                              )),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}