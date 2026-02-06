abstract interface class ActiveModeStorage {
  Future<String?> readActiveModeId();

  Future<void> writeActiveModeId(String modeId);

  Future<void> clearActiveModeId();
}
