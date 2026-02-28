import '../models/stats_summary.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class StatsApiService {
  final ApiService _apiService = ApiService();

  // Get statistics summary
  Future<StatsSummary> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiService.get(
      ApiConstants.statsSummary,
      queryParameters: {
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      },
    );

    return StatsSummary.fromJson(response.data as Map<String, dynamic>);
  }

  // Get weekly summary (convenience method)
  Future<StatsSummary> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getSummary(startDate: startOfWeek, endDate: endOfWeek);
  }

  // Get monthly summary (convenience method)
  Future<StatsSummary> getMonthlySummary() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return getSummary(startDate: startOfMonth, endDate: endOfMonth);
  }
}
