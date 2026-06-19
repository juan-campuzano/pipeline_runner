# Feature Specification: Infinite Runner Game (Flutter Flame)

**Feature Branch**: `001-infinite-runner-game`

**Created**: 2026-06-19

**Status**: Draft

**Input**: User description: "Un juego de carrera infinita donde el personaje avanza automáticamente y debe esquivar obstáculos. El jugador solo toca la pantalla para saltar (o doble salto). Temática: un desarrollador/commit que esquiva Bugs, Líneas de código rotas y Servidores caídos para llegar a producción. Sprites de kenney.nl."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Jugar una partida completa (Priority: P1)

El jugador abre el juego, ve al personaje (un "commit") corriendo automáticamente por un entorno de desarrollo, toca la pantalla para saltar obstáculos, y continúa hasta chocar con uno o llegar al final de la sesión.

**Why this priority**: Es el loop principal del juego; sin esto no existe el producto.

**Independent Test**: Se puede probar completamente iniciando el juego y jugando hasta perder. Entrega el MVP de inmediato.

**Acceptance Scenarios**:

1. **Given** el juego está en pantalla principal, **When** el jugador toca "Jugar", **Then** el personaje comienza a correr automáticamente de izquierda a derecha.
2. **Given** el personaje está corriendo, **When** el jugador toca la pantalla una vez, **Then** el personaje salta por encima del obstáculo.
3. **Given** el personaje está en el aire durante el primer salto, **When** el jugador toca la pantalla de nuevo, **Then** el personaje ejecuta un doble salto.
4. **Given** el personaje colisiona con un obstáculo (Bug, línea rota o servidor caído), **When** ocurre la colisión, **Then** la partida termina y se muestra la pantalla de "Game Over" con la puntuación obtenida.
5. **Given** la partida está en curso, **When** el fondo avanza, **Then** el entorno se desplaza de forma continua e infinita sin cortes visibles.

---

### User Story 2 - Ver y superar la puntuación más alta (Priority: P2)

El jugador completa una partida, ve su puntuación, y puede iniciar una nueva partida para intentar superar su récord anterior.

**Why this priority**: Motiva la rejugabilidad y da contexto de progreso al jugador.

**Independent Test**: Se puede probar reiniciando el juego tras perder y verificando que el high score persiste entre partidas.

**Acceptance Scenarios**:

1. **Given** la partida ha terminado, **When** se muestra la pantalla de Game Over, **Then** se muestra la puntuación actual y el récord máximo alcanzado.
2. **Given** el jugador supera su récord anterior, **When** termina la partida, **Then** el nuevo récord queda guardado y se muestra como "¡Nuevo récord!".
3. **Given** el jugador está en la pantalla de Game Over, **When** toca "Reintentar", **Then** se inicia una nueva partida desde el principio.

---

### User Story 3 - Dificultad creciente (Priority: P3)

A medida que la partida avanza, los obstáculos aparecen con mayor frecuencia y la velocidad de desplazamiento del entorno aumenta gradualmente.

**Why this priority**: Mantiene el reto y el interés a lo largo del tiempo; mejora la experiencia de presentación demostrando el escalado del juego.

**Independent Test**: Se puede observar después de ~30 segundos de juego que la velocidad y la frecuencia de obstáculos han aumentado respecto al inicio.

**Acceptance Scenarios**:

1. **Given** el jugador lleva más de 30 segundos en partida, **When** aparecen nuevos obstáculos, **Then** el intervalo entre obstáculos es menor que al inicio.
2. **Given** la velocidad base de desplazamiento al inicio, **When** el jugador lleva 60 segundos en partida, **Then** la velocidad de desplazamiento es notablemente mayor que la inicial.

---

### Edge Cases

- ¿Qué ocurre si el jugador toca la pantalla antes de que el juego haya iniciado completamente?
- ¿Qué ocurre si el jugador intenta hacer un tercer salto mientras ya realizó el doble salto (sin tocar suelo)?
- ¿Qué pasa si el personaje llega al borde lateral de la pantalla por variaciones de tamaño de dispositivo?
- ¿Cómo se comporta el juego si el dispositivo recibe una llamada o notificación durante la partida (pausa/foco perdido)?

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El juego DEBE desplazar automáticamente al personaje de izquierda a derecha sin intervención del jugador.
- **FR-002**: El jugador DEBE poder hacer saltar al personaje tocando la pantalla una vez (salto simple).
- **FR-003**: El jugador DEBE poder realizar un segundo salto (doble salto) tocando la pantalla mientras el personaje está en el aire tras el primer salto.
- **FR-004**: El juego NO DEBE permitir más de dos saltos consecutivos sin que el personaje toque el suelo.
- **FR-005**: El sistema DEBE generar obstáculos (Bugs, Líneas de código rotas, Servidores caídos) de forma procedural e infinita durante la partida.
- **FR-006**: El sistema DEBE detectar la colisión entre el personaje y los obstáculos y, al producirse, terminar la partida.
- **FR-007**: El fondo DEBE desplazarse de forma continua creando el efecto de entorno infinito.
- **FR-008**: El sistema DEBE calcular y mostrar la puntuación del jugador en tiempo real durante la partida (basada en distancia/tiempo recorrido).
- **FR-009**: El sistema DEBE almacenar y mostrar el récord máximo del jugador entre sesiones.
- **FR-010**: La velocidad de desplazamiento y la frecuencia de aparición de obstáculos DEBEN incrementarse gradualmente con el tiempo.
- **FR-011**: El juego DEBE mostrar una pantalla de inicio con opción de comenzar la partida.
- **FR-012**: El juego DEBE mostrar una pantalla de "Game Over" con la puntuación final y el récord, y la opción de reintentar.
- **FR-013**: El juego DEBE usar sprites visuales para el personaje y los obstáculos, coherentes con la temática de desarrollo de software.

### Key Entities

- **Personaje (Commit/Desarrollador)**: El avatar controlado indirectamente por el jugador. Tiene estado de posición vertical (en suelo / en primer salto / en doble salto) y animaciones de carrera y salto.
- **Obstáculo**: Elemento generado proceduralmente. Tipos: Bug, Línea de código rota, Servidor caído. Cada tipo tiene sprite propio y puede tener variaciones de tamaño o altura.
- **Puntuación**: Valor numérico que crece mientras la partida está activa, representando la distancia o el tiempo de supervivencia.
- **Récord (High Score)**: Puntuación máxima histórica del jugador, persistida entre sesiones.
- **Entorno / Fondo**: Capas visuales que se desplazan a distintas velocidades (efecto parallax) para simular profundidad y movimiento continuo.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El jugador puede iniciar y jugar una partida completa en menos de 10 segundos desde que abre la aplicación.
- **SC-002**: El juego se ejecuta de forma fluida (sin saltos o congelaciones perceptibles) durante al menos 5 minutos continuos de juego.
- **SC-003**: El 100% de las colisiones detectadas visualmente por un observador externo resultan en Game Over (sin colisiones falsas ni ignoradas).
- **SC-004**: El récord del jugador se mantiene correctamente tras cerrar y volver a abrir la aplicación.
- **SC-005**: Un evaluador nuevo (sin instrucciones) comprende la mecánica de salto en su primer intento al ver la pantalla de inicio.
- **SC-006**: La dificultad aumenta de forma perceptible antes de los 60 segundos de juego, validado por al menos 3 observadores durante la presentación.

---

## Assumptions

- Los sprites se obtendrán del catálogo gratuito de kenney.nl y serán compatibles con uso en presentaciones académicas.
- El juego está diseñado para dispositivos móviles (pantalla táctil), pero puede ejecutarse en escritorio usando clics de ratón como sustituto del toque.
- El almacenamiento del récord máximo se hará de forma local en el dispositivo; no se requiere sincronización en la nube ni cuentas de usuario.
- No se requiere sonido ni música para el MVP de presentación, aunque puede añadirse si el tiempo lo permite.
- El juego es para un solo jugador; no hay modo multijugador ni tablas de clasificación en línea.
- La presentación se realizará el martes 2026-06-23, por lo que el alcance está deliberadamente limitado a lo implementable en pocos días.
- Se asume que el entorno de desarrollo Flutter está configurado y funcional en la máquina del presentador.
