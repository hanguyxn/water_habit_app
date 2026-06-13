import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';
import 'package:water_habit_app/features/profile/domain/profile_model.dart';

class ProfileRepository {
  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _achievementsCollection =>
      _firestore.collection('achievements');

  /// Stream a user's profile
  Stream<UserModel?> getProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
    });
  }

  /// Fetch computed profile stats
  Future<ProfileStats> getProfileStats(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return ProfileStats.empty();

      final userData = userDoc.data()!;

      // Fetch daily goals to compute stats
      final goalsSnapshot = await _usersCollection
          .doc(userId)
          .collection('dailyGoals')
          .orderBy('date', descending: true)
          .get();

      int totalDaysTracked = goalsSnapshot.docs.length;
      int goalsCompleted = 0;
      double totalWaterMl = 0;

      for (final doc in goalsSnapshot.docs) {
        final data = doc.data();
        final consumed = (data['consumedMl'] as num?)?.toDouble() ?? 0;
        totalWaterMl += consumed;
        if (data['completed'] == true) {
          goalsCompleted++;
        }
      }

      final averageDailyMl =
          totalDaysTracked > 0 ? totalWaterMl / totalDaysTracked : 0.0;

      // Fetch achievement count
      final achievementsSnapshot = await _usersCollection
          .doc(userId)
          .collection('achievements')
          .where('isUnlocked', isEqualTo: true)
          .get();

      return ProfileStats(
        totalDaysTracked: totalDaysTracked,
        goalsCompleted: goalsCompleted,
        averageDailyMl: averageDailyMl,
        currentStreak: (userData['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (userData['longestStreak'] as num?)?.toInt() ?? 0,
        totalWaterLiters: totalWaterMl / 1000.0,
        achievementCount: achievementsSnapshot.docs.length,
        friendCount: (userData['friendCount'] as num?)?.toInt() ?? 0,
        level: (userData['level'] as num?)?.toInt() ?? 1,
        xp: (userData['xp'] as num?)?.toInt() ?? 0,
        xpForNextLevel: _calculateXpForNextLevel(
          (userData['level'] as num?)?.toInt() ?? 1,
        ),
        seasonalRank: (userData['seasonalRank'] as num?)?.toInt() ?? 0,
        prestigeStars: (userData['prestigeStars'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      return ProfileStats.empty();
    }
  }

  /// Update profile fields
  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _usersCollection.doc(userId).update(updates);
  }

  /// Upload avatar image and return download URL
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final ref = _storage.ref().child('avatars/$userId/profile.jpg');

    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Update user document with new avatar URL
    await _usersCollection.doc(userId).update({
      'avatarUrl': downloadUrl,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  /// Update daily water goal
  Future<void> updateDailyGoal(String userId, int goalMl) async {
    await _usersCollection.doc(userId).update({
      'dailyGoalMl': goalMl,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream achievements for a user
  Stream<List<Achievement>> getAchievements(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('achievements')
        .orderBy('earnedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  /// Get all possible achievements (template)
  Future<List<Achievement>> getAllAchievementTemplates() async {
    final snapshot = await _achievementsCollection.get();
    return snapshot.docs.map((doc) {
      return Achievement.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Get weekly water data for chart
  Future<List<WeeklyWaterData>> getWeeklyWaterData(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final days = <WeeklyWaterData>[];

    // Get user's daily goal
    final userDoc = await _usersCollection.doc(userId).get();
    final dailyGoalMl =
        (userDoc.data()?['dailyGoalMl'] as num?)?.toDouble() ?? 2500;

    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final dayLabel = dayLabels[date.weekday - 1];

      // Try to fetch the daily goal document
      final goalDoc = await _usersCollection
          .doc(userId)
          .collection('dailyGoals')
          .doc(dateStr)
          .get();

      final consumedMl =
          (goalDoc.data()?['consumedMl'] as num?)?.toDouble() ?? 0;

      days.add(WeeklyWaterData(
        dayLabel: dayLabel,
        amountMl: consumedMl,
        goalMl: dailyGoalMl,
        date: date,
      ));
    }

    return days;
  }

  int _calculateXpForNextLevel(int currentLevel) {
    // XP curve: each level requires progressively more XP
    return 100 + (currentLevel * 50);
  }
}
