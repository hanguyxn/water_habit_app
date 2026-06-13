import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';
import 'package:water_habit_app/features/friends/domain/friend_model.dart';
import 'package:water_habit_app/features/friends/domain/friend_request_model.dart';

class FriendRepository {
  FriendRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _friendRequestsCollection =>
      _firestore.collection('friend_requests');

  CollectionReference<Map<String, dynamic>> get _waterSupportCollection =>
      _firestore.collection('water_supports');

  // ─── Search Users ──────────────────────────────────────────────────────────

  /// Search users by username prefix. Returns up to 20 matching users,
  /// excluding the current user.
  Future<List<UserModel>> searchUsers(String query, {String? excludeUserId}) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();
    final endQuery = '${normalizedQuery}\uf8ff';

    final snapshot = await _usersCollection
        .where('username', isGreaterThanOrEqualTo: normalizedQuery)
        .where('username', isLessThanOrEqualTo: endQuery)
        .limit(20)
        .get();

    return snapshot.docs
        .where((doc) => doc.id != excludeUserId)
        .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ─── Friend Requests ──────────────────────────────────────────────────────

  /// Send a friend request from currentUserId to targetUserId.
  /// Checks for existing requests and existing friendships.
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    // Check if already friends
    final existingFriend = await _usersCollection
        .doc(currentUserId)
        .collection('friends')
        .doc(targetUserId)
        .get();

    if (existingFriend.exists) {
      throw FriendException('Đã là bạn bè rồi');
    }

    // Check for existing pending request in either direction
    final existingRequest = await _friendRequestsCollection
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: targetUserId)
        .where('status', isEqualTo: 0) // pending
        .limit(1)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw FriendException('Đã gửi lời mời kết bạn');
    }

    // Check if the target user already sent us a request
    final reverseRequest = await _friendRequestsCollection
        .where('senderId', isEqualTo: targetUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 0) // pending
        .limit(1)
        .get();

    if (reverseRequest.docs.isNotEmpty) {
      // Auto-accept the reverse request
      await acceptFriendRequest(reverseRequest.docs.first.id);
      return;
    }

    // Get sender info
    final senderDoc = await _usersCollection.doc(currentUserId).get();
    final senderData = senderDoc.data();
    if (senderData == null) throw FriendException('Không tìm thấy người dùng');

    // Get receiver info
    final receiverDoc = await _usersCollection.doc(targetUserId).get();
    final receiverData = receiverDoc.data();
    if (receiverData == null) throw FriendException('Không tìm thấy người dùng');

    await _friendRequestsCollection.add({
      'senderId': currentUserId,
      'senderUsername': senderData['username'] ?? '',
      'senderAvatarUrl': senderData['avatarUrl'],
      'senderLevel': senderData['level'] ?? 1,
      'receiverId': targetUserId,
      'receiverUsername': receiverData['username'] ?? '',
      'status': 0, // pending
      'createdAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    });
  }

  /// Accept a friend request - creates bidirectional friend entries.
  Future<void> acceptFriendRequest(String requestId) async {
    final requestDoc = await _friendRequestsCollection.doc(requestId).get();
    final data = requestDoc.data();
    if (data == null) throw FriendException('Không tìm thấy lời mời');

    if (data['status'] != 0) {
      throw FriendException('Lời mời đã được xử lý');
    }

    final senderId = data['senderId'] as String;
    final receiverId = data['receiverId'] as String;
    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();

    // Update request status
    batch.update(_friendRequestsCollection.doc(requestId), {
      'status': 1, // accepted
      'respondedAt': now,
    });

    // Get both user documents for friend data
    final senderDoc = await _usersCollection.doc(senderId).get();
    final receiverDoc = await _usersCollection.doc(receiverId).get();
    final senderData = senderDoc.data() ?? {};
    final receiverData = receiverDoc.data() ?? {};

    // Add friend entry for sender -> receiver
    batch.set(
      _usersCollection.doc(senderId).collection('friends').doc(receiverId),
      {
        'id': receiverId,
        'username': receiverData['username'] ?? '',
        'displayName': receiverData['displayName'],
        'avatarUrl': receiverData['avatarUrl'],
        'level': receiverData['level'] ?? 1,
        'currentStreak': receiverData['currentStreak'] ?? 0,
        'todayProgressPercent': 0.0,
        'todayConsumedMl': 0,
        'todayGoalMl': receiverData['dailyGoalMl'] ?? 2500,
        'friendStatus': 0,
        'lastActiveAt': receiverData['lastActiveAt'],
        'friendsSince': now,
      },
    );

    // Add friend entry for receiver -> sender
    batch.set(
      _usersCollection.doc(receiverId).collection('friends').doc(senderId),
      {
        'id': senderId,
        'username': senderData['username'] ?? '',
        'displayName': senderData['displayName'],
        'avatarUrl': senderData['avatarUrl'],
        'level': senderData['level'] ?? 1,
        'currentStreak': senderData['currentStreak'] ?? 0,
        'todayProgressPercent': 0.0,
        'todayConsumedMl': 0,
        'todayGoalMl': senderData['dailyGoalMl'] ?? 2500,
        'friendStatus': 0,
        'lastActiveAt': senderData['lastActiveAt'],
        'friendsSince': now,
      },
    );

    // Increment friend count for both users
    batch.update(_usersCollection.doc(senderId), {
      'friendCount': FieldValue.increment(1),
    });
    batch.update(_usersCollection.doc(receiverId), {
      'friendCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Reject a friend request.
  Future<void> rejectFriendRequest(String requestId) async {
    final requestDoc = await _friendRequestsCollection.doc(requestId).get();
    if (!requestDoc.exists) throw FriendException('Không tìm thấy lời mời');

    final data = requestDoc.data();
    if (data?['status'] != 0) {
      throw FriendException('Lời mời đã được xử lý');
    }

    await _friendRequestsCollection.doc(requestId).update({
      'status': 2, // rejected
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an outgoing friend request.
  Future<void> cancelFriendRequest(String requestId) async {
    final requestDoc = await _friendRequestsCollection.doc(requestId).get();
    if (!requestDoc.exists) throw FriendException('Không tìm thấy lời mời');

    final data = requestDoc.data();
    if (data?['status'] != 0) {
      throw FriendException('Lời mời đã được xử lý');
    }

    await _friendRequestsCollection.doc(requestId).update({
      'status': 3, // cancelled
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a friend - deletes bidirectional friend entries.
  Future<void> removeFriend(String currentUserId, String friendId) async {
    final batch = _firestore.batch();

    batch.delete(
      _usersCollection.doc(currentUserId).collection('friends').doc(friendId),
    );
    batch.delete(
      _usersCollection.doc(friendId).collection('friends').doc(currentUserId),
    );

    // Decrement friend count for both
    batch.update(_usersCollection.doc(currentUserId), {
      'friendCount': FieldValue.increment(-1),
    });
    batch.update(_usersCollection.doc(friendId), {
      'friendCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // ─── Friends List ─────────────────────────────────────────────────────────

  /// Stream of friends list for a user, ordered by last active time.
  Stream<List<FriendModel>> getFriends(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('friends')
        .orderBy('lastActiveAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendModel.fromJson({
          ...data,
          'id': doc.id,
          // Handle Firestore Timestamps
          'friendsSince': data['friendsSince'] is Timestamp
              ? (data['friendsSince'] as Timestamp).toDate().toIso8601String()
              : data['friendsSince'],
          'lastActiveAt': data['lastActiveAt'] is Timestamp
              ? (data['lastActiveAt'] as Timestamp).toDate().toIso8601String()
              : data['lastActiveAt'],
        });
      }).toList();
    });
  }

  /// Stream of incoming friend requests (pending) for a user.
  Stream<List<FriendRequestModel>> getIncomingRequests(String userId) {
    return _friendRequestsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 0) // pending
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromJson({
          ...data,
          'id': doc.id,
          'createdAt': data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : data['createdAt'],
          'respondedAt': data['respondedAt'] is Timestamp
              ? (data['respondedAt'] as Timestamp).toDate().toIso8601String()
              : data['respondedAt'],
        });
      }).toList();
    });
  }

  /// Stream of outgoing friend requests (pending) for a user.
  Stream<List<FriendRequestModel>> getOutgoingRequests(String userId) {
    return _friendRequestsCollection
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 0) // pending
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromJson({
          ...data,
          'id': doc.id,
          'createdAt': data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : data['createdAt'],
          'respondedAt': data['respondedAt'] is Timestamp
              ? (data['respondedAt'] as Timestamp).toDate().toIso8601String()
              : data['respondedAt'],
        });
      }).toList();
    });
  }

  // ─── Water Support ────────────────────────────────────────────────────────

  /// Check if water support can be sent (24h cooldown).
  Future<bool> canSendWaterSupport(String fromUserId, String toUserId) async {
    final cooldownThreshold = DateTime.now().subtract(const Duration(hours: 24));

    final existing = await _waterSupportCollection
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cooldownThreshold))
        .limit(1)
        .get();

    return existing.docs.isEmpty;
  }

  /// Send water support (+5 XP for both users). Enforces 24h cooldown.
  Future<void> sendWaterSupport(String fromUserId, String toUserId) async {
    final canSend = await canSendWaterSupport(fromUserId, toUserId);
    if (!canSend) {
      throw FriendException('Đã gửi hỗ trợ cho bạn này rồi. Hãy đợi 24 giờ nhé!');
    }

    final batch = _firestore.batch();

    // Record the support
    final supportRef = _waterSupportCollection.doc();
    batch.set(supportRef, {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Award XP to both users
    batch.update(_usersCollection.doc(fromUserId), {
      'xp': FieldValue.increment(5),
    });
    batch.update(_usersCollection.doc(toUserId), {
      'xp': FieldValue.increment(5),
    });

    await batch.commit();
  }
}

class FriendException implements Exception {
  const FriendException(this.message);
  final String message;

  @override
  String toString() => message;
}
