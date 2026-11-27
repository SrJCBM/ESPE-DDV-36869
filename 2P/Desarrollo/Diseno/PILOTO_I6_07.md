# Piloto I6-07 · Recorrido y lectura

Guía para las tres sesiones de [I6-07](../ITERACION_06.md#piloto-de-i6-07). Cada sesión dura de 30 a 40 minutos con una persona que no haya jugado ni visto el juego. Quien facilita lee las consignas tal cual, observa y anota, y no explica nada del juego.

## Qué queremos saber

1. Si una persona nueva se orienta desde la portada hasta la primera mesa sin ayuda.
2. Si entiende la Máscara: que su valor está oculto, qué indica el intervalo y cuándo se revela.
3. Si encuentra la tienda tras el primer sello.
4. Si sabe explicar qué cambiaría una compra en su próxima mano, leyendo el coste y el efecto del objeto.

La auditoría de pantallas del 26 de noviembre dejó cuatro dudas que esta prueba puede confirmar o descartar. Prestar atención a ellas sin mencionarlas:

| Hipótesis | Qué observar |
| --- | --- |
| La suma y el umbral están lejos (D2) | ¿Mira el 17 de la esquina antes de pedir? ¿Pregunta cuánto le falta? |
| El aviso «E · …» está lejos de la puerta (D5) | ¿Tarda en descubrir que E abre puertas y habla con personajes? |
| Los rótulos son pequeños (D1) | ¿Se acerca a la pantalla, entrecierra los ojos o no lee «1 oculta» ni «MAZO»? |
| La recompensa y la compra no muestran su efecto en la baraja (D12) | ¿Explica el objeto por su efecto o solo por su precio? |

## Preparación

- **Versión.** `juego/exportaciones/piloto_i6_07/LaUltimaMesa.exe`, exportada de `main` con las correcciones de la auditoría (335 pruebas en verde). Copiar la carpeta entera al equipo de la prueba. La carpeta `exportaciones/` no se sube al repositorio.
- **Partida nueva.** Antes de cada sesión, borrar `partida.json` y `ajustes.cfg` de `%APPDATA%\Godot\app_userdata\La Última Mesa\`. Así el menú muestra «Entrar al casino» y las opciones vuelven a sus valores iniciales.
- **Partida de respaldo.** `partida_con_sello.json`, en la misma carpeta, deja a Klein en el pasillo del Custodio con el primer sello y 20 fichas, como tras una victoria sin carta. Solo se usa si la persona no consigue el sello a tiempo: cerrar el juego, copiar el archivo como `%APPDATA%\Godot\app_userdata\La Última Mesa\partida.json` y elegir «Continuar». Se regenera con `godot --headless --path . --script res://tests/qa_piloto_i6_07.gd`.
- **Pantalla y sonido.** Ventana a 1280 × 720 o pantalla completa en un monitor de portátil, con auriculares o altavoces a volumen cómodo.
- **Registro.** Cronómetro y una copia de la hoja de registro. Con permiso, grabar la pantalla y la voz (OBS o la grabadora de Windows con Win + Alt + R). Si no hay permiso, solo notas.

## Guion de la sesión

**Antes de empezar (leer).** «Gracias por venir. Vamos a probar el juego, no a ti: si algo no se entiende, es un problema del juego. Te pediré algunas tareas. Por favor, piensa en voz alta: di qué miras, qué esperas que pase y qué te confunde. No podré explicarte cómo se juega, pero puedes usar todo lo que el juego te ofrezca.»

Si la persona se queda bloqueada más de dos minutos, decir solo «¿Qué estás buscando?». Si sigue bloqueada un minuto más, dar la pista mínima de la tabla y anotarla como **pista**.

| # | Consigna (leer tal cual) | Límite | Termina cuando | Pista mínima |
| --- | --- | :---: | --- | --- |
| 1 | «Empieza una partida nueva y llega a la primera mesa.» | 10 min | Se sienta con el Custodio («Tomar asiento») | «Las personas del casino pueden indicarte el camino.» |
| 2 | «Juega hasta resolver una mano en la que tengas una Máscara. Antes de plantarte, dime cuánto crees que vale tu mano.» | 10 min | Se planta o hace Quiebra con una Máscara en la mano | «El libro del Custodio está siempre disponible.» |
| 3 | «Intenta ganar esta mesa.» | 15 min | Gana el sello. Si se agota el tiempo o pierde el intento, usar la partida de respaldo | Ninguna |
| 4 | «Busca dónde se pueden comprar cosas.» | 5 min | Entra en el Gabinete de la anfitriona | «Mira el plano.» |
| 5 | «Elige un objeto que te interese. Sin comprarlo todavía, explícame qué cambiaría en tu próxima mano.» | 5 min | Da una explicación. Después puede comprarlo si quiere | Ninguna |

**Preguntas finales (leer).**

1. «Con tus palabras, ¿cómo se gana una mano?»
2. «¿Qué es una Máscara?»
3. «¿Qué pasa cuando se acaban las campanadas?»
4. «¿Hubo algo que buscaste y no encontraste?»
5. «Si pudieras cambiar una sola cosa, ¿cuál sería?»

## Qué anotar en cada tarea

- El **primer punto de duda**: el momento y lo que dijo o hizo.
- Si abrió el **plano** (M), la **ayuda** (H o «Cómo jugar») o el **inventario** (I), y en qué momento.
- Si necesitó **pista** y cuál.
- **Citas** literales que resuman cómo entiende algo.
- En la tarea 2, el valor que estimó frente al intervalo que mostraba el juego («5–14») y si sabía que la Máscara se revela al plantarse.
- En la tarea 5, si menciona el **efecto**, el **precio** o el **saldo**, y si su explicación es correcta.

## Hoja de registro

Copiar una por participante.

**Participante:** P_ · **Fecha:** ___ · **Facilita:** ___ · **¿Juega a juegos de cartas?** sí / no · **¿Grabación?** sí / no

| # | Tiempo | ¿Sin pista? | Primer punto de duda | Plano / ayuda / inventario | Notas y citas |
| --- | :---: | :---: | --- | --- | --- |
| 1 Llegar a la mesa | | | | | |
| 2 Resolver una Máscara | | | | | Estimó: ___ · El juego mostraba: ___ |
| 3 Ganar la mesa | | | | | Manos: ___ · Quiebras: ___ · ¿Respaldo?: ___ |
| 4 Encontrar la tienda | | | | | |
| 5 Explicar una compra | | | | | Objeto: ___ · ¿Efecto correcto?: ___ |

**Respuestas finales:** 1 ___ · 2 ___ · 3 ___ · 4 ___ · 5 ___

## Resumen de las tres sesiones

Rellenar al terminar y copiarlo en [ITERACION_06.md](../ITERACION_06.md#piloto-de-i6-07).

| Tarea | P1 | P2 | P3 | Resultado |
| --- | :---: | :---: | :---: | --- |
| 1 Llegar a la mesa | | | | |
| 2 Entender la Máscara | | | | |
| 3 Ganar la mesa | | | | |
| 4 Encontrar la tienda | | | | |
| 5 Explicar una compra | | | | |

Marcar cada casilla con **✓** si lo logró sin pista, **P** si necesitó pista y **✗** si no lo logró. Una tarea **se supera** si al menos dos de las tres personas la logran sin pista. Para cada tarea no superada, anotar la causa observada y el ajuste propuesto antes de añadir instrucciones, como pide el orden de trabajo de I6.
