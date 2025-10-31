import 'package:btl_mobile_todolist/features/tasks/domain/entities/task.dart';
import 'package:btl_mobile_todolist/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<TaskEntity?> call({
    required String title,
    required String description,
    required int groupId,
    required DateTime dueDate,
    required String time, // <--- đổi sang String
    required int dueDateSelect,
    required int repeatType,
    int? repeatOption,
    int? repeatInterval,
    DateTime? repeatDueDate,
    List<int>? tagIds,
  }) {
    return repository.createTask(
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