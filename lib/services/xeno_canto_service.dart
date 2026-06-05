import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class XenoCantoService {
  static const _xcKey = String.fromEnvironment(
    'XC_KEY',
    defaultValue: 'demo',
  );

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    validateStatus: (status) => status != null && status < 500,
  ));

  Future<String?> getBestCallUrl(String scientificName) async {
    // Spróbuj z Polską najpierw
    final url = await _fetch(scientificName, country: 'Poland');
    if (url != null) return url;
    // Fallback — globalnie
    return _fetch(scientificName);
  }

  Future<String?> _fetch(String scientificName, {String? country}) async {
    try {
      // Podziel "Turdus merula" → gen:Turdus sp:merula
      final parts = scientificName.trim().split(' ');
      if (parts.length < 2) return null;
      final genus   = parts[0];
      final species = parts[1];

      var query = 'gen:$genus sp:$species';
      if (country != null) query += ' cnt:"$country" type:"song"';

      debugPrint('🎵 Query: $query');

      final res = await _dio.get(
        'https://xeno-canto.org/api/3/recordings',
        queryParameters: {
          'query': query,
          'key': _xcKey,
        },
      );

      debugPrint('🎵 Status: ${res.statusCode}');
      if (res.statusCode != 200) return null;

      final recordings = res.data['recordings'] as List?;
      debugPrint('🎵 Recordings: ${recordings?.length ?? 0}');
      if (recordings == null || recordings.isEmpty) return null;

      final fileUrl = recordings.first['file'] as String?;
      debugPrint('🎵 File: $fileUrl');
      if (fileUrl == null) return null;

      return fileUrl.startsWith('//')
          ? 'https:$fileUrl'
          : fileUrl;
    } catch (e) {
      debugPrint('🎵 Error: $e');
      return null;
    }
  }
}