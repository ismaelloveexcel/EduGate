# EduGate – MVP Scope

> This document defines what is **in** and **out** of scope for the v1.0 MVP.

---

## ✅ In Scope

### Authentication
- [x] Parent sign-up and sign-in (Firebase Auth email/password)
- [x] Parent sign-out
- [x] Password reset email

### Child Profiles
- [x] Create child (name, age, grade, PIN 4–6 digits, avatar)
- [x] List all children under parent account
- [x] Edit child profile
- [x] Delete child profile
- [x] PIN entry screen (SHA-256 hashed PIN)

### Quiz Engine
- [x] 5-question quiz sessions
- [x] Question types: MCQ, True/False, Fill-in-number
- [x] Subject filter (math, science, english, history, geography)
- [x] Adaptive difficulty per subject (easy → medium → hard based on rolling 20-attempt accuracy)
- [x] Every attempt logged to Firestore
- [x] Progress updated atomically (Firestore transaction)

### Gamification
- [x] +10 XP per correct answer
- [x] +10 coins per correct answer
- [x] Streak tracking (increments when daily minimum of 5 attempts met)
- [x] Level system (10 levels, XP thresholds)
- [x] Cosmetics shop with 5 built-in items

### Notifications
- [x] Local notification scheduling (flutter_local_notifications)
- [x] Quiz interval: 15 / 30 / 60 minutes (per-child setting)
- [x] Quiet hours suppression
- [x] Notification tap → open Quiz screen (TODO: wire navigation)

### Parent Dashboard
- [x] Per-child: level, XP, coins, streak
- [x] Last 7-day accuracy line chart (fl_chart)

### Settings (per child)
- [x] Quiz interval (15/30/60 min)
- [x] Subjects enabled/disabled
- [x] Quiet hours start/end

### Infrastructure
- [x] Flutter CI (GitHub Actions: analyze + test)
- [x] Firestore security rules draft
- [x] Question seed script placeholder (~200 questions)
- [x] Firebase Analytics + Crashlytics enabled in main.dart
- [x] No secrets committed (firebase_options.dart uses placeholder values)

---

## ❌ Out of Scope (MVP)

- Server-side quiz scheduling (FCM triggered from Cloud Functions)
- Subscription / paywall
- Rich media questions
- Offline caching
- Social features (leaderboards, friend comparisons)
- Web / desktop targets
- Third-party SSO
- Per-item cosmetics persistence in Firestore (shop purchases are in-memory in MVP)
- Detailed weak-topic breakdown in dashboard
- Admin console for question bank management

---

## 🚀 Post-MVP Roadmap

1. **v1.1** – Server-side FCM scheduling via Cloud Functions
2. **v1.2** – Offline mode with Firestore offline persistence
3. **v1.3** – Leaderboards and friend challenges
4. **v1.4** – Rich media questions (images)
5. **v2.0** – Subscription tier with advanced analytics and AI question generation
