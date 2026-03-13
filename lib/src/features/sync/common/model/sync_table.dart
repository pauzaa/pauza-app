enum SyncTable {
  modes('modes', 'updated_at'),
  modeBlockedApps('mode_blocked_apps', 'updated_at'),
  schedules('schedules', 'updated_at'),
  restrictionSessions('restriction_sessions', 'updated_at'),
  restrictionLifecycleEvents('restriction_lifecycle_events', 'created_at'),
  nfcLinkedChips('nfc_linked_chips', 'updated_at'),
  qrLinkedCodes('qr_linked_codes', 'updated_at'),
  streakSessionDailyRollups('streak_session_daily_rollups', 'updated_at'),
  streakDailyAggregates('streak_daily_aggregates', 'updated_at');

  const SyncTable(this.key, this.cursorColumn);

  final String key;
  final String cursorColumn;
}
