# La Última Mesa · coordinación del desarrollo

La campaña local abre en el vestíbulo. La iteración 3 añade respuesta visual de las manos, ajustes de balance y movimiento reducido persistente. Incluye siete espacios conectados, tienda, inventario y cuatro mesas en Godot 4.7.2. [Iteración 02 y recorrido de prueba](ITERACION_02.md).

El pulido de presentación reduce el texto permanente a una indicación contextual. Los patrones resaltan las cartas con ratón o teclado; la cuenta resuelta explica los bonos y el final ofrece resumen y Volver a jugar. El libro y el desglose conservan los detalles.

El reglamento visual «El libro del Custodio» organiza ayuda, palos, puntuación y controles en cuatro páginas. Usa las ilustraciones originales y ejemplos preparados. La mesa mantiene información oculta, foco por teclado, confirmaciones y movimiento reducido durante la sesión.

Ariel completó I1-00 e I1-08 y compartió el ejecutable de I1, según la confirmación recibida el 18 de noviembre. Faltan los comentarios de I1-07. [Revisión de I1](Archivo/I1/REVISION_I1.md).

## Responsabilidades

| Integrante | Responsabilidad | Entrega para revisión |
| --- | --- | --- |
| **Kenned Sigcha** | Base, acciones, costes, estados e integración | I1-00, I1-03, I1-06 e I1-08 |
| **Ariel Llumiquinga** | Baraja, datos, efectos, patrones y puntuación | I1-02 e I1-04 completadas; revisión de cálculos en la entrega integrada |
| **Julio Blacio** | Interfaz, cartas, controles, ayuda y experiencia de uso | I1-01 e I1-05 y revisión de los comentarios de I1-07 |

Las responsabilidades se mantienen aunque haya colaboración. La UI solicita acciones y representa la vista del controlador; no cambia cartas, puntos ni campanadas por su cuenta. La devolución de Llave corresponde al comando de Kenned y Ariel revisa sus condiciones.

## Tablero de trabajo

**Pendiente:** falta realizar. **En curso:** iniciado. **Por revisar:** existe una entrega para revisar. **Completado:** entrega técnica comprobada. **Bloqueado:** impedimento identificado. La aceptación de la iteración completa exige además el piloto y la prueba en otro equipo.

| ID | Tarea | Responsable | Estado | Evidencia o pendiente |
| --- | --- | --- | --- | --- |
| I1-00 | Base y comprobación de los tres entornos | Kenned coordina, cada integrante comprueba su equipo | **Completado** | Ariel terminó su verificación. [Registro](Archivo/I1/ENTREGA_I1_00.md) |
| I1-01 | Aceptar diseño y reglas del Custodio | Julio; Ariel y Kenned revisan | Por revisar | Figma, implementación y contraste técnico con GDD disponibles; aceptación del equipo pendiente |
| I1-02 | Catálogo y datos del intento | Ariel | **Completado** | 24 cartas exactas, identidades, fábrica, zonas, reciclaje e independencia comprobados |
| I1-03 | Comandos y fases | Kenned | Por revisar | Iniciar, pedir, devolver y plantarse implementados; costes y rechazos probados |
| I1-04 | Efectos y puntuación | Ariel | **Completado** | Cuatro palos, cinco patrones, Quiebra y ejemplos 102/119 comprobados |
| I1-05 | Interfaz en Godot | Julio | Por revisar | Mesa conectada, cartas, libro de ayuda, desglose, confirmaciones, teclado y movimiento reducido |
| I1-06 | Encuentro y reinicio | Kenned | Por revisar | Victoria, derrota, prioridad de meta y reinicio probados; recorrido 221 puntos / 7 campanadas |
| I1-07 | Piloto de usabilidad | Ariel recopila, Julio revisa los hallazgos | **Pendiente de comentarios** | Registrar observaciones de los jugadores antes de cerrar la revisión. |
| I1-08 | Exportación de I1 para Windows | Ariel y Kenned | **Completado** | Ariel entregó el ejecutable, según confirmó Julio el 18 de noviembre. |

I1-00, I1-02, I1-04 e I1-08 están completadas. Las observaciones de jugadores y la revisión cruzada se registran por separado.

## Cómo probarlo

1. Abrir Godot 4.7.2 e importar `juego/project.godot`.
2. Pulsar **F5** para explorar I2. Para el piloto original, usar el ejecutable de Ariel o abrir `principal/principal.tscn` y pulsar **F6**.
3. Usar **Cómo jugar** o **H** para consultar el libro. Tab / Mayús+Tab recorre los controles; Enter o Espacio activa y Esc vuelve a la mesa.
4. Para revisar resultados repetibles, activar **Demostración guiada** y confirmar. Es una baraja preparada, distinta de la partida normal.

La secuencia guiada es: iniciar, pedir, plantarse → 102; iniciar, pedir, plantarse → Quiebra; iniciar, pedir dos veces, plantarse → 119. Termina con **221 puntos, victoria y siete campanadas**. Reiniciar devuelve al juego normal.

Los comandos de pruebas y exportación están en [juego/README.md](juego/README.md). El protocolo de I1-07 y la tabla para anotar cada sesión están en [ITERACION_01.md](ITERACION_01.md#piloto-de-usabilidad). No anticipar la solución al participante antes de observar su intento.

## Documentos y materiales

- [Iteración 01 y criterios R01–R20](ITERACION_01.md).
- [Iteración 02: campaña y revisión con Damián](ITERACION_02.md).
- [Iteración 03: pulido, balance y deuda técnica](ITERACION_03.md), con el estado de cada mejora.
- [Iteración 04 · Interfaz y recorrido del casino](ITERACION_04.md): vitrina, corredor, HUD, mesa, diálogos y menús. Cerrada en código; falta el piloto.
- [Iteración 05 · Pasillos de los jefes](ITERACION_05.md): en curso. Primer tramo jugable (entrada, vestíbulo y pasillos del Custodio y del Recaudador), elección inicial de objeto, «Ver baraja» y la variante de la Vela de Racha ×2.
- [Iteración 06 · Lectura y presencia narrativa](ITERACION_06.md): portada ilustrada, visitantes en el recorrido y revisión de la carga de texto.
- [Balance de la campaña y del Recaudador](BALANCE_CAMPANA.md).
- [Revisión técnica y pendientes de cierre](Archivo/I1/REVISION_I1.md).
- [Plan general](PLAN_DE_TRABAJO.md), [arquitectura](ARQUITECTURA_Y_PATRONES.md) y [entorno](ENTORNO_Y_HERRAMIENTAS.md).
- [Figma y alcance del prototipo](Diseno/FIGMA.md): referencia de diseño; sus repartos preparados no sustituyen pruebas del juego.
- [Dirección artística](Diseno/DIRECCION_ARTISTICA.md) para generar arte, pantallas y sonido coherentes.
- [Archivo de I1](Archivo/README.md) con las revisiones y evidencias históricas.
