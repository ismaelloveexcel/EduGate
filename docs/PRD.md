# EduGate — Product Requirements Document (PRD)

## 1. Overview

**Product name:** EduGate  
**Type:** Mobile app (Flutter + Firebase)  
**Target platforms:** iOS, Android  
**Audience:** Families with school-age children (ages 5–14)

EduGate is a family learning game that lets a parent create one master account and add multiple child profiles (siblings). The app sends micro-quiz prompts every 15–30 minutes, rewards correct answers with XP, coins, and streaks, and gives parents a clear analytics dashboard to track progress.

---

## 2. Problem Statement

Children are constantly on their devices but rarely learning anything. Parents want a lightweight, low-friction way to squeeze educational moments into the day without having to supervise every session. Existing apps are either too rigid (fixed lesson plans) or too loose (no accountability). EduGate bridges the gap with quick micro-quizzes, gamified rewards, and parent-controlled settings.

---

## 3. Goals & Success Metrics

| Goal | Metric | Target (90-day post-launch) |
|------|--------|-----------------------------|
| Daily engagement | DAU / MAU ratio | ≥ 30 % |
| Learning outcomes | Average quiz accuracy | ≥ 65 % |
| Retention | Day-7 retention | ≥ 40 % |
| Parent trust | Parent dashboard weekly opens | ≥ 2× per week |
| Monetisation (phase 2) | In-app purchase conversion | ≥ 5 % |

---

## 4. User Personas

### Parent (primary account holder)
- Age: 28–45
- Goal: monitor children's learning, set subjects and difficulty, view reports
- Pain points: no time to sit with child; doesn't trust passive screen time

### Child
- Age: 5–14
- Goal: earn rewards, beat streaks, unlock cool avatars
- Pain points: quizzes feel like school; wants instant gratification

---

## 5. Core Features (by milestone)

| Milestone | Feature |
|-----------|---------|
| M0 | Monorepo scaffold, Flutter CI baseline |
| M1 | Parent auth, child sub-accounts with PIN, child switcher, Firestore security rules |
| M2 | Question data model, quiz UI (MCQ, T/F, fill-in), attempt logging, adaptive difficulty |
| M3 | In-app timer trigger, FCM push notifications, quiet hours, missed-quiz handling |
| M4 | XP + coins + streaks, leveling, boss battles, cosmetic shop |
| M5 | Parent dashboard (accuracy, streak, weak topics, 7-day chart), weekly export |
| M6 | Crashlytics, Remote Config, anti-cheat, offline cache, privacy/consent |

---

## 6. Non-Goals (v1)

- Web or desktop app
- Live tutoring / human teachers
- Social features outside the family unit
- Paid content / subscriptions (phase 2)
- Curriculum alignment / school integration (phase 2)

---

## 7. Constraints & Assumptions

- Firebase is the sole backend (Firestore, Auth, FCM, Crashlytics, Remote Config).
- All question content is hand-curated by the EduGate team for v1.
- The app must work offline; attempts are queued and synced when connectivity returns.
- COPPA / GDPR-K compliance is required before public launch (parental consent flow in M6).

---

## 8. Open Questions

- [ ] Minimum viable question count per subject for launch?
- [ ] Should difficulty adapt per-subject or globally per child?
- [ ] Pricing model for phase 2 (subscription vs. one-time unlock)?
- [ ] Localisation requirements for non-English markets?
