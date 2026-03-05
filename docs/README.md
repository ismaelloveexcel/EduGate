# EduGate Documentation

## FlutterFire Setup

To connect the Flutter app to Firebase:

1. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com).

3. **Configure FlutterFire** from the `apps/mobile` directory:
   ```bash
   cd apps/mobile
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` (already in `.gitignore`) and registers your app with Firebase for each platform (Android / iOS / Web).

4. **Add FlutterFire packages** to `apps/mobile/pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^2.x.x
     firebase_auth: ^4.x.x
     cloud_firestore: ^4.x.x
     firebase_messaging: ^14.x.x
     firebase_crashlytics: ^3.x.x
     firebase_remote_config: ^4.x.x
   ```
   Then run `flutter pub get`.

5. **Initialise Firebase** in `lib/main.dart`:
   ```dart
   import 'firebase_options.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const EduGateApp());
   }
   ```

6. **Environment notes**
   - Never commit `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` (all covered by `.gitignore`).
   - Use **Firebase Remote Config** to manage runtime values (quiz intervals, reward amounts, etc.) without app releases.
   - Use **Firebase App Check** to protect backend resources in production.

## Firestore Security Rules

See `functions/firestore.rules` for the security rules that enforce family data isolation (a parent can only access their own family documents and child sub-collections).

## Architecture Overview

```
EduGate
├── apps/
│   └── mobile/          # Flutter app (Dart)
├── functions/           # Firebase Cloud Functions (Node.js/TypeScript)
├── docs/                # Project documentation
└── .github/
    ├── workflows/        # CI/CD pipelines
    └── ISSUE_TEMPLATE/   # GitHub issue templates
```
