class StatsSummary {
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int totalTimeMinutes;
  final int averageTimeMinutes;
  final int highPriorityCount;
  final int mediumPriorityCount;
  final int lowPriorityCount;
  final Map<String, int> byCategory;
  final List<DailyCompletion> dailyCompletion;

  StatsSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.totalTimeMinutes,
    required this.averageTimeMinutes,
    required this.highPriorityCount,
    required this.mediumPriorityCount,
    required this.lowPriorityCount,
    required this.byCategory,
    required this.dailyCompletion,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) => StatsSummary(
        totalTasks: json['total_tasks'] as int,
        completedTasks: json['completed_tasks'] as int,
        completionRate: (json['completion_rate'] as num).toDouble(),
        totalTimeMinutes: json['total_time_minutes'] as int,
        averageTimeMinutes: json['average_time_minutes'] as int,
        highPriorityCount: json['high_priority_count'] as int,
        mediumPriorityCount: json['medium_priority_count'] as int,
        lowPriorityCount: json['low_priority_count'] as int,
        byCategory: Map<String, int>.from(json['by_category'] as Map),
        dailyCompletion: (json['daily_completion'] as List)
            .map((e) => DailyCompletion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'completion_rate': completionRate,
        'total_time_minutes': totalTimeMinutes,
        'average_time_minutes': averageTimeMinutes,
        'high_priority_count': highPriorityCount,
        'medium_priority_count': mediumPriorityCount,
        'low_priority_count': lowPriorityCount,
        'by_category': byCategory,
        'daily_completion': dailyCompletion.map((e) => e.toJson()).toList(),
      };
}

class DailyCompletion {
  final String date;
  final int completed;

  DailyCompletion({
    required this.date,
    required this.completed,
  });

  factory DailyCompletion.fromJson(Map<String, dynamic> json) =>
      DailyCompletion(
        date: json['date'] as String,
        completed: json['completed'] as int,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'completed': completed,
      };
}
