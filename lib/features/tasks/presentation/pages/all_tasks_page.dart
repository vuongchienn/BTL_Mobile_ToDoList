import 'package:flutter/material.dart';
import 'task_list_page.dart';

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: 'Tất cả công việc',
      type: 'all',
    );
  }
}