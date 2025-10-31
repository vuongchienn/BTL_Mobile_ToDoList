import 'package:flutter/material.dart';
import 'task_list_page.dart';

class DeletedTasksPage extends StatelessWidget {
  const DeletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: 'Thùng rác',
      type: 'deleted',
    );
  }
}