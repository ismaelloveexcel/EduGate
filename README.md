# EduGate

Flutter + Firebase family learning game: parent master login creates multiple child profiles (siblings) with PIN, triggers micro-quizzes every 15–30 minutes, tracks progress/history, and gamifies learning with XP, streaks, rewards, and parent analytics.

## Repository Structure

```
EduGate/
├── apps/
│   └── mobile/          # Flutter app
├── functions/           # Firebase Cloud Functions
├── docs/                # Project documentation
└── .github/
    ├── workflows/        # CI/CD pipelines
    └── ISSUE_TEMPLATE/   # GitHub issue templates
```

## Getting Started

### Mobile (Flutter)

```bash
cd apps/mobile
flutter pub get
flutter run
```

### Documentation

See [`docs/README.md`](docs/README.md) for FlutterFire setup and architecture notes.

### Cloud Functions

See [`functions/README.md`](functions/README.md) for Firebase Functions setup.

## Contributing

### Workflow

1. Pick an issue from the **Backlog** column in the GitHub Project.
2. Create a branch from `main` using the pattern `feature/<issue-number>-short-description`.
3. Open a PR using the [PR template](.github/pull_request_template.md) and link the issue (`Closes #<number>`).
4. CI will run `flutter analyze` + `flutter test` automatically on any change under `apps/mobile/`.
5. Request a review; merge once approved and CI is green.

### Issue Templates

- **Feature**: use [`.github/ISSUE_TEMPLATE/feature.md`](.github/ISSUE_TEMPLATE/feature.md)
- **Bug**: use [`.github/ISSUE_TEMPLATE/bug.md`](.github/ISSUE_TEMPLATE/bug.md)

### Labels

| Label | Description |
|-------|-------------|
| `epic` | Epic / planning container |
| `mvp` | Required for MVP |
| `phase-2` | Post-MVP scope |
| `blocked` | Blocked on something |
| `needs-review` | Awaiting review |
| `feature` | New feature work |
| `bug` | Bug fix |
| `tech-debt` | Refactor / clean-up |
| `docs` | Documentation |
| `security` | Security-related |
| `analytics` | Analytics / telemetry |
| `content` | Content (questions, copy) |
| `design` | Design / UI |
| `P0` | Critical priority |
| `P1` | High priority |
| `P2` | Medium priority |

### Milestones

| Milestone | Scope |
|-----------|-------|
| M0 | Repo + CI Baseline |
| M1 | Auth + Family Accounts |
| M2 | Quiz Engine v1 |
| M3 | Triggers + Notifications |
| M4 | Progress + Rewards |
| M5 | Parent Dashboard v1 |
| M6 | Beta Hardening |
