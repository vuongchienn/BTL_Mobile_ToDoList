import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import 'package:btl_mobile_todolist/core/utils/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home_section.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:btl_mobile_todolist/features/task_groups/data/datasources/task_group_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/task_groups/data/repositories/task_group_repository_impl.dart';
import '../../../task_groups/domain/usecases/create_task_group_usecase.dart';
import '../../../task_groups/domain/usecases/update_task_group_usecase.dart';
import '../../../task_groups/domain/usecases/delete_task_group_usecase.dart';
import '../../../task_groups/data/models/task_group_model.dart';

import 'package:btl_mobile_todolist/features/tags/data/datasources/tag_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/tags/data/repositories/tag_repository_impl.dart';
import '../../../tags/domain/usecases/create_tag_usecase.dart';
import '../../../tags/domain/usecases/update_tag_usecase.dart';
import '../../../tags/domain/usecases/delete_tag_usecase.dart';
import '../../../tags/data/models/tag_model.dart';


import 'package:btl_mobile_todolist/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:btl_mobile_todolist/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:btl_mobile_todolist/features/tasks/data/models/task_model.dart';

import 'package:btl_mobile_todolist/features/auth/domain/usecases/logout_user.dart';
import 'package:btl_mobile_todolist/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../auth/data/datasources/auth_remote_data_source.dart'; 
import '../../../../core/routing/auth_stream_service.dart';

import 'package:btl_mobile_todolist/features/search_histories/data/datasources/search_history_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/search_histories/data/repositories/search_history_repository_impl.dart';
import 'package:btl_mobile_todolist/features/search_histories/domain/usecases/get_search_histories_usecase.dart';
import 'package:btl_mobile_todolist/features/search_histories/domain/usecases/delete_search_histories_usecase.dart';
import 'package:btl_mobile_todolist/features/search_histories/domain/usecases/delete_all_search_histories_usecase.dart';
import 'package:btl_mobile_todolist/features/search_histories/domain/usecases/add_search_histories_usecase.dart';
import 'package:btl_mobile_todolist/features/search_histories/data/models/search_history_model.dart';
import 'package:btl_mobile_todolist/features/search_histories/domain/entities/search_history.dart';



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

  List<TagModel> _tags = [];
  TagRemoteDataSource? _tagRemoteDataSource;
  TagRepositoryImpl? _tagRepository;
  CreateTagUseCase? _createTagUseCase;
  UpdateTagUseCase? _updateTagUseCase;
  DeleteTagUseCase? _deleteTagUseCase;

  TaskRemoteDataSource? _taskRemoteDataSource;
  TaskRepositoryImpl? _taskRepository;
  CreateTaskUseCase? _createTaskUseCase;

  AuthRemoteDataSource? _authRemoteDataSource;
  AuthRepositoryImpl? _authRepository;
  LogoutUseCase? _logoutUseCase;

  List<TaskGroupModel> _taskGroups = [];
  bool isLoading = true;


  // Thêm các biến mới
  SearchHistoryRemoteDataSource? _searchHistoryRemoteDataSource;
  SearchHistoryRepositoryImpl? _searchHistoryRepository;
  GetSearchHistoriesUseCase? _getSearchHistoriesUseCase;
  DeleteSearchHistoryUseCase? _deleteSearchHistoryUseCase;
  DeleteAllSearchHistoryUseCase? _deleteAllSearchHistoryUseCase;
  AddSearchHistoryUseCase? _addSearchHistoryUseCase;
  List<SearchHistory> _searchHistories = [];

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

    _tagRemoteDataSource = TagRemoteDataSource(_dio!);
    _tagRepository = TagRepositoryImpl(_tagRemoteDataSource!);
    _createTagUseCase = CreateTagUseCase(_tagRepository!);
    _updateTagUseCase = UpdateTagUseCase(_tagRepository!);
    _deleteTagUseCase = DeleteTagUseCase(_tagRepository!);

    _taskRemoteDataSource = TaskRemoteDataSource(_dio!);
    _taskRepository = TaskRepositoryImpl(_taskRemoteDataSource!);
    _createTaskUseCase = CreateTaskUseCase(_taskRepository!);

    _authRemoteDataSource = AuthRemoteDataSource(_dio!);
    _authRepository = AuthRepositoryImpl(_authRemoteDataSource!);
    _logoutUseCase = LogoutUseCase(_authRepository!);

    _searchHistoryRemoteDataSource = SearchHistoryRemoteDataSource(_dio!);
    _searchHistoryRepository = SearchHistoryRepositoryImpl(_searchHistoryRemoteDataSource!);
    _getSearchHistoriesUseCase = GetSearchHistoriesUseCase(_searchHistoryRepository!);
    _deleteSearchHistoryUseCase = DeleteSearchHistoryUseCase(_searchHistoryRepository!);
    _deleteAllSearchHistoryUseCase = DeleteAllSearchHistoryUseCase(_searchHistoryRepository!);
    _addSearchHistoryUseCase = AddSearchHistoryUseCase(_searchHistoryRepository!);



    await _loadTags();
    await _loadTaskGroups();
    await _loadSearchHistories();
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

  Future<void> _loadSearchHistories() async {
    try {
      if (_getSearchHistoriesUseCase == null) {
        setState(() => _searchHistories = []);
        return;
      }
      final histories = await _getSearchHistoriesUseCase!.call();
      setState(() => _searchHistories = histories);
    } catch (e) {
      print('Lỗi khi load search histories: $e');
      setState(() => _searchHistories = []); // Đặt danh sách rỗng nếu có lỗi
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
Future<void> _confirmAndDeleteTaskGroup(int id) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xoá nhóm'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xoá nhóm không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF6820),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Xoá',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await _deleteTaskGroup(id);
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




  Future<void> _loadTags() async {
  try {
    final tags = await _tagRemoteDataSource!.getTags();
    setState(() => _tags = tags);
  } catch (e) {
    print('Lỗi khi load tags: $e');
  }
}

Future<void> _createTag(String name) async {
  if (name.isEmpty || _createTagUseCase == null) return;
  try {
    final tag = await _createTagUseCase!(name);
    await _loadTags();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Tạo thẻ "${tag.name}" thành công')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
  }
}

Future<void> _deleteTag(int id) async {
  try {
    await _deleteTagUseCase!(id);
    await _loadTags();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Xóa thẻ thành công')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Lỗi xóa thẻ: $e')));
  }
}

Future<void> _updateTag(int id, String newName) async {
  try {
    await _updateTagUseCase!(id, newName);
    await _loadTags();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cập nhật thẻ thành công')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Lỗi cập nhật thẻ: $e')));
  }
}


Future<void> _showCreateTagDialog() async {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tạo thẻ mới'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Nhập tên thẻ'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF6820)),
          onPressed: () async {
            await _createTag(controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Tạo'),
        )
      ],
    ),
  );
}

void _showTagOptions(TagModel tag) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFFEF6820)),
            title: const Text('Đổi tên'),
            onTap: () {
              Navigator.pop(context);
              _showUpdateTagDialog(tag);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa'),
            onTap: () {
              Navigator.pop(context);
              _deleteTag(tag.id);
            },
          ),
        ],
      );
    },
  );
}

void _showUpdateTagDialog(TagModel tag) {
  final controller = TextEditingController(text: tag.name);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cập nhật thẻ'),
      content: TextField(controller: controller),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () async {
            await _updateTag(tag.id, controller.text.trim());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF6820)),
          child: const Text('Cập nhật'),
        )
      ],
    ),
  );
}


Future<void> _showCreateTaskBottomSheet() async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  TaskGroupModel? selectedGroup;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TagModel? selectedTag;

  // Khởi tạo cấu hình lặp mặc định
  Map<String, dynamic>? repeatConfig = {
    'repeat': 'Không lặp lại', // Đảm bảo giá trị mặc định
    'endType': null,
    'count': null,
    'endDate': null,
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Hủy bỏ - Tạo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF6820)),
                        child: const Text('Hủy bỏ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedGroup == null || selectedDate == null || selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                            );
                            return;
                          }

                          if (_createTaskUseCase == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hệ thống chưa sẵn sàng, vui lòng thử lại sau')),
                            );
                            return;
                          }

                          try {
                            // Tính dueDateSelect và dueDate
                            int dueDateSelect;
                            DateTime dueDate;
                            final now = DateTime.now();
                            if (selectedDate!.day == now.day && selectedDate!.month == now.month && selectedDate!.year == now.year) {
                              dueDateSelect = 1; // Hôm nay
                              dueDate = selectedDate!;
                            } else if (selectedDate!.day == now.day + 1 && selectedDate!.month == now.month && selectedDate!.year == now.year) {
                              dueDateSelect = 2; // Ngày mai
                              dueDate = selectedDate!;
                            } else if (selectedDate!.difference(now).inDays <= 7) { // Tuần này
                              dueDateSelect = 3;
                              dueDate = selectedDate!;
                            } else {
                              dueDateSelect = 4; // Tùy chọn
                              dueDate = selectedDate!; // Sử dụng selectedDate cho tùy chọn
                            }

                            // Tạo dueDateTime từ selectedDate và selectedTime
                            final dueDateTime = DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            );

                            // Lấy repeatType từ cấu hình lặp, xử lý an toàn hơn
                            String repeatValue = repeatConfig?['repeat'] ?? 'Không lặp lại'; // Giá trị mặc định nếu null
                            int repeatType = {'Không lặp lại': 0, 'Hàng ngày': 1, 'Ngày trong tuần': 2, 'Hàng tháng': 3}[repeatValue] ?? 0;
                            print('repeatConfig: $repeatConfig');
                            print('repeatValue: $repeatValue');
                            int? repeatOption;
                            int? repeatInterval;
                            DateTime? repeatDueDate = repeatConfig?['endDate'] as DateTime?;
                            if (repeatConfig?['endType'] != null) {
                              print('endType: ${repeatConfig?['endType']}');
                              if (repeatConfig!['endType'] == 'count') {
                                repeatOption = 1;
                                repeatInterval = repeatConfig!['count'] as int?;
                                print('count: $repeatInterval');
                              } else if (repeatConfig!['endType'] == 'date') {
                                repeatOption = 2;
                                repeatDueDate = repeatConfig!['endDate'] as DateTime?;
                                print('endDate: $repeatDueDate');
                              }
                            }
                            // Sử dụng giá trị mặc định cho repeatDueDate nếu null
                            final DateTime finalRepeatDueDate = repeatDueDate ?? dueDateTime;

                            final List<int>? tagIds = selectedTag != null ? [selectedTag!.id] : null;
print('Task Data: {title: ${titleController.text.trim()}, description: ${descriptionController.text.trim()}, groupId: ${selectedGroup!.id}, dueDate: $dueDate, dueDateSelect: $dueDateSelect, time: $selectedTime, repeatType: $repeatType, repeatOption: $repeatOption, repeatInterval: $repeatInterval, repeatDueDate: $finalRepeatDueDate, tagIds: $tagIds}');
                            final task = await _createTaskUseCase!.call(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              groupId: selectedGroup!.id,
                              dueDate: dueDate,
                              dueDateSelect: dueDateSelect,
                              time: '${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}',
                              repeatType: repeatType,
                              repeatOption: repeatOption,
                              repeatInterval: repeatInterval,
                              repeatDueDate: finalRepeatDueDate,
                              tagIds: tagIds,
                            );

                          

                            if (task != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tạo task thành công')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tạo task thất bại')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi khi tạo task: $e')),
                            );
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF6820)),
                        child: const Text('Tạo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 16),

                  // Tiêu đề (bỏ viền, không nhãn)
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tiêu đề',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Mô tả',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown chọn nhóm sát trái
                  DropdownButton<TaskGroupModel>(
                    hint: const Text('Chọn nhóm'),
                    value: selectedGroup,
                    items: _taskGroups.map((group) {
                      return DropdownMenuItem<TaskGroupModel>(
                        value: group,
                        child: Text(group.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedGroup = value),
                  ),
                  const SizedBox(height: 16),

                  // Hàng icon ngang (lịch, giờ, lặp, tag)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 📅 Chọn ngày — icon và popup nằm sát nhau
                      if (selectedDate == null)
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed: () async {
                            final RenderBox button = context.findRenderObject() as RenderBox;
                            final Offset offset = button.localToGlobal(Offset.zero);

                            final selectedValue = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                offset.dx + 30,
                                offset.dy + 380,
                                0,
                                0,
                              ),
                              items: const [
                                PopupMenuItem(value: 'Hôm nay', child: Text('Hôm nay')),
                                PopupMenuItem(value: 'Ngày mai', child: Text('Ngày mai')),
                                PopupMenuItem(value: 'Tuần này', child: Text('Tuần này')),
                                PopupMenuItem(value: 'Tùy chọn', child: Text('Tùy chọn')),
                              ],
                            );

                            if (selectedValue != null) {
                              final now = DateTime.now();
                              if (selectedValue == 'Hôm nay') {
                                setState(() => selectedDate = now);
                              } else if (selectedValue == 'Ngày mai') {
                                setState(() => selectedDate = now.add(const Duration(days: 1)));
                              } else if (selectedValue == 'Tuần này') {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: now.add(const Duration(days: 7)),
                                );
                                if (picked != null) setState(() => selectedDate = picked);
                              } else {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setState(() => selectedDate = picked);
                              }
                            }
                          },
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedDate!.day == DateTime.now().day &&
                                      selectedDate!.month == DateTime.now().month &&
                                      selectedDate!.year == DateTime.now().year
                                  ? 'Hôm nay'
                                  : selectedDate!.day == DateTime.now().day + 1 &&
                                          selectedDate!.month == DateTime.now().month &&
                                          selectedDate!.year == DateTime.now().year
                                      ? 'Ngày mai'
                                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                              style: const TextStyle(color: Color(0xFFEF6820), fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => selectedDate = null),
                            ),
                          ],
                        ),

                      // ⏰ Chọn giờ
                      const SizedBox(width: 4),
                      if (selectedTime == null)
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) setState(() => selectedTime = picked);
                          },
                        )
                      else
                        Row(
                          children: [
                            Text(
                              '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Color(0xFFEF6820), fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => selectedTime = null),
                            ),
                          ],
                        ),

                      // 🔁 Lặp
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.repeat),
                        onPressed: () async {
                          final result = await _showRepeatBottomSheet(context);
                          if (result != null) {
                            setState(() => repeatConfig = result);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã lưu cấu hình lặp: ${result['repeat']}')),
                            );
                          }
                        },
                      ),

                      // 🏷️ Thẻ
                      const SizedBox(width: 4),
                      if (selectedTag == null)
                        IconButton(
                          icon: const Icon(Icons.local_offer_outlined),
                          onPressed: () async {
                            final tag = await _showTagSelectionBottomSheet(context);
                            if (tag != null) {
                              setState(() => selectedTag = tag);
                            }
                          },
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedTag!.name,
                                style: const TextStyle(
                                  color: Color(0xFFEF6820),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() => selectedTag = null);
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFFEF6820),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


Future<TagModel?> _showTagSelectionBottomSheet(BuildContext context) async {
  final List<TagModel> tags = await _tagRemoteDataSource!.getTags();

  return await showModalBottomSheet<TagModel>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: tags.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tag = tags[index];
          return ListTile(
            title: Text(tag.name), // ⚡ dùng thuộc tính name trong TagModel
            onTap: () => Navigator.pop(context, tag),
          );
        },
      );
    },
  );
}




Future<Map<String, dynamic>?> _showRepeatBottomSheet(BuildContext context) async {
  String selectedRepeat = 'Không lặp lại';
  int? repeatCount;
  DateTime? endDate;
  String? selectedEndType;

  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final TextEditingController repeatCountController = TextEditingController();

      return FractionallySizedBox(
        heightFactor: 0.4,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF6820),
                          ),
                          child: const Text(
                            'Trở lại',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'repeat': selectedRepeat,
                              'endType': selectedEndType,
                              'count': repeatCount,
                              'endDate': endDate,
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF6820),
                          ),
                          child: const Text(
                            'Lưu',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 20),

                    // --- Lặp lại ---
                    const Text(
                      'Lặp lại',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedRepeat,
                      items: const [
                        DropdownMenuItem(value: 'Không lặp lại', child: Text('Không lặp lại')),
                        DropdownMenuItem(value: 'Hàng ngày', child: Text('Hàng ngày')),
                        DropdownMenuItem(value: 'Ngày trong tuần', child: Text('Ngày trong tuần')),
                        DropdownMenuItem(value: 'Hàng tháng', child: Text('Hàng tháng')),
                      ],
                      onChanged: (value) {
                        setModalState(() => selectedRepeat = value!);
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Kết thúc',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // --- Số lần lặp ---
                    Row(
                      children: [
                        Radio<String>(
                          value: 'count',
                          groupValue: selectedEndType,
                          onChanged: (value) {
                            setModalState(() => selectedEndType = value);
                          },
                          activeColor: const Color(0xFFEF6820),
                        ),
                        const Text('Số lần lặp lại'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: repeatCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                setModalState(() => repeatCount = int.tryParse(val));
                              }
                            },
                            enabled: selectedEndType == 'count',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // --- Ngày kết thúc ---
                    Row(
                      children: [
                        Radio<String>(
                          value: 'date',
                          groupValue: selectedEndType,
                          onChanged: (value) {
                            setModalState(() => selectedEndType = value);
                          },
                          activeColor: const Color(0xFFEF6820),
                        ),
                        const Text('Vào ngày'),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed: selectedEndType == 'date'
                              ? () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 1)),
                                    firstDate: DateTime.now().add(const Duration(days: 1)),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setModalState(() => endDate = picked);
                                  }
                                }
                              : null,
                        ),
                        if (endDate != null)
                          Text(
                            DateFormat('dd/MM/yyyy').format(endDate!),
                            style: const TextStyle(color: Color(0xFFEF6820)),
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void _showLogoutBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context); 
                try {
                  await _logoutUseCase?.call();
                  await AuthStorage.clearToken();
                  await authStreamService.notifyChange(); // router sẽ redirect về login

                  // Sau khi đăng xuất thành công, chuyển về trang login
                  context.go(AppRoutes.login); 
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng xuất thất bại: $e')),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


Future<void> _showSearchHistoryBottomSheet(BuildContext context) async {
  await _loadSearchHistories(); // Đảm bảo dữ liệu mới nhất
  final TextEditingController _searchController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔸 Header với nút đóng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lịch sử tìm kiếm',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFEF6820),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFEF6820)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔸 Thanh tìm kiếm
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search, // Hiển thị nút Enter dạng “Search”
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onSubmitted: (query) async {
                          if (query.trim().isEmpty) return;

                           // 👉 Thêm vào lịch sử tìm kiếm
                          await _addSearchHistoryUseCase?.call(query.trim());

                          // 👉 Điều hướng sang trang kết quả (đúng route)
                         context.push(AppRoutes.search, extra: query.trim());
                        },
                      ),
                    ),


                    // 🔸 Hàng chứa “Lịch sử tìm kiếm” và “Xóa tất cả”
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kết quả gần đây',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                               if (_deleteAllSearchHistoryUseCase != null) {
                                await _deleteAllSearchHistoryUseCase!.call();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã xóa tất cả lịch sử tìm kiếm')),
                                );

                                await _loadSearchHistories(); // reload danh sách rỗng
                                setState(() {}); // cập nhật UI
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không thể xóa, use case chưa khởi tạo')),
                                );
                              }
                            },
                            child: const Text(
                              'Xóa tất cả',
                              style: TextStyle(
                                color: Color(0xFFEF6820),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔸 Danh sách lịch sử tìm kiếm
                    Expanded(
                      child: _searchHistories.isEmpty
                          ? const Center(
                              child: Text(
                                'Không có lịch sử tìm kiếm',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _searchHistories.length,
                              itemBuilder: (context, index) {
                                final history = _searchHistories[index];
                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    leading: const Icon(Icons.history, color: Color(0xFFEF6820)),
                                    title: Text(
                                      history.searchQuery,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        if (history.id != null && _deleteSearchHistoryUseCase != null) {
                                          await _deleteSearchHistoryUseCase!.call(history.id!);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Xóa lịch sử thành công')),
                                          );
                                          await _loadSearchHistories(); // Tải lại danh sách
                                          setState(() {}); // Cập nhật UI trong bottom sheet
                                   
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Không thể xóa, ID không hợp lệ')),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () async {
                                      final query = history.searchQuery;
                                      // Khi người dùng chọn 1 lịch sử → điền vào ô tìm kiếm
                                       if (query.trim().isEmpty) return;

                           // 👉 Thêm vào lịch sử tìm kiếm
                                      await _addSearchHistoryUseCase?.call(query.trim());

                                      // 👉 Điều hướng sang trang kết quả (đúng route)
                                    context.push(AppRoutes.search, extra: query.trim());
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
        title: GestureDetector(
          onTap: () => _showSearchHistoryBottomSheet(context),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    'Tìm kiếm',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showLogoutBottomSheet,
              child: const Icon(Icons.more_vert, color: Colors.black87),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thẻ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: _showCreateTagDialog,
                        child: const Icon(Icons.add, color: Color(0xFFEF6820)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
  spacing: 8,
  runSpacing: 8,
  children: _tags.isEmpty
      ? [const Text('Chưa có thẻ nào 😄', style: TextStyle(color: Colors.grey))]
      : _tags.map(
          (tag) => GestureDetector(
            onTap: () => _showTagOptions(tag),
            child: _buildTag(tag.name, accent),
          ),
        ).toList(),
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
    // 🔸 Nút "Tạo mới" góc trái dưới
Positioned(
  left: 20,
  bottom: 20,
  child: GestureDetector(
    onTap: _showCreateTaskBottomSheet,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add, color: Color(0xFFEF6820), size: 18),
          SizedBox(width: 4),
          Text(
            'Tạo mới',
            style: TextStyle(
              color: Color(0xFFEF6820),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
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
        GestureDetector(
        onTap: () => context.go(AppRoutes.today),
        child: const HomeSection(
          title: 'Hôm nay',
          count: 0,
          icon: Icons.check_circle_outline,
          color: Color(0xFFEF6820),
          highlighted: true,
          fullWidth: true,
          height: 50,
        ),
      ),
        const SizedBox(height: 12),
        Row(
          children: [
           Expanded(
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.next3Days),
              child: const HomeSection(
                title: '3 ngày tới',
                count: 0,
                icon: Icons.calendar_today_outlined,
                color: Color(0xFFEF6820),
                highlighted: true,
                height: 70,
              ),
            ),
          ),
            SizedBox(width: 12),
             Expanded(
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.next7Days),
              child: const HomeSection(
                title: '7 ngày tới',
                count: 0,
                icon: Icons.date_range_outlined,
                height: 70,
              ),
            ),
          ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.all),
              child: const HomeSection(
                title: 'Tất cả',
                count: 0,
                icon: Icons.list_alt_outlined,
                height: 70,
              ),
            ),
          ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.note),
                child: const HomeSection(
                  title: 'Ghi chú',
                  count: 0,
                  icon: Icons.note_alt_outlined,
                  height: 70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.completedTasks), 
                  child: const HomeSection(
                    title: 'Hoàn thành',
                    count: 0,
                    icon: Icons.check_circle_outline,
                    height: 70,
                  ),
                ),
              ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.deletedTasks), // Điều hướng đến DeletedTasksPage
                child: const HomeSection(
                  title: 'Thùng rác',
                  count: 0,
                  icon: Icons.delete_outline,
                  height: 70,
                ),
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