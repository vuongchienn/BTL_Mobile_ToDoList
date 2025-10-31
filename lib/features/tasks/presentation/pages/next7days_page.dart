import 'package:flutter/material.dart';
import 'task_list_page.dart';

class Next7DaysPage extends StatelessWidget {
  const Next7DaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListPage(
      title: '7 ngày tới',
      type: 'seven_days',
    );
  }
}