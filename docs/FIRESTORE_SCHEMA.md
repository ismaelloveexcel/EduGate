# EduGate — Firestore Schema

All top-level collections are listed below. Field names use `camelCase`. Timestamps are Firestore `Timestamp` objects. Booleans default to `false` unless noted.

---

## `/families/{familyId}`

Represents one parent account and its associated children.

| Field | Type | Description |
|-------|------|-------------|
| `parentUid` | `string` | Firebase Auth UID of the parent |
| `email` | `string` | Parent's email address |
| `displayName` | `string` | Parent's display name |
| `createdAt` | `Timestamp` | Account creation time |
| `updatedAt` | `Timestamp` | Last profile update |

---

## `/families/{familyId}/children/{childId}`

One document per child sub-account.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Child's display name |
| `pin` | `string` | Hashed 4–6 digit PIN |
| `avatarId` | `string` | Selected avatar asset key |
| `themeId` | `string` | Selected theme key |
| `xp` | `number` | Total XP earned |
| `coins` | `number` | Spendable coin balance |
| `level` | `number` | Current level (derived from XP) |
| `streak` | `number` | Current daily correct-answer streak |
| `lastActiveDate` | `string` | ISO date string (`YYYY-MM-DD`) of last quiz activity |
| `subjects` | `string[]` | Enabled subjects (e.g. `["math","english","logic"]`) |
| `difficulty` | `map<string, string>` | Per-subject difficulty: `{ math: "medium", english: "easy" }` |
| `quizIntervalMinutes` | `number` | Minutes between quiz triggers (default `20`) |
| `quietHoursStart` | `string` | HH:mm — start of no-notification window |
| `quietHoursEnd` | `string` | HH:mm — end of no-notification window |
| `fcmToken` | `string` | Latest FCM device token for this child session |
| `createdAt` | `Timestamp` | Sub-account creation time |
| `updatedAt` | `Timestamp` | Last settings update |

---

## `/questions/{questionId}`

Global read-only question bank (written by admin / seed scripts only).

| Field | Type | Description |
|-------|------|-------------|
| `subject` | `string` | `"math"` \| `"english"` \| `"logic"` |
| `difficulty` | `string` | `"easy"` \| `"medium"` \| `"hard"` |
| `type` | `string` | `"mcq"` \| `"truefalse"` \| `"fillin"` |
| `questionText` | `string` | The question displayed to the child |
| `options` | `string[]` | Answer choices (MCQ: 4 items; T/F: `["True","False"]`; fill-in: empty) |
| `correctAnswer` | `string` | Correct option text or numeric string |
| `explanation` | `string` | Brief explanation shown after answer |
| `tags` | `string[]` | Optional topic tags (e.g. `["addition","carry"]`) |
| `createdAt` | `Timestamp` | When the question was added |

---

## `/families/{familyId}/children/{childId}/attempts/{attemptId}`

One document per quiz attempt by a child.

| Field | Type | Description |
|-------|------|-------------|
| `questionId` | `string` | Reference to `/questions/{questionId}` |
| `subject` | `string` | Denormalised from question |
| `difficulty` | `string` | Denormalised from question |
| `type` | `string` | Denormalised from question |
| `givenAnswer` | `string` | Answer the child submitted |
| `isCorrect` | `boolean` | Whether `givenAnswer` matches `correctAnswer` |
| `timeTakenMs` | `number` | Milliseconds from question display to answer |
| `triggeredBy` | `string` | `"timer"` \| `"push"` \| `"manual"` |
| `timestamp` | `Timestamp` | Server-side time of the attempt |
| `xpEarned` | `number` | XP granted for this attempt |
| `coinsEarned` | `number` | Coins granted for this attempt |

---

## `/families/{familyId}/children/{childId}/inventory/{itemId}`

Cosmetic items owned by the child.

| Field | Type | Description |
|-------|------|-------------|
| `itemType` | `string` | `"avatar"` \| `"theme"` |
| `itemKey` | `string` | Asset key matching client-side catalogue |
| `unlockedAt` | `Timestamp` | When the item was unlocked |
| `coinsCost` | `number` | Cost paid (0 if level-unlock) |

---

## Firestore Security Rules (summary)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Questions — any authenticated user may read; only admin writes
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if false; // admin SDK only
    }

    // Family data — parent owns everything under their familyId
    match /families/{familyId} {
      allow read, write: if request.auth != null
        && request.auth.uid == resource.data.parentUid;

      match /{document=**} {
        allow read, write: if request.auth != null
          && get(/databases/$(database)/documents/families/$(familyId)).data.parentUid
             == request.auth.uid;
      }
    }
  }
}
```

> Full rules file lives at `functions/firestore.rules` (to be added in M1).

---

## Indexes (planned)

| Collection | Fields | Query use-case |
|------------|--------|----------------|
| `questions` | `subject ASC`, `difficulty ASC`, `__name__ ASC` | Quiz question selection |
| `attempts` | `subject ASC`, `timestamp DESC` | Per-subject accuracy charts |
| `attempts` | `timestamp DESC` | Recent attempts feed |
