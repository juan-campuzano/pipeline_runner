# Data Model: Infinite Runner Game

**Date**: 2026-06-19
**Branch**: `001-infinite-runner-game`

---

## Entities

### PlayerCharacter

Represents the on-screen avatar (the "commit" / developer).

| Field | Type | Description |
|-------|------|-------------|
| `position` | Vector2 | Current x/y position on screen |
| `velocity` | Vector2 | Current movement vector (x is locked; y changes on jump) |
| `jumpCount` | int | 0 = grounded, 1 = first jump, 2 = double jump |
| `isAlive` | bool | False when a collision with an obstacle has occurred |
| `animationState` | enum (run, jump, fall, dead) | Controls which animation frame is displayed |

**Validation rules**:
- `jumpCount` must never exceed 2
- `jumpCount` resets to 0 when `position.y` returns to ground level
- `isAlive` transitions to `false` exactly once per game session (no recovery mid-session)

**State transitions**:
```
grounded (jumpCount=0)
  → tap → jumping (jumpCount=1)
  → tap again (while airborne) → double-jumping (jumpCount=2)
  → land → grounded (jumpCount=0)
  → collide with obstacle → dead (isAlive=false)
```

---

### Obstacle

A hazard generated procedurally during the run.

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum (bug, brokenLine, serverDown) | Determines sprite and display label |
| `position` | Vector2 | Current x/y position; x decreases each tick |
| `size` | Vector2 | Width and height of hitbox; may vary by type |
| `scrollSpeed` | double | Pixels per second the obstacle moves left (mirrors world speed) |
| `isActive` | bool | False when obstacle has scrolled off the left edge (pending removal) |

**Validation rules**:
- `scrollSpeed` must always equal the current world scroll speed at spawn time
- Obstacle is removed from the component tree when `position.x + size.x < 0`

---

### ObstacleSpawner (controller)

Manages timing and variety of obstacle generation.

| Field | Type | Description |
|-------|------|-------------|
| `spawnInterval` | double | Seconds between obstacle spawns; decreases over time |
| `timer` | Timer | Countdown to next spawn event |
| `minInterval` | double | Floor for `spawnInterval` (prevents impossible obstacle density) |

---

### DifficultyManager (value object)

Computes current difficulty parameters based on elapsed game time.

| Field | Type | Description |
|-------|------|-------------|
| `elapsedSeconds` | double | Total seconds of the current game session |
| `worldSpeed` | double | Current scroll speed in pixels/second (increases with time) |
| `spawnInterval` | double | Current obstacle spawn interval in seconds (decreases with time) |

**Scaling rules**:
- `worldSpeed` starts at a comfortable baseline and increases linearly until a capped maximum
- `spawnInterval` starts generous and decreases until `minInterval`
- Both values must be recalculated each `update()` tick based on `elapsedSeconds`

---

### Score

Tracks and persists player performance.

| Field | Type | Description |
|-------|------|-------------|
| `currentScore` | int | Points accumulated in the current session |
| `highScore` | int | All-time best score, loaded from local storage at game start |
| `isNewRecord` | bool | True if `currentScore > highScore` at session end |

**Validation rules**:
- `currentScore` is read-only during Game Over screen (no post-death increments)
- `highScore` is updated in local storage only when `isNewRecord` is true and the session ends

---

### GameSession (state machine)

Top-level state of a play session.

| State | Description |
|-------|-------------|
| `mainMenu` | Start screen is visible; no game loop running |
| `playing` | Game loop active; player is running |
| `gameOver` | Collision occurred; Game Over screen visible |

**Transitions**:
```
mainMenu → [tap "Play"] → playing
playing  → [collision]  → gameOver
gameOver → [tap "Retry"]→ playing  (new session, score reset)
```

---

## Relationships

```
GameSession
  └── has one PlayerCharacter
  └── has one DifficultyManager
  └── has one ObstacleSpawner
       └── generates many Obstacles
  └── has one Score
```

---

## Asset References (not entities, but referenced by components)

| Asset | Format | Used by |
|-------|--------|---------|
| Character sprite sheet | PNG sprite sheet | PlayerCharacter |
| Bug sprite | PNG | Obstacle (type: bug) |
| Broken line sprite | PNG | Obstacle (type: brokenLine) |
| Server down sprite | PNG | Obstacle (type: serverDown) |
| Background layer 1–3 | PNG (tileable) | ParallaxComponent |
