import 'package:flutter/material.dart';
import '../widgets/home_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEF6820);

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
          // Nội dung chính có thể cuộn
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // để chừa chỗ cho nút dưới
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildTaskSection(accent),
                const SizedBox(height: 24),
                const Text(
                  'Nhóm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const HomeSection(
                  title: 'Nhờ người khác',
                  count: 0,
                  icon: Icons.group_outlined,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                const HomeSection(
                  title: 'Cá nhân',
                  count: 0,
                  icon: Icons.person_outline,
                  fullWidth: true,
                ),
                const SizedBox(height: 28),

                const Text(
                  'Thẻ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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

          // Nút cố định ở dưới
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomButton('+ Tạo mới', accent),
                  _buildBottomButton('Tạo nhóm', accent),
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

  Widget _buildBottomButton(String text, Color color) {
    return Container(
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
    );
  }
}