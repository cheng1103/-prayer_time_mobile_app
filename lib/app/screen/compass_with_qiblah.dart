import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/qiblah_compass_widget.dart';
import '../component/footer_navigation.dart';
import '../component/custom_drawer.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  _CompassWithQiblahState createState() => _CompassWithQiblahState();
}

class _CompassWithQiblahState extends State<CompassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiblah Compass'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: QiblahCompassWidget(),
            ),
          ),
          FooterNavigation(),
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
      drawerEnableOpenDragGesture: false,
    );
  }
}
