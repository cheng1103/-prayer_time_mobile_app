import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prayer_time_mobile_app/app/provider/prayer_provider.dart';

class DbPrayerProvider extends ChangeNotifier {
  Map<String, int> _attendanceCounts = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };
  
  final PrayerProvider _prayerProvider;
  
  DbPrayerProvider(this._prayerProvider);

  // Fetch monthly attendance data
  void fetchMonthlyAttendanceData() async {
    // Fetch the data from Firebase or your local database here
    // For now, we can simulate some data to work with
    _attendanceCounts = {
      'Fajr': 3,
      'Dhuhr': 15,
      'Asr': 10,
      'Maghrib': 12,
      'Isha': 8,
    };

    // Notify listeners after updating the data
    notifyListeners();
  }

  Map<String, int> get attendanceCounts => _attendanceCounts;

  // Create BarChart data
  BarChartData getBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(reservedSize: 30, showTitles: true),
        ),
      ),
      borderData: FlBorderData(show: true),
      barGroups: _generateBarGroups(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.grey,
          tooltipRoundedRadius: 8,
        ),
      ),
    );
  }

  // Generate bar chart data for each prayer
  List<BarChartGroupData> _generateBarGroups() {
    return [
      _createBarGroup('Fajr'),
      _createBarGroup('Dhuhr'),
      _createBarGroup('Asr'),
      _createBarGroup('Maghrib'),
      _createBarGroup('Isha'),
    ];
  }

  // Create each bar group
  BarChartGroupData _createBarGroup(String prayerName) {
    return BarChartGroupData(
      x: _getPrayerIndex(prayerName),
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: _attendanceCounts[prayerName]!.toDouble(),
          color: _getPrayerColor(prayerName),
          width: 15,
        ),
      ],
    );
  }

  // Get the index for the prayer name
  int _getPrayerIndex(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 0;
      case 'Dhuhr':
        return 1;
      case 'Asr':
        return 2;
      case 'Maghrib':
        return 3;
      case 'Isha':
        return 4;
      default:
        return 0;
    }
  }

  // Get the color for each prayer
  Color _getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Colors.blue;
      case 'Dhuhr':
        return Colors.green;
      case 'Asr':
        return Colors.orange;
      case 'Maghrib':
        return Colors.red;
      case 'Isha':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
