#!/usr/bin/env bash
# EduGate — GitHub Project Setup Script
# Run once after cloning to create all labels, milestones, and issues.
#
# Prerequisites:
#   gh auth login   (GitHub CLI authenticated)
#   gh extension install github/gh-projects  (for project board)
#
# Usage:
#   chmod +x .github/setup-project.sh
#   REPO="ismaelloveexcel/EduGate" bash .github/setup-project.sh

set -euo pipefail
REPO="${REPO:-ismaelloveexcel/EduGate}"

echo "==> Creating labels for $REPO"

# ── Type labels ──────────────────────────────────────────────────────────────
gh label create "epic"       --repo "$REPO" --color "7B61FF" --description "Epic / large initiative"         --force
gh label create "feature"    --repo "$REPO" --color "0075CA" --description "New feature"                     --force
gh label create "bug"        --repo "$REPO" --color "D73A4A" --description "Bug report"                      --force
gh label create "docs"       --repo "$REPO" --color "0075CA" --description "Documentation"                   --force
gh label create "tech-debt"  --repo "$REPO" --color "E4E669" --description "Technical debt"                  --force
gh label create "security"   --repo "$REPO" --color "B60205" --description "Security concern"                --force
gh label create "content"    --repo "$REPO" --color "F9D0C4" --description "Content / question data"         --force
gh label create "analytics"  --repo "$REPO" --color "BFD4F2" --description "Analytics / telemetry"          --force
gh label create "ui"         --repo "$REPO" --color "E99695" --description "UI / design"                     --force

# ── Priority labels ───────────────────────────────────────────────────────────
gh label create "P0"         --repo "$REPO" --color "B60205" --description "Critical — blocks launch"        --force
gh label create "P1"         --repo "$REPO" --color "FF8C00" --description "High priority"                   --force
gh label create "P2"         --repo "$REPO" --color "FBCA04" --description "Medium priority"                 --force

# ── Phase labels ──────────────────────────────────────────────────────────────
gh label create "mvp"        --repo "$REPO" --color "0E8A16" --description "MVP scope"                       --force
gh label create "phase-2"    --repo "$REPO" --color "C2E0C6" --description "Phase 2 scope"                   --force

echo "==> Creating milestones"

gh api repos/"$REPO"/milestones --method POST -f title="M0 — Repo & CI Baseline"        -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M1 — Parent Auth + Child Profiles" -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M2 — Quiz Engine v1"             -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M3 — Progress + Rewards"         -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M4 — Notifications"              -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M5 — Parent Dashboard"           -f state=open > /dev/null
gh api repos/"$REPO"/milestones --method POST -f title="M6 — Beta Hardening"             -f state=open > /dev/null

echo "==> Fetching milestone numbers"
M0=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M0")) | .number')
M1=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M1")) | .number')
M2=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M2")) | .number')
M3=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M3")) | .number')
M4=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M4")) | .number')
M5=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M5")) | .number')
M6=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title | startswith("M6")) | .number')

echo "==> Creating 40 issues"

# ── M0 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M0" \
  --label "P0,feature,mvp" \
  --title "Scaffold monorepo folders + Flutter app" \
  --body "## Acceptance Criteria
- [ ] Repo contains \`/apps/mobile\` Flutter project
- [ ] App runs on emulator/device"

gh issue create --repo "$REPO" --milestone "$M0" \
  --label "P0,feature,mvp" \
  --title "Add GitHub Actions Flutter CI (analyze + test)" \
  --body "## Acceptance Criteria
- [ ] PR triggers CI
- [ ] \`flutter analyze\` + \`flutter test\` pass"

gh issue create --repo "$REPO" --milestone "$M0" \
  --label "P1,docs,mvp" \
  --title "Add docs folder + initial documentation pack" \
  --body "## Acceptance Criteria
- [ ] \`/docs\` contains the finalized documentation set"

gh issue create --repo "$REPO" --milestone "$M0" \
  --label "P1,docs" \
  --title "Add issue + PR templates" \
  --body "## Acceptance Criteria
- [ ] Feature and bug issue templates exist
- [ ] PR template exists"

gh issue create --repo "$REPO" --milestone "$M0" \
  --label "P0,feature,mvp" \
  --title "Add baseline dependencies + app config (Riverpod + GoRouter)" \
  --body "## Acceptance Criteria
- [ ] Riverpod + GoRouter installed and minimal routing works"

# ── M1 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,feature,mvp" \
  --title "Firebase project setup (dev)" \
  --body "## Acceptance Criteria
- [ ] Firebase project created
- [ ] Auth + Firestore + Analytics enabled"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,feature,mvp" \
  --title "FlutterFire configure + firebase_options integrated" \
  --body "## Acceptance Criteria
- [ ] App connects to Firebase
- [ ] Builds on Android and iOS (or at least Android initially)"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,feature,mvp" \
  --title "Parent signup/login/logout (Email/Password)" \
  --body "## Acceptance Criteria
- [ ] Parent can sign up, login, logout
- [ ] Session persists on restart"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,feature,mvp" \
  --title "Parent profile document creation in Firestore" \
  --body "## Acceptance Criteria
- [ ] On first login, \`parents/{parentId}\` doc is created"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,feature,mvp" \
  --title "Child profiles CRUD (create/edit/archive)" \
  --body "## Acceptance Criteria
- [ ] Parent can create multiple children
- [ ] Can edit name/age/grade
- [ ] Can archive a child"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,security,mvp" \
  --title "Child PIN setup + secure validation" \
  --body "## Acceptance Criteria
- [ ] PIN stored as hash
- [ ] PIN validation works for profile access"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,ui,mvp" \
  --title "Child selector screen (siblings switch)" \
  --body "## Acceptance Criteria
- [ ] Parent selects a child profile before gameplay"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P0,ui,mvp" \
  --title "Child PIN screen (gates child access)" \
  --body "## Acceptance Criteria
- [ ] After selecting child, PIN required
- [ ] Successful PIN takes user to Child Home"

gh issue create --repo "$REPO" --milestone "$M1" \
  --label "P1,feature,mvp" \
  --title "Child settings per child (interval/subjects/difficulty/quiet hours)" \
  --body "## Acceptance Criteria
- [ ] Settings saved under child doc/subcollection
- [ ] Settings affect quiz selection (later)"

# ── M2 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,feature,mvp" \
  --title "Question model + Firestore questions schema" \
  --body "## Acceptance Criteria
- [ ] Question fields match spec (subject/difficulty/type/prompt/options/correctAnswer/tags/isActive)"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,content,mvp" \
  --title "Seed initial question set (min 200)" \
  --body "## Acceptance Criteria
- [ ] 200+ questions inserted into Firestore
- [ ] At least Math + English + Logic"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,feature,mvp" \
  --title "Question fetch service (filter by settings)" \
  --body "## Acceptance Criteria
- [ ] Fetch respects enabled subjects and difficulty range"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,ui,mvp" \
  --title "Quiz UI: Multiple choice" \
  --body "## Acceptance Criteria
- [ ] Renders question + options
- [ ] Handles answer selection"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P1,ui,mvp" \
  --title "Quiz UI: True/False" \
  --body "## Acceptance Criteria
- [ ] True/False question renders and logs"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P1,ui,mvp" \
  --title "Quiz UI: Fill-in-number" \
  --body "## Acceptance Criteria
- [ ] Numeric input supported with validation"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,feature,mvp" \
  --title "Attempt logging under parent subtree" \
  --body "## Acceptance Criteria
- [ ] Writes to: \`parents/{parentId}/children/{childId}/attempts/{attemptId}\`
- [ ] Includes \`timeTakenMs\`, \`isCorrect\`, \`createdAt\`"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P0,ui,mvp" \
  --title "Result screen feedback (correct/incorrect + rewards)" \
  --body "## Acceptance Criteria
- [ ] Shows correct/incorrect
- [ ] Shows XP/coins earned"

gh issue create --repo "$REPO" --milestone "$M2" \
  --label "P1,feature,mvp" \
  --title "Duplicate prevention: avoid repeating last N questions" \
  --body "## Acceptance Criteria
- [ ] Doesn't serve any of last N questions (default N=10)"

# ── M3 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P0,feature,mvp" \
  --title "Progress document creation + update logic" \
  --body "## Acceptance Criteria
- [ ] \`progress/main\` created per child
- [ ] Updated after each attempt"

gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P0,feature,mvp" \
  --title "XP + coins reward calculation" \
  --body "## Acceptance Criteria
- [ ] Correct grants XP/coins as per spec
- [ ] Incorrect grants minimal/none (configurable)"

gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P0,feature,mvp" \
  --title "Level calculation + level-up event" \
  --body "## Acceptance Criteria
- [ ] Level updates correctly
- [ ] Level-up tracked (analytics)"

gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P0,feature,mvp" \
  --title "Streak system (daily minimum quizzes)" \
  --body "## Acceptance Criteria
- [ ] Streak increments when daily minimum met
- [ ] Breaks after missed day"

gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P1,feature,mvp" \
  --title "Mastery-by-subject tracking" \
  --body "## Acceptance Criteria
- [ ] Updates counters/accuracy per subject in progress doc"

gh issue create --repo "$REPO" --milestone "$M3" \
  --label "P0,ui,mvp" \
  --title "Child Home screen (level/streak/next quiz timer)" \
  --body "## Acceptance Criteria
- [ ] Displays XP, level, coins, streak, upcoming quiz prompt"

# ── M4 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M4" \
  --label "P0,feature,mvp" \
  --title "FCM token registration per device" \
  --body "## Acceptance Criteria
- [ ] Token stored under parent doc (or device table)
- [ ] Token refresh handled"

gh issue create --repo "$REPO" --milestone "$M4" \
  --label "P0,feature,mvp" \
  --title "Notification deep-link routing to Quiz screen" \
  --body "## Acceptance Criteria
- [ ] Tap notification opens quiz for selected child (or asks to select)"

gh issue create --repo "$REPO" --milestone "$M4" \
  --label "P1,feature,mvp" \
  --title "Local scheduling fallback (device-based)" \
  --body "## Acceptance Criteria
- [ ] If server scheduling not ready, app schedules local reminders"

gh issue create --repo "$REPO" --milestone "$M4" \
  --label "P1,feature,mvp" \
  --title "Quiet hours enforcement" \
  --body "## Acceptance Criteria
- [ ] No notifications fired during quiet hours"

gh issue create --repo "$REPO" --milestone "$M4" \
  --label "P2,feature" \
  --title "Missed quiz behavior (gentle reminder + streak pause optional)" \
  --body "## Acceptance Criteria
- [ ] Reminder after missed quiz
- [ ] Configurable streak impact"

# ── M5 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M5" \
  --label "P0,ui,mvp" \
  --title "Parent dashboard: summary metrics per child" \
  --body "## Acceptance Criteria
- [ ] Attempts, accuracy, streak, level shown for last 7 days"

gh issue create --repo "$REPO" --milestone "$M5" \
  --label "P1,feature,mvp" \
  --title "Weak topics list + recommended practice subject" \
  --body "## Acceptance Criteria
- [ ] Shows weakest subject by accuracy"

gh issue create --repo "$REPO" --milestone "$M5" \
  --label "P2,feature" \
  --title "Weekly report generator (shareable text)" \
  --body "## Acceptance Criteria
- [ ] Generates a report summary for sharing"

gh issue create --repo "$REPO" --milestone "$M5" \
  --label "P2,ui" \
  --title "Multi-child comparison view (family leaderboard)" \
  --body "## Acceptance Criteria
- [ ] Compares siblings by XP/streak"

# ── M6 ────────────────────────────────────────────────────────────────────────
gh issue create --repo "$REPO" --milestone "$M6" \
  --label "P0,feature,mvp" \
  --title "Crashlytics + error boundaries" \
  --body "## Acceptance Criteria
- [ ] Crashlytics reports crashes
- [ ] App handles Firestore errors gracefully"

gh issue create --repo "$REPO" --milestone "$M6" \
  --label "P1,feature,mvp" \
  --title "Remote Config for rewards + interval tuning" \
  --body "## Acceptance Criteria
- [ ] Reward values and interval can be adjusted remotely"

echo ""
echo "==> All labels, milestones, and issues created."
echo ""
echo "==> Next: create a GitHub Project Board (Classic or Projects v2)"
echo "    Go to: https://github.com/$REPO/projects"
echo "    Add columns: Backlog | Ready | In Progress | In Review | Done"
echo ""
echo "==> Move these issues to 'Ready' immediately:"
echo "    #1 Scaffold monorepo, #2 Flutter CI, #5 Riverpod+GoRouter"
echo "    #6 Firebase setup, #7 FlutterFire configure"
echo "    #8 Parent signup/login, #9 Parent profile doc"
echo "    #10 Child profiles CRUD, #11 Child PIN, #12 Child selector, #13 Child PIN screen"
