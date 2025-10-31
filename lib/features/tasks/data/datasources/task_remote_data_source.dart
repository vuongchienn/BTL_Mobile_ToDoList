import 'package:dio/dio.dart';
import '../../domain/entities/task.dart';

class TaskRemoteDataSource {
  final Dio dio;
  TaskRemoteDataSource(this.dio);

  Future<Map<String, List<TaskEntity>>> getTasks(String type) async {
    final response = await dio.get(
      '/task', // Sử dụng đường dẫn tương đối, baseUrl đã được cấu hình trong Dio
      queryParameters: {'type': type},
    );

    final raw = response.data['data'] as Map<String, dynamic>;

    final Map<String, List<TaskEntity>> groupedTasks = {};

    raw.forEach((key, value) {
      if (key == 'total_tasks') return;
      groupedTasks[key] = (value as List)
          .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return groupedTasks;
  }
  // Thêm phương thức lấy task đã hoàn thành
  Future<Map<String, List<TaskEntity>>> getCompletedTasks() async {
    final response = await dio.get('/task/completed');

    final raw = response.data['data'] as Map<String, dynamic>;

    final Map<String, List<TaskEntity>> groupedTasks = {};

    raw.forEach((key, value) {
      if (key == 'total_tasks') return;
      groupedTasks[key] = (value as List)
          .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return groupedTasks;
  }

// Thêm phương thức lấy task đã bị xóa
  Future<Map<String, List<TaskEntity>>> getDeletedTasks() async {
    final response = await dio.get('/task/deleted');

    final raw = response.data['data'] as Map<String, dynamic>;

    final Map<String, List<TaskEntity>> groupedTasks = {};

    raw.forEach((key, value) {
      if (key == 'total_tasks') return;
      groupedTasks[key] = (value as List)
          .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return groupedTasks;
  }
  // Thêm phương thức tạo task
  Future<TaskEntity?> createTask({
    required String title,
    required String description,
    required int groupId,
    required DateTime dueDate,
    required String time, // <--- đổi từ TimeOfDay sang String
    required int dueDateSelect,
    required int repeatType,
    int? repeatOption,
    int? repeatInterval,
    DateTime? repeatDueDate,
    List<int>? tagIds,
  }) async {
    try {
      final dueDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      );


      final response = await dio.post(
        '/task/create',
        data: {
          'title': title,
          'description': description,
          'group_id': groupId,
          'due_date_select': dueDateSelect,
          'due_date': dueDateSelect == 4 ? dueDateTime.toIso8601String() : null,
          'time': time, // gửi trực tiếp chuỗi HH:mm
          'repeat_type': repeatType,
          'repeat_option': repeatOption,
          'repeat_interval': repeatInterval,
          'repeat_due_date': repeatDueDate?.toIso8601String(),
          'tag_ids': tagIds,
        },
      );

      if (response.statusCode == 200) {
        final taskData = response.data['data'] as Map<String, dynamic>;
        
        return TaskEntity.fromJson(taskData);
      }
      return null;
    } catch (e) {
      print('Lỗi khi tạo task: $e');
      return null;
    }
  }
}