class ConnectedUser {
  final String nickname;
  final String email;
  final bool connected;
  final String targetUserId; // Store the target user's ID

  ConnectedUser({
    required this.nickname,
    required this.email,
    required this.connected,
    required this.targetUserId, // Include targetUserId in constructor
  });

  // Factory method to create a ConnectedUser from Firestore data
  factory ConnectedUser.fromFirestore(Map<String, dynamic> data) {
    return ConnectedUser(
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      connected: data['connected'] ?? false,
      targetUserId: data['targetUserId'] ?? '', // Fetch targetUserId from Firestore
    );
  }

  // Convert a ConnectedUser instance to a map (useful for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'connected': connected,
      'targetUserId': targetUserId, // Include targetUserId in map for saving
    };
  }
}
