import 'package:flutter/material.dart';
import 'package:btl_mobile_todolist/core/routing/app_go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'To do list',
      routerConfig: AppGoRouter.appRouter,
    );
  }
}

