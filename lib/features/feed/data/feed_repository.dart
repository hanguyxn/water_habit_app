import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_habit_app/features/feed/domain/feed_item_model.dart';

class FeedRepository {
  FeedRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _feedCollection =>
      _firestore.collection('feed');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // ─── Feed Stream ──────────────────────────────────────────────────────────

  /// Get paginated feed stream for a user (shows their friends' activities).
  /// Returns feed items from friends, ordered by creation time descending.
  Stream<List<FeedItemModel>> getFeed(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) {
    // First get the user's friend IDs
    return _usersCollection
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((friendsSnapshot) async {
      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();

      if (friendIds.isEmpty) return <FeedItemModel>[];

      // Firestore 'whereIn' supports max 30 values, so we chunk
      final allItems = <FeedItemModel>[];

      for (var i = 0; i < friendIds.length; i += 30) {
        final chunk = friendIds.sublist(
          i,
          i + 30 > friendIds.length ? friendIds.length : i + 30,
        );

        Query<Map<String, dynamic>> query = _feedCollection
            .where('userId', whereIn: chunk)
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();

        allItems.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return FeedItemModel.fromJson({
            ...data,
            'id': doc.id,
            'createdAt': data['createdAt'] is Timestamp
                ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
                : data['createdAt'],
            'reactions': (data['reactions'] as Map<String, dynamic>?)
                    ?.map((k, v) => MapEntry(k, v as int)) ??
                {},
          });
        }));
      }

      // Sort all items by createdAt descending
      allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allItems.take(limit).toList();
    });
  }

  // ─── Reactions ────────────────────────────────────────────────────────────

  /// Add or update a reaction on a feed item.
  /// reactionType: 0 = ❤️, 1 = 🌱, 2 = 🔥, 3 = 💧
  Future<void> addReaction(
    String feedItemId,
    String userId,
    int reactionType,
  ) async {
    await _feedCollection.doc(feedItemId).update({
      'reactions.$userId': reactionType,
    });
  }

  /// Remove a reaction from a feed item.
  Future<void> removeReaction(String feedItemId, String userId) async {
    await _feedCollection.doc(feedItemId).update({
      'reactions.$userId': FieldValue.delete(),
    });
  }

  // ─── Post Feed Event ──────────────────────────────────────────────────────

  /// Post a new feed event.
  /// eventType: goalCompleted(0), streakMilestone(1), levelUp(2), waterSupport(3), newFriend(4)
  Future<void> postFeedEvent(
    String userId,
    int eventType,
    String message, {
    String? extraData,
  }) async {
    // Get user info for the feed item
    final userDoc = await _usersCollection.doc(userId).get();
    final userData = userDoc.data();
    if (userData == null) return;

    await _feedCollection.add({
      'userId': userId,
      'username': userData['username'] ?? '',
      'userAvatarUrl': userData['avatarUrl'],
      'userLevel': userData['level'] ?? 1,
      'eventType': eventType,
      'message': message,
      'extraData': extraData,
      'reactions': {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
