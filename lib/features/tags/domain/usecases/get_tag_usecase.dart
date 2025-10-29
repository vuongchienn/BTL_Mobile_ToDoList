import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class GetTagsUseCase {
  final TagRepository repository;
  GetTagsUseCase(this.repository);

  Future<List<Tag>> call() async {
    return await repository.getTags();
  }
}