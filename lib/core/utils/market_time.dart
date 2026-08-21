/// Indian Stock Exchange (NSE/BSE) market schedule helper.
class MarketTime {
  MarketTime._();

  /// Checks whether the Indian stock market (NSE) is currently open.
  /// Standard Trading Hours: Monday to Friday, 09:15 AM to 03:30 PM IST (UTC+5:30).
  static bool get isMarketOpen {
    // Current time in IST (UTC + 5 hours 30 minutes)
    final nowUtc = DateTime.now().toUtc();
    final nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));

    // Weekend check: Saturday (6) and Sunday (7)
    if (nowIst.weekday == DateTime.saturday ||
        nowIst.weekday == DateTime.sunday) {
      return false;
    }

    final currentMinutes = nowIst.hour * 60 + nowIst.minute;
    const marketOpenMinutes = 9 * 60 + 15; // 09:15 AM
    const marketCloseMinutes = 15 * 60 + 30; // 03:30 PM

    return currentMinutes >= marketOpenMinutes &&
        currentMinutes < marketCloseMinutes;
  }

  /// Formatted market status string.
  static String get statusText {
    return isMarketOpen ? 'LIVE' : 'CLOSED';
  }

  /// Helper description text.
  static String get statusSubtitle {
    return isMarketOpen
        ? 'NSE · Real-time'
        : 'NSE · Closed (Opens 9:15 AM IST)';
  }
}
