import 'package:dio/dio.dart';
import '../models/note_model.dart';

class NoteRemoteDataSource {
  final Dio dio;
  NoteRemoteDataSource(this.dio);

  Future<List<NoteModel>> getNotes(int paginate) async {
    final response = await dio.get('/notes/$paginate');
    final List<dynamic> raw = response.data['data'];
    return raw.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<NoteModel> createNote(String content) async {
    final response = await dio.post('/notes/create', data: {
      'content': content,
    });
    return NoteModel.fromJson(response.data['data']);
  }

  Future<NoteModel> updateNote(int id, String content) async {
    final response = await dio.put('/notes/update/$id', data: {
      'content': content,
    });
    return NoteModel.fromJson(response.data['data']);
  }

  Future<void> deleteNote(int id) async {
    await dio.delete('/notes/delete/$id');
  }
}