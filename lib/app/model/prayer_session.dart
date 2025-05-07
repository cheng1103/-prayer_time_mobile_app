  import 'package:cloud_firestore/cloud_firestore.dart';

  class PrayerSession {
    final DateTime date;
    final String fajr;
    final String dhuhr;
    final String asr;
    final String maghrib;
    final String isha;

    PrayerSession({
      required this.date,
      required this.fajr,
      required this.dhuhr,
      required this.asr,
      required this.maghrib,
      required this.isha,
    });

    // Factory constructor to create a PrayerSession from Firestore document
    factory PrayerSession.fromFirestore(DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      return PrayerSession(
        date: (data['date'] as Timestamp).toDate(),
        fajr: data['fajr'] ?? '',
        dhuhr: data['dhuhr'] ?? '',
        asr: data['asr'] ?? '',
        maghrib: data['maghrib'] ?? '',
        isha: data['isha'] ?? '',
      );
    }

    // Method to convert PrayerSession to Map for Firestore (optional)
    Map<String, dynamic> toMap() {
      return {
        'date': Timestamp.fromDate(date),
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };
    }
  }
