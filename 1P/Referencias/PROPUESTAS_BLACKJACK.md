# Tres propuestas de videojuego: blackjack con progresión roguelite

Documento de conceptualización para discusión grupal. Fecha: 4 de octubre de 2026. Demostración prevista: 5 de octubre de 2026.

Los nombres son provisionales. Las cifras de economía y balance son hipótesis de diseño que deberán probarse con jugadores, no resultados de pruebas realizadas.

## 1. Intención del proyecto

Desarrollar un videojuego individual de cartas, en español, que combine la decisión inmediata del blackjack —pedir otra carta o plantarse— con objetos que permitan crear estrategias distintas en cada partida. La inspiración en Balatro se concentra en la combinación de efectos y la progresión entre rondas; la narrativa, los recursos, los personajes y el arte serán propios.

**Objetivo general del desarrollo:** producir una experiencia breve y rejugable donde el jugador comprenda las reglas con rapidez y tome decisiones sobre riesgo, información y recursos.

**Objetivos específicos:**

- Implementar un blackjack consistente, con ases de valor adaptable y resolución clara de cada mano.
- Diseñar consumibles de un solo uso y amuletos con efectos persistentes durante la partida.
- Permitir al menos tres estrategias viables sin que exista un objeto indispensable.
- Comunicar visualmente qué efecto se activó y por qué cambió el resultado.
- Completar una partida de aproximadamente 10–20 minutos en la versión académica.

**Público previsto:** estudiantes y jugadores que disfruten juegos de cartas y estrategia ligera. Es una orientación de diseño, no una clasificación oficial por edades. Plataforma inicial: computadora, control con ratón y teclado. Todas las monedas y apuestas son ficticias.

**Vocabulario:** una mano es un enfrentamiento de cartas; un encuentro contiene varias manos; una partida comprende el recorrido completo. Un consumible desaparece al utilizarse. Un amuleto ocupa un espacio y permanece hasta venderse o terminar la partida. Roguelite significa que cada intento reorganiza recompensas y desafíos y permite desbloquear contenido para intentos posteriores.

## 2. Propuesta A — La Última Mesa

**Idea central:** escapar de un casino sobrenatural antes del amanecer, ganando fichas y combinando amuletos que alteran las recompensas del blackjack.

### Historia y ambientación

El protagonista recibe una invitación a un casino que aparece únicamente durante una noche. Al entrar descubre que la salida exige tres sellos, custodiados por distintos crupieres. Cada uno ofrece una interpretación diferente del riesgo: prudencia, codicia y sacrificio. El jugador debe reunir los sellos y derrotar al dueño de la casa para recuperar su libertad.

La historia avanza mediante conversaciones cortas antes de cada encuentro. No requiere cinemáticas ni exploración de escenarios. La mesa es el escenario principal: terciopelo verde oscuro, latón envejecido, cartas de marfil y luces cálidas. Sonido de fichas, barajado y jazz lento original o con licencia compatible.

**Género:** estrategia de cartas y roguelite de gestión de recursos.

### Objetivo y ciclo de juego

Empezar con 100 fichas, superar tres encuentros y ganar la mesa final. Cada encuentro normal exige alcanzar un saldo objetivo en un máximo de cinco manos; el objetivo y las reglas se muestran antes de entrar. Entre encuentros se visita una tienda. Perder todas las fichas o agotar las manos sin cumplir la meta termina el intento.

Ciclo: leer regla de mesa → apostar → jugar blackjack → recibir resultado y efectos → comprar o ahorrar → entrar al siguiente encuentro.

Las apuestas iniciales sugeridas son 10 y 20 fichas. Su viabilidad depende de ajustar los objetivos al saldo con el que se llega a cada mesa. Las tiendas no deben exigir gastar tanto que la próxima mesa resulte imposible.

### Elementos y decisiones

Tres espacios de amuletos y dos de consumibles. Efectos propuestos:

| Tipo | Objeto | Efecto inicial para prototipar |
|---|---|---|
| Amuleto | Moneda mellada | Al empatar, otorga 2 fichas adicionales; una vez por mano. |
| Amuleto | Sello del prudente | Ganar con 18 o 19 otorga 4 fichas adicionales. |
| Amuleto | Corona del riesgo | Ganar con cuatro cartas o más otorga 8 fichas adicionales. |
| Consumible | Lente de humo | Revela la carta oculta del crupier antes de plantarse. |
| Consumible | Hilo del destino | Sustituye la última carta pedida por la siguiente del mazo; una vez y antes de resolver la mano. |

La sustitución necesita una ventana de decisión explícita antes de declarar una derrota por exceso; no debe actuar retroactivamente tras pagar una mano.

**Ejemplo de sinergia:** la lente aporta información y el sello recompensa plantarse con valores moderados. La corona incentiva una estrategia distinta: seguir pidiendo cartas pequeñas.

**Jefe de ejemplo:** El Recaudador cobra dos fichas al comenzar cada mano. La regla se anuncia y no cambia silenciosamente el valor de las cartas.

**Identidad propia:** sobrevivir económicamente y decidir cuánto arriesgar, con una historia de escape. El atractivo no depende únicamente de multiplicar puntuaciones.

**Alcance académico:** una mesa reutilizable, tres retratos de crupieres, seis amuletos, cuatro consumibles, una tienda y tres encuentros. Los tres sellos pueden reutilizar esa estructura sin construir un casino explorable.

**Riesgo principal:** que los objetivos dependan demasiado del azar. Mitigación: apuestas limitadas, información previa y consumibles que aporten control.

**Tecnología propuesta:** Phaser + TypeScript + Vite. Es la alternativa recomendada si el equipo ya conoce JavaScript y desea presentar en navegador.

## 3. Propuesta B — Veintiuno: Pacto de Ceniza

**Idea central:** utilizar manos de blackjack como duelos de combate para salir del inframundo.

### Historia y ambientación

Un mensajero despierta en una estación de tránsito para almas. Su nombre fue incluido por error en el registro de los muertos. Para recuperar su identidad debe derrotar a los guardianes que conservan fragmentos de su memoria. Cada victoria entrega un fragmento narrativo; el último guardián revela quién alteró el registro.

Fantasía oscura con grabados, ceniza, sellos rojos y cartas rituales. Las almas y enemigos aparecen como ilustraciones estáticas con movimientos breves. Campanas, percusión discreta y sonidos de pergamino.

**Género:** combate por turnos con cartas y estructura roguelite.

### Objetivo y ciclo de juego

El jugador inicia con 40 puntos de vida. Cada enemigo posee su propia vida. Cada mano se juega contra un crupier que representa al enemigo: victoria causa 6 de daño; blackjack natural causa 10; derrota recibida causa 6; empate no causa daño. Es una base de balance, no una regla universal de blackjack.

Derrotar tres guardianes completa la versión académica. Llegar a cero de vida termina el intento. Entre combates se elige entre curarse o recibir una reliquia.

Ciclo: observar intención del enemigo → jugar mano → resolver daño → escoger recompensa → avanzar.

### Elementos y decisiones

| Tipo | Objeto | Efecto inicial para prototipar |
|---|---|---|
| Amuleto | Diente de ceniza | Ganar con 20 causa 3 de daño adicional. |
| Amuleto | Velo funerario | Reduce en 2 el daño de una derrota sin pasarse de 21. |
| Amuleto | Corazón prestado | El primer blackjack natural de cada combate cura 4 de vida. |
| Consumible | Sal del regreso | Recupera 6 de vida antes del reparto. |
| Consumible | Ojo del barquero | Revela la carta oculta del enemigo durante esa mano. |

**Ejemplo de sinergia:** el velo y la sal favorecen supervivencia; el diente recompensa buscar 20. La diferencia con la propuesta A está en conservar vida, no en administrar apuestas.

**Jefe de ejemplo:** El Guardián del Eco anuncia un ataque de 8 de daño cada tercera mano. Solo se ejecuta si el jugador pierde esa mano; un icono indica cuándo ocurrirá.

**Alcance académico:** tres enemigos, una pantalla de combate, una pantalla de recompensas, seis reliquias y cuatro consumibles. Sin movimiento libre ni árbol complejo de habilidades.

**Riesgo principal:** combates repetitivos o demasiado largos. Mitigación: vida reducida, intenciones claras y enemigos con una sola regla especial.

**Tecnología propuesta:** Godot con GDScript si se prefiere trabajar con escenas y un editor visual. Phaser también sirve si el grupo quiere conservar la misma base web.

## 4. Propuesta C — Protocolo 21

**Idea central:** infiltrarse en un casino controlado por una inteligencia artificial, manipulando información sin llenar el medidor de sospecha.

### Historia y ambientación

Una auditora descubre que una corporación utiliza su casino para retener las identidades digitales de sus clientes. Para recuperar las pruebas debe acceder a tres mesas de seguridad creciente. Sus herramientas permiten observar y alterar cartas, pero cada intervención deja un rastro. El enfrentamiento final se libra contra el sistema que controla la sala.

Estética tecnológica de terminales, negro y ámbar con acentos cian. Cartas legibles y animaciones cortas de interferencia. Música electrónica tenue y alertas con volumen ajustable.

**Género:** estrategia de cartas y gestión de riesgo con progresión roguelite.

### Objetivo y ciclo de juego

Conseguir tres fragmentos de acceso antes de alcanzar 100 puntos de sospecha. Cada mesa entrega un fragmento al ganar tres manos en un máximo de cinco. Las derrotas añaden 10 de sospecha; los empates consumen una mano. Fallar un encuentro termina el intento en el alcance inicial.

Pedir y plantarse no generan sospecha adicional. Los consumibles tecnológicos sí lo hacen, por lo que una ventaja inmediata puede comprometer las siguientes mesas.

Ciclo: estudiar protocolo → jugar o intervenir → resolver mano y sospecha → mejorar herramientas → acceder al siguiente nivel.

### Elementos y decisiones

| Tipo | Objeto | Efecto inicial para prototipar |
|---|---|---|
| Amuleto | Proxy | Reduce en 5 la sospecha del primer consumible de cada mesa. |
| Amuleto | Caché limpia | Ganar sin consumibles reduce 5 de sospecha. |
| Amuleto | Analizador | Muestra un registro de cartas ya reveladas, sin revelar las ocultas. |
| Consumible | Escáner | Revela la carta oculta y suma 10 de sospecha. |
| Consumible | Inyección | Sustituye la última carta pedida antes de resolver la mano y suma 20 de sospecha. |

**Ejemplo de sinergia:** proxy y escáner permiten una intervención barata; caché limpia recompensa alternar manos asistidas y manos sin herramientas.

**Jefe de ejemplo:** El Supervisor duplica el coste de sospecha de la segunda intervención utilizada en una misma mesa. El coste final se muestra antes de confirmar.

**Alcance académico:** tres protocolos, seis módulos, cuatro consumibles, un medidor de sospecha y una tienda simple. La ambientación representa tecnología ficticia; no necesita conexión a servicios externos.

**Riesgo principal:** sobrecargar al jugador con dos sistemas de riesgo. Mitigación: comenzar con un tutorial de blackjack y presentar la sospecha en la segunda mesa.

**Tecnología propuesta:** Phaser + TypeScript + Vite. La interfaz de cartas, registro y medidores encaja en una aplicación 2D de navegador.

## 5. Comparación y recomendación

| Criterio | La Última Mesa | Pacto de Ceniza | Protocolo 21 |
|---|---|---|---|
| Recurso principal | Fichas | Vida | Sospecha |
| Pregunta del jugador | ¿Cuánto arriesgo? | ¿Cómo sobrevivo? | ¿Cuándo uso una ventaja? |
| Cercanía al blackjack clásico | Alta | Media | Media |
| Complejidad relativa estimada | Baja a media | Media | Media a alta |
| Mayor trabajo adicional | Economía y tienda | Daño y enemigos | Intervenciones y claridad de interfaz |
| Demo básica reutilizable | Directamente | Reutiliza reglas de cartas | Reutiliza reglas de cartas |

**Recomendación:** La Última Mesa. Comunica la idea con pocas explicaciones y permite convertir la demo de blackjack en el juego final por incrementos pequeños. Pacto de Ceniza es preferible si el equipo disfruta diseñar enemigos. Protocolo 21 ofrece una decisión adicional interesante, pero requiere más pruebas de comprensión.

## 6. Herramientas y organización técnica inicial

| Herramienta | Función | Cuándo elegirla |
|---|---|---|
| HTML, CSS y JavaScript | Prototipo de mesa y reglas | Para demostrar mañana con pocas dependencias. |
| Phaser + TypeScript | Framework 2D y lógica tipada | Para continuar como juego web con animaciones y escenas. |
| Vite | Servidor de desarrollo y empaquetado | Acompaña la opción web; no es un motor de juego. |
| Godot + GDScript | Motor con editor de escenas y herramientas 2D | Si el equipo conoce Godot o prioriza un ejecutable de escritorio. |
| Git | Historial y colaboración | Desde el inicio, con cambios pequeños y revisables. |

Phaser está orientado a juegos 2D en navegador y permite JavaScript y TypeScript: [documentación oficial](https://docs.phaser.io/phaser/getting-started/what-is-phaser). Godot proporciona herramientas 2D y 3D: [sitio oficial](https://godotengine.org/). Vite facilita desarrollo y generación de archivos estáticos: [guía oficial](https://vite.dev/guide/).

No hace falta un servidor de cuentas ni una base de datos para el alcance inicial. El guardado de ajustes y desbloqueos puede ser local. Tampoco hace falta añadir React si la interfaz del juego queda resuelta con Phaser.

Separación propuesta para facilitar cambios:

- **Reglas:** creación del mazo, barajado, puntuación, blackjack y resolución; sin depender de dibujos ni botones.
- **Estado:** saldo, manos, fase actual y acciones permitidas.
- **Presentación:** cartas, controles, mensajes y sonidos.
- **Contenido futuro:** amuletos y consumibles definidos como datos con identificador, momento de activación, efecto y límite.

Los efectos se resolverán en un orden fijo: acción → cambio de cartas → evaluación → resultado base → bonificaciones → actualización visual. Una bonificación no volverá a dispararse a sí misma. Cada pantalla explicará la regla especial vigente.

## 7. Diseño concreto de la demo para mañana

**Estado: prototipo básico implementado en `prototipo/index.html` tras la aprobación del alcance.** Las instrucciones y la verificación están en `prototipo/README.md`.

Una mesa de blackjack individual, en español, usable en un navegador de computadora. Apariencia de casino nocturno compatible con La Última Mesa. Duración de la demostración: 2–3 minutos.

### Reglas cerradas para evitar ambigüedades

- Mazo estándar de 52 cartas sin comodines; se vuelve a barajar al comenzar cada mano.
- Saldo inicial de 100 fichas, apuesta fija de 10 y sin dinero real.
- Dos cartas para el jugador y dos para el crupier; una del crupier permanece oculta durante el turno del jugador.
- Figuras valen 10; as vale 11 o 1 según convenga sin exceder 21.
- Acciones: repartir, pedir, plantarse, siguiente mano y reiniciar saldo.
- El crupier pide con menos de 17 y se planta con 17, incluido 17 suave.
- Blackjack natural significa 21 con las dos cartas iniciales. Supera cualquier 21 formado con más cartas.
- Los naturales se comprueban tras el reparto: ambos naturales empatan; natural solo del crupier pierde el jugador; natural solo del jugador paga 3:2.
- La apuesta se descuenta al repartir. Una victoria normal devuelve 20; un blackjack devuelve 25; un empate devuelve 10; una derrota devuelve 0.
- Si el jugador supera 21, pierde inmediatamente. Si el crupier supera 21 y el jugador no, gana el jugador.
- Al llegar a 21 con tres o más cartas se pasa al turno del crupier; ese 21 no recibe el pago de blackjack natural.
- Sin división de parejas, doblar, seguro, tienda, consumibles ni amuletos en esta primera demo.

### Interfaz

Saldo y apuesta en la parte superior; mano del crupier arriba y mano del jugador abajo; botones grandes de Pedir y Plantarse; resultado explicado en una frase. La puntuación del crupier solo incluirá cartas visibles mientras haya una oculta. Los botones se desactivarán fuera de su turno. Los palos tendrán símbolos además de colores y habrá foco visible para teclado.

### Comprobaciones necesarias

Verificar ases múltiples, blackjack natural frente a 21 de tres cartas, empate, ambos tipos de exceso, crupier con 17 suave, pagos y acciones fuera de turno. Probar el ciclo completo en navegador y reiniciar varias manos. Para exponer sin depender de la suerte, puede añadirse un modo de ejemplos marcado explícitamente como demostración con secuencias preparadas.

### Guion de demostración

1. Explicar que se muestra la mecánica base y que los objetos pertenecen a una fase posterior.
2. Repartir y mostrar la diferencia entre información visible y carta oculta.
3. Pedir una carta o plantarse y explicar la decisión.
4. Resolver la mano y comprobar el cambio de saldo.
5. Mostrar una diapositiva conceptual con un amuleto y explicar cómo ampliará esta misma mecánica.

## 8. Exposición grupal sugerida: 8–10 minutos

Se proponen dos bloques de exposición que el grupo puede repartir internamente.

| Tiempo | Responsable | Contenido visual y discurso |
|---|---|---|
| 0:00–1:00 | Expositor 1 | Necesidad del proyecto, objetivo y decisión básica del blackjack. |
| 1:00–2:30 | Expositor 1 | Tres propuestas: una frase de historia, recurso principal y diferencia jugable de cada una. |
| 2:30–4:00 | Expositor 1 | Propuesta recomendada: historia, ambientación, público y condición de victoria. |
| 4:00–5:30 | Expositor 2 | Ciclo de juego; diferencia entre consumible y amuleto; una sinergia concreta. |
| 5:30–6:30 | Expositor 2 | Herramientas, alcance inicial y fases del desarrollo. |
| 6:30–9:00 | Expositor 2 | Demostración de una o dos manos con explicación de decisiones. |
| 9:00–10:00 | Ambos | Preguntas y cierre sobre qué se implementará después. |

**Apertura sugerida:** «Nuestro proyecto parte de una decisión fácil de entender: pedir otra carta o plantarse antes de superar veintiuno. Queremos convertir esa decisión en una aventura breve, donde los objetos obtenidos cambien la estrategia de cada partida».

**Defensa de la originalidad:** «La referencia a Balatro está en combinar efectos y construir estrategias. Nuestro juego conserva el enfrentamiento contra un crupier y desarrolla una historia de escape, una economía propia y objetos diseñados alrededor del riesgo del blackjack».

**Cierre sugerido:** «La primera entrega demuestra que la mecánica central funciona. Después incorporaremos una tienda, pocos objetos bien diferenciados y crupieres con reglas especiales. Así podremos comprobar cada ampliación antes de aumentar el contenido».

## 9. Plan posterior a la exposición

Hitos propuestos, sujetos al calendario real de la asignatura:

1. Base: validar blackjack, controles y lectura de resultados.
2. Primer recorrido: conectar tres encuentros y una condición final de victoria o derrota.
3. Objetos: implementar dos amuletos y dos consumibles, medir sus interacciones y después ampliar el catálogo.
4. Presentación: integrar arte, sonido, tutorial breve y guardado de ajustes.
5. Evaluación: observar jugadores nuevos, registrar confusiones y ajustar dificultad y duración.

Criterios de aceptación del proyecto: reglas sin errores conocidos, efectos explicables, una partida completa, controles claros, recursos gráficos con procedencia documentada y una compilación local reproducible. El número final de objetos importa menos que su utilidad y claridad.

