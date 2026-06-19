# Quickstart: Infinite Runner Game

**Date**: 2026-06-19
**Branch**: `001-infinite-runner-game`

---

## Prerequisites

- Flutter SDK 3.x installed and on PATH (`flutter --version`)
- A connected device or emulator (or a browser for web)
- Sprite assets downloaded from kenney.nl (see Asset Setup below)

---

## 1. Create the Flutter Project

```bash
flutter create --org com.example infinite_runner
cd infinite_runner
```

## 2. Add Dependencies

In `pubspec.yaml`, under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0
  shared_preferences: ^2.3.0
```

Under `flutter:` → `assets:`:

```yaml
flutter:
  assets:
    - assets/images/
```

Then run:

```bash
flutter pub get
```

## 3. Asset Setup

1. Download from kenney.nl:
   - **Simplified Platformer Pack** — character sprite sheet (run + jump frames)
   - **Platformer Art Extended** or **Generic Items** — obstacle sprites (bug, broken line, server)
   - Any tileable background suitable for a tech/city theme (2–3 layers for parallax)

2. Place all PNGs under `assets/images/`:

```
assets/images/
├── player_run.png       # sprite sheet: run animation frames
├── player_jump.png      # sprite sheet (or single frame)
├── obstacle_bug.png
├── obstacle_broken.png
├── obstacle_server.png
├── bg_layer1.png        # furthest background (slowest scroll)
├── bg_layer2.png
└── bg_layer3.png        # nearest background (fastest scroll)
```

## 4. Project Structure

```
lib/
├── main.dart                    # Flutter entry point, MaterialApp wrapper
├── game/
│   ├── runner_game.dart         # FlameGame subclass (HasCollisionDetection)
│   ├── player.dart              # PlayerCharacter component
│   ├── obstacle.dart            # Obstacle component
│   ├── obstacle_spawner.dart    # Spawner component + timer
│   ├── difficulty_manager.dart  # Speed/interval scaling
│   ├── score_display.dart       # HUD component (TextComponent)
│   └── parallax_background.dart # ParallaxComponent setup
└── screens/
    ├── main_menu.dart           # Start screen widget
    └── game_over.dart           # Game Over screen widget
```

## 5. Run the Game

```bash
# On connected device / emulator
flutter run

# As web app (for presentation demo)
flutter run -d chrome
```

## 6. Key Flame Concepts Used

| Concept | Where Used | Presentation Talking Point |
|---------|-----------|---------------------------|
| `FlameGame` | `runner_game.dart` | Root of the component tree |
| `ParallaxComponent` | `parallax_background.dart` | Infinite background effect |
| `SpriteAnimationComponent` | `player.dart` | Frame-based character animation |
| `RectangleHitbox` + `CollisionCallbacks` | `player.dart`, `obstacle.dart` | Collision detection |
| `Timer` (Flame) | `obstacle_spawner.dart` | Procedural obstacle spawning |
| `TextComponent` | `score_display.dart` | Live score HUD |
| `shared_preferences` | `runner_game.dart` (on game over) | High score persistence |

## 7. Presentation Demo Checklist

- [ ] Assets placed under `assets/images/` and declared in `pubspec.yaml`
- [ ] `flutter pub get` succeeded
- [ ] App launches to main menu
- [ ] Tap starts the run and parallax background scrolls
- [ ] Single tap makes character jump
- [ ] Double tap in mid-air triggers double jump
- [ ] Collision with an obstacle shows Game Over screen with score
- [ ] High score persists after restart
- [ ] Speed visibly increases after ~30 seconds
