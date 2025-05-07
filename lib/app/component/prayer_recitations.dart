import 'package:flutter/material.dart';

class PrayerRecitations extends StatelessWidget {
  final String currentPrayer;

  const PrayerRecitations({super.key, required this.currentPrayer});

  @override
  Widget build(BuildContext context) {
    final List<String> recitations = getRecitationsForPrayer(currentPrayer);

    return Expanded(
      child: ListView.builder(
        itemCount: recitations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              recitations[index],
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  // can change recitations here
  List<String> getRecitationsForPrayer(String prayerName) {
    switch (prayerName) {
      case "Fajr":
        return [
          "1. Surah Al-Fatiha: \nIn the name of Allah, the Most Gracious, the Most Merciful...",
          "2. Surah Al-Ikhlas: \nSay, 'He is Allah, [Who is] One, Allah, the Eternal Refuge...",
          "Or Surah Al-Falaq: \nSay, 'I seek refuge in the Lord of the dawn...'",
          "Or Surah An-Nas: \nSay, 'I seek refuge in the Lord of mankind...'"
        ];
      case "Dhuhr":
        return [
          "1. Surah Al-Fatiha: \nIn the name of Allah, the Most Gracious, the Most Merciful...",
          "2. Surah Al-Ikhlas: \nSay, 'He is Allah, [Who is] One, Allah, the Eternal Refuge...",
          "Or Surah Al-Falaq: \nSay, 'I seek refuge in the Lord of the dawn...'",
          "Or Surah An-Nas: \nSay, 'I seek refuge in the Lord of mankind...'",
          "Or Surah Al-Zalzalah: \nWhen the earth is shaken with its [final] earthquake..."
        ];
      case "Asr":
        return [
          "1. Surah Al-Fatiha: \nIn the name of Allah, the Most Gracious, the Most Merciful...",
          "2. Surah Al-Ikhlas: \nSay, 'He is Allah, [Who is] One, Allah, the Eternal Refuge...",
          "Or Surah Al-Falaq: \nSay, 'I seek refuge in the Lord of the dawn...'",
          "Or Surah An-Nas: \nSay, 'I seek refuge in the Lord of mankind...'"
        ];
      case "Maghrib":
        return [
          "1. Surah Al-Fatiha: \nIn the name of Allah, the Most Gracious, the Most Merciful...",
          "2. Surah Al-Ikhlas: \nSay, 'He is Allah, [Who is] One, Allah, the Eternal Refuge...",
          "Or Surah Al-Falaq: \nSay, 'I seek refuge in the Lord of the dawn...'",
          "Or Surah An-Nas: \nSay, 'I seek refuge in the Lord of mankind...'",
          "Or Surah Al-Zalzalah: \nWhen the earth is shaken with its [final] earthquake..."
        ];
      case "Isha":
        return [
          "1. Surah Al-Fatiha: \nIn the name of Allah, the Most Gracious, the Most Merciful...",
          "2. Surah Al-Ikhlas: \nSay, 'He is Allah, [Who is] One, Allah, the Eternal Refuge...",
          "Or Surah Al-Falaq: \nSay, 'I seek refuge in the Lord of the dawn...'",
          "Or Surah An-Nas: \nSay, 'I seek refuge in the Lord of mankind...'",
          "Or Surah Al-Mulk: \nBlessed is He in whose hand is the dominion..."
        ];
      default:
        return [];
    }
  }
}
