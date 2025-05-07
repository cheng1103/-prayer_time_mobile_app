import 'package:hijri/hijri_calendar.dart';

class HijriDateService {
  // Returns current date in Gregorian and Hijri formats
  Map<String, String> getCurrentDate() {
    final now = DateTime.now();
    final hijriDate = HijriCalendar.now();

    // Format Gregorian date
    final gregorianDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    // Format Hijri date
    final hijriDay = hijriDate.hDay.toString().padLeft(2, '0');
    final hijriMonth = _getHijriMonthName(hijriDate.hMonth);
    final hijriYear = hijriDate.hYear;
    final hijriDateFormatted = '$hijriDay $hijriMonth $hijriYear';

    return {
      'gregorian': gregorianDate,
      'hijri': hijriDateFormatted,
    };
  }

  // Returns a specific date in Gregorian and Hijri formats
  Map<String, String> getFormattedDate(DateTime date) {
    final hijriDate = HijriCalendar.fromDate(date);

    // Format Gregorian date
    final gregorianDate =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

    // Format Hijri date
    final hijriDay = hijriDate.hDay.toString().padLeft(2, '0');
    final hijriMonth = _getHijriMonthName(hijriDate.hMonth);
    final hijriYear = hijriDate.hYear;
    final hijriDateFormatted = '$hijriDay $hijriMonth $hijriYear';

    return {
      'gregorian': gregorianDate,
      'hijri': hijriDateFormatted,
    };
  }

  // Helper function to get the Hijri month name
  String _getHijriMonthName(int month) {
    const hijriMonths = [
      'Muharram',
      'Safar',
      'Rabi\'ul Awwal',
      'Rabi\'ul Thani',
      'Jumada\'ul Awwal',
      'Jumada\'ul Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu\'l-Qa\'dah',
      'Dhu\'l-Hijjah'
    ];
    return hijriMonths[month - 1];
  }
}
