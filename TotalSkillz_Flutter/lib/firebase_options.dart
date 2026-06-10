// Firebase configuration for TotalSkillz Flutter app
// Ported from public/js/firebase-config.js

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.linux:
        return linux;
      default:
        return linux;
    }
  }

  static const FirebaseOptions _sharedConfig = FirebaseOptions(
    apiKey: 'AIzaSyC2FW6zzT4zZJj__KY1OozMk0bIRqS8wN4',
    authDomain: 'totalskillz-7193a.firebaseapp.com',
    projectId: 'totalskillz-7193a',
    storageBucket: 'totalskillz-7193a.firebasestorage.app',
    messagingSenderId: '991145221732',
    appId: '1:991145221732:web:2d684b3b66afba56570971',
  );

  static const FirebaseOptions linux = _sharedConfig;
  static const FirebaseOptions android = _sharedConfig;
}
