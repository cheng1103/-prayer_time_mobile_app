import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
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
