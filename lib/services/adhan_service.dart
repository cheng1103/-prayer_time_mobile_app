import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class AdhanService {
  DateTime getIslamicMidnight(PrayerTimes prayerTimes) {
    final sunset = prayerTimes.maghrib;
    final fajr = prayerTimes.fajr.add(const Duration(days: 1));

    final duration = fajr.difference(sunset);
    return sunset.add(Duration(milliseconds: duration.inMilliseconds ~/ 2));
  }

  Future<String> getCurrentPrayer(Coordinates coordinates) async {
    final params = CalculationMethod.karachi.getParameters();
    final prayerTimes = PrayerTimes.today(coordinates, params);
    final now = DateTime.now();

    final midnight = getIslamicMidnight(prayerTimes);

    if (now.isAfter(prayerTimes.fajr) && now.isBefore(prayerTimes.sunrise)) {
      return 'Fajr';
    }
    if (now.isAfter(prayerTimes.dhuhr) && now.isBefore(prayerTimes.asr)) {
      return 'Dhuhr';
    }
    if (now.isAfter(prayerTimes.asr) && now.isBefore(prayerTimes.maghrib)) {
      return 'Asr';
    }
    if (now.isAfter(prayerTimes.maghrib) && now.isBefore(prayerTimes.isha)) {
      return 'Maghrib';
    }
    if (now.isAfter(prayerTimes.isha) && now.isBefore(midnight)) {
      return 'Isha';
    }
    return '';
  }

  Future<Map<String, dynamic>> calculateNextAdhan(
      Coordinates coordinates) async {
    final params = CalculationMethod.karachi.getParameters();
    final prayerTimes = PrayerTimes.today(coordinates, params);
    final now = DateTime.now();

    final nextPrayer = _getNextPrayer(prayerTimes, now);

    if (nextPrayer != null) {
      return {
        'nextAdhanName': nextPrayer.name,
        'nextAdhanTime': DateFormat.jm().format(nextPrayer.time),
        'nextPrayerTime': nextPrayer.time
      };
    } else {
      // Handle next day's Fajr
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextDayPrayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow), // Convert DateTime to DateComponents
        params,
      );
      return {
        'nextAdhanName': 'Fajr',
        'nextAdhanTime': DateFormat.jm().format(nextDayPrayerTimes.fajr),
        'nextPrayerTime': nextDayPrayerTimes.fajr
      };
    }
  }

  Prayer? _getNextPrayer(PrayerTimes prayerTimes, DateTime now) {
    if (now.isBefore(prayerTimes.fajr)) {
      return Prayer(name: 'Fajr', time: prayerTimes.fajr);
    }
    if (now.isBefore(prayerTimes.sunrise)) {
      return Prayer(name: 'Sunrise', time: prayerTimes.sunrise);
    }
    if (now.isBefore(prayerTimes.dhuhr)) {
      return Prayer(name: 'Dhuhr', time: prayerTimes.dhuhr);
    }
    if (now.isBefore(prayerTimes.asr)) {
      return Prayer(name: 'Asr', time: prayerTimes.asr);
    }
    if (now.isBefore(prayerTimes.maghrib)) {
      return Prayer(name: 'Maghrib', time: prayerTimes.maghrib);
    }
    if (now.isBefore(prayerTimes.isha)) {
      return Prayer(name: 'Isha', time: prayerTimes.isha);
    }
    return null;
  }

  Future<Map<String, String>> getPrayerTimes(
      Coordinates coordinates, DateTime date) async {
    final params = CalculationMethod.karachi.getParameters();
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(date), // Convert DateTime to DateComponents
      params,
    );

    final formatter = DateFormat.jm();
    return {
      'Fajr': formatter.format(prayerTimes.fajr),
      'Dhuhr': formatter.format(prayerTimes.dhuhr),
      'Asr': formatter.format(prayerTimes.asr),
      'Maghrib': formatter.format(prayerTimes.maghrib),
      'Isha': formatter.format(prayerTimes.isha),
    };
  }
}

class Prayer {
  final String name;
  final DateTime time;

  Prayer({required this.name, required this.time});
}
