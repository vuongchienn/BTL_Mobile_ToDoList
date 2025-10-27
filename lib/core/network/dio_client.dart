import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.2.9:8000/api', // emulator -> host
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  return dio;
}