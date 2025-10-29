
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_data_source.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;
  TagRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Tag>> getTags() async {
    final models = await remoteDataSource.getTags();
    return models.map((e) => Tag(
      id: e.id,
      name: e.name,
      isAdminCreated: e.isAdminCreated,
      userId: e.userId,
    )).toList();
  }

  @override
  Future<Tag> createTag(String name) async {
    final model = await remoteDataSource.createTag(name);
    return Tag(
      id: model.id,
      name: model.name,
      isAdminCreated: model.isAdminCreated,
      userId: model.userId,
    );
  }

  @override
  Future<Tag> updateTag(int id, String name) async {
    final model = await remoteDataSource.updateTag(id, name);
    return Tag(
      id: model.id,
      name: model.name,
      isAdminCreated: model.isAdminCreated,
      userId: model.userId,
    );
  }

  @override
  Future<void> deleteTag(int id) async {
    await remoteDataSource.deleteTag(id);
  }
}