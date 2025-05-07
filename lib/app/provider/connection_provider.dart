import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/model/connected_user.dart';

class ConnectionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userId = '';
  List<ConnectedUser> _connectedUsers = [];

  ConnectionProvider();

  String get userId => _userId;
  List<ConnectedUser> get connectedUsers => _connectedUsers;

  set userId(String id) {
    _userId = id;
    notifyListeners();
  }

  // Function to connect with another user by email
  Future<void> connectToUserByEmail(String email, String nickname) async {
    try {
      bool emailAlreadyConnected =
          _connectedUsers.any((user) => user.email == email);
      if (emailAlreadyConnected) {
        throw 'This email is already connected.';
      }

      // Check if the email exists in Firestore
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1) // We just need to check one document
          .get();

      if (userSnapshot.docs.isEmpty) {
        // No user found with this email in Firestore
        throw 'No user found with this email';
      }

      // If user is found, get their user data
      var userDoc = userSnapshot.docs.first;
      String targetUserId = userDoc.id;

      // Add to the current user's connected_users
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('connected_users')
          .doc(targetUserId)
          .set({
        'nickname': nickname,
        'email': email,
        'connected': true,
      });

      _connectedUsers.add(ConnectedUser.fromFirestore({
        'nickname': nickname,
        'email': email,
        'connected': true,
        'targetUserId': targetUserId
      }));

      notifyListeners();
    } catch (e) {
      print('Error connecting to user: $e');
      throw 'Failed to connect. Please check the email address.';
    }
  }

  // Get connected users from Firestore
  Future<void> getConnectedUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('connected_users')
          .get();

      _connectedUsers = snapshot.docs.map((doc) {
        return ConnectedUser.fromFirestore({
          'nickname': doc['nickname'] ?? '',
          'email': doc['email'] ?? '',
          'connected': doc['connected'] ?? false,
          'targetUserId': doc.id
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching connected users: $e');
    }
  }
}
