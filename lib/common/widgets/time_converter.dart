/// Converts backend date/time values — always UTC ISO-8601 — to Bangladesh
/// Standard Time (UTC+06:00) so the app never compares or displays raw UTC
/// values against the user's wall clock.
///
/// The offset is fixed to Dhaka rather than the device's own timezone since
/// the app only serves Bangladesh, and a misconfigured device timezone would
/// otherwise still show the wrong exam/unlock time.
class TimeConverter {
  TimeConverter._();

  static const Duration dhakaOffset = Duration(hours: 6);

  /// Converts a UTC [DateTime] to its Dhaka (UTC+06:00) wall-clock equivalent.
  static DateTime toDhakaTime(DateTime utcTime) {
    return utcTime.toUtc().add(dhakaOffset);
  }

  /// Parses a backend UTC ISO-8601 string and converts it to Dhaka time.
  /// Returns null when [isoString] is null/empty or not a valid date.
  static DateTime? parseToDhakaTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) return null;
    return toDhakaTime(parsed);
  }

  /// The current moment in Dhaka time (UTC+06:00), independent of the
  /// device's own timezone setting.
  static DateTime nowInDhaka() {
    return DateTime.now().toUtc().add(dhakaOffset);
  }

  /// Whether the backend UTC date string [isoString] falls on the same
  /// Dhaka calendar day as "now".
  static bool isTodayInDhaka(String isoString) {
    final date = parseToDhakaTime(isoString);
    if (date == null) return false;
    final now = nowInDhaka();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Whether the backend UTC date string [isoString] has already unlocked —
  /// i.e. it is today (Dhaka calendar day) or earlier.
  static bool isUnlockedInDhaka(String isoString) {
    final date = parseToDhakaTime(isoString);
    if (date == null) return false;
    return isTodayInDhaka(isoString) || date.isBefore(nowInDhaka());
  }
}
