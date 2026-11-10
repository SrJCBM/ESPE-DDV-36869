# La Última Mesa

Proyecto académico de Desarrollo de Videojuegos, Universidad de las Fuerzas Armadas ESPE.

Esta carpeta conserva la conceptualización inicial y el prototipo histórico. Las reglas y el alcance actuales se consultan en el [diseño v2.4](../Diseno_Videojuego/Documento_Diseno_La_Ultima_Mesa_v2_4.docx) y el [plan de trabajo](../../2P/Desarrollo/PLAN_DE_TRABAJO.md).

**Integrantes:** Julio Blacio, Kenned Sigcha y Ariel Llumiquinga.

**Asignatura:** 36869-DESARROLLO DE VIDEOJUEGOS.

**Docente:** Hector Paul Pinto Pachacama.

## Decisión vigente

El videojuego se desarrollará en **Godot 4 con GDScript**. No se utilizarán Phaser ni otros frameworks web para implementar el juego. [Alcance de esta decisión](DECISION_GODOT.md).

El prototipo anterior de HTML, CSS y JavaScript está **descartado como base de desarrollo**. La carpeta `prototipo/` queda como referencia histórica. Sus reglas, casos de prueba, criterios de interfaz y recursos con licencia válida podrán revisarse para una reutilización selectiva. Esto no significa trasladar automáticamente su código ni dar por validadas las reglas en Godot.

## Contenido

- `DECISION_GODOT.md`: motor elegido, estado del prototipo y criterios de reutilización.
- `Entregables/La_Ultima_Mesa_Conceptualizacion.docx`: conceptualización actualizada.
- `Referencias/PROPUESTAS_BLACKJACK.md`: propuestas y alcance vigente.
- `prototipo/`: material histórico descartado como implementación.
- `REVISION_GODOT_MCP.md`: revisión de instalación e integración.

## Desarrollo previsto

Construir una nueva implementación con escenas de Godot para la mesa, cartas, tienda y encuentros. La interfaz usará nodos Control, contenedores y señales. GDScript resolverá las reglas y los estados del turno. Los amuletos y consumibles se definirán como datos mediante Resources.

Primero se validará una mano completa en Godot. Después se incorporarán encuentros y objetos de forma gradual. La validación inicial se hará en Windows y el destino final de exportación se confirmará durante el desarrollo.

Las capturas de Balatro son referencias académicas atribuidas. Los recursos reutilizados deberán conservar sus licencias. Todavía no se declara una implementación Godot del videojuego como terminada.
