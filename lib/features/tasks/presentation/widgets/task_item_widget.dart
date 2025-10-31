import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskItemWidget extends StatelessWidget {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isImportant;
  final bool isRepeating;
  final List<String>? tags;
  final bool isDeleted;

  const TaskItemWidget({
    Key? key,
    required this.title,
    this.description,
    this.dueDate,
    this.tags,
    this.isImportant = false,
    this.isRepeating = false,
    this.isDeleted = false, // Giá trị mặc định là false
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEF6820);

    return InkWell(
      onTap: null, // Có thể thêm logic nếu cần
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDeleted ? Colors.grey[200] : Colors.white, // Nền xám cho task đã xóa
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox hoặc dấu lặp lại
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRepeating ? accent : Colors.grey.shade300,
              ),
              child: isRepeating
                  ? const Icon(Icons.repeat, size: 16, color: Colors.white)
                  : null,
            ),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + star
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal, // Chữ nghiêng cho task đã xóa
                            color: isDeleted ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: null, // Có thể thêm logic nếu cần
                        child: Icon(
                          isImportant ? Icons.star : Icons.star_border,
                          color: isImportant ? accent : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDeleted ? Colors.grey[500] : Colors.grey[600],
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        height: 1.3,
                      ),
                    ),
                  ],

                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags!
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
                              ))
                          .toList(),
                    ),
                  ],

                  if (dueDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isDeleted ? Colors.grey[400] : accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDeleted ? Colors.grey[400] : accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}