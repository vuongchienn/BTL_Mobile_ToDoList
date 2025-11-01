import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
class TaskItemWidget extends StatelessWidget {
  final int id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isImportant;
  final bool isRepeating;
  final List<String>? tags;
  final bool isDeleted;
  final Function()? onEdit;
  final Function()? onDelete;
  final VoidCallback? onDeleted; // thêm vào
  final DeleteTaskUseCase? onDeleteUseCase;
  final CompleteTaskUseCase? onCompleteUseCase;
  final bool isSelected;
  const TaskItemWidget({
    Key? key,
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.tags,
    this.isImportant = false,
    this.isRepeating = false,
    this.isDeleted = false,
    this.onEdit,
    this.onDelete,
    this.onDeleted,
    this.onDeleteUseCase, 
    this.onCompleteUseCase,
    this.isSelected = false, // Giá trị mặc định là false
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '';
    }
  }
    void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Sửa task'),
                onTap: () {
                  Navigator.pop(context);
                  if (onEdit != null) onEdit!();
                },
              ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Xóa task'),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: const Text('Bạn có chắc muốn xóa task này không?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    if (onDeleteUseCase != null) {
                      final success = await onDeleteUseCase!.call(id); // dùng id
                      print(id);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xóa task thành công')),
                        );
                        if (onDeleted != null) onDeleted!(); // reload danh sách
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xóa task thất bại')),
                        );
                      }
                    }
                  },
                ),
              ListTile(
  leading: const Icon(Icons.check_circle, color: Colors.green),
  title: const Text('Hoàn thành'),
  onTap: () async {
    Navigator.pop(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn đánh dấu task này là hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (onCompleteUseCase != null) {
      final success = await onCompleteUseCase!.call(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đánh dấu hoàn thành thành công')),
        );
        if (onDeleted != null) onDeleted!(); // reload danh sách
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hoàn thành task thất bại')),
        );
      }
    }
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
    final gray = Colors.grey.shade400;
    return InkWell(
      onTap: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDeleted ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox hoặc dấu lặp lại
            // 🔸 Dòng tiêu đề có RadioButton + title + star
            // 🔸 Dòng tiêu đề + star
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // 🔸 Dòng tiêu đề + icon repeat + star
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon lặp lại (hoặc chỗ trống nếu không lặp)
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRepeating ? accent : Colors.transparent,
          ),
          child: isRepeating
              ? const Icon(Icons.repeat, size: 16, color: Colors.white)
              : null,
        ),
        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
              color: isDeleted ? Colors.grey[600] : Colors.black87,
            ),

            // Main content
                      ),
        ),
        // Star
        Icon(
          isImportant ? Icons.star : Icons.star_border,
          color: isImportant ? accent : gray,
          size: 20,
        ),
      ],
    ),

    // 🔸 Mô tả
    if (description != null && description!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(left: 40, top: 4),
        child: Text(
          description!,
          style: TextStyle(
            fontSize: 13,
            color: isDeleted ? Colors.grey[500] : Colors.grey[700],
            fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),

    // 🔸 Tag list
  // 🔸 Tag list
if (tags != null && tags!.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(left: 40, top: 6), // thẳng với title & description
    child: Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags!.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDeleted ? Colors.grey[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 12,
            color: isDeleted ? Colors.grey[600] : Colors.black54,
          ),
        ),
      )).toList(),
    ),
  ),

    // 🔸 Ngày + icon repeat
    if (dueDate != null)
      Padding(
        padding: const EdgeInsets.only(left: 40, top: 8),
        child: Row(
          children: [
            Icon(
              Icons.repeat,
              size: 16,
              color: isRepeating ? accent : gray,
            ),
            const SizedBox(width: 6),
            Icon(Icons.calendar_today, size: 14, color: accent),
            const SizedBox(width: 6),
            Text(
              _formatDate(dueDate),
              style: TextStyle(fontSize: 12, color: accent),
                ),
                      ],
            ),
          ),
      ],
    )
          ],
        ),
      ),
    );
  }
}
