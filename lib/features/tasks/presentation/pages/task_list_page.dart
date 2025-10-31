import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/entities/task.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';

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

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEF6820);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
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
                                title: task.title,
                                description: task.description,
                                dueDate: task.dueDate.isNotEmpty
                                    ? DateTime.parse(task.dueDate)
                                    : null,
                                isImportant: task.isImportant,
                                isRepeating: task.isRepeating,
                                tags: task.tags,
                                isDeleted: widget.type == 'deleted', // Thêm flag để nhận diện task đã xóa
                              )).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}