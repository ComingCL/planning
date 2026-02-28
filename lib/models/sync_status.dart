class SyncStatus {
  final DateTime? lastSync;
  final int pendingChanges;
  final bool syncEnabled;

  SyncStatus({
    this.lastSync,
    required this.pendingChanges,
    required this.syncEnabled,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) => SyncStatus(
        lastSync: json['last_sync'] != null
            ? DateTime.parse(json['last_sync'] as String)
            : null,
        pendingChanges: json['pending_changes'] as int,
        syncEnabled: json['sync_enabled'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'last_sync': lastSync?.toIso8601String(),
        'pending_changes': pendingChanges,
        'sync_enabled': syncEnabled,
      };
}
