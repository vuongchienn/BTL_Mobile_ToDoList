import '../entities/task_group.dart';

abstract class TaskGroupRepository {
  Future<List<TaskGroup>> getTaskGroups();
  Future<TaskGroup> createTaskGroup(String name);
  Future<TaskGroup> updateTaskGroup(int id, String name);
  Future<void> deleteTaskGroup(int id);
}