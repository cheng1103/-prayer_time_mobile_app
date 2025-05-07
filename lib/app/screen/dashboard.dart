import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer_time_mobile_app/app/provider/db_prayer_provider.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the monthly attendance data when the screen is initialized
    final dbPrayerProvider =
        Provider.of<DbPrayerProvider>(context, listen: false);

    // Use addPostFrameCallback to avoid notifying listeners during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dbPrayerProvider
          .fetchMonthlyAttendanceData(); // Fetch data after the frame is built
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbPrayerProvider = Provider.of<DbPrayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Prayer Attendance'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: CustomDrawer(
        onLogout: () {
          // Implement logout functionality
        },
        onSettings: () {
          Navigator.pushNamed(context, '/settings');
        },
        onFeedback: () {
          Navigator.pushNamed(context, '/feedback');
        },
        onNotifications: () {
          Navigator.pushNamed(context, '/notifications');
        },
      ),
      drawerEnableOpenDragGesture: false,
      bottomNavigationBar: const FooterNavigation(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildPrayerChart(dbPrayerProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerChart(DbPrayerProvider dbPrayerProvider) {
    return SizedBox(
      height: 300,
      child: BarChart(
        dbPrayerProvider.getBarChartData(),
      ),
    );
  }
}
