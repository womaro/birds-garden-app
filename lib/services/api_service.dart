import 'package:dio/dio.dart';

class ApiService {
  static const _base = 'https://birds.garden';
  static const _key  = 'bird-secret-2026-xK9mP';

  final _dio = Dio(BaseOptions(
    baseUrl: _base,
    headers: {'x-api-key': _key},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Map<String, dynamic>>> getDetections({int limit = 200}) async {
    final res = await _dio.get('/detections', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> getSpecies() async {
    final res = await _dio.get('/species');
    return List<Map<String, dynamic>>.from(res.data);
  }
}