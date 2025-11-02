import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import '../utils/auth_storage.dart';
import 'go_router_refresh_change.dart';
import '/features/auth/presentation/pages/login_page.dart';
import '/features/auth/presentation/pages/register_page.dart';
import '/features/auth/presentation/pages/success_register_page.dart';
import '/features/auth/presentation/pages/forgot_password_page.dart';
import '/features/auth/presentation/pages/verify_otp_page.dart';
import '/features/auth/presentation/pages/reset_password_page.dart';
import '/features/auth/presentation/pages/reset_password_success_page.dart';
import '/features/home/presentation/pages/home_page.dart';
import '/features/notes/presentation/pages/note_page.dart';
import '/features/tasks/presentation/pages/all_tasks_page.dart';
import '/features/tasks/presentation/pages/today_page.dart';
import '/features/tasks/presentation/pages/next3days_page.dart';
import '/features/tasks/presentation/pages/next7days_page.dart';
import '/features/tasks/presentation/pages/completed_tasks_page.dart';
import '/features/tasks/presentation/pages/deleted_tasks_page.dart';
import '/features/tasks/presentation/pages/search_result_page.dart';

class AppGoRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
        final token = await AuthStorage.getToken();
        final path = state.uri.path;

       // Các route cho phép truy cập mà không cần login
        final publicRoutes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.successRegister,
          AppRoutes.forgotPassword,
          AppRoutes.verifyOtp,
          AppRoutes.resetPassword,
          AppRoutes.resetPasswordSuccess,
        ];

        final isPublic = publicRoutes.contains(path);
        if (token == null && !isPublic) return AppRoutes.login;
        if (token != null && isPublic) return AppRoutes.home;

        return null; // không redirect
      },
    routes:[
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
       GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
       GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
       GoRoute(path: AppRoutes.successRegister, builder: (context, state) => const SuccessRegisterPage()),
       GoRoute(path: AppRoutes.forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
       GoRoute(path: AppRoutes.note, builder: (context, state) => const NotePage()),
       GoRoute(path: AppRoutes.verifyOtp,builder: (context, state) {
              final email = state.extra as String?;
              return VerifyOtpPage(email: email ?? '');
        },
        ),

        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final email = extra?['email'] ?? '';
            final otp = extra?['otp'] ?? '';
            return ResetPasswordPage(email: email, otp: otp);
          },
        ),
        GoRoute(
        path: AppRoutes.resetPasswordSuccess,
        builder: (context, state) => const ResetPasswordSuccessPage(),
      ),
        GoRoute(
          path: AppRoutes.today,
          builder: (context, state) => const TodayPage(),
      ),
      GoRoute(
          path: AppRoutes.all,
          builder: (context, state) => const AllTasksPage(),
      ),
      GoRoute(
          path: AppRoutes.next3Days,
          builder: (context, state) => const Next3DaysPage(),
      ),
      GoRoute(
          path: AppRoutes.next7Days,
          builder: (context, state) => const Next7DaysPage(),
      ),
          GoRoute(
      path: AppRoutes.completedTasks,
      builder: (context, state) => const CompletedTasksPage(),
    ),
    GoRoute(
      path: AppRoutes.deletedTasks,
      builder: (context, state) => const DeletedTasksPage(),
    ),
        GoRoute(
        path: AppRoutes.search, // '/search'
        builder: (context, state) {
          final keyword = state.extra as String? ?? '';
          return SearchResultPage(keyword: keyword);
        },
      ),
    ],

  );
  static _getIndexForLocation(String path) {
    return 0;
  }
}