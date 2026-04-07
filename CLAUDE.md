# ScorePad — Claude Context

## What this app is
ScorePad is a free, no-ads, no-login Flutter Android app for tracking scores in any board/card game. The UI/UX reference is `scorepad-poc.html` at the project root — always read it before making UI changes.

## Stack
- **Flutter** 3.41.6 (stable), **Dart** 3.11.4
- **State management**: `provider` (single `GameProvider` ChangeNotifier)
- **Persistence**: `sqflite` (3 tables: `players`, `scores`, `meta`)
- **Fonts**: Syne (UI) + JetBrains Mono (scores) via `google_fonts`
- **External link**: `url_launcher` for Buy Me a Coffee

## Project structure
```
lib/
  main.dart                    # Entry point
  app.dart                     # ScorePadApp + _Root (handles resume from persisted game)
  constants/player_colors.dart # 8-color palette
  theme/app_theme.dart         # AppColors + AppTheme.dark
  models/
    player.dart                # Player { id, name, color, position }
    game_state.dart            # GameState { players, rounds[][], currentRound, liveRound }
  services/database_service.dart
  providers/game_provider.dart
  screens/
    setup_screen.dart
    game_screen.dart
  widgets/
    player_setup_row.dart      # Draggable row in ReorderableListView
    player_score_card.dart     # Game card with +/- buttons
    score_bottom_sheet.dart    # showScoreBottomSheet() helper
    reset_bottom_sheet.dart    # showResetBottomSheet() helper
    coffee_button.dart         # buymeacoffee.com/kassoum
```

## Database schema
- `players` — id, name, color_hex (int ARGB), position
- `scores` — player_id, round_index, score (row absence = null/unscored)
- `meta` — key/value: `live_round`, `current_round`

## Key design rules
- **One active game at a time.** No multi-game history.
- **Scores are additive within a round.** Pressing +5 then +3 gives 8 for that round.
- **Next round button** is disabled until every player has at least one score entry for the current round.
- **Past rounds are read-only.** Navigation arrows let you browse; back-to-live button returns.
- **Leader** = player with the highest cumulative total (accent border + top bar on card). No leader shown when all totals are 0.
- **Max 8 players, min 2.** Remove button hidden when exactly 2 players.
- App resumes last game on cold start (loaded from sqflite in `GameProvider.init()`).

## Theme colors (AppColors)
| Name | Hex |
|---|---|
| bg | #0F0F0F |
| surface | #1A1A1A |
| surface2 | #222222 |
| border | #2A2A2A |
| accent | #E8FF47 |
| accentDim | #B8CC30 |
| textPrimary | #F0F0F0 |
| textMuted | #666666 |
| danger | #FF4747 |
| coffee | #F5A623 |

## App icon
Source file: `assets/icon/icon.png`. Configured via `flutter_launcher_icons` in `pubspec.yaml`. The Dockerfile runs `dart run flutter_launcher_icons` automatically before the build — no manual step needed.

## App ID & signing
- Application ID: `com.kassoum.scorepad`
- Keystore: `~/keys/scorepad-upload-key.jks` (never commit, never lose)
- Signing config: `android/key.properties` (gitignored) — fill in passwords before building
- Alias: `scorepad`

## Building the APK
No Android SDK locally. Build via Docker:
```bash
# Build (first run ~7 min, cached runs faster)
docker build --platform linux/amd64 -f Dockerfile.apk -t scorepad-builder .

# Extract APK to Desktop
docker run --rm --platform linux/amd64 -v ~/Desktop:/output scorepad-builder \
  cp build/app/outputs/flutter-apk/app-release.apk /output/ScorePad.apk
```
- Must use `--platform linux/amd64` — ARM image lacks Android AAPT2 and gen_snapshot.
- Output: `build/app/outputs/flutter-apk/app-release.apk`

## Building the signed AAB (Play Store)
```bash
# Build
docker build --platform linux/amd64 -f Dockerfile.aab -t scorepad-aab-builder \
  --build-arg DUMMY=1 .
# The keystore is mounted at runtime, not baked into the image

docker run --rm --platform linux/amd64 \
  -v ~/keys:/keys \
  -v ~/Desktop:/output \
  scorepad-aab-builder \
  sh -c "cp build/app/outputs/bundle/release/app-release.aab /output/ScorePad.aab"
```
Output: `~/Desktop/ScorePad.aab` — upload this to Play Console.

## Lint / analysis
```bash
flutter analyze lib/   # must stay at 0 issues before building
```
- Use single underscore `_` not double `__` for unused params (Dart lint rule)
- No unary `+` in Dart — use plain integer literals (`1` not `+1`)
