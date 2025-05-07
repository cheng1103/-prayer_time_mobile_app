import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prayer_time_mobile_app/app/component/logout.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onSettings;
  final VoidCallback onFeedback;
  final VoidCallback onNotifications;

  const CustomDrawer({
    required this.onLogout,
    required this.onSettings,
    required this.onFeedback,
    required this.onNotifications,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      elevation: 16.0,
      child: Column(
        children: [
          // Profile Section
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "No Name"),
            accountEmail: Text(user?.email ?? "No Email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(
                user?.displayName != null
                    ? user!.displayName![0].toUpperCase()
                    : "N/A",
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              onSettings(); // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Feedback"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              onFeedback(); // Navigate to feedback page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              onNotifications(); // Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              LogoutDialog.showLogoutDialog(context); // Show logout dialog
            },
          ),
        ],
      ),
    );
  }
}
