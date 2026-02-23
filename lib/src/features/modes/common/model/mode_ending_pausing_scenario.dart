enum ModeEndingPausingScenario {
  nfc('nfc'),
  qrCode('qr'),
  manual('manual');

  const ModeEndingPausingScenario(this.dbValue);

  final String dbValue;

  static ModeEndingPausingScenario fromDbValue(String? raw) {
    return values.firstWhere((scenario) => scenario.dbValue == raw, orElse: () => ModeEndingPausingScenario.manual);
  }
}
