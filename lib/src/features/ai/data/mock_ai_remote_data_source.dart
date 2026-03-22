import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';
import 'package:pauza/src/features/ai/data/ai_remote_data_source.dart';

final class MockAiRemoteDataSource implements AiRemoteDataSource {
  const MockAiRemoteDataSource();

  @override
  Future<String> analyzeUsage(UsageAnalysisRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return '''
## Usage Analysis

Your screen time patterns reveal some interesting trends:

- **Social media** accounts for roughly **40%** of your total screen time, with Instagram and TikTok leading the way.
- You tend to pick up your phone most frequently between **8 PM and 11 PM**, which correlates with a dip in your focus session consistency.
- Your productivity apps (notes, calendar) only make up **12%** of daily usage, despite being opened frequently — suggesting short, fragmented interactions.

### Recommendation
Consider setting a **30-minute daily cap** on social media apps during weekdays. Even a small reduction here can free up meaningful time for deeper work or rest.
''';
  }

  @override
  Future<String> suggestFocusSchedule(FocusScheduleRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return '''
## Suggested Focus Schedule

Based on your usage patterns and preferred focus hours, here's an optimised schedule:

| Day | Focus Block | Duration |
|-----|------------|----------|
| Mon–Fri | 9:00 AM – 11:30 AM | 2h 30m |
| Mon–Fri | 2:00 PM – 4:00 PM | 2h |
| Sat | 10:00 AM – 12:00 PM | 2h |

### Why this works
- Your phone usage is **lowest** in the morning, making it the ideal window for deep focus.
- The afternoon block avoids your typical post-lunch browsing spike at 1 PM.
- Weekend sessions are lighter to maintain consistency without burnout.
''';
  }

  @override
  Future<String> generateDailyReport(DailyReportRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return '''
## Daily Report — ${request.date}

Here's how your day looked:

- **Total screen time:** 4h 32m (↓ 18% vs. yesterday)
- **Focus sessions:** 3 completed, 1h 45m effective time
- **Most used app:** Instagram — 58 min
- **Unlocks:** 47 times
- **First pickup:** 7:12 AM

### Highlights
- You completed all 3 planned focus sessions — great consistency!
- Social media usage dropped by 22 minutes compared to your weekly average.
- Evening screen time (after 9 PM) was 1h 10m — consider winding down earlier for better sleep.
''';
  }

  @override
  Future<String> checkAddiction(AddictionCheckRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return '''
## Addiction Risk Assessment

**Overall risk level: Moderate**

### Key findings

1. **Compulsive checking** — You unlock your phone an average of **52 times/day**, which is above the recommended threshold of 40.
2. **Late-night usage** — On 5 of the last 7 days, you used your phone past **11:30 PM**, which may impact sleep quality.
3. **Positive trend** — Your total screen time has decreased by **14%** over the past two weeks, suggesting that your focus sessions are having a positive effect.

### Suggestions
- Enable "Wind Down" mode starting at 10:30 PM to reduce late-night usage.
- Try the **Pomodoro technique** during work hours to build structured breaks.
- Continue your current streak — consistency is the strongest predictor of long-term change.
''';
  }
}
