import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'go_router_refresh_change.dart';

import '../utils/auth_storage.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import '/features/auth/presentation/pages/login_page.dart';
import '/features/auth/presentation/pages/register_page.dart';
import '/features/auth/presentation/pages/success_register_page.dart';
import '/features/auth/presentation/pages/forgot_password_page.dart';
import '/features/auth/presentation/pages/verify_otp_page.dart';
import '/features/auth/presentation/pages/reset_password_page.dart';
import '/features/auth/presentation/pages/reset_password_success_page.dart';
import '/features/home/presentation/pages/home_page.dart';

class AppGoRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    debugLogDiagnostics: true,
    routes:[
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
       GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
       GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
       GoRoute(path: AppRoutes.successRegister, builder: (context, state) => const SuccessRegisterPage()),
       GoRoute(path: AppRoutes.forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
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
    ],

  );
  static _getIndexForLocation(String path) {
    return 0;
  }
}