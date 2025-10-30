import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../data/datasources/note_remote_data_source.dart';
import '../../data/repositories/note_repository_impl.dart';
import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _noteController = TextEditingController();

  GetNotesUseCase? _getNotesUseCase;
  CreateNoteUseCase? _createNoteUseCase;
  UpdateNoteUseCase? _updateNoteUseCase;
  DeleteNoteUseCase? _deleteNoteUseCase;

  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    final token = await AuthStorage.getToken();

    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final dataSource = NoteRemoteDataSource(dio);
    final repository = NoteRepositoryImpl(dataSource);

    setState(() {
      _getNotesUseCase = GetNotesUseCase(repository);
      _createNoteUseCase = CreateNoteUseCase(repository);
      _updateNoteUseCase = UpdateNoteUseCase(repository);
      _deleteNoteUseCase = DeleteNoteUseCase(repository);
    });

    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    if (_getNotesUseCase == null) return;
    setState(() => _isLoading = true);
    final notes = await _getNotesUseCase!(10);
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _createNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty || _createNoteUseCase == null) return;

    await _createNoteUseCase!(content);
    _noteController.clear();
    _fetchNotes();
  }

  Future<void> _updateNoteDialog(Note note) async {
    final controller = TextEditingController(text: note.content);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa ghi chú'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nhập nội dung mới...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (updated != null &&
        updated.trim().isNotEmpty &&
        _updateNoteUseCase != null) {
      await _updateNoteUseCase!(note.id, updated.trim());
      _fetchNotes();
    }
  }

  Future<void> _deleteNoteConfirm(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xoá ghi chú'),
          content: const Text('Bạn có chắc muốn xoá ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );

    if (confirm == true && _deleteNoteUseCase != null) {
      await _deleteNoteUseCase!(note.id);
      _fetchNotes();
    }
  }

  void _onNoteTap(Note note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa ghi chú'),
                onTap: () {
                  Navigator.pop(context);
                  _updateNoteDialog(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xoá ghi chú'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNoteConfirm(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEF6820);

    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange),
            onPressed: () => context.go(AppRoutes.home),
          ),
          titleSpacing: 0,
          centerTitle: false,
          title: GestureDetector(
            onTap: () => context.go(AppRoutes.home), // ✅ bấm chữ cũng quay lại
            child: const Text(
              'Ghi chú',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState(accent)
              : _buildNotesList(),
      bottomNavigationBar: _buildInputBar(accent),
    );
  }

  /// Giao diện khi chưa có ghi chú
  Widget _buildEmptyState(Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, color: accent, size: 80),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _createNote,
            icon: Icon(Icons.add_circle_outline, color: accent),
            label: Text(
              'Thêm ghi chú',
              style: TextStyle(color: accent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách ghi chú
  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return GestureDetector(
          onTap: () => _onNoteTap(note),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Thanh nhập ghi chú
  Widget _buildInputBar(Color accent) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Viết ghi chú',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _createNote,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration:  BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}