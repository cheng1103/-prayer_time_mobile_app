import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

      body: const Center(
        child: Text('Settings Screen'),
      ),
      bottomNavigationBar:
          const FooterNavigation(), // Add the FooterNavigation here
      drawerEnableOpenDragGesture: false, // Disable drag to open drawer
    );
  }
}
