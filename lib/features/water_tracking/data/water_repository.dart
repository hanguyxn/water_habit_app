import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:water_habit_app/features/water_tracking/domain/daily_goal_model.dart';
import 'package:water_habit_app/features/water_tracking/domain/water_entry_model.dart';

class WaterRepository {
  WaterRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  CollectionReference<Map<String, dynamic>> _dailyGoalsCollection(
    String userId,
  ) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_goals');

  /// Add a water entry for today
  Future<void> addWaterEntry(String userId, WaterEntry entry) async {
    final today = _dateFormat.format(DateTime.now());
    final docRef = _dailyGoalsCollection(userId).doc(today);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final currentConsumed = (data['consumedMl'] as num?)?.toInt() ?? 0;
        final goalMl = (data['goalMl'] as num?)?.toInt() ?? 2500;
        final entries = List<Map<String, dynamic>>.from(
          data['entries'] as List? ?? [],
        );
        entries.add(entry.toJson());

        final newConsumed = currentConsumed + entry.amountMl;
        final isCompleted = newConsumed >= goalMl;

        transaction.update(docRef, {
          'consumedMl': newConsumed,
          'entries': entries,
          'completed': isCompleted,
          if (isCompleted && data['completedAt'] == null)
            'completedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final isCompleted = entry.amountMl >= 2500;
        transaction.set(docRef, {
          'date': today,
          'goalMl': 2500,
          'consumedMl': entry.amountMl,
          'entries': [entry.toJson()],
          'completed': isCompleted,
          if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    // Update total in user document
    await _firestore.collection('users').doc(userId).update({
      'totalWaterMl': FieldValue.increment(entry.amountMl.toDouble()),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a water entry
  Future<void> removeWaterEntry(
    String userId,
    String date,
    String entryId,
  ) async {
    final docRef = _dailyGoalsCollection(userId).doc(date);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final entries = List<Map<String, dynamic>>.from(
        data['entries'] as List? ?? [],
      );

      final entryIndex = entries.indexWhere((e) => e['id'] == entryId);
      if (entryIndex == -1) return;

      final removedAmount =
          (entries[entryIndex]['amountMl'] as num?)?.toInt() ?? 0;
      entries.removeAt(entryIndex);

      final newConsumed =
          ((data['consumedMl'] as num?)?.toInt() ?? 0) - removedAmount;
      final goalMl = (data['goalMl'] as num?)?.toInt() ?? 2500;

      transaction.update(docRef, {
        'consumedMl': newConsumed.clamp(0, double.infinity).toInt(),
        'entries': entries,
        'completed': newConsumed >= goalMl,
        if (newConsumed < goalMl) 'completedAt': null,
      });

      // Update user total
      await _firestore.collection('users').doc(userId).update({
        'totalWaterMl': FieldValue.increment(-removedAmount.toDouble()),
      });
    });
  }

  /// Get daily goal stream for a specific date
  Stream<DailyGoal> getDailyGoal(String userId, String date) {
    return _dailyGoalsCollection(userId)
        .doc(date)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return DailyGoal(
          date: date,
          goalMl: 2500,
          consumedMl: 0,
          entries: [],
          completed: false,
        );
      }
      return DailyGoal.fromJson(snapshot.data()!);
    });
  }

  /// Update daily goal amount
  Future<void> updateDailyGoal(String userId, int goalMl) async {
    final today = _dateFormat.format(DateTime.now());
    final docRef = _dailyGoalsCollection(userId).doc(today);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final consumedMl =
          (snapshot.data()?['consumedMl'] as num?)?.toInt() ?? 0;
      await docRef.update({
        'goalMl': goalMl,
        'completed': consumedMl >= goalMl,
      });
    } else {
      await docRef.set({
        'date': today,
        'goalMl': goalMl,
        'consumedMl': 0,
        'entries': [],
        'completed': false,
      });
    }

    // Update user's default daily goal
    await _firestore.collection('users').doc(userId).update({
      'dailyGoalMl': goalMl,
    });
  }

  /// Get weekly data
  Future<List<DailyGoal>> getWeeklyData(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (i) {
      return _dateFormat.format(startOfWeek.add(Duration(days: i)));
    });

    final snapshots = await Future.wait(
      dates.map((date) => _dailyGoalsCollection(userId).doc(date).get()),
    );

    return List.generate(7, (i) {
      final snapshot = snapshots[i];
      if (snapshot.exists && snapshot.data() != null) {
        return DailyGoal.fromJson(snapshot.data()!);
      }
      return DailyGoal(
        date: dates[i],
        goalMl: 2500,
        consumedMl: 0,
        entries: [],
        completed: false,
      );
    });
  }

  /// Get monthly data
  Future<List<DailyGoal>> getMonthlyData(String userId) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;

    final dates = List.generate(daysInMonth, (i) {
      return _dateFormat.format(firstDay.add(Duration(days: i)));
    });

    final query = await _dailyGoalsCollection(userId)
        .where('date', isGreaterThanOrEqualTo: dates.first)
        .where('date', isLessThanOrEqualTo: dates.last)
        .get();

    final dataMap = <String, DailyGoal>{};
    for (final doc in query.docs) {
      if (doc.data().isNotEmpty) {
        dataMap[doc.id] = DailyGoal.fromJson(doc.data());
      }
    }

    return dates.map((date) {
      return dataMap[date] ??
          DailyGoal(
            date: date,
            goalMl: 2500,
            consumedMl: 0,
            entries: [],
            completed: false,
          );
    }).toList();
  }

  /// Get today's date string
  String getTodayDate() => _dateFormat.format(DateTime.now());
}
