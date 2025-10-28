import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'go_router_refresh_change.dart';

import '../utils/auth_storage.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import '/features/auth/presentation/pages/login_page.dart';
import '/features/auth/presentation/pages/register_page.dart';
import '/features/auth/presentation/pages/success_register_page.dart';


class AppGoRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes:[
       GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
       GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
       GoRoute(path: AppRoutes.successRegister, builder: (context, state) => const SuccessRegisterPage()),
    ],

  );
  static _getIndexForLocation(String path) {
    return 0;
  }
}