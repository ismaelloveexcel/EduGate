# EduGate — Brand & UI Notes

## 1. Brand Identity

| Attribute | Value |
|-----------|-------|
| **Product name** | EduGate |
| **Tagline** | *Learn a little, every day.* |
| **Personality** | Playful, encouraging, trustworthy |
| **Tone of voice** | Friendly but not silly; clear and concise |

---

## 2. Colour Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary | Deep Purple | `#5C35D4` | Buttons, active states, AppBar |
| Primary light | Lavender | `#9B7FE8` | Highlights, chip borders |
| Secondary | Amber | `#FFB300` | Coins, rewards, streak flame |
| Success | Emerald | `#2ECC71` | Correct answer feedback, XP gains |
| Error | Coral | `#E74C3C` | Wrong answer feedback, warnings |
| Background | Off-white | `#F7F8FC` | App background |
| Surface | White | `#FFFFFF` | Cards, bottom sheets |
| On-surface | Charcoal | `#1A1A2E` | Body text |
| Muted | Slate | `#8892A4` | Hint text, secondary labels |

> Use `ColorScheme.fromSeed(seedColor: Color(0xFF5C35D4))` with `useMaterial3: true` as the Flutter theme base. Override individual roles via `copyWith` as needed.

---

## 3. Typography

| Style | Font | Weight | Size | Usage |
|-------|------|--------|------|-------|
| Display | Nunito | 800 ExtraBold | 32 sp | Level-up screen, boss battle |
| Headline | Nunito | 700 Bold | 24 sp | Screen titles |
| Title | Nunito | 600 SemiBold | 18 sp | Card headings, quiz question |
| Body | Nunito | 400 Regular | 16 sp | Body copy, answer options |
| Label | Nunito | 600 SemiBold | 12 sp | Chip labels, stat counters |
| Caption | Nunito | 400 Regular | 11 sp | Timestamps, footnotes |

- Add `google_fonts: ^6.x.x` to `pubspec.yaml` and use `GoogleFonts.nunitoTextTheme()`.
- Minimum tap target: **48 × 48 dp** (Material 3 default).

---

## 4. Iconography

- Use the **Material Symbols** icon set (rounded style).
- Custom icons (EduGate brand mascot, subject icons) will be provided as SVGs in `apps/mobile/assets/icons/`.
- Subject icons: 🧮 Math → `icon_math.svg`, 📖 English → `icon_english.svg`, 🧩 Logic → `icon_logic.svg`.

---

## 5. Spacing & Grid

| Token | Value |
|-------|-------|
| `xs` | 4 dp |
| `sm` | 8 dp |
| `md` | 16 dp |
| `lg` | 24 dp |
| `xl` | 32 dp |
| `xxl` | 48 dp |

- Page horizontal padding: **16 dp** (`md`).
- Card corner radius: **16 dp**.
- Button corner radius: **12 dp**.
- Bottom navigation height: **64 dp**.

---

## 6. Animations & Motion

- Use `flutter_animate` package for micro-interactions (answer feedback, XP pop, level-up burst).
- Correct answer: ✅ green ripple + scale pop (200 ms).
- Wrong answer: ❌ red shake (150 ms).
- XP/coins earned: floating "+XP" label animates upward and fades (400 ms).
- Level-up: full-screen confetti burst (`confetti` package), 1.5 s.
- Page transitions: `FadeTransition` (150 ms) for navigation pushes; keep it snappy.

---

## 7. Child UI vs Parent UI

| Aspect | Child UI | Parent UI |
|--------|----------|-----------|
| **Colours** | Bright, playful (full palette) | Muted, professional (primary + surface) |
| **Font size** | +2 sp relative to base | Base sizes |
| **Illustrations** | Mascot, badges, avatar | Clean charts, data tables |
| **Navigation** | Bottom nav with icons | Standard app bar + drawer |
| **Feedback** | Animated rewards, sounds | Toasts / snack bars |

---

## 8. Accessibility

- Minimum contrast ratio: **4.5 : 1** for normal text, **3 : 1** for large text (WCAG AA).
- All interactive elements have semantic labels for screen readers (`Semantics` widget).
- Support **dynamic text sizes** — avoid fixed-height containers that clip text.
- Support **reduced motion** — check `MediaQuery.disableAnimations` and skip decorative animations accordingly.

---

## 9. Asset Organisation

```
apps/mobile/assets/
├── icons/          # SVG subject + UI icons
├── images/         # PNG illustrations (mascot, backgrounds)
├── animations/     # Lottie JSON files (level-up, boss battle)
└── fonts/          # If self-hosting Nunito (fallback to google_fonts)
```

Declare assets in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
    - assets/animations/
```

---

## 10. Design File

Figma link: *(to be added by design team)*
