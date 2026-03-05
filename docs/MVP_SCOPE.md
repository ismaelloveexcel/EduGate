# EduGate — MVP Scope

## Purpose

This document defines the minimum viable product (MVP) boundary — what must ship for the first public beta, what is explicitly deferred, and the ordered sprint plan.

---

## In-Scope for MVP

### M0 — Repo + CI Baseline
- [ ] Monorepo folder structure (`apps/mobile`, `functions`, `docs`, `.github`)
- [ ] Flutter app builds and passes CI (`flutter analyze` + `flutter test`)
- [ ] GitHub Actions workflow on PRs targeting `apps/mobile/**`
- [ ] Issue / PR templates and labels documented

### M1 — Auth + Family Accounts
- [ ] Parent sign-up / login / logout (Firebase Email + Password)
- [ ] Session persistence (stays logged in on app restart)
- [ ] Create / edit / remove child sub-accounts with 4–6 digit PIN
- [ ] Child switcher screen (select active child profile)
- [ ] Firestore security rules — parent can only access their own family data
- [ ] Per-child settings: subject selection, frequency, difficulty

### M2 — Quiz Engine v1
- [ ] Firestore question data model (subject / difficulty / type / options / answer)
- [ ] ≥ 200 seeded questions across Math, English, and Logic
- [ ] MCQ quiz UI + answer validation (correct / incorrect feedback)
- [ ] Attempt logging: `timeTakenMs`, `isCorrect`, `subject`, `difficulty`, `timestamp`
- [ ] True/False and fill-in-number question types
- [ ] Basic accuracy-based adaptive difficulty (per child × subject)

### M3 — Triggers + Notifications
- [ ] In-app timer trigger (configurable interval, session-based)
- [ ] FCM push notification + deep link to quiz screen
- [ ] Quiet hours (no notifications during configured sleep window)
- [ ] Missed-quiz handling (streak pause + gentle nudge notification)

### M4 — Progress + Rewards
- [ ] XP + coins + daily streak engine
- [ ] Leveling system (XP thresholds → level up) + item unlock logic
- [ ] Boss battle every 10 correct answers (bonus rewards)
- [ ] Cosmetic inventory (avatars / themes) + simple coin shop

### M5 — Parent Dashboard v1
- [ ] Per-child dashboard: attempts, accuracy %, streak, weak topics
- [ ] Last-7-days data view
- [ ] Weekly shareable report summary

### M6 — Beta Hardening
- [ ] Firebase Crashlytics integration + graceful error handling
- [ ] Remote Config for quiz interval + reward values
- [ ] Anti-cheat: rate-limit attempts, `timeTaken` sanity checks
- [ ] Offline question cache + retry queue for attempt syncs
- [ ] Privacy / Terms placeholder screens + parental consent acknowledgement

---

## Out of Scope for MVP

| Item | Reason |
|------|--------|
| Web / desktop app | Mobile-first; web adds complexity |
| Social / friend groups | Scope creep; family unit only |
| Paid subscriptions | Phase 2 monetisation |
| Curriculum alignment | Requires external partnerships |
| Localisation (non-English) | Post-launch |
| Live tutoring | Different product category |
| AI-generated questions | Content quality risk for v1 |

---

## Sprint Plan

| Sprint | Issues | Focus |
|--------|--------|-------|
| Sprint 1 | 1, 2, 5, 6, 7, 10, 12, 13, 20 | Vertical slice — auth + one working quiz loop |
| Sprint 2 | 11, 14, 16, 17, 21, 24, 27, 28 | Real MVP feel — notifications + rewards |
| Sprint 3 | 18, 19, 22, 23, 25, 30 | Retention boosters — boss battles, shop, dashboard |

---

## Definition of Done (per issue)

1. Acceptance criteria all checked off.
2. CI green (analyze + test).
3. Reviewed and approved by at least one other contributor.
4. Relevant Firestore rules updated if data shape changed.
5. Analytics events fired where specified.
