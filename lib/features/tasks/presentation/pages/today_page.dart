import 'package:flutter/material.dart';
import 'task_list_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: 'Hôm nay',
      type: 'today',
    );
  }
}