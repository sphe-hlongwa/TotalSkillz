import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BugReport {
  final String id;
  final String userId;
  final String userEmail;
  final String title;
  final String description;
  final String severity; // low, medium, high, critical
  final String? screenshot; // URL to stored image
  final String appVersion;
  final DateTime createdAt;
  final String status; // open, acknowledged, in_progress, resolved, closed

  BugReport({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.severity,
    this.screenshot,
    required this.appVersion,
    required this.createdAt,
    this.status = 'open',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'severity': severity,
      'screenshot': screenshot,
      'appVersion': appVersion,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory BugReport.fromMap(Map<String, dynamic> map, String id) {
    return BugReport(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'medium',
      screenshot: map['screenshot'],
      appVersion: map['appVersion'] ?? '1.0.0',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'open',
    );
  }
}

class BugReportService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitBugReport({
    required String title,
    required String description,
    required String severity,
    String? screenshot,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String appVersion = '1.0.0';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      } catch (e) {
        // Fallback to default
      }

      await _firestore.collection('reports').add({
        'uid': user.uid,
        'userEmail': user.email ?? 'unknown@app.com',
        'comment': description,       // Firestore rule validates 'comment'
        'module': 'Bug Report Form',  // Firestore rule validates 'module'
        'severity': severity,
        'screenshot': screenshot,
        'appVersion': appVersion,
        'status': 'open',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit bug report: $e');
    }
  }

  // Admin function to fetch all bug reports
  Stream<List<BugReport>> getBugReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BugReport.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user's own bug reports
  Stream<List<BugReport>> getUserBugReports() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('reports')
        .where('uid', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BugReport.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Admin: Update bug status
  Future<void> updateBugStatus(String bugId, String status) async {
    try {
      await _firestore.collection('reports').doc(bugId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update bug status: $e');
    }
  }
}
