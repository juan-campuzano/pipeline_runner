# Research: Infinite Runner Game with Flutter Flame

**Date**: 2026-06-19
**Branch**: `001-infinite-runner-game`

---

## Decision 1: Flutter Flame Version

- **Decision**: Flame 1.x (latest stable, ~1.18+)
- **Rationale**: Flame 1.x introduced the component system (`FlameGame`, `Component`, `HasCollisionDetection`) which aligns perfectly with the spec's requirement for CollisionCallbacks and ParallaxComponent. It is the current recommended version for new projects.
- **Alternatives considered**: Flame 0.x — legacy API, not maintained; raw Flutter CustomPainter — too low-level for a game, no built-in collision or parallax.

---

## Decision 2: Game Loop Architecture

- **Decision**: `FlameGame` with a component tree. The game class extends `FlameGame` and mixes in `HasCollisionDetection`. All game objects (player, obstacles, background) are `Component` subclasses added to the game component tree.
- **Rationale**: Flame's component lifecycle (`onLoad`, `update`, `render`, `onRemove`) maps cleanly to the infinite runner's needs. Components are self-contained, making development and presentation explanations straightforward.
- **Alternatives considered**: Single `Game` class with manual rendering loop — too verbose, harder to explain in a presentation.

---

## Decision 3: Background / Parallax

- **Decision**: `ParallaxComponent` built into Flame, with 2–3 image layers at different scroll speeds.
- **Rationale**: `ParallaxComponent` is available out-of-the-box in Flame. It handles infinite scrolling automatically and is explicitly mentioned in the user's original idea as a key talking point for the presentation.
- **Alternatives considered**: Manual tiling of `SpriteComponent`s — more control but reinvents functionality that Flame already provides.

---

## Decision 4: Obstacle Generation

- **Decision**: A dedicated `ObstacleSpawner` component that uses a timer (`Timer` class from Flame) to add new obstacles at intervals. The spawn interval and obstacle scroll speed are controlled by a `DifficultyManager` that scales with elapsed game time.
- **Rationale**: Decouples difficulty logic from individual obstacle components. Easy to tune and demonstrate scaling in the presentation.
- **Alternatives considered**: Spawning from within `update()` with a manual counter — works but conflates concerns.

---

## Decision 5: Collision Detection

- **Decision**: Flame's `ShapeHitbox` (specifically `RectangleHitbox`) on both the player and obstacles, with the player implementing `CollisionCallbacks`. The `onCollisionStart` callback triggers Game Over.
- **Rationale**: Flame's built-in collision system is purpose-designed for this use case. `RectangleHitbox` is accurate enough for a sprite-based runner and avoids expensive polygon intersection. Directly maps to what the spec lists as a presentation talking point.
- **Alternatives considered**: Manual AABB overlap checks in `update()` — functional but bypasses Flame's idiomatic system, making the code less illustrative.

---

## Decision 6: Sprite Assets

- **Decision**: Use kenney.nl's **Simplified Platformer Pack** or **Runner Pack** for the character sprites (run + jump animation frames). Use kenney.nl's **Platformer Art Extended** or **Generic Items** pack for obstacle sprites (bug icon, broken code icon, server icon).
- **Rationale**: kenney.nl assets are CC0 (public domain), vector-clean, and well-suited for sprite sheets. Flame's `SpriteAnimationComponent` loads sprite sheets via `SpriteAnimation.fromFrameData`.
- **Alternatives considered**: Custom pixel art — too time-consuming given the Tuesday deadline.

---

## Decision 7: Score & Persistence

- **Decision**: Score is a running integer incremented by elapsed seconds × multiplier during each `update()` tick. High score is persisted using the `shared_preferences` Flutter package (key-value local storage, no setup required).
- **Rationale**: `shared_preferences` is the standard Flutter solution for lightweight local persistence. Zero backend required. Ships in hours.
- **Alternatives considered**: `hive` or `sqflite` — overkill for a single integer value.

---

## Decision 8: Input Handling

- **Decision**: Wrap the `FlameGame` widget in a `GestureDetector` (or use Flame's `TapCallbacks` mixin on the game) to detect taps. Each tap triggers `player.jump()`. The player component tracks jump count (0, 1, or 2) and resets on ground contact.
- **Rationale**: Simple tap-to-jump is the only input the game needs. Flame provides `TapCallbacks` as a mixin, keeping input handling idiomatic.
- **Alternatives considered**: Keyboard input — not appropriate for a mobile-first game; accelerometer — adds unnecessary complexity.

---

## Decision 9: Project Structure

- **Decision**: Single Flutter project at the repository root (or a dedicated subdirectory `game/`). Source organized by concern:
  - `lib/game/` — Flame components and game class
  - `lib/screens/` — Flutter widgets for menus and game over screen
  - `assets/images/` — sprite sheets and background layers
- **Rationale**: Standard Flutter project layout. Keeps separation between Flame (game logic) and Flutter (UI screens) clear.

---

## Decision 10: Target Platform

- **Decision**: Mobile (Android + iOS) as primary target, with Web as optional secondary target for easy live demo during the presentation.
- **Rationale**: Flutter supports both. Running as a web build avoids device-specific setup issues during a presentation (can open in a browser). Mobile is the canonical target per the spec.
- **Alternatives considered**: Desktop — not relevant for a mobile game presentation.

---

## Decision 11: Viewport, Orientación y Resolución

- **Decision**: Usar `FixedResolutionViewport` de Flame con una resolución lógica fija (p.ej. 800×300 px landscape). En web el canvas se estira al viewport del browser manteniendo el aspect ratio con letterboxing. En móvil se bloquea la orientación a landscape con `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])` al arrancar la app.
- **Rationale**: Una resolución lógica fija garantiza que todas las coordenadas del juego (posición del suelo, altura de salto, posición del spawner) sean constantes independientemente del dispositivo o tamaño de ventana. Simplifica el desarrollo y evita bugs de posicionamiento en la demo. `FixedResolutionViewport` es la solución idiomática de Flame para esto.
- **Alternatives considered**: Coordenadas 100% relativas a `game.size` — más flexible pero requiere más cálculos y es más propenso a errores bajo presión de tiempo; resolución adaptativa sin viewport fijo — el juego se vería diferente en cada dispositivo, difícil de controlar para la presentación.

---

## Resolved Clarifications from Spec

| Question | Resolution |
|----------|------------|
| Audio/music | Out of scope for MVP per spec assumptions |
| Cloud sync / accounts | Local `shared_preferences` only |
| Third-party libraries | `flame ^1.18`, `shared_preferences ^2.x` |
| Sprite format | Kenney.nl PNG sprite sheets, CC0 license |
