import '../../domain/entities/task_group.dart' as domain;
import '../../domain/repositories/task_group_repository.dart';
import '../datasources/task_group_remote_data_source.dart';

class TaskGroupRepositoryImpl implements TaskGroupRepository {
  final TaskGroupRemoteDataSource remoteDataSource;

  TaskGroupRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<domain.TaskGroup>> getTaskGroups() async {
    final models = await remoteDataSource.getTaskGroups();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<domain.TaskGroup> createTaskGroup(String name) async {
    final model = await remoteDataSource.createTaskGroup(name);
    return model.toEntity();
  }

  @override
  Future<domain.TaskGroup> updateTaskGroup(int id, String name) async {
    final model = await remoteDataSource.updateTaskGroup(id, name);
    return model.toEntity();
  }

  @override
  Future<void> deleteTaskGroup(int id) => remoteDataSource.deleteTaskGroup(id);
}
