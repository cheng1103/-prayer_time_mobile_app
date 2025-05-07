import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch additional user data from your Firebase database
      // Here, just returning a dummy map for demonstration
      return {
        'username': user.displayName ?? 'Unknown User',
        'email': user.email ?? 'No Email',
        'age': '', // Empty string if no data
        'phone': '' // Empty string if no data
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    userData['username']?.substring(0, 2) ?? 'UP',
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userData['username'] ?? 'Thang Xian Ya',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['email'] ?? 'example@mail.com',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FooterNavigation(),
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
