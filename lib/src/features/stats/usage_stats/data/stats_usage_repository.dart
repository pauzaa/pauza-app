import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class StatsUsageRepository {}

class StatsUsageRepositoryImpl implements StatsUsageRepository {
  StatsUsageRepositoryImpl({required UsageStatsManager usageStatsManager}) : _usageStatsManager = usageStatsManager;

  final UsageStatsManager _usageStatsManager;
}
