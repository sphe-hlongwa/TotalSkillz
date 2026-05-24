import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  /// Get the current user's progress document
  Stream<UserProgress?> watchUserProgress() {
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProgress.fromFirestore(snap.data()!, uid!);
    });
  }

  Future<UserProgress?> getUserProgress() async {
    if (uid == null) return null;
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProgress.fromFirestore(snap.data()!, uid!);
  }

  /// Update topic progress after a quiz session
  Future<void> updateTopicProgress({
    required String topic,
    required int attempted,
    required int correct,
    required int total,
    int xpEarned = 0,
  }) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'topics.$topic.attempted': FieldValue.increment(attempted),
      'topics.$topic.correct': FieldValue.increment(correct),
      'topics.$topic.total': total,
      'topics.$topic.completed': correct >= (total * 0.8).ceil(),
      'xp': FieldValue.increment(xpEarned),
      'lastActive': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  /// Add a mistake to the vault
  Future<void> addToMistakeVault(MistakeItem mistake) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'mistakeVault': FieldValue.arrayUnion([mistake.toMap()]),
    });
  }

  /// Update user settings
  Future<void> updateSettings(UserSettings settings) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'settings': settings.toMap(),
    });
  }

  /// Update user streak
  Future<void> updateStreak() async {
    if (uid == null) return;
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return;

    final lastActive = data['lastActive'];
    if (lastActive == null) {
      await _db.collection('users').doc(uid).update({
        'streak': 1,
        'lastActive': FieldValue.serverTimestamp(),
      });
      return;
    }

    final DateTime lastDate;
    if (lastActive is Timestamp) {
      lastDate = lastActive.toDate();
    } else if (lastActive is String) {
      lastDate = DateTime.tryParse(lastActive) ?? DateTime.now();
    } else {
      lastDate = DateTime.now();
    }

    final now = DateTime.now();
    final diff = now.difference(lastDate).inDays;

    if (diff == 1) {
      await _db.collection('users').doc(uid).update({
        'streak': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } else if (diff > 1) {
      await _db.collection('users').doc(uid).update({
        'streak': 1,
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Admin: fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snap = await _db.collection('users').get();
      return snap.docs.map((d) {
        final data = d.data();
        data['uid'] = d.id; // Ensure UID is included
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  /// Admin: Toggle admin status
  Future<void> toggleAdminStatus(String targetUid, bool status) async {
    if (uid == null) return;
    await _db.collection('users').doc(targetUid).update({'role': status ? 'admin' : 'student'});
  }

  /// Admin: Delete user account
  Future<void> deleteUser(String targetUid) async {
    if (uid == null) return;
    await _db.collection('users').doc(targetUid).delete();
  }

  /// Admin: reset user progress
  Future<void> resetUserProgress(String targetUid) async {
    if (uid == null) return;
    await _db.collection('users').doc(targetUid).update({
      'topics': {},
      'xp': 0,
      'streak': 0,
      'mistakeVault': [],
    });
  }

  /// Admin: Fetch bug reports
  Stream<List<Map<String, dynamic>>> watchBugReports() {
    return _db.collection('reports').orderBy('timestamp', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    });
  }

  /// Admin: Update report status
  Future<void> updateReportStatus(String reportId, String status) async {
    await _db.collection('reports').doc(reportId).update({'status': status});
  }

  /// Admin: Send broadcast
  Future<void> sendBroadcast({
    required String title,
    required String body,
    required String type,
    required int expiryDays,
  }) async {
    await _db.collection('broadcasts').add({
      'title': title,
      'body': body,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(Duration(days: expiryDays)),
      'author': uid,
    });
  }

  /// Admin: Fetch all broadcasts count
  Future<int> getBroadcastCount() async {
    final snap = await _db.collection('broadcasts').get();
    return snap.size;
  }

  /// Student: Watch for active broadcasts
  Stream<List<Map<String, dynamic>>> watchActiveBroadcasts() {
    final now = DateTime.now();
    return _db
        .collection('broadcasts')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Student: Submit a bug report
  Future<void> submitBugReport({
    required String description, // Keep parameter name for UI compatibility
    required String source,
  }) async {
    if (uid == null) return;
    await _db.collection('reports').add({
      'uid': uid,
      'comment': description, // Rule expects 'comment'
      'module': source,       // Rule expects 'module'
      'status': 'open',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
