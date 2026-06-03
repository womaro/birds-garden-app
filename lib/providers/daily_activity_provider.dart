import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final dailyActivityProvider =
    FutureProvider.autoDispose<List<int>>((ref) async {
  final data = await ApiService().getDailyActivity(days: 7);
  return data.map((d) => (d['count'] as num).toInt()).toList();
});
