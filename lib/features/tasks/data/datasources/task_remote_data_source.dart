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
}