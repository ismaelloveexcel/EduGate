# EduGate – Agent Guide

This file gives GitHub Copilot (and any other automated agent) the context
needed to work on this repository confidently.

---

## Repository layout

```
EduGate/
├── apps/
│   └── mobile/              # Flutter app (Dart)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── firebase_options.dart   # placeholder – never commit real keys
│       │   ├── services/
│       │   │   └── notification_service.dart
│       │   ├── features/
│       │   │   ├── auth/
│       │   │   ├── children/
│       │   │   ├── quiz/
│       │   │   ├── rewards/
│       │   │   ├── dashboard/
│       │   │   └── settings/
│       │   └── shared/
│       │       ├── models/
│       │       ├── repositories/
│       │       ├── services/
│       │       └── router/
│       └── test/unit/
├── functions/               # Firebase Cloud Functions (TypeScript scaffold)
├── scripts/                 # Dart seed script for question data
├── docs/                    # PRD, schema, analytics event catalogue
├── firestore.indexes.json
└── .github/
    ├── workflows/
    │   ├── mobile_ci.yml           # PR/push CI for the Flutter app
    │   └── copilot-setup-steps.yml # pre-installs Flutter for Copilot sessions
    ├── ISSUE_TEMPLATE/
    └── pull_request_template.md
```

---

## Tech stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter / Dart (≥ 3.10) |
| State management | Riverpod (`flutter_riverpod ^3.x`) |
| Navigation | GoRouter (`^17.x`) |
| Backend | Firebase (Auth, Firestore, FCM, Crashlytics, Analytics) |
| Charts | `fl_chart` |
| Hashing | `crypto` (SHA-256 + per-child random salt) |

---

## Working directory

All Flutter commands must be run from **`apps/mobile/`**.

```bash
cd apps/mobile
```

---

## Common commands

### Install dependencies
```bash
flutter pub get
```

### Run the app (requires a connected device / emulator)
```bash
flutter run
```

### Run unit tests
```bash
flutter test test/unit/
```

### Static analysis
```bash
flutter analyze --no-fatal-infos
```

### Check formatting (what CI uses)
```bash
dart format --output=none --set-exit-if-changed .
```

### Auto-fix formatting
```bash
dart format .
```

### Deploy Firestore rules & indexes
```bash
firebase deploy --only firestore
```

---

## CI pipeline (`mobile_ci.yml`)

The pipeline runs on every push/PR to `main` or `develop` that touches
`apps/mobile/**`. It:

1. Installs Flutter via `subosito/flutter-action@v2` (Flutter is installed
   at `/opt/hostedtoolcache/flutter`, **not** `/opt/flutter`).
2. Runs `flutter pub get`.
3. Checks formatting with `dart format --output=none --set-exit-if-changed .`
4. Runs `flutter analyze --no-fatal-infos`.
5. Runs `flutter test test/unit/ --coverage`.
6. Uploads coverage to Codecov.

---

## Known pre-existing issues

- **Dart formatting:** Approximately 25 files in `apps/mobile/lib/` have
  pre-existing `dart format` violations that were present before any agent
  sessions began. These are tracked and will be fixed in a dedicated
  formatting PR. Do **not** fix unrelated formatting unless the task
  specifically asks for it, to keep diffs minimal and reviewable.

---

## Key architectural decisions

- **Firestore data model:** All child data lives under the parent document
  (`parents/{parentId}/children/{childId}/...`). There are no cross-collection
  ownership lookups.
- **PIN security:** PINs are never stored in plaintext. Each child has a
  unique random salt (`PinService.generateSalt()`); the PIN is SHA-256
  hashed with that salt before being written to Firestore.
- **Adaptive difficulty:** `QuizEngine` uses the last 20 attempts per subject
  to adjust difficulty. If accuracy > 80% → raise; < 50% → lower.
- **Streak tracking:** A streak increments only when a child meets
  `kDailyMinAttempts` (5) correct answers on consecutive calendar days.
- **Firebase credentials:** `lib/firebase_options.dart` in the repo holds
  **placeholder** values. Real credentials are generated locally with
  `flutterfire configure` and must never be committed.

---

## Adding new features

Follow the existing feature folder pattern:

```
lib/features/<feature>/
├── providers/   # Riverpod notifiers / providers
└── screens/     # Widget screens
```

Shared, cross-feature code goes in `lib/shared/`.

New unit tests belong in `apps/mobile/test/unit/`.

---

## Secrets & environment

Never commit:
- `google-services.json`
- `GoogleService-Info.plist`
- `lib/firebase_options.dart` (with real keys)

Use Firebase Remote Config for runtime-configurable values (quiz intervals,
reward amounts, etc.) so they can be updated without an app release.
