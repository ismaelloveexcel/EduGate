# EduGate – Analytics Events

> All events are logged via Firebase Analytics (`firebase_analytics`).
> Screen views are tracked automatically via `FirebaseAnalyticsObserver`.

---

## Event Catalogue

### Authentication

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `sign_up` | Parent creates account | `method: "email"` |
| `login` | Parent signs in | `method: "email"` |
| `logout` | Parent signs out | — |

### Child Profile

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `child_created` | Parent adds a child | `child_id`, `age`, `grade` |
| `child_updated` | Parent edits a child | `child_id` |
| `child_deleted` | Parent deletes a child | `child_id` |
| `pin_verified` | Child successfully enters PIN | `child_id` |
| `pin_failed` | Child enters wrong PIN | `child_id`, `attempt_number` |

### Quiz

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `quiz_started` | Child starts a quiz session | `child_id`, `subjects`, `question_count` |
| `question_answered` | Child submits an answer | `child_id`, `question_id`, `subject`, `difficulty`, `type`, `is_correct`, `time_taken_ms` |
| `quiz_completed` | All questions answered | `child_id`, `correct_count`, `total_count`, `accuracy`, `xp_earned`, `coins_earned` |
| `quiz_exited` | Child exits mid-quiz | `child_id`, `questions_answered` |

### Gamification

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `level_up` | Child reaches a new level | `child_id`, `new_level`, `xp` |
| `streak_extended` | Daily minimum met; streak increments | `child_id`, `new_streak` |
| `streak_reset` | Day skipped; streak resets | `child_id`, `lost_streak` |
| `cosmetic_purchased` | Child buys a cosmetic item | `child_id`, `item_id`, `item_name`, `coin_cost` |

### Notifications

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `notification_sent` | Local quiz notification scheduled | `child_id`, `interval_minutes` |
| `notification_tapped` | User taps notification to open quiz | `child_id` |

### Dashboard

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `dashboard_viewed` | Parent opens dashboard | — |
| `child_stats_viewed` | Parent views individual child's stats | `child_id` |

### Settings

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `settings_saved` | Parent saves child settings | `child_id`, `interval_minutes`, `subjects_count`, `quiet_hours_enabled` |

---

## Screen Views (Auto-tracked)

Configure `FirebaseAnalyticsObserver` in the GoRouter or MaterialApp to automatically log screen view events.

| Screen Name | Route |
|-------------|-------|
| `login` | `/login` |
| `signup` | `/signup` |
| `child_profiles` | `/children` |
| `add_child` | `/children/add` |
| `pin_entry` | `/pin/:childId` |
| `child_home` | `/child-home/:childId` |
| `quiz` | `/quiz/:childId` |
| `results` | `/results/:childId` |
| `dashboard` | `/dashboard` |
| `cosmetics_shop` | `/shop/:childId` |
| `settings` | `/settings/:childId` |

---

## Implementation Notes

- TODO: Add `FirebaseAnalytics.instance.logEvent(...)` calls at each trigger point listed above.
- TODO: Set `user_id` on analytics after sign-in: `await analytics.setUserId(id: uid)`.
- TODO: Set custom user properties for child analytics: grade, age group.
- TODO: Wire `FirebaseAnalyticsObserver` to GoRouter for automatic screen tracking.
