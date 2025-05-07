import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '',
              style: TextStyle(fontSize: 24),
            ),
          ),
          FooterNavigation(), // Footer navigation buttons
        ],
      ),

      endDrawer: CustomDrawer(
        onLogout: () {
          // Implement logout functionality
        },
        onSettings: () {
          Navigator.pushNamed(context, '/settings'); // Navigate to settings
        },
        onFeedback: () {
          Navigator.pushNamed(
              context, '/feedback'); // Navigate to feedback page
        },
        onNotifications: () {
          Navigator.pushNamed(
              context, '/notifications'); // Navigate to notifications page
        },
      ),

      drawerEnableOpenDragGesture: false, // Disable drag to open drawer
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';
// import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
// import 'package:quran/quran.dart' as quran;
// import 'package:google_fonts/google_fonts.dart';

// class QuranScreen extends StatefulWidget {
//   const QuranScreen({super.key});

//   @override
//   _QuranScreenState createState() => _QuranScreenState();
// }

// class _QuranScreenState extends State<QuranScreen> {
//   // This will hold the selected button (Surah or Juz)
//   bool isSurahSelected = true;
//   TextEditingController searchController = TextEditingController();
//   List<String> surahTitles = [];
//   List<String> juzTitles = [];
//   List<String> filteredTitles = [];

//   @override
//   void initState() {
//     super.initState();
//     // Populate Surah and Juz titles
//     surahTitles = List.generate(
//         quran.totalSurahCount, (index) => quran.getSurahName(index + 1));
//     juzTitles =
//         List.generate(30, (index) => 'Juz ${index + 1}'); // Total of 30 Juz
//     filteredTitles = surahTitles;
//   }

//   // Function to filter the titles based on the search query
//   void filterTitles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredTitles = isSurahSelected ? surahTitles : juzTitles;
//       } else {
//         filteredTitles = (isSurahSelected ? surahTitles : juzTitles)
//             .where((title) => title.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quran'),
//       ),
//       body: Column(
//         children: [
//           // Box with buttons
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isSurahSelected = true;
//                       filteredTitles = surahTitles;
//                     });
//                   },
//                   child: const Text('Surah'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isSurahSelected = false;
//                       filteredTitles = juzTitles;
//                     });
//                   },
//                   child: const Text('Juz'),
//                 ),
//               ],
//             ),
//           ),
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: TextField(
//               controller: searchController,
//               onChanged: filterTitles,
//               decoration: InputDecoration(
//                 hintText: 'Search for a Surah or Juz',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//             ),
//           ),
//           // List bar to show Surah or Juz
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredTitles.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(
//                     filteredTitles[index],
//                     style: GoogleFonts.amiri(),
//                   ),
//                   onTap: () {
//                     if (isSurahSelected) {
//                       // When Surah is selected, show Surah details
//                       int surahNumber =
//                           surahTitles.indexOf(filteredTitles[index]) + 1;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SurahDetailScreen(surahNumber: surahNumber),
//                         ),
//                       );
//                     } else {
//                       // When Juz is selected, show Juz details
//                       int juzNumber =
//                           juzTitles.indexOf(filteredTitles[index]) + 1;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               JuzDetailScreen(juzNumber: juzNumber),
//                         ),
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//           FooterNavigation(), // Footer navigation buttons
//         ],
//       ),
//       endDrawer: CustomDrawer(
//         onLogout: () {
//           // Implement logout functionality
//         },
//         onSettings: () {
//           Navigator.pushNamed(context, '/settings'); // Navigate to settings
//         },
//         onFeedback: () {
//           Navigator.pushNamed(
//               context, '/feedback'); // Navigate to feedback page
//         },
//         onNotifications: () {
//           Navigator.pushNamed(
//               context, '/notifications'); // Navigate to notifications page
//         },
//       ),
//       drawerEnableOpenDragGesture: false, // Disable drag to open drawer
//     );
//   }
// }

// class SurahDetailScreen extends StatelessWidget {
//   final int surahNumber;

//   const SurahDetailScreen({super.key, required this.surahNumber});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(quran.getSurahName(surahNumber)),
//       ),
//       body: ListView.builder(
//         itemCount: quran.getVerseCount(surahNumber),
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(
//               quran.getVerse(surahNumber, index + 1, verseEndSymbol: true),
//               textAlign: TextAlign.right,
//               style: GoogleFonts.amiri(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class JuzDetailScreen extends StatelessWidget {
//   final int juzNumber;

//   const JuzDetailScreen({super.key, required this.juzNumber});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Juz $juzNumber'),
//       ),
//       body: ListView.builder(
//         itemCount: quran.getSurahAndVersesFromJuz(juzNumber).length,
//         itemBuilder: (context, index) {
//           var surahInfo = quran.getSurahAndVersesFromJuz(juzNumber)[index];
//           return ListTile(
//             title: Text(
//               // Ensure surahNumber is parsed to an integer
//               '${quran.getSurahName(int.parse(surahInfo['surahNumber'].toString()))} - Verse ${surahInfo['verseNumber']}',
//               style: GoogleFonts.amiri(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
