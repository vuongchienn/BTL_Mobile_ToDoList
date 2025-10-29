import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/home_section.dart';
import 'package:dio/dio.dart';
import 'package:btl_mobile_todolist/features/task_groups/data/datasources/task_group_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/task_groups/data/repositories/task_group_repository_impl.dart';
import '../../../task_groups/domain/usecases/create_task_group_usecase.dart';
import '../../../task_groups/domain/usecases/update_task_group_usecase.dart';
import '../../../task_groups/domain/usecases/delete_task_group_usecase.dart';
import '../../../task_groups/data/models/task_group_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Dio? _dio;
  TaskGroupRemoteDataSource? _remoteDataSource;
  TaskGroupRepositoryImpl? _repository;
  CreateTaskGroupUseCase? _createTaskGroupUseCase;
  UpdateTaskGroupUseCase? _updateTaskGroupUseCase;
  DeleteTaskGroupUseCase? _deleteTaskGroupUseCase;

  List<TaskGroupModel> _taskGroups = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    final token = await AuthStorage.getToken();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    _remoteDataSource = TaskGroupRemoteDataSource(_dio!);
    _repository = TaskGroupRepositoryImpl(_remoteDataSource!);
    _createTaskGroupUseCase = CreateTaskGroupUseCase(_repository!);
    _updateTaskGroupUseCase = UpdateTaskGroupUseCase(_repository!);
    _deleteTaskGroupUseCase = DeleteTaskGroupUseCase(_repository!);

    await _loadTaskGroups();
    setState(() => isLoading = false);

  }

  Future<void> _createTaskGroup(String name) async {
    if (name.isEmpty || _createTaskGroupUseCase == null) return;

    try {
      final newGroup = await _createTaskGroupUseCase!.call(name);
      await _loadTaskGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo nhóm "${newGroup.name}" thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }

  }

  Future<void> _loadTaskGroups() async {
    try {
      final groups = await _remoteDataSource!.getTaskGroups();
      setState(() {
        _taskGroups = groups;
      });
    } catch (e) {
      print('Lỗi khi load task groups: $e');
    }
  }


  Future<void> _showCreateTaskGroupDialog() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo nhóm'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập tên nhóm'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                await _createTaskGroup(name);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF6820),
              ),
              child: const Text('Tạo nhóm'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _deleteTaskGroup(int id) async {
    if (_remoteDataSource == null) return;
    try {

      await _deleteTaskGroupUseCase!(id);
      await _loadTaskGroups(); // Cập nhật danh sách sau khi xóa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa nhóm thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa nhóm: $e')),
      );
    }
  }

  void _showUpdateTaskGroupDialog(TaskGroupModel group) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cập nhật nhóm'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập tên mới'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  try {
                    final updatedGroup = await _updateTaskGroupUseCase!(group.id, controller.text.trim());
                    await _loadTaskGroups(); // Cập nhật danh sách sau khi sửa
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật nhóm "${updatedGroup.name}" thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi cập nhật nhóm: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF6820)),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTaskGroupOptions(TaskGroupModel group) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Đảm bảo backdrop mờ
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút "Sửa tên" với icon bút
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFFEF6820), size: 24),
                title: const Text('Sửa tên', style: TextStyle(color: Color(0xFFEF6820), fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateTaskGroupDialog(group);
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              // Nút "Xóa" với icon thùng rác
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red, size: 24),
                title: const Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTaskGroup(group.id);
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
    final accent = const Color(0xFFEF6820);

    if (_createTaskGroupUseCase == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert, color: Colors.black87),
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _loadTaskGroups,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildTaskSection(accent),
                  const SizedBox(height: 24),
                  const Text('Nhóm',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (_taskGroups.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text('Chưa có nhóm nào 😄',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    Column(
                      children: _taskGroups
                          .map(
                            (group) => Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(group.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: () => _showTaskGroupOptions(group),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  const SizedBox(height: 28),
                  const Text('Thẻ',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('Cá nhân', accent),
                      _buildTag('Công việc', accent),
                      _buildAddTag(accent),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔸 Cố định chữ “Tạo nhóm” góc phải dưới
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _showCreateTaskGroupDialog,
              child: const Text(
                'Tạo nhóm',
                style: TextStyle(
                  color: Color(0xFFEF6820),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildTaskSection(Color accent) {
    return Column(
      children: [
        const HomeSection(
          title: 'Hôm nay',
          count: 0,
          icon: Icons.check_circle_outline,
          color: Color(0xFFEF6820),
          highlighted: true,
          fullWidth: true,
          height: 50,
        ),
        const SizedBox(height: 12),

        Row(
          children: const [
            Expanded(
              child: HomeSection(
                title: '3 ngày tới',
                count: 0,
                icon: Icons.calendar_today_outlined,
                color: Color(0xFFEF6820),
                highlighted: true,
                height: 70,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: HomeSection(
                title: '7 ngày tới',
                count: 0,
                icon: Icons.date_range_outlined,
                height: 70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: const [
            Expanded(
              child: HomeSection(
                title: 'Tất cả',
                count: 0,
                icon: Icons.list_alt_outlined,
                height: 70,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: HomeSection(
                title: 'Ghi chú',
                count: 0,
                icon: Icons.note_alt_outlined,
                height: 70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: const [
            Expanded(
              child: HomeSection(
                title: 'Hoàn thành',
                count: 0,
                icon: Icons.check_circle_outline,
                height: 70,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: HomeSection(
                title: 'Thùng rác',
                count: 0,
                icon: Icons.delete_outline,
                height: 70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const HomeSection(
          title: 'Lặp lại',
          count: 0,
          icon: Icons.repeat,
          fullWidth: true,
          height: 70,
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAddTag(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.add, size: 18, color: color),
    );
  }

  Widget _buildBottomButton(String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}