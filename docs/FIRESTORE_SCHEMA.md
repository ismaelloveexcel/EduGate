# Firestore Schema

parents/{parentId}

fields:
- email
- createdAt
- subscriptionStatus

parents/{parentId}/children/{childId}

fields:
- name
- age
- grade
- pinHash
- avatarId
- createdAt

children/{childId}/progress/{doc}

fields:
- xp
- level
- coins
- streakCount
- lastActiveDate

children/{childId}/attempts/{attemptId}

fields:
- questionId
- subject
- difficulty
- isCorrect
- timeTakenMs
- createdAt

questions/{questionId}

fields:
- subject
- difficulty
- type
- prompt
- options[]
- correctAnswer
