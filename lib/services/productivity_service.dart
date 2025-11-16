import 'dart:math';
import "package:focusflow/screens/user/other/other.dart";

class ProductivityService {
  /// Returns the daily tip based on the current date (4AM cutoff)
  static String getDailyTip({DateTime? now}) {
    final current = now ?? DateTime.now();
    DateTime tipDate = current;

    // Before 4AM, consider it the previous day
    if (current.hour < 4) {
      tipDate = current.subtract(const Duration(days: 1));
    }

    // Generate a deterministic pseudo-random tip for the day
    final daySeed = tipDate.year * 10000 + tipDate.month * 100 + tipDate.day;
    final random = Random(daySeed);
    return productivityTips[random.nextInt(productivityTips.length)];
  }

  /// Returns DateTime for the next 4AM from now
  static DateTime getNext4AM({DateTime? now}) {
    final current = now ?? DateTime.now();
    DateTime next4AM = DateTime(current.year, current.month, current.day, 4);
    if (current.isAfter(next4AM)) {
      next4AM = next4AM.add(const Duration(days: 1));
    }
    return next4AM;
  }

  /// Duration until the next 4AM
  static Duration durationUntilNext4AM({DateTime? now}) {
    final current = now ?? DateTime.now();
    return getNext4AM(now: current).difference(current);
  }
}
