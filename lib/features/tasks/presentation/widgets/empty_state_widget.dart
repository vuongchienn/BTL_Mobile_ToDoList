import 'package:flutter/material.dart';

class EmptyTaskWidget extends StatelessWidget {
  final Color accent;
  final VoidCallback onCreatePressed;
  final String title;
  final String buttonText;

  const EmptyTaskWidget({
    Key? key,
    required this.accent,
    required this.onCreatePressed,
    this.title = 'Tạo danh sách việc cần làm ngay!',
    this.buttonText = 'Tạo mới',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thay bằng Image.asset nếu muốn ảnh cụ thể:
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  Icons.checklist_rounded,
                  size: 72,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black87, fontSize: 16, height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}