import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

/// Provide Dio instance (createDio from core)
final dioAuthProvider = Provider<Dio>((ref) => createDio());

/// Provide AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioAuthProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(dio));
});

/// Current logged user
final userProvider = StateProvider<User?>((ref) => null);

/// Auth controller to handle login/logout flows
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  () => AuthController(),
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // optional: check existing token and load profile on startup
  }

  Future<void> login(WidgetRef ref, String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    try {
      await repo.login(email, password);
      final user = await repo.getProfile();
      ref.read(userProvider.notifier).state = user;
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout(WidgetRef ref) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(userProvider.notifier).state = null;
  }
}