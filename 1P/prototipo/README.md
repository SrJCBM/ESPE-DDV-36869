# La Última Mesa — prototipo para la exposición

## Abrir

Abre `index.html` con doble clic en Edge, Chrome o Firefox. Mantén la carpeta completa, incluido `assets`, junto al archivo. No requiere internet ni instalación. Usa F11 para proyectar a pantalla completa.

El reparto animado está activado desde el inicio: las cartas se deslizan desde la baraja hasta la mesa y se voltean al llegar. El control **Animaciones** permite desactivar los movimientos manualmente. Las cartas y sus totales siempre aparecen una por una.

Opcional: ejecuta `node serve.cjs` desde esta carpeta y abre http://127.0.0.1:8766. Detén el servidor con Ctrl+C.

## Qué mostrar en dos minutos

1. Presenta el objetivo: superar a la casa sin pasar de 21.
2. Pulsa Repartir. La apuesta descuenta 10 de las 100 fichas iniciales.
3. Observa el reparto alternado: jugador, casa, jugador, casa. Las caras y los totales se muestran conforme llegan las cartas.
4. Pide una carta o plántate. Al plantarte, la casa revela la carta oculta y pide las necesarias.
5. Explica el resultado y el cambio de saldo. Consulta Cómo jugar si hace falta.

Los controles de juego y reinicio se bloquean durante la animación. El saldo de la resolución y el historial se actualizan al terminar el turno de la casa. Las manos son aleatorias. Los naturales se resuelven después de su reparto y revelación.

Reiniciar sesión restaura 100 fichas y borra el historial, previa confirmación. Recargar también empieza una sesión nueva. No hay guardado persistente.

## Alcance

Blackjack básico individual: ases de 1 u 11, casa que se planta en todo 17, pago 3:2 para natural, empates, saldo y últimas cinco manos. Sin consumibles, amuletos, tienda, dividir, doblar ni seguro.

## Verificación

Ejecuta `node --test game.test.cjs presenter.test.cjs`.

19 pruebas aprobadas: 13 de reglas y 6 de presentación secuencial, bloqueo de acciones y resultados diferidos. Verificación en navegador: reparto animado sin revelar el total al pulsar, pedir mediante Enter, bloqueo durante el movimiento, revelación de la casa, actualización del saldo, ayuda y cierre con Escape. La mesa cabe en 1366 × 768 y no desborda horizontalmente en una pantalla estrecha.

## Archivos

- game.js: reglas y estado del blackjack.
- presenter.js: secuencia del reparto y estado visible durante animaciones.
- app.js: cartas, movimiento, controles e información de la sesión.
- styles.css: diseño y adaptación de pantalla.
- assets/fonts: fuentes locales Outfit y DM Sans, con sus licencias OFL.
- game.test.cjs y presenter.test.cjs: pruebas ejecutables con Node.
- serve.cjs: servidor local opcional.

Se aplicaron Taste, Redesign y Web Design Guidelines para tipografía, jerarquía, estados interactivos, teclado y una opción manual para desactivar el movimiento. El juego no carga recursos de internet.
