import 'package:flutter/material.dart';
import 'task_list_page.dart';

class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: 'Đã hoàn thành',
      type: 'completed',
    );
  }
}