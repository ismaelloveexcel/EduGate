// lib/firebase_options.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// ⚠️  PLACEHOLDER FILE — DO NOT USE IN PRODUCTION
// ─────────────────────────────────────────────────────────────────────────────
//
// This file contains stub values.  The app will throw an assertion error at
// startup if these placeholders have not been replaced.
//
// HOW TO FIX:
//   1. Create a Firebase project at https://console.firebase.google.com/
//   2. Install the FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//   3. From apps/mobile/ run:
//        flutterfire configure --project=<your-firebase-project-id>
//   4. That command overwrites this file with your real credentials.
//
// See README.md → "Setup Instructions" for the full walkthrough.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

const _kPlaceholderPattern = 'YOUR_';

/// Returns true when [value] is still a placeholder stub.
bool _isPlaceholder(String value) => value.startsWith(_kPlaceholderPattern);

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Run: flutterfire configure --project=<your-project-id>',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _assertConfigured(android);
        return android;
      case TargetPlatform.iOS:
        _assertConfigured(ios);
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Throws a descriptive [StateError] when placeholder values are detected,
  /// so the developer gets a clear message instead of a cryptic Firebase error.
  static void _assertConfigured(FirebaseOptions options) {
    if (_isPlaceholder(options.apiKey)) {
      throw StateError(
        '\n'
        '╔══════════════════════════════════════════════════════════════╗\n'
        '║  EduGate: Firebase is not configured yet.                    ║\n'
        '║                                                              ║\n'
        '║  Run the following command from apps/mobile/:                ║\n'
        '║    flutterfire configure --project=<your-firebase-project>   ║\n'
        '║                                                              ║\n'
        '║  See README.md for full setup instructions.                  ║\n'
        '╚══════════════════════════════════════════════════════════════╝\n',
      );
    }
  }

  // ─── Placeholder values — replaced by `flutterfire configure` ─────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.edugate.app',
  );
}
