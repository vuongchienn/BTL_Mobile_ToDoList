import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();
  Future<Tag> createTag(String name);
  Future<Tag> updateTag(int id, String name);
  Future<void> deleteTag(int id);
}