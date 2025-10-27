import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Helper to obtain SharedPreferences instance asynchronously and cache via a FutureProvider if desired.
/// For simplicity, we'll just use SharedPreferences.getInstance() in datasources.