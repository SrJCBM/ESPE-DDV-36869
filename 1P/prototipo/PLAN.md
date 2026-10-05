# Plan de implementación — La Última Mesa

Objetivo: ejecutar el blackjack básico aprobado en PROPUESTAS_BLACKJACK.md, sección 7.
Arquitectura: reglas independientes en game.js, interfaz en app.js, documento index.html y estilos styles.css. JavaScript clásico permite abrir index.html sin servidor ni internet. Sin dependencias.

1. Escribir y ejecutar pruebas Node de ases, naturales, pagos, empate, exceso, 17 suave y bloqueo de acciones fuera de turno.
2. Implementar el motor y comprobar las pruebas.
3. Construir la mesa accesible, adaptable y con reglas consultables.
4. Verificar interacción real en navegador, teclado y tamaño móvil; preparar README e instrucciones de exposición.

Revisión: saldo insuficiente, pulsaciones repetidas, cartas ocultas, manos largas y reinicio deben tener comportamiento definido. Reinicio mediante confirmación nativa. Las reglas completas y el alcance están aprobados; ejecución directa en esta sesión.
