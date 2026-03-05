# Firestore Schema

> **Note:** This file documents the MVP-locked Firestore schema. See `docs/FIRESTORE_SCHEMA.md` for the full field-level reference.

## Data Layout (parent-subtree)

All child data lives under the parent document — ownership is determined by the path prefix:

```
parents/{parentId}
parents/{parentId}/children/{childId}
parents/{parentId}/children/{childId}/progress/main
parents/{parentId}/children/{childId}/attempts/{attemptId}
questions/{questionId}
```

### parents/{parentId}

fields:
- email
- displayName
- createdAt
- fcmTokens (array of device tokens)

### parents/{parentId}/children/{childId}

fields:
- parentId (denormalised)
- name
- age
- grade
- pinHash
- pinSalt
- avatarId
- createdAt
- subjectsEnabled (array)
- quizIntervalMinutes
- quietHoursStart
- quietHoursEnd

### parents/{parentId}/children/{childId}/progress/main

fields:
- xp
- level
- coins
- streakCount
- lastMinMetDate
- lastAttemptDate
- dailyAttemptsToday
- difficultyBySubject (map)

### parents/{parentId}/children/{childId}/attempts/{attemptId}

fields:
- childId
- questionId
- subject
- difficulty
- type
- isCorrect
- timeTakenMs
- createdAt

### questions/{questionId}

fields:
- subject
- difficulty
- type
- prompt
- options[]
- correctAnswer
- tags[]

