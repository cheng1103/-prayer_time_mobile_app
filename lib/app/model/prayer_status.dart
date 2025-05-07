
class PrayerStatus {
  String date;
  String fajr;
  String dhuhr;
  String asr;
  String maghrib;
  String isha;

  PrayerStatus({
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha
  });

  factory PrayerStatus.fromFirestore(Map<String, dynamic> data) {
    return PrayerStatus(
      date: data['date'],
      fajr: data['Fajr'] ?? 'pending',
      dhuhr: data['Dhuhr'] ?? 'pending',
      asr: data['Asr'] ?? 'pending',
      maghrib: data['Maghrib'] ?? 'pending',
      isha: data['Isha'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }
}
