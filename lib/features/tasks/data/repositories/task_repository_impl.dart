import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import 'package:flutter/material.dart';
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, List<TaskEntity>>> getTasksByType(String type) {
    return remoteDataSource.getTasks(type);
  }
    @override
  Future<Map<String, List<TaskEntity>>> getCompletedTasks() {
    return remoteDataSource.getCompletedTasks();
  }

  @override
  Future<Map<String, List<TaskEntity>>> getDeletedTasks() {
    return remoteDataSource.getDeletedTasks();
  }
  @override
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
  }) {
    return remoteDataSource.createTask(
      title: title,
      description: description,
      groupId: groupId,
      dueDate: dueDate,
      time: time,
      dueDateSelect: dueDateSelect,
      repeatType: repeatType,
      repeatOption: repeatOption,
      repeatInterval: repeatInterval,
      repeatDueDate: repeatDueDate,
      tagIds: tagIds,
    );
  }
}