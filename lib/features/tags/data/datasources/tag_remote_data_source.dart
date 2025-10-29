import 'package:dio/dio.dart';
import '../models/tag_model.dart';

class TagRemoteDataSource {
  final Dio dio;
  TagRemoteDataSource(this.dio);

  Future<List<TagModel>> getTags() async {
    final response = await dio.get('/tags');
    final data = response.data['data'] as List;
    return data.map((json) => TagModel.fromJson(json)).toList();
  }

  Future<TagModel> createTag(String name) async {
    final response = await dio.post('/tags/create', data: {'name': name});
    return TagModel.fromJson(response.data['data']);
  }

  Future<TagModel> updateTag(int id, String name) async {
    final response = await dio.put('/tags/update/$id', data: {'name': name});
    return TagModel.fromJson(response.data['data']);
  }

  Future<void> deleteTag(int id) async {
    await dio.delete('/tags/delete/$id');
  }
}