# La Última Mesa · coordinación del desarrollo

La mesa local del Custodio está implementada en `juego/`: 24 cartas, acciones y costes, cuatro palos, cinco patrones, resolución, victoria, derrota y reinicio. Versión **0.1.0**, Godot **4.7.2 estándar con GDScript**. La base de Kenned (`5d73d50`) se conserva en el historial.

El reglamento visual «El libro del Custodio» organiza ayuda, palos, puntuación y controles en cuatro páginas. Usa las ilustraciones originales y ejemplos preparados. La mesa mantiene información oculta, foco por teclado, confirmaciones y movimiento reducido durante la sesión.

La implementación se integra en `main` local. El piloto I1-07 y la aceptación humana siguen pendientes; una revisión técnica no sustituye esas actividades. [Resultados técnicos y límites](REVISION_I1.md).

## Responsabilidades

| Integrante | Responsabilidad | Entrega para revisión |
| --- | --- | --- |
| **Kenned Sigcha** | Base, acciones, costes, estados e integración | I1-00, I1-03, I1-06 e I1-08 |
| **Ariel Llumiquinga** | Baraja, datos, efectos, patrones y puntuación | I1-02 e I1-04 completadas; revisión de cálculos en la entrega integrada |
| **Julio Blacio** | Interfaz, cartas, controles, ayuda y experiencia de uso | I1-01 e I1-05; moderar y registrar I1-07 |

Las responsabilidades se mantienen aunque haya colaboración. La UI solicita acciones y representa la vista del controlador; no cambia cartas, puntos ni campanadas por su cuenta. La devolución de Llave corresponde al comando de Kenned y Ariel revisa sus condiciones.

## Tablero de trabajo

**Pendiente:** falta realizar. **En curso:** iniciado. **Por revisar:** existe una entrega para revisar. **Completado:** entrega técnica comprobada. **Bloqueado:** impedimento identificado. La aceptación de la iteración completa exige además el piloto y la prueba en otro equipo.

| ID | Tarea | Responsable | Estado | Evidencia o pendiente |
| --- | --- | --- | --- | --- |
| I1-00 | Base y comprobación de los tres entornos | Kenned coordina; cada integrante verifica su equipo | En curso | Base recibida e integrada; faltan comprobación de Ariel y aceptación humana. [Registro histórico](ENTREGA_I1_00.md) |
| I1-01 | Aceptar diseño y reglas del Custodio | Julio; Ariel y Kenned revisan | Por revisar | Figma, implementación y contraste técnico con GDD disponibles; aceptación del equipo pendiente |
| I1-02 | Catálogo y datos del intento | Ariel | **Completado** | 24 cartas exactas, identidades, fábrica, zonas, reciclaje e independencia comprobados |
| I1-03 | Comandos y fases | Kenned | Por revisar | Iniciar, pedir, devolver y plantarse implementados; costes y rechazos probados |
| I1-04 | Efectos y puntuación | Ariel | **Completado** | Cuatro palos, cinco patrones, Quiebra y ejemplos 102/119 comprobados |
| I1-05 | Interfaz en Godot | Julio | Por revisar | Mesa conectada, cartas, libro de ayuda, desglose, confirmaciones, teclado y movimiento reducido |
| I1-06 | Encuentro y reinicio | Kenned | Por revisar | Victoria, derrota, prioridad de meta y reinicio probados; recorrido 221 puntos / 7 campanadas |
| I1-07 | Piloto y correcciones de usabilidad | Julio modera; otro integrante toma notas | **Pendiente** | Julio realizará las sesiones con tres participantes y registrará hallazgos |
| I1-08 | Exportación y cierre | Kenned; Ariel prueba otro equipo y Julio UI | Por revisar | Exportación técnica local; faltan juego en otro equipo, hallazgos del piloto y cierre de aceptación |

Solo I1-02 e I1-04 pasan a Completado. Las demás entregas implementadas permanecen Por revisar para los compañeros; la revisión técnica registrada no se atribuye a una aprobación humana.

## Cómo probarlo

1. Abrir Godot 4.7.2 e importar `juego/project.godot`.
2. Pulsar **F5**. Se abre la mesa del Custodio y comienza un intento normal con baraja mezclada.
3. Usar **Cómo jugar** o **H** para consultar el libro. Tab / Mayús+Tab recorre los controles; Enter o Espacio activa y Esc vuelve a la mesa.
4. Para revisar resultados repetibles, activar **Demostración guiada** y confirmar. Es una baraja preparada, distinta de la partida normal.

La secuencia guiada es: iniciar, pedir, plantarse → 102; iniciar, pedir, plantarse → Quiebra; iniciar, pedir dos veces, plantarse → 119. Termina con **221 puntos, victoria y siete campanadas**. Reiniciar devuelve al juego normal.

Los comandos de pruebas y exportación están en [juego/README.md](juego/README.md). El protocolo de I1-07 y la tabla para anotar cada sesión están en [ITERACION_01.md](ITERACION_01.md#piloto-de-usabilidad). No anticipar la solución al participante antes de observar su intento.

## Documentos y materiales

- [Iteración 01 y criterios R01–R20](ITERACION_01.md).
- [Revisión técnica y pendientes de cierre](REVISION_I1.md).
- [Plan general](PLAN_DE_TRABAJO.md), [arquitectura](ARQUITECTURA_Y_PATRONES.md) y [entorno](ENTORNO_Y_HERRAMIENTAS.md).
- [Figma y alcance del prototipo](Diseno/FIGMA.md): referencia de diseño; sus repartos preparados no sustituyen pruebas del juego.

Después de aceptar I1, el siguiente incremento será una ronda por LAN con el mismo núcleo. Campaña, tienda, amuletos y otras mesas pertenecen a incrementos posteriores.
