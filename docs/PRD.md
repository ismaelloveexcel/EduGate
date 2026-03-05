# EduGate – Product Requirements Document (PRD)

> **Version:** 0.1 MVP  
> **Last Updated:** 2024  
> **Status:** Draft

---

## 1. Overview

EduGate turns kids' idle screen time into productive micro-learning sessions. A parent creates a master account, then sets up individual child profiles (siblings). Each child gets a PIN-protected profile. The app fires quiz reminders every 15–60 minutes; tapping the notification launches a short 5-question quiz. Progress is gamified with XP, coins, streaks, levels, and an in-app cosmetics shop.

---

## 2. Goals

| Goal | Description |
|------|-------------|
| Micro-learning | 5-question quizzes in under 3 minutes |
| Multi-child | One parent account supports multiple children |
| Gamification | XP, coins, streaks, levels, unlockable cosmetics |
| Parent oversight | Dashboard showing per-child accuracy, streak, weak topics |
| Adaptive difficulty | Per-subject adaptive difficulty based on recent performance |

---

## 3. Non-Goals (MVP)

- Social / multiplayer features
- Subscription billing
- Rich media questions (audio/video)
- Web or desktop app
- Third-party SSO (Google, Apple)

---

## 4. User Stories

### Parent
- As a parent, I can create an account with email and password.
- As a parent, I can add multiple child profiles with name, age, grade, and PIN.
- As a parent, I can view per-child analytics: attempts, accuracy, streak, weak topics.
- As a parent, I can configure quiz interval and subjects per child.
- As a parent, I can set quiet hours to suppress notifications at night.

### Child
- As a child, I can enter my PIN to access my profile.
- As a child, I can see my level, XP, coins, and streak on my home screen.
- As a child, I can start a quiz any time by tapping "Start Quiz".
- As a child, I receive notification reminders to take quizzes.
- As a child, I earn XP and coins for correct answers.
- As a child, I can spend coins to unlock cosmetic items in the shop.

---

## 5. Screens

| Screen | Description |
|--------|-------------|
| Login | Parent email/password sign-in |
| Sign Up | Parent account creation |
| Child Profiles | List of child profiles, add/edit, tap to enter PIN |
| PIN Entry | Child types 4–6 digit PIN to authenticate |
| Child Home | Level, streak, coins, XP progress bar, Start Quiz button |
| Quiz | 5 MCQ/True-False/Fill-in-number questions |
| Results | Score, accuracy %, XP/coins earned |
| Parent Dashboard | Per-child stats + 7-day accuracy chart |
| Cosmetics Shop | Grid of purchasable items with coin costs |
| Settings | Quiz interval, subjects, quiet hours |

---

## 6. Technical Requirements

- Flutter 3.x with Riverpod state management
- GoRouter for navigation
- Firebase Auth (email/password)
- Firestore for all data
- Firebase Analytics + Crashlytics
- FCM push notifications (local scheduling acceptable for MVP)
- No secret keys committed to repository

---

## 7. KPIs (Post-Launch)

- Daily active children (DAC)
- Average quiz attempts per child per day
- 7-day streak retention
- Average accuracy across subjects
- Coins spent in shop (engagement proxy)

---

## 8. Open Questions

- TODO: Should sibling switching require parent password re-entry or just PIN?
- TODO: Offline mode – should quizzes work without connectivity?
- TODO: Should weak topic detection trigger a different question set?
- TODO: Content strategy – how to seed and update the question bank?
