import 'package:dio/dio.dart';
import '../models/task_group_model.dart';

class TaskGroupRemoteDataSource {
  final Dio dio;
  TaskGroupRemoteDataSource(this.dio);

  Future<List<TaskGroupModel>> getTaskGroups() async {
    final response = await dio.get('/task-groups');
    final raw = response.data['data'] as List;
    return raw.map((e) => TaskGroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskGroupModel> createTaskGroup(String name) async {
    final response = await dio.post('/task-groups/create', data: {'name': name});
    return TaskGroupModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<TaskGroupModel> updateTaskGroup(int id, String name) async {
    final response = await dio.put('/task-groups/update/$id', data: {'name': name});
    return TaskGroupModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTaskGroup(int id) async {
    await dio.delete('/task-groups/delete/$id');
  }
}