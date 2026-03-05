/**
 * EduGate Firebase Cloud Functions
 *
 * MVP Note: Most quiz scheduling is done via local notifications in the Flutter app.
 * These Cloud Functions are scaffolded for future server-side features.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// ─── Scheduled Quiz Notifications ───────────────────────────────────────────
// TODO: Implement server-side FCM scheduling for quiz reminders.
// For MVP, local notifications in the Flutter app handle scheduling.
// In v1.1+, migrate to this Cloud Function approach for better reliability:
//
// export const scheduleQuizNotifications = functions.pubsub
//   .schedule("every 1 hours")
//   .onRun(async (_context) => {
//     // TODO: Query all children with active intervals
//     // TODO: Check quiet hours per child
//     // TODO: Send FCM messages to parent devices
//   });

// ─── New Child Created ───────────────────────────────────────────────────────
/**
 * When a child is created under parents/{parentId}/children/{childId},
 * initialise their progress document in children/{childId}/progress/current.
 */
export const onChildCreated = functions.firestore
  .document("parents/{parentId}/children/{childId}")
  .onCreate(async (snap, context) => {
    const { childId } = context.params;

    const progressRef = db
      .collection("children")
      .doc(childId)
      .collection("progress")
      .doc("current");

    await progressRef.set({
      xp: 0,
      level: 1,
      coins: 0,
      streakCount: 0,
      lastActiveDate: null,
      dailyAttemptsToday: 0,
      difficultyBySubject: {},
    });

    functions.logger.info(`Initialised progress for child ${childId}`);
  });

// ─── Weekly Analytics Aggregation ───────────────────────────────────────────
// TODO: Implement weekly rollup of per-child accuracy by subject.
// This will power the parent dashboard's weak-topic detection.
//
// export const weeklyAnalyticsRollup = functions.pubsub
//   .schedule("every monday 00:00")
//   .timeZone("UTC")
//   .onRun(async (_context) => {
//     // TODO: Aggregate attempts from last 7 days per child per subject
//     // TODO: Write summary to children/{childId}/analytics/weekly
//   });

// ─── Seed Questions (Admin only) ─────────────────────────────────────────────
// TODO: Create an HTTPS callable function (admin-authenticated) to seed
// the questions collection. For MVP, use the Dart seed script in scripts/.
