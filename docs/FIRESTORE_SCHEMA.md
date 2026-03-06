# EduGate – Firestore Schema

> **Note:** All timestamps are stored as Unix milliseconds (int). Firestore server timestamps should be used in production — see TODO notes.

---

## Data Model: Parent-Subtree Layout

All child data lives under the parent document — ownership is enforced via the path prefix, with no cross-collection lookups needed:

```
parents/{parentId}
parents/{parentId}/children/{childId}
parents/{parentId}/children/{childId}/progress/main
parents/{parentId}/children/{childId}/attempts/{attemptId}
questions/{questionId}   # read-only to authenticated users
```

---

## Collection: `parents/{parentId}`

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | Parent's email address |
| `displayName` | string | Parent's display name |
| `createdAt` | int (ms) | Account creation timestamp |
| `childIds` | string[] | List of child IDs under this parent |
| `fcmTokens` | string[] | FCM device tokens for push notifications (supports multiple devices) |

**Security:** Readable/writable only by the authenticated parent (`request.auth.uid == parentId`).

---

## Sub-collection: `parents/{parentId}/children/{childId}`

| Field | Type | Description |
|-------|------|-------------|
| `parentId` | string | Parent's UID (denormalised for convenience) |
| `name` | string | Child's display name |
| `age` | int | Child's age |
| `grade` | string | e.g. "Grade 3", "Year 5" |
| `pinHash` | string | SHA-256 hash of 4–6 digit PIN (with per-child salt) |
| `pinSalt` | string | Random hex salt unique to this child |
| `avatarId` | string | Avatar identifier |
| `createdAt` | int (ms) | Profile creation timestamp |
| `subjectsEnabled` | string[] | Active subjects for quiz selection |
| `quizIntervalMinutes` | int | 15, 30, or 60 |
| `quietHoursStart` | int | Hour (0–23) quiet period begins |
| `quietHoursEnd` | int | Hour (0–23) quiet period ends |

---

## Sub-collection: `parents/{parentId}/children/{childId}/progress/main`

| Field | Type | Description |
|-------|------|-------------|
| `xp` | int | Total experience points |
| `level` | int | Current level (1–10) |
| `coins` | int | Current coin balance |
| `streakCount` | int | Current day streak |
| `lastActiveDate` | int? (ms) | Last date child completed minimum attempts |
| `dailyAttemptsToday` | int | Attempts recorded today |
| `difficultyBySubject` | map&lt;string, string&gt; | Per-subject current difficulty: "easy" \| "medium" \| "hard" |

**TODO:** Verify atomicity — progress updates must use Firestore transactions to avoid race conditions when multiple devices are in use.

---

## Sub-collection: `parents/{parentId}/children/{childId}/attempts/{attemptId}`

| Field | Type | Description |
|-------|------|-------------|
| `childId` | string | Child ID |
| `questionId` | string | Reference to `questions/{questionId}` |
| `subject` | string | Question subject |
| `difficulty` | string | "easy" \| "medium" \| "hard" |
| `type` | string | "mcq" \| "trueFalse" \| "fillInNumber" |
| `isCorrect` | bool | Whether the answer was correct |
| `timeTakenMs` | int | Time taken to answer in milliseconds |
| `createdAt` | int (ms) | Attempt timestamp |

**Indexes needed:**
- `childId ASC, createdAt DESC` (for recent attempts query)
- `childId ASC, subject ASC, createdAt DESC` (for per-subject adaptive difficulty)

---

## Collection: `questions/{questionId}`

| Field | Type | Description |
|-------|------|-------------|
| `subject` | string | "math" \| "science" \| "english" \| "history" \| "geography" |
| `difficulty` | string | "easy" \| "medium" \| "hard" |
| `type` | string | "mcq" \| "trueFalse" \| "fillInNumber" |
| `prompt` | string | Question text |
| `options` | string[] | Answer options (empty for fillInNumber) |
| `correctAnswer` | string | The correct answer string |
| `tags` | string[] | Searchable tags (e.g. ["addition", "fractions"]) |

**Note:** Questions are read-only for end users. Seeding is done via admin scripts.

---

## Security Rules Summary

Ownership is determined entirely by the Firestore path — no secondary lookups needed:

```
parents/{parentId}                               → isOwner(parentId) read/write
parents/{parentId}/children/{childId}            → isOwner(parentId) read/write
parents/{parentId}/children/{childId}/progress/* → isOwner(parentId) read/write
parents/{parentId}/children/{childId}/attempts/* → isOwner(parentId) create/read; immutable once written
questions                                        → authenticated read; Admin SDK write only
```

See `functions/firestore.rules` for the full rules file.

