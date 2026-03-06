# EduGate Assets

This directory contains app assets:

- `avatar_*.png` – Child avatar images
- `badge_*.png` – Achievement badge images  
- `theme_*.png` – Cosmetic theme preview images

## Adding Assets

1. Add PNG/JPG files to this directory
2. They are already declared in `pubspec.yaml` under `assets/images/`
3. Run `flutter pub get` to register new assets

## Cosmetics Shop

The cosmetics shop references these asset paths (see `lib/shared/models/cosmetic_item_model.dart`):
- `assets/images/avatar_rocket.png`
- `assets/images/avatar_owl.png`
- `assets/images/badge_star.png`
- `assets/images/badge_lightning.png`
- `assets/images/theme_ocean.png`

For the MVP, placeholder icons are used in the UI. Replace with actual art assets before release.
