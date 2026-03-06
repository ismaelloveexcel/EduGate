# AGENTS.md

## Cursor Cloud specific instructions

### Overview

EduGate is a Flutter + Firebase mobile educational game. Two main components:

- **Flutter app** at `apps/mobile/` — the core product (Dart/Flutter)
- **Firebase Cloud Functions** at `functions/` — TypeScript backend scaffold (Node 18)

### Running checks

Standard commands are documented in `README.md`. Quick reference:

| Task | Command | Working directory |
|------|---------|-------------------|
| Lint/analyze | `flutter analyze --no-fatal-infos` | `apps/mobile` |
| Format check | `dart format --output=none --set-exit-if-changed .` | `apps/mobile` |
| Unit tests | `flutter test test/unit/` | `apps/mobile` |
| Build functions | `npx tsc --skipLibCheck` | `functions` |
| Seed questions | `dart run scripts/seed_questions.dart` | repo root |

### Gotchas

- **Flutter SDK location**: Installed at `/opt/flutter`; ensure `PATH` includes `/opt/flutter/bin`.
- **Node.js version**: Firebase Functions require Node 18. Use `nvm use 18` before working in `functions/`.
- **TypeScript build**: `npm run build` in `functions/` fails due to third-party type definition conflicts in `node_modules`. Use `npx tsc --skipLibCheck` to build successfully. This is a pre-existing issue in the dependency versions, not a code problem.
- **`firebase_options.dart`**: Contains placeholder values. The app cannot run on a device/emulator without a real Firebase project configured via `flutterfire configure`. Unit tests do not require Firebase credentials.
- **Flutter analyze**: The codebase currently has 0 errors. There are pre-existing warnings and info-level issues (deprecated APIs, unnecessary imports) that do not affect unit tests. Use `--no-fatal-infos` to avoid failing on info-level issues.
- **Dart format**: ~23 source files do not pass `dart format --set-exit-if-changed`. This is a pre-existing formatting state.
- **No Android emulator/device in cloud VM**: The Flutter app targets mobile platforms (Android/iOS). It cannot be run in headless cloud VMs without an emulator. Testing is limited to `flutter analyze` and `flutter test`.
