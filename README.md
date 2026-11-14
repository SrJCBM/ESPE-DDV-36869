# ESPE Desarrollo de Videojuegos

Repositorio académico del curso **36869-DESARROLLO DE VIDEOJUEGOS** de la Universidad de las Fuerzas Armadas ESPE.

**Docente:** Hector Paul Pinto Pachacama.

## Proyecto vigente

**La Última Mesa** es un juego de cartas y estrategia con exploración 2D, umbrales, campanadas y cuatro palos propios. Se desarrollará en **Godot 4 con GDScript**, con campaña individual y duelo 1 contra 1 por LAN.

El prototipo web anterior está descartado como base. Se conserva como referencia histórica para revisar reglas, casos de prueba y posibles recursos reutilizables.

- [Documentación del proyecto](1P/Tarea%201/README.md)
- [Decisión técnica y reutilización](1P/Tarea%201/DECISION_GODOT.md)
- [Comparación de motores y guion vigentes](1P/Tarea2_Motores/README.md)
- [Diseño del videojuego v2.4 y material de exposición](1P/Diseno_Videojuego/README.md)
- [Plan iterativo incremental](2P/Desarrollo/PLAN_DE_TRABAJO.md)
- [Primera iteración y guía del equipo](2P/Desarrollo/ITERACION_01.md)
- [Instalaciones, MCP y plugins](2P/Desarrollo/ENTORNO_Y_HERRAMIENTAS.md)

La revisión de la instalación de Godot y del MCP se registra en `1P/Tarea 1/REVISION_GODOT_MCP.md`.

## Organización

El material del primer parcial está agrupado en `1P/`:

- `Tarea 1/`: conceptualización, referencias y prototipo histórico.
- `Tarea2_Motores/`: presentación de Godot y guion vigente en PDF y Markdown.
- `Diseno_Videojuego/`: documento de diseño v2.4 y material de exposición.
- `Calificados/`: entregas evaluadas y documentos de referencia, conservados como antecedentes.

El segundo parcial se trabaja en `2P/`:

- `Desarrollo/`: plan general, primera iteración, arquitectura y entorno común. La versión acordada es Godot 4.7.2 con GDScript.
- `Referencias/Clase/`: material docente sobre ingeniería de software, creación con motores y patrones de diseño.

La mesa local del Custodio está implementada en `2P/Desarrollo/juego/`, versión 0.1.0, sobre la base de Kenned (`5d73d50`). Incluye cartas, reglas, estados, interfaz, libro de ayuda, victoria, derrota y reinicio. El incremento se integra en `main` local. Las pruebas técnicas están registradas en la [revisión I1](2P/Desarrollo/REVISION_I1.md); el [tablero](2P/Desarrollo/README.md) mantiene pendientes la aceptación humana, el piloto de Julio y la comprobación en otro equipo. [Ejecutar y exportar](2P/Desarrollo/juego/README.md).

Se conserva una versión vigente por entrega, junto con sus formatos editables y material de apoyo. Las versiones superadas y las carpetas temporales de generación y revisión se retiraron durante la limpieza del 9 de noviembre de 2026.
