import '../repositories/task_repository.dart';
import '../entities/task.dart';

class SearchTasksByTitleUseCase {
  final TaskRepository _repository;

  SearchTasksByTitleUseCase(this._repository);

  Future<Map<String, List<TaskEntity>>> call(String title) async {
    return await _repository.searchTasksByTitle(title);
  }
   Future<bool> updateTask({
    required int taskDetailId,
    required String title,
    required String description,
    required String dueDate,
    required String time,
    required List<int> tagIds,
    required int priority, 
  }) {
    return _repository.updateTask(
      taskDetailId: taskDetailId,
      title: title,
      description: description,
      dueDate: dueDate,
      time: time,
      tagIds: tagIds,
      priority: priority
    );
  }
}