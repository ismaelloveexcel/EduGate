# EduGate 🎓

Flutter + Firebase family learning game: parent master login creates multiple child profiles (siblings) with PIN, triggers micro-quizzes every 15–30 minutes, tracks progress/history, and gamifies learning with XP, streaks, rewards, and parent analytics.

---

## Features

- **Multi-child accounts** – One parent account, multiple child profiles, each with their own 4–6 digit PIN
- **Micro-quizzes** – 5-question sessions (MCQ, True/False, Fill-in-number), triggered by notifications every 15–60 minutes
- **Adaptive difficulty** – Per-subject difficulty adjusts automatically based on rolling 20-attempt accuracy
- **Gamification** – XP, coins, streaks, levels (1–10), and an in-app cosmetics shop
- **Parent Dashboard** – Per-child stats: level, XP, coins, streak, and 7-day accuracy chart
- **Settings** – Quiz interval, enabled subjects, and quiet hours per child

---

## Repository Structure

```
EduGate/
├── apps/
│   └── mobile/              # Flutter app
│       ├── lib/
│       │   ├── main.dart
│       │   ├── firebase_options.dart   # ← Replace with FlutterFire output
│       │   ├── services/
│       │   │   └── notification_service.dart  # FCM + deep-link routing
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
│       └── test/unit/        # Unit tests
├── functions/                # Firebase Cloud Functions (TypeScript scaffold)
│   └── firestore.rules       # Firestore security rules
├── scripts/                  # Seed script for ~200 questions
├── docs/                     # PRD, MVP scope, schema, analytics events
├── firestore.indexes.json    # Firestore composite indexes
└── .github/
    ├── workflows/mobile_ci.yml
    ├── setup-project.sh      # One-shot GitHub labels/milestones/issues setup
    ├── ISSUE_TEMPLATE/
    └── pull_request_template.md
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.19.0
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (`dart pub global activate flutterfire_cli`)
- A Firebase project (see setup below)

---

## Setup Instructions

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → Enter project name (e.g. `edugate-dev`)
3. Enable **Google Analytics** (recommended)
4. Enable **Email/Password** authentication:
   - Authentication → Sign-in method → Email/Password → Enable
5. Create a **Firestore** database (Start in test mode for development)
6. Enable **Firebase Cloud Messaging** (FCM) for push notifications
7. Enable **Crashlytics** (optional but recommended)

### 2. Configure FlutterFire

```bash
cd apps/mobile
flutterfire configure --project=<your-firebase-project-id>
```

This generates `lib/firebase_options.dart` with your real credentials. **Do not commit this file** if it contains secrets (the placeholder version is committed instead).

### 3. Install Dependencies

```bash
cd apps/mobile
flutter pub get
```

### 4. Run the App

```bash
cd apps/mobile
flutter run
```

### 5. Seed Questions (Development)

Run the seed script to generate question JSON for Firestore:

```bash
dart run scripts/seed_questions.dart
```

This prints ~200 questions as JSON. Import them into Firestore via:
- Firebase Console → Firestore → Import
- Or programmatically via the Admin SDK

### 6. Deploy Firestore Rules & Indexes

```bash
firebase deploy --only firestore
```
---

## Running Tests

```bash
cd apps/mobile
flutter test test/unit/
```

### Running Analysis

```bash
cd apps/mobile
flutter analyze
```

---

## Architecture

- **State management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod ^3.x`)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router) (`^17.x`)
- **Database:** Cloud Firestore (parent-subtree data model)
- **Auth:** Firebase Auth (email/password for parents; PIN entry for children)
- **Notifications:** FCM push notifications + `flutter_local_notifications` for foreground banners
- **Charts:** `fl_chart` for 7-day accuracy visualization

### Firestore Data Model

All child data lives under the parent document — no cross-collection ownership lookups needed:

```
parents/{parentId}
parents/{parentId}/children/{childId}
parents/{parentId}/children/{childId}/progress/main
parents/{parentId}/children/{childId}/attempts/{attemptId}
questions/{questionId}   # read-only to authenticated users
```

### Data Flow

```
Firebase Auth → AuthRepository → AuthNotifier (Riverpod)
                                      ↓
ChildrenRepository → ChildProfilesScreen → PinEntryScreen → ChildHomeScreen
                                                                   ↓
QuestionsRepository + ProgressRepository → QuizNotifier → QuizScreen
                                                               ↓
                                                         ResultsScreen
```

---

## Environment & Secrets

> ⚠️ **Never commit real Firebase credentials.**

The `lib/firebase_options.dart` file in this repo contains **placeholder values**. After running `flutterfire configure`, your real `firebase_options.dart` will be generated locally. Add it to `.gitignore` if it contains sensitive keys, or follow [Firebase security best practices](https://firebase.google.com/docs/projects/learn-more#best-practices).

---

## Contributing

See [`.github/pull_request_template.md`](.github/pull_request_template.md) for PR guidelines.  
Use issue templates for [bugs](.github/ISSUE_TEMPLATE/bug_report.md) and [features](.github/ISSUE_TEMPLATE/feature_request.md).

### GitHub Project Setup

Run once to provision all labels, milestones, and 40 issues in the project board:

```bash
REPO="ismaelloveexcel/EduGate" bash .github/setup-project.sh
```

---

## Docs

- [PRD](docs/PRD.md) – Product Requirements Document  
- [MVP Scope](docs/MVP_SCOPE.md) – What's in and out of scope  
- [Firestore Schema](docs/FIRESTORE_SCHEMA.md) – Data model reference  
- [Analytics Events](docs/ANALYTICS_EVENTS.md) – Firebase Analytics event catalogue
