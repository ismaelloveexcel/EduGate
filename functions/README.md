# Firebase Cloud Functions

This directory will contain Firebase Cloud Functions (Node.js / TypeScript) for EduGate backend logic such as:

- Push notification triggers (FCM)
- Scheduled tasks (weekly reports, quiet-hours enforcement)
- Firestore security rule helpers
- Server-side anti-cheat checks

## Setup

1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Log in and select your project:
   ```bash
   firebase login
   firebase use <your-project-id>
   ```

3. Install dependencies (once `package.json` exists here):
   ```bash
   cd functions
   npm install
   ```

4. Deploy functions:
   ```bash
   firebase deploy --only functions
   ```

## Firestore Security Rules

[`firestore.rules`](firestore.rules) enforces that each parent can only read/write their own family's Firestore documents. Unauthorised access is blocked at the database level.

To deploy the rules:

```bash
firebase deploy --only firestore:rules
```

### Data structure enforced by these rules

```
parents/{parentId}
parents/{parentId}/children/{childId}
parents/{parentId}/children/{childId}/progress/main
parents/{parentId}/children/{childId}/attempts/{attemptId}

questions/{questionId}   # read-only to authenticated users; written via Admin SDK only
```
