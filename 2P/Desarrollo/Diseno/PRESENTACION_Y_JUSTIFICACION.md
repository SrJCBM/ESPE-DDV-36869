# La Última Mesa · Presentación y justificación grupal

**Estado:** propuesta de Kenned del 24 de noviembre de 2026 para preparar la exposición de interfaces y diseño. Pensada para **15 minutos de exposición y 5 de preguntas**; si el docente da otro tiempo, se escalan los bloques en la misma proporción.

**Equipo:** Kenned Sigcha, Julio Blacio y Ariel Llumiquinga.

## Índice

1. [Qué evalúa la rúbrica y dónde está la evidencia](#1-qué-evalúa-la-rúbrica-y-dónde-está-la-evidencia)
2. [Reparto de la exposición](#2-reparto-de-la-exposición)
3. [Guion de la exposición](#3-guion-de-la-exposición)
4. [Decisiones de diseño y su justificación](#4-decisiones-de-diseño-y-su-justificación)
5. [Utilidad de las interfaces](#5-utilidad-de-las-interfaces)
6. [Utilidad de los personajes](#6-utilidad-de-los-personajes)
7. [Quién conoce cada parte](#7-quién-conoce-cada-parte)
8. [Preguntas probables](#8-preguntas-probables)
9. [Preparación](#9-preparación)

---

## 1. Qué evalúa la rúbrica y dónde está la evidencia

| Criterio (4 puntos cada uno) | Qué hay que mostrar | Evidencia en el repositorio | Quién lo defiende |
| --- | --- | --- | --- |
| **Coherencia de la interfaz con el videojuego** | Que menús, HUD e interfaces nacen del objetivo, el género, la historia, la estética y las mecánicas | [DIRECCION_ARTISTICA.md](DIRECCION_ARTISTICA.md), [FIGMA.md](FIGMA.md), [ITERACION_04.md](../ITERACION_04.md) | Julio |
| **Diseño visual** | Orden, legibilidad, color, tipografía, iconos, botones y distribución | Paleta y tipografías en Figma; capturas de `tests/qa_interfaz_i4.gd` a 1024 × 576 y 1280 × 720 | Julio |
| **Navegación y experiencia de usuario** | Cómo se pasa entre inicio, juego, pausa, opciones y demás pantallas | [NAVEGACION_PANTALLAS.md](NAVEGACION_PANTALLAS.md) | Kenned |
| **Objetos, personajes y mecánicas** | Listado claro y la función de cada uno en la jugabilidad | [CATALOGO_JUEGO.md](CATALOGO_JUEGO.md) | Ariel |
| **Presentación y justificación grupal** | Decisiones de diseño explicadas, utilidad de interfaces y personajes, y que los tres expongan en partes iguales | Este documento: tres bloques de 5 minutos y las secciones 4 a 6 | Los tres, 5 minutos cada uno |

---

## 2. Reparto de la exposición

**Participación equilibrada = los tres exponen en partes iguales.** Cada integrante tiene **5 minutos exactos** de exposición y responde un tercio de las preguntas. La apertura la hace Julio dentro de sus 5 minutos y el cierre lo hace Kenned dentro de los suyos, así nadie habla más que otro. Cada bloque termina presentando al siguiente.

| Integrante | Bloque | Minutos | Criterios que cubre |
| --- | --- | ---: | --- |
| **Julio** | Apertura, concepto, coherencia y diseño visual | 5 | 1 y 2 |
| **Ariel** | Objetos, personajes y mecánicas | 5 | 4 |
| **Kenned** | Navegación, experiencia de usuario y cierre | 5 | 3 |
| **Los tres** | Justificación de decisiones (criterio 5) | — | Cada uno justifica las decisiones de su propio bloque con la tabla de la [sección 4](#4-decisiones-de-diseño-y-su-justificación) |

El reparto sigue lo que cada uno diseñó o construyó (ver [sección 7](#7-quién-conoce-cada-parte)), para que cada integrante defienda lo que mejor conoce.

---

## 3. Guion de la exposición

| Tiempo | Quién | Qué se dice | Qué se muestra |
| --- | --- | --- | --- |
| 0:00–0:30 | Julio | Presenta al equipo y el juego en una frase: «un juego de cartas y exploración en un casino sobrenatural, donde cada mano arriesga contra un umbral y cada campanada cuesta una oportunidad». | Pantalla de inicio |
| 0:30–2:00 | Julio | **Concepto y coherencia.** Género (cartas por turnos con exploración 2D), objetivo (reunir tres sellos y vencer al Dueño) y por qué todo el arte es grabado del siglo XIX: el casino es una casa antigua donde el tiempo se detuvo. | Vestíbulo y una carta ampliada |
| 2:00–5:00 | Julio | **Diseño visual.** Paleta (verde profundo, latón, marfil) y por qué; dos tipografías; iconos de palos reconocibles por silueta; sellos y fichas ilustrados; dial de campanadas; una sola pista a la vez. Cierra: «Ariel explicará qué hace el jugador con todo esto». | Capturas de la mesa, el HUD y la vitrina a dos resoluciones |
| 5:00–10:00 | Ariel | **Objetos, personajes y mecánicas.** La mano: pedir, plantarse, umbral y Quiebra. Los cuatro palos y su regla. Los patrones y la fórmula de puntos. Los objetos y el objeto inicial, cada uno con la decisión que crea. Los personajes como curva de dificultad: cada crupier enseña algo. Cierra: «Kenned mostrará cómo se recorre todo esto». | Una mano real: pedir, revelar una Máscara, desglose; tabla del catálogo |
| 10:00–14:30 | Kenned | **Navegación y experiencia.** Flujo completo: inicio → exploración → crupier → mesa → recompensa → tienda. La pausa con Esc que congela y devuelve al mismo punto; «Ver baraja» sin revelar información oculta; el mapa como selección de nivel; accesibilidad (teclado, movimiento reducido, volumen por canal); el prólogo de novela visual previsto. | Diagrama de navegación y recorrido en vivo |
| 14:30–15:00 | Kenned | **Cierre:** «cada interfaz responde a una pregunta del jugador: adónde voy, qué tengo, cuánto arriesgo y qué acaba de pasar». | Diagrama del bucle de juego |

**Preguntas (5 minutos):** cada integrante responde las de su bloque. Si una pregunta es general, responde quien haya hablado menos en las preguntas anteriores, para mantener el equilibrio.

---

## 4. Decisiones de diseño y su justificación

| Decisión | Por qué | Dónde se ve |
| --- | --- | --- |
| **Estética de grabado del siglo XIX** | Une el tema (casino antiguo y sobrenatural) con una técnica coherente para personajes, cartas y fondos; el tramado permite arte legible a tamaños pequeños | Retratos, cartas, salas |
| **Paleta de verde profundo, latón y marfil** | El verde evoca el tapete de casino; el latón marca lo interactivo y lo importante; el marfil asegura contraste de lectura sobre fondos oscuros | Toda la interfaz |
| **Dos tipografías con funciones distintas** | Cormorant da el tono de época en títulos y cifras grandes; DM Sans asegura lectura rápida en reglas y botones | Menús, mesa, diálogos |
| **Una sola pista a la vez** | Las pruebas de I3 mostraron demasiado texto; cerca de un objeto aparece una sola acción y el objetivo vive en una esquina | Exploración |
| **Sellos y fichas ilustrados en el HUD** | El progreso de la campaña se entiende de un vistazo, sin leer | Esquina superior derecha |
| **Dial de campanadas** | Las campanadas son el recurso más importante de la mesa; un dial con el sonido de campana las hace visibles y temáticas | Mesa |
| **Intervalo en lugar del valor de las Máscaras** | Mantiene la incertidumbre que define al palo sin engañar al jugador | Mesa |
| **Franja de patrones con estado** | Los patrones son objetivos secundarios; mostrarlos en progreso enseña a buscarlos | Mesa |
| **Vitrina con fichas ilustradas** | Comprar debe sentirse como mirar un escaparate: imagen, precio, efecto y motivo si no se puede | Tienda |
| **Diálogos de novela visual** | La historia es parte del género; retrato, nombre y texto progresivo sostienen la narrativa sin interrumpir el juego | Anfitriona |
| **Esc retrocede un paso y la pausa congela** | Evita perder el contexto y acciones dobles; el jugador siempre sabe cómo volver | Todo el juego |
| **El mapa como selección de nivel** | La campaña es lineal; las puertas que se abren con cada sello muestran el avance en el propio mundo | Pasillos |
| **Accesibilidad básica** | Teclado completo, foco visible, movimiento reducido, volumen por canal y lienzo escalable desde 1024 × 576 | Opciones |
| **«Ver baraja» sin orden ni Máscaras de la mano** | Ayuda a planificar sin regalar información que la mesa oculta | Inventario |

---

## 5. Utilidad de las interfaces

Cada interfaz responde a una pregunta del jugador. Detalle de cada pantalla en [NAVEGACION_PANTALLAS.md](NAVEGACION_PANTALLAS.md).

| Pregunta del jugador | Interfaz que la responde |
| --- | --- |
| ¿Adónde voy? | Objetivo en la esquina, puerta iluminada, placas de las puertas |
| ¿Qué puedo hacer aquí? | Pista única «E · …» y rombos de interacción |
| ¿Qué tengo? | HUD de sellos y fichas, inventario, «Ver baraja» |
| ¿Cuánto arriesgo? | Umbral, intervalo, dial de campanadas, presentación del crupier |
| ¿Qué acaba de pasar? | Revelado de Máscaras, desglose, resultado y recompensa |
| ¿Cómo se juega? | «Cómo jugar» en el inicio, la pausa y la mesa (**H**) |
| ¿Cómo paro o ajusto? | Pausa, opciones de sonido y movimiento reducido |

---

## 6. Utilidad de los personajes

Los personajes no solo decoran: cada uno enseña o exige algo distinto. Detalle en [CATALOGO_JUEGO.md](CATALOGO_JUEGO.md#2-personajes).

| Personaje | Utilidad en el juego |
| --- | --- |
| **Visitante** | El avatar del jugador; une exploración y mesa |
| **Anfitriona** | Tutorial y guía: entrega los recursos, ofrece el objeto inicial y anuncia la regla de la siguiente mesa |
| **Custodio** | Enseña las reglas básicas con un umbral bajo |
| **Recaudador** | Enseña a administrar recursos: pedir tiene coste |
| **Coleccionista** | Enseña a adaptarse: la baraja pierde cartas altas durante el encuentro |
| **Dueño** | Examen final: la misma estrategia deja de servir porque el umbral baja |
| **Otros visitantes** (previstos) | Pistas narrativas de errores comunes |

---

## 7. Quién conoce cada parte

Sirve para repartir la exposición y las preguntas según lo que cada uno hizo, no para medir participación: en la exposición, los tres hablan lo mismo.

| Integrante | Lo que diseñó o construyó |
| --- | --- |
| **Julio** | Diseño en Figma de la mesa y la baraja; mesa en Godot basada en Figma; dirección artística, arte del HUD y de la mesa; planificación de iteraciones y balance de la campaña |
| **Ariel** | Catálogo exacto de 24 cartas y fábrica de cartas; evaluación de manos, patrones y puntuación con pruebas; verificación del entorno y del ejecutable de la primera iteración |
| **Kenned** | Base del proyecto en Godot; acciones y estados de la mesa; recorrido del casino, vitrina, HUD, menús, pausa y diálogos; mapa de pasillos, objeto inicial y «Ver baraja»; guion de novela visual |

---

## 8. Preguntas probables

| Pregunta | Respuesta breve | Responde |
| --- | --- | --- |
| ¿Por qué no hay selección de nivel? | La campaña es lineal y corta; el casino hace de selector: las puertas se abren con los sellos y se puede volver a salas ya visitadas | Kenned |
| ¿Cómo sabe el jugador qué hacer? | Objetivo siempre visible, puerta iluminada, pistas de la anfitriona y una sola acción a la vez | Kenned |
| ¿Por qué esa paleta y esas fuentes? | Tema de casino antiguo, contraste de lectura y separación entre tono (títulos) y lectura (reglas) | Julio |
| ¿Cómo comprobaron que la interfaz se entiende? | Capturas a dos resoluciones, más de 200 pruebas automáticas de flujo y un piloto con personas planificado en I4-08 | Julio |
| ¿Qué aporta cada palo? | Una decisión distinta: multiplicar (Velas), corregir (Llaves), arriesgar menos (Relojes) y decidir a ciegas (Máscaras) | Ariel |
| ¿Cómo se calculan los puntos? | Suma de la mano por el multiplicador: 1 más los bonos de patrones, las Velas y los amuletos; una Quiebra da cero | Ariel |
| ¿Qué pasa si se pierde? | Termina el intento y empieza otro desde cero; los ajustes se conservan | Ariel |
| ¿Qué falta por hacer? | Arte definitivo de la entrada y los pasillos, el prólogo de novela visual y el duelo por LAN | Quien haya respondido menos |

---

## 9. Preparación

- [ ] Exportar una versión del juego y probarla en el equipo de la exposición (resolución del proyector incluida).
- [ ] Llevar capturas de respaldo por si falla la demo: generarlas con `tests/qa_interfaz_i4.gd` (vistas `inicio`, `pausa`, `opciones`, `mesa-mano`, `vitrina`, `oferta`, `baraja` y `pasillo`).
- [ ] Tener a mano la **demostración guiada** de la mesa (botón «DEMOSTRACIÓN GUIADA», fuera de la campaña): tres manos preparadas para enseñar revelado, Quiebra y desglose sin depender del azar.
- [ ] Imprimir o tener abiertos los diagramas de [navegación](NAVEGACION_PANTALLAS.md#2-diagrama-de-pantallas-implementadas) y del [bucle de juego](CATALOGO_JUEGO.md#1-el-bucle-de-juego).
- [ ] Ensayar con cronómetro: **5 minutos por persona**, sin pasarse; cada uno termina su bloque presentando al siguiente.
- [ ] Que cada integrante pueda responder al menos una pregunta de otro bloque.
