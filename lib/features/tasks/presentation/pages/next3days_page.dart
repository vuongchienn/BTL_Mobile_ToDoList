import 'package:flutter/material.dart';
import 'task_list_page.dart';

class Next3DaysPage extends StatelessWidget {
  const Next3DaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: '3 ngày tới',
      type: 'next3days',
    );
  }
}