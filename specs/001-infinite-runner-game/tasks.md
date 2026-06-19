# Tasks: Infinite Runner Game (Flutter Flame)

**Input**: Design documents from `specs/001-infinite-runner-game/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Tests**: No test tasks incluidas — no solicitadas en la spec (MVP de presentación).

**Organization**: Tareas agrupadas por user story para permitir implementación y prueba independiente de cada historia.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Se puede paralelizar (archivos distintos, sin dependencias bloqueantes)
- **[Story]**: A qué user story pertenece la tarea (US1, US2, US3)
- Todos los paths son relativos a `infinite_runner/` (raíz del proyecto Flutter)

---

## Phase 1: Setup (Infraestructura compartida)

**Purpose**: Crear el proyecto Flutter, configurar dependencias y preparar assets.

- [x] T001 Crear proyecto Flutter: `flutter create --org com.example infinite_runner` y verificar que `flutter run` levanta la app por defecto
- [x] T002 Añadir dependencias en `pubspec.yaml`: `flame: ^1.18.0` y `shared_preferences: ^2.3.0`; ejecutar `flutter pub get`
- [x] T003 Declarar carpeta de assets en `pubspec.yaml` bajo `flutter.assets`: `- assets/images/`
- [x] T004 [P] Descargar sprites de kenney.nl y colocarlos en `assets/images/`: `player_run.png`, `player_jump.png`, `obstacle_bug.png`, `obstacle_broken.png`, `obstacle_server.png`, `bg_layer1.png`, `bg_layer2.png`, `bg_layer3.png`
- [x] T005 [P] Crear estructura de carpetas: `lib/game/` y `lib/screens/` dentro del proyecto

**Checkpoint**: `flutter pub get` exitoso, carpeta de assets declarada, sprites presentes en `assets/images/`.

---

## Phase 2: Fundacional (Prerrequisitos bloqueantes)

**Purpose**: Game root y viewport configurados — necesarios antes de cualquier componente de juego.

**⚠️ CRÍTICO**: Ninguna user story puede comenzar hasta que esta fase esté completa.

- [x] T006 Crear `lib/game/runner_game.dart`: clase `RunnerGame extends FlameGame with HasCollisionDetection`; configurar `camera.viewport = FixedResolutionViewport(Vector2(800, 300))` en `onLoad`
- [x] T007 Actualizar `lib/main.dart`: llamar `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])` antes de `runApp`; mostrar `GameWidget(game: RunnerGame())` directamente (sin menú aún)
- [x] T008 Crear `lib/game/parallax_background.dart`: `ParallaxBackground extends ParallaxComponent`; cargar las 3 capas (`bg_layer1.png`, `bg_layer2.png`, `bg_layer3.png`) con velocidades base `[20, 40, 80]` px/s respectivamente; añadirlo en `RunnerGame.onLoad`
- [x] T009 Crear `lib/game/difficulty_manager.dart`: clase `DifficultyManager` con campos `elapsedSeconds`, `worldSpeed` (base 150, máx 400), `spawnInterval` (base 2.5s, mín 0.8s); método `update(double dt)` que incrementa ambos linealmente

**Checkpoint**: `flutter run -d chrome` muestra el fondo parallax desplazándose en landscape a 800×300. Velocidad aumenta si se imprime `worldSpeed` en consola tras 60s.

---

## Phase 3: User Story 1 — Loop principal: correr, saltar, morir (Priority: P1) 🎯 MVP

**Goal**: El jugador puede iniciar partida, saltar (simple y doble) sobre obstáculos y perder al colisionar. Loop completo jugable.

**Independent Test**: Iniciar la app, pulsar "Jugar", saltar obstáculos con tap, verificar que colisionar muestra Game Over con puntuación. Todo funciona sin US2 ni US3.

### Implementación US1 — Personaje

- [x] T010 [US1] Crear `lib/game/player.dart`: `PlayerCharacter extends SpriteAnimationComponent with CollisionCallbacks`; campos `jumpCount` (int, máx 2), `isAlive` (bool), `velocity` (Vector2); posición inicial `(80, 220)` en coordenadas lógicas 800×300
- [x] T011 [US1] En `PlayerCharacter`: implementar `update(double dt)` con gravedad (`velocity.y += 600 * dt`), aplicar `velocity` a `position`, y resetear `jumpCount = 0` cuando `position.y >= 220` (suelo)
- [x] T012 [US1] En `PlayerCharacter`: método `jump()` — si `jumpCount < 2`, incrementar `jumpCount`, aplicar `velocity.y = -350`; cargar sprite de salto en el primer jump, sprite de run al aterrizar
- [x] T013 [US1] En `PlayerCharacter`: cargar animación de run desde `player_run.png` (sprite sheet); cargar frame de jump desde `player_jump.png`; añadir `RectangleHitbox` ajustado al sprite
- [x] T014 [US1] En `PlayerCharacter.onCollisionStart`: si colisiona con `Obstacle`, setear `isAlive = false` y llamar `gameRef.triggerGameOver()`

### Implementación US1 — Obstáculos

- [x] T015 [P] [US1] Crear `lib/game/obstacle.dart`: `Obstacle extends SpriteComponent`; enum `ObstacleType {bug, brokenLine, serverDown}`; campo `scrollSpeed` (double); `update(dt)` mueve `position.x -= scrollSpeed * dt`; se elimina con `removeFromParent()` cuando `position.x + size.x < 0`; añadir `RectangleHitbox`
- [x] T016 [US1] Crear `lib/game/obstacle_spawner.dart`: `ObstacleSpawner extends Component`; usa `Timer` de Flame para disparar `_spawnObstacle()` cada `difficultyManager.spawnInterval` segundos; elige tipo aleatorio; posición inicial `x = 820`, `y = 220 - spriteHeight`; añade obstáculo a `gameRef`

### Implementación US1 — Score HUD

- [x] T017 [US1] Crear `lib/game/score_display.dart`: `ScoreDisplay extends TextComponent`; `update(dt)` incrementa `currentScore += (worldSpeed / 10 * dt).round()`; posición `(700, 10)` en lógica 800×300; texto `"Score: $currentScore"`

### Implementación US1 — Game Over flow (sin persistencia aún)

- [x] T018 [US1] En `RunnerGame`: método `triggerGameOver()` — pausa el juego (`pauseEngine()`), almacena `currentScore`, muestra overlay `'GameOver'` registrado en `GameWidget.overlays`
- [x] T019 [US1] Crear `lib/screens/game_over.dart`: `GameOverScreen` Flutter widget (recibe `score` y `highScore`); muestra puntuación, high score placeholder "---", y botón "Reintentar" que llama `game.restart()`
- [x] T020 [US1] En `RunnerGame`: método `restart()` — elimina obstáculos, resetea `PlayerCharacter`, resetea `currentScore`, resetea `DifficultyManager`, llama `resumeEngine()`, cierra overlay `'GameOver'`
- [x] T021 [US1] Actualizar `lib/main.dart`: envolver `GameWidget` con `overlays: {'GameOver': (ctx, game) => GameOverScreen(...)}` y mostrar `MainMenu` antes de iniciar el juego
- [x] T022 [US1] Crear `lib/screens/main_menu.dart`: `MainMenuScreen` Flutter widget; título del juego, botón "Jugar" que cierra el overlay `'MainMenu'` e inicia el game loop

**Checkpoint**: Loop completo funcional. App abre en menú → "Jugar" → personaje corre → tap salta → doble tap doble salto → colisión muestra Game Over → "Reintentar" reinicia. Sin high score persistido aún.

---

## Phase 4: User Story 2 — High Score persistente y reintento (Priority: P2)

**Goal**: La puntuación máxima se guarda entre sesiones con `shared_preferences` y se muestra en Game Over.

**Independent Test**: Jugar hasta perder, anotar puntuación, cerrar y reabrir la app, volver a perder con puntuación menor — verificar que el récord anterior se muestra correctamente.

- [x] T023 [US2] Crear `lib/game/score_repository.dart`: clase `ScoreRepository` con métodos `Future<int> loadHighScore()` y `Future<void> saveHighScore(int score)` usando `shared_preferences` (clave `'high_score'`)
- [x] T024 [US2] En `RunnerGame.onLoad`: llamar `await scoreRepository.loadHighScore()` y almacenar en campo `highScore`
- [x] T025 [US2] En `RunnerGame.triggerGameOver()`: comparar `currentScore` con `highScore`; si `currentScore > highScore`, actualizar `highScore` y llamar `scoreRepository.saveHighScore(currentScore)`; setear `isNewRecord = true`
- [x] T026 [US2] Actualizar `lib/screens/game_over.dart`: mostrar `highScore` real (en lugar de "---"); si `isNewRecord == true`, mostrar banner "¡Nuevo récord!" con estilo destacado

**Checkpoint**: High score persiste entre sesiones. Nuevo récord se señaliza visualmente.

---

## Phase 5: User Story 3 — Dificultad creciente perceptible (Priority: P3)

**Goal**: La velocidad y la frecuencia de obstáculos aumentan de forma visible antes de los 60 segundos de juego.

**Independent Test**: Iniciar partida y observar durante 60 segundos — la velocidad de desplazamiento y la frecuencia de aparición de obstáculos deben ser notablemente mayores que al inicio.

- [x] T027 [US3] En `DifficultyManager.update(dt)`: incrementar `elapsedSeconds += dt`; calcular `worldSpeed = 150 + (elapsedSeconds / 60) * 250` (llega a 400 px/s en ~60s), clampeado a 400; calcular `spawnInterval = max(0.8, 2.5 - (elapsedSeconds / 60) * 1.7)`
- [x] T028 [US3] En `ParallaxBackground.update(dt)`: recibir `worldSpeed` del `DifficultyManager` y escalar las velocidades de las capas proporcionalmente: capa 1 = `worldSpeed * 0.13`, capa 2 = `worldSpeed * 0.27`, capa 3 = `worldSpeed * 0.53`
- [x] T029 [US3] En `ObstacleSpawner.update(dt)`: releer `difficultyManager.spawnInterval` en cada tick del timer para que el intervalo de spawn se actualice en tiempo real sin recrear el timer (usar `timer.limit = newInterval` si el valor cambió)

**Checkpoint**: A los 30s la velocidad es perceptiblemente mayor. A los 60s los obstáculos aparecen con ~doble frecuencia respecto al inicio.

---

## Phase 6: Polish & Presentación

**Purpose**: Ajustes visuales, hitboxes, validación del demo checklist de `quickstart.md`.

- [x] T030 [P] Activar `debugMode = true` temporalmente en `RunnerGame` para visualizar hitboxes; ajustar `RectangleHitbox` de player y obstáculos hasta que las colisiones sean justas; desactivar `debugMode` antes de la presentación
- [x] T031 [P] Añadir texto de tipo de obstáculo (`"BUG"`, `"BROKEN"`, `"SERVER DOWN"`) como `TextComponent` hijo del `Obstacle` para que sea visible durante la demo
- [x] T032 Probar build web: `flutter build web` y `flutter run -d chrome`; verificar que parallax no parpadea y que el canvas queda centrado con letterboxing en distintos tamaños de ventana
- [x] T033 Probar en dispositivo móvil (Android o iOS): verificar orientación landscape bloqueada y que los hitboxes se comportan igual que en web
- [x] T034 Recorrer el checklist completo de `specs/001-infinite-runner-game/quickstart.md` y marcar cada ítem como superado

**Checkpoint**: Todos los ítems del checklist de presentación pasan. App lista para el martes 2026-06-23.

---

## Dependencies & Execution Order

### Dependencias entre fases

- **Phase 1 (Setup)**: Sin dependencias — empezar aquí
- **Phase 2 (Fundacional)**: Depende de Phase 1 — **bloquea todo lo demás**
- **Phase 3 (US1)**: Depende de Phase 2 — es el MVP completo
- **Phase 4 (US2)**: Depende de Phase 3 (necesita `currentScore` y `triggerGameOver`)
- **Phase 5 (US3)**: Depende de Phase 2 (`DifficultyManager` ya existe); puede trabajarse en paralelo con US2 si hay capacidad
- **Phase 6 (Polish)**: Depende de Phases 3–5

### Dependencias dentro de US1

```
T010 (PlayerCharacter estructura)
  → T011 (física/gravedad)
  → T012 (lógica de salto)
  → T013 (sprites + hitbox)
  → T014 (onCollisionStart)

T015 (Obstacle) ──────────────────┐
T016 (ObstacleSpawner) ←─ T015 ──┤→ T018 (triggerGameOver)
T017 (ScoreDisplay) ──────────────┘    → T019 (GameOverScreen)
                                        → T020 (restart)
                                        → T021 (overlays main.dart)
                                        → T022 (MainMenuScreen)
```

### Oportunidades de paralelismo

- T004 y T005 (Phase 1) — en paralelo
- T010–T013 + T015 + T017 (Phase 3) — en paralelo (archivos distintos)
- T030 y T031 (Phase 6) — en paralelo

---

## Parallel Example: User Story 1

```bash
# Lanzar en paralelo (archivos independientes):
Task: "T010 — lib/game/player.dart (estructura base)"
Task: "T015 — lib/game/obstacle.dart"
Task: "T017 — lib/game/score_display.dart"

# Luego en secuencia (dependen de T010):
Task: "T011 — física de gravedad en player.dart"
Task: "T012 — lógica de salto en player.dart"
Task: "T013 — sprites y hitbox en player.dart"
Task: "T014 — onCollisionStart en player.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 únicamente)

1. Completar Phase 1: Setup
2. Completar Phase 2: Fundacional (parallax visible en web)
3. Completar Phase 3: US1 — loop completo jugable
4. **PARAR Y VALIDAR**: Jugar en browser, confirmar que el loop funciona
5. Demo viable desde aquí si el tiempo aprieta

### Entrega incremental

1. Setup + Fundacional → parallax corriendo
2. US1 → **demo jugable** (MVP para la presentación)
3. US2 → high score persistente (añade rejugabilidad)
4. US3 → dificultad creciente (hace el juego más interesante en demo)
5. Polish → presentación pulida

---

## Notes

- `[P]` = archivos distintos, sin dependencias entre sí
- `[US1/2/3]` mapea cada tarea a su user story para trazabilidad
- Las coordenadas lógicas (p.ej. `y = 220`) se basan siempre en la resolución fija 800×300
- `debugMode = true` en Flame activa la visualización de hitboxes — usar durante Phase 6, desactivar antes de la presentación
- Fase 6 es opcional si el tiempo es ajustado; Phases 1–4 son el mínimo para una demo sólida
