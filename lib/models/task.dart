enum Priority {
  high,
  medium,
  low;

  String toJson() => name;

  static Priority fromJson(String json) {
    return Priority.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Priority.medium,
    );
  }

  String get displayName {
    switch (this) {
      case Priority.high:
        return '高优先级';
      case Priority.medium:
        return '中优先级';
      case Priority.low:
        return '低优先级';
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String toJson() => name;

  static TaskStatus fromJson(String json) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => TaskStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.cancelled:
        return '已取消';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? timeRange; // e.g., "09:00 - 10:00"
  final String? category;
  final List<String> tags;
  final String? userId;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.status = TaskStatus.pending,
    this.isCompleted = false,
    this.dueDate,
    this.timeRange,
    this.category,
    this.tags = const [],
    this.userId,
    this.estimatedMinutes,
    this.actualMinutes,
    DateTime? createdAt,
    this.updatedAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Backward compatibility: create from old format
  factory Task.fromLegacy({
    required String id,
    required String title,
    required String priority,
    required String time,
  }) {
    return Task(
      id: id,
      title: title,
      priority: _parsePriority(priority),
      timeRange: time,
      createdAt: DateTime.now(),
    );
  }

  static Priority _parsePriority(String priority) {
    final lower = priority.toLowerCase();
    if (lower.contains('高') || lower == 'high') return Priority.high;
    if (lower.contains('低') || lower == 'low') return Priority.low;
    return Priority.medium;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.toJson(),
        'status': status.toJson(),
        'is_completed': isCompleted,
        'due_date': dueDate?.toIso8601String(),
        'time_range': timeRange,
        'category': category,
        'tags': tags,
        'user_id': userId,
        'estimated_minutes': estimatedMinutes,
        'actual_minutes': actualMinutes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle legacy format (old local storage data)
    if (!json.containsKey('created_at') && json.containsKey('time')) {
      return Task.fromLegacy(
        id: json['id'] as String,
        title: json['title'] as String,
        priority: json['priority'] as String,
        time: json['time'] as String,
      );
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: Priority.fromJson(json['priority'] as String),
      status: TaskStatus.fromJson(json['status'] as String? ?? 'pending'),
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      timeRange: json['time_range'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      userId: json['user_id'] as String?,
      estimatedMinutes: json['estimated_minutes'] as int?,
      actualMinutes: json['actual_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    bool? isCompleted,
    DateTime? dueDate,
    String? timeRange,
    String? category,
    List<String>? tags,
    String? userId,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      timeRange: timeRange ?? this.timeRange,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
