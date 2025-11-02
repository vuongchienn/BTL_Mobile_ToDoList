import 'dart:async';
import '../utils/auth_storage.dart';

class AuthStreamService {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  // Gọi khi login hoặc logout
  Future<void> notifyChange() async {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

final authStreamService = AuthStreamService();