# EduGate – Firestore Schema

> **Note:** All timestamps are stored as Unix milliseconds (int). Firestore server timestamps should be used in production — see TODO notes.

---

## Collection: `parents/{parentId}`

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | Parent's email address |
| `displayName` | string | Parent's display name |
| `createdAt` | int (ms) | Account creation timestamp |
| `childIds` | string[] | List of child IDs under this parent |
| `fcmToken` | string? | FCM device token for push notifications |

**Security:** Readable/writable only by the authenticated parent (`request.auth.uid == parentId`).

---

## Sub-collection: `parents/{parentId}/children/{childId}`

| Field | Type | Description |
|-------|------|-------------|
| `parentId` | string | Parent's UID (denormalised for security rules) |
| `name` | string | Child's display name |
| `age` | int | Child's age |
| `grade` | string | e.g. "Grade 3", "Year 5" |
| `pinHash` | string | SHA-256 hash of 4–6 digit PIN |
| `avatarId` | string | Avatar identifier |
| `createdAt` | int (ms) | Profile creation timestamp |
| `subjectsEnabled` | string[] | Active subjects for quiz selection |
| `quizIntervalMinutes` | int | 15, 30, or 60 |
| `quietHoursStart` | int | Hour (0–23) quiet period begins |
| `quietHoursEnd` | int | Hour (0–23) quiet period ends |

---

## Collection: `childParentMap/{childId}`

| Field | Type | Description |
|-------|------|-------------|
| `parentId` | string | Parent UID who owns this child |

Used by security rules to verify parent ownership when accessing child sub-collections.

---

## Sub-collection: `children/{childId}/progress/current`

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

## Sub-collection: `children/{childId}/attempts/{attemptId}`

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

```
// See firestore.rules for full rules draft
parents/{parentId}           → parent read/write own doc only
parents/{parentId}/children  → parent read/write own children
children/{childId}/progress  → parent who owns childId (via childParentMap lookup)
children/{childId}/attempts  → parent who owns childId (via childParentMap lookup)
questions                    → authenticated read, no write
childParentMap               → server-only write, authenticated read
```

**TODO:** Implement Firestore rules function `isParentOfChild(childId)` that queries `childParentMap/{childId}.parentId == request.auth.uid`.
