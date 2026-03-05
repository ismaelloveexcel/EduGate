# EduGate — Analytics Events

All events are logged via Firebase Analytics. Property names use `snake_case`. Every event automatically inherits the standard Firebase user properties (`user_id`, `app_version`, `platform`, `os_version`).

---

## Naming Convention

```
<noun>_<verb>
```

Examples: `quiz_started`, `answer_submitted`, `level_up`.

---

## Global Properties (sent with every event)

| Property | Type | Description |
|----------|------|-------------|
| `child_id` | `string` | ID of the active child profile |
| `family_id` | `string` | Parent's family document ID |
| `subject` | `string` | Active subject context |
| `difficulty` | `string` | Active difficulty context |
| `app_session_id` | `string` | UUID generated at app launch |

---

## Auth Events

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `parent_signed_up` | Parent completes sign-up | — |
| `parent_logged_in` | Parent successfully logs in | — |
| `parent_logged_out` | Parent taps logout | — |
| `child_profile_created` | New child sub-account saved | — |
| `child_profile_updated` | Child settings changed | `changed_fields: string[]` |
| `child_switched` | Parent selects a different child | — |

---

## Quiz Events

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `quiz_triggered` | Quiz prompt shown | `trigger_source: "timer" \| "push" \| "manual"` |
| `quiz_started` | Child taps "Start quiz" | `question_count: number` |
| `quiz_dismissed` | Child dismisses quiz without starting | `trigger_source` |
| `answer_submitted` | Child submits an answer | `question_id`, `is_correct`, `time_taken_ms`, `given_answer` |
| `quiz_completed` | All questions in session answered | `correct_count`, `total_count`, `xp_earned`, `coins_earned`, `duration_ms` |
| `boss_battle_started` | Boss battle triggered (every 10 correct) | `boss_level: number` |
| `boss_battle_won` | Child wins boss battle | `bonus_xp`, `bonus_coins` |
| `boss_battle_lost` | Child fails boss battle | — |

---

## Progress & Rewards Events

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `xp_earned` | XP added after attempt | `amount`, `source: "correct_answer" \| "bonus"` |
| `coins_earned` | Coins added | `amount`, `source` |
| `level_up` | Child levels up | `new_level: number`, `old_level: number` |
| `streak_incremented` | Daily streak increases | `new_streak: number` |
| `streak_broken` | Streak resets to 0 | `lost_streak: number` |
| `item_unlocked` | Item unlocked via level or purchase | `item_key`, `item_type`, `method: "level" \| "shop"` |
| `shop_opened` | Child opens cosmetic shop | — |
| `purchase_attempted` | Child attempts to buy item | `item_key`, `coins_cost`, `coins_balance` |
| `purchase_completed` | Coins deducted, item granted | `item_key`, `coins_cost` |
| `purchase_failed` | Insufficient coins | `item_key`, `coins_cost`, `coins_balance` |

---

## Notification Events

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `push_notification_received` | FCM notification arrives | `notification_type: "quiz_trigger" \| "nudge"` |
| `push_notification_tapped` | User taps notification | `notification_type`, `deep_link` |
| `quiet_hours_blocked` | Trigger suppressed by quiet hours | `scheduled_time` |

---

## Parent Dashboard Events

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `dashboard_opened` | Parent opens dashboard | — |
| `weekly_report_viewed` | Parent views weekly report | `child_id` |
| `weekly_report_shared` | Parent shares report | `share_method: "copy" \| "system_share"` |
| `leaderboard_viewed` | Family leaderboard viewed | — |

---

## Error / Crash Events

These are captured automatically by Firebase Crashlytics; the following are manual log events for non-fatal issues:

| Event | When fired | Extra properties |
|-------|-----------|-----------------|
| `sync_retry_queued` | Attempt queued for offline retry | `attempt_id`, `reason` |
| `sync_retry_succeeded` | Queued attempt synced | `attempt_id`, `retry_count` |
| `sync_retry_failed` | Retry exhausted | `attempt_id`, `retry_count` |
| `anti_cheat_flagged` | Attempt flagged by rate-limit or time check | `reason: "rate_limit" \| "time_sanity"` |

---

## Implementation Notes

- Use the `FirebaseAnalytics.instance.logEvent()` wrapper from `firebase_analytics` Flutter package.
- Create a central `AnalyticsService` class in `lib/services/analytics_service.dart` with typed methods for each event to prevent typos and missing properties.
- Do **not** log PII (names, emails) as event properties — use opaque IDs only.
- Remote Config flag `analytics_enabled` can disable all non-essential events without a release.
