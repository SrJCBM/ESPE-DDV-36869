# Decisión técnica vigente de La Última Mesa

Actualización: 9 de noviembre de 2026. Integrantes: Ariel Llumiquinga, Julio Blacio y Kenned Sigcha.

La especificación vigente es el [documento de diseño v2.4](../Diseno_Videojuego/Documento_Diseno_La_Ultima_Mesa_v2_4.docx). Conserva las reglas de v2.3 y añade tecnología y plan de desarrollo. El trabajo comienza con el [plan iterativo incremental](../../2P/Desarrollo/PLAN_DE_TRABAJO.md).

## Motor y lenguaje

El proyecto se desarrollará en Godot 4 con GDScript. La elección de Godot es definitiva para este trabajo. No se utilizarán Phaser, Vite, React ni otros motores o frameworks web para implementar el videojuego. Una eventual exportación web deberá generarse desde Godot.

## Estado del prototipo anterior

El prototipo HTML/CSS/JavaScript está descartado como base de desarrollo. Se conserva en `prototipo/` como referencia histórica. No constituye el proyecto activo y sus pruebas no acreditan el funcionamiento de una implementación Godot.

Podrán reutilizarse, después de revisarlos:

- La forma de documentar ejemplos y casos límite. Las reglas históricas de blackjack, pagos, ases y naturales no definen el juego vigente, basado en umbrales, patrones, campanadas y palos propios.
- La separación conceptual entre reglas, estado y presentación, sin trasladar automáticamente su código JavaScript.
- Las decisiones de legibilidad, bloqueo de acciones durante el reparto, mensajes de resultado y navegación por teclado.
- Recursos gráficos, textos y fuentes cuya utilidad y licencia se comprueben. Las capturas de Balatro siguen siendo referencias académicas, no recursos del juego.

La interfaz HTML/CSS, el servidor Node y las pruebas JavaScript no se incorporarán como tecnología de ejecución del juego. Las reglas deberán implementarse y comprobarse de nuevo en GDScript.

## Organización prevista en Godot

- Escenas reutilizables para la mesa, las cartas, la tienda y los encuentros.
- Nodos Control y contenedores para la interfaz, botones y mensajes.
- GDScript para las reglas actuales de cartas, patrones, campanadas y estados del turno, separados de la representación visual.
- Resources para definir amuletos, consumibles y encuentros como datos.
- Señales para comunicar acciones y resultados entre componentes.

El primer objetivo será validar una mesa local del Custodio y después comprobar una ronda LAN entre dos computadoras. Se ampliarán la progresión, los objetos y el duelo completo por incrementos. La exportación inicial será para Windows.

## Criterios de aceptación

Cuatro palos y cinco patrones correctos, costes de campanadas comprensibles, Máscaras sin filtración de valores, devolución única de Llaves, acciones bloqueadas fuera del turno y reinicio consistente. La entrega completa deberá permitir una campaña y un duelo LAN completos. Las pruebas del prototipo descartado son antecedentes y no resultados del juego nuevo.
