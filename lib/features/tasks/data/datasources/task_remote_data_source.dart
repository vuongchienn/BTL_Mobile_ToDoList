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
        final data = response.data;

      // ✅ Nếu backend trả object task → parse luôn
      if (data is Map<String, dynamic>) {
        return TaskEntity.fromJson(data);
      }
      // ✅ Nếu backend trả true/false → bỏ qua
      print('⚠️ Response không phải là Map (giá trị: $data)');
      return null;
    }
      return null;
    } catch (e) {
      print('Lỗi khi tạo task: $e');
      return null;
    }
  }
  Future<bool> updateTask({
    required int taskDetailId,
    required String title,
    required String description,
    required String dueDate,
    required String time,
    required List<int> tagIds,
    required int priority,
  }) async {
    try {
      final response = await dio.put(
        '/task/update/$taskDetailId',
        data: {
          'title': title,
          'description': description,
          'due_date': dueDate,
          'time': time,
          'priority': priority,
          'tag_ids': tagIds,
        },
      );

      print('🟢 UpdateTask status: ${response.statusCode}');
      print('🟢 UpdateTask response: ${response.data}');

      // Nếu API trả về { data: true, message: "..." }
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final isSuccess = data['data'] == true;
        return isSuccess;
      }

      return false;
    } catch (e) {
      print('❌ Lỗi khi cập nhật task: $e');
      return false;
    }
  }
      // task_remote_data_source.dart
Future<bool> deleteTask(int taskId) async {
  try {
    final response = await dio.post('/task/bin/$taskId');
    print('🟢 DeleteTask status: ${response.statusCode}');

    // Chỉ cần check status 200 là coi như thành công
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Lỗi khi xóa task: $e');
    return false;
  }
}

 Future<bool> completeTask(int taskId) async {
    try {
      final response = await dio.post('/task/updateStatusToDone/$taskId'); // endpoint Laravel
      print('🟢 CompleteTask status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Lỗi khi hoàn thành task: $e');
      return false;
    }
  }


   Future<Map<String, List<TaskEntity>>> searchTasksByTitle(String title) async {
    try {
      final response = await dio.post(
        '/task/search',
        data: {'title': title},
      );
      print('API response for searchTasksByTitle: ${response.data}'); // Debug log

      if (response.statusCode != 200) {
        print('Lỗi HTTP khi tìm kiếm: ${response.statusCode} - ${response.data}');
        return {};
      }

      final data = response.data['data'];
      if (data == null) {
        print('Dữ liệu "data" từ API là null khi tìm kiếm với tiêu đề: $title');
        return {};
      }

      if (data is! Map<String, dynamic>) {
        print('Dữ liệu "data" không phải là Map<String, dynamic>: $data');
        return {};
      }

      final Map<String, dynamic> rawData = data as Map<String, dynamic>;
      final Map<String, List<TaskEntity>> groupedTasks = {};

      rawData.forEach((key, value) {
        if (value is List) {
          groupedTasks[key] = value
              .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          print('Giá trị của key $key không phải là List: $value');
        }
      });

      return groupedTasks;
    } catch (e) {
      print('Lỗi khi tìm kiếm task: $e');
      return {};
    }
  }

  
}