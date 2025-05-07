import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prayer_time_mobile_app/app/model/prayer_status.dart';

class PrayerProvider extends ChangeNotifier {
  String? _userId;
  DateTime? _creationDate;
  List<PrayerStatus> _allPrayerSessions = [];

  String get userId => _userId ?? '';
  DateTime get creationDate => _creationDate ?? DateTime.now();
  List<PrayerStatus> get prayerStatuses => _allPrayerSessions;

  set userId(String id) {
    _userId = id;
    notifyListeners();
  }

  set creationDate(DateTime creationDate) {
    _creationDate = creationDate;
    notifyListeners();
  }

  // Fetch all prayer sessions sorted by timestamp (date)
  Future<void> fetchPrayerStatuses() async {
    if (userId.isEmpty) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('prayers')
          .orderBy('timestamp', descending: true)
          .get();

      _allPrayerSessions = snapshot.docs.map((doc) {
        return PrayerStatus.fromFirestore({
          'date': doc.id, // Document ID is the date (yyyy-MM-dd)
          'Fajr': doc['Fajr'] ?? 'pending',
          'Dhuhr': doc['Dhuhr'] ?? 'pending',
          'Asr': doc['Asr'] ?? 'pending',
          'Maghrib': doc['Maghrib'] ?? 'pending',
          'Isha': doc['Isha'] ?? 'pending',
          'timestamp': doc['timestamp'],
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching prayer statuses: $e');
    }
  }

  // Fetch all prayer sessions sorted by timestamp (date)
  Future<void> fetchConnectedUserPrayerStatuses(String connectedUserId) async {
    if (connectedUserId.isEmpty) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(connectedUserId)
          .collection('prayers')
          .orderBy('timestamp', descending: true)
          .get();

      _allPrayerSessions = snapshot.docs.map((doc) {
        return PrayerStatus.fromFirestore({
          'date': doc.id, // Document ID is the date (yyyy-MM-dd)
          'Fajr': doc['Fajr'] ?? 'pending',
          'Dhuhr': doc['Dhuhr'] ?? 'pending',
          'Asr': doc['Asr'] ?? 'pending',
          'Maghrib': doc['Maghrib'] ?? 'pending',
          'Isha': doc['Isha'] ?? 'pending',
          'timestamp': doc['timestamp'],
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching prayer statuses: $e');
    }
  }

  // Save or update Prayer Status in Firestore
  Future<void> savePrayerStatus({
    required String prayerName,
    required String status, // "success", "failed", "pending"
  }) async {
    try {
      String currentDate = DateTime.now().toIso8601String().split('T').first;
      DocumentReference prayerDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('prayers')
          .doc(currentDate);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(prayerDocRef);

        if (!snapshot.exists) {
          // If prayer data for today doesn't exist, create it
          transaction.set(prayerDocRef, {
            'Fajr': 'pending',
            'Dhuhr': 'pending',
            'Asr': 'pending',
            'Maghrib': 'pending',
            'Isha': 'pending',
            'timestamp': DateTime.now(),
          });
        }

        // Update the specific prayer status
        transaction.update(prayerDocRef, {
          prayerName: status,
        });

        // Update local provider data
        _updateLocalPrayerStatus(currentDate, prayerName, status);
      });

      notifyListeners();
    } catch (e) {
      print('Error saving prayer status: $e');
    }
  }

  // Update local prayer status after saving
  void _updateLocalPrayerStatus(String currentDate, String prayerName, String status) {
    final index = _allPrayerSessions.indexWhere((p) => p.date == currentDate);
    
    if (index != -1) {
      PrayerStatus updatedPrayer = _allPrayerSessions[index];
      if (prayerName == 'Fajr') updatedPrayer.fajr = status;
      if (prayerName == 'Dhuhr') updatedPrayer.dhuhr = status;
      if (prayerName == 'Asr') updatedPrayer.asr = status;
      if (prayerName == 'Maghrib') updatedPrayer.maghrib = status;
      if (prayerName == 'Isha') updatedPrayer.isha = status;

      // Replace the old PrayerStatus instance with the updated one
      _allPrayerSessions[index] = updatedPrayer;
    } else {
      PrayerStatus newPrayerStatus = PrayerStatus(
        date: currentDate,
        fajr: prayerName == 'Fajr' ? status : 'pending',
        dhuhr: prayerName == 'Dhuhr' ? status : 'pending',
        asr: prayerName == 'Asr' ? status : 'pending',
        maghrib: prayerName == 'Maghrib' ? status : 'pending',
        isha: prayerName == 'Isha' ? status : 'pending',
      );

      // Add the new PrayerStatus to the list
      _allPrayerSessions.add(newPrayerStatus);
    }
  }
}
