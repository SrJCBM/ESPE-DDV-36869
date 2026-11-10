# La Última Mesa · coordinación del desarrollo

**Siguiente objetivo:** implementar una primera mano del Custodio en Godot y, desde esa base, completar la mesa local con victoria, derrota y reinicio.

**Estado actual:** el prototipo de Figma, la baraja inicial, el reglamento y las familias LUM están preparados y revisados técnica y visualmente. La aceptación del equipo sigue pendiente. Todavía no existe un `project.godot` en `2P`; las instalaciones de los tres equipos y la implementación no están verificadas.

**Versión acordada:** Godot 4.7.2 estándar con GDScript y plantillas coincidentes. Su comprobación corresponde a I1-00.

## Material que ya tenemos

| Material | Estado | Evidencia |
| --- | --- | --- |
| Prototipo de interacción, cartas y reglamento | Completado como material de diseño; revisión de equipo pendiente | [Figma](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=13-103), [alcance y comprobaciones](Diseno/FIGMA.md) |
| Baraja inicial y recursos visuales | Preparado para implementar | 24 cartas iniciales, cuatro ilustraciones de palos, Máscara oculta y reverso; recursos en `Diseno/recursos/` |
| Biblioteca LUM | Preparada para implementar | Seis variantes de cartas y ocho de acciones en Figma; no son componentes de Godot todavía |
| Plan, arquitectura y casos de aceptación | Preparados | [Iteración 01](ITERACION_01.md), [patrones](ARQUITECTURA_Y_PATRONES.md), [entorno](ENTORNO_Y_HERRAMIENTAS.md) |

El prototipo usa repartos preparados. Sus comprobaciones no acreditan código, exportación, balance ni usabilidad del juego implementado.

## Responsabilidades de esta iteración

| Persona | Responsabilidad | Entrega concreta | Revisor |
| --- | --- | --- | --- |
| **Ariel Llumiquinga** | Datos de cartas y reglas de evaluación | Catálogo exacto, identidades de cartas, fábrica, estado de datos por intento y evaluador de valores, patrones y puntuación, con sus pruebas | Kenned; Julio comprueba que el desglose sea comprensible |
| **Kenned Sigcha** | Base del proyecto, acciones, estados e integración | Proyecto común; comandos de iniciar, pedir, devolver y plantarse; costes y legalidad; vista pública; victoria, derrota, reinicio y exportación | Ariel revisa reglas; Julio revisa el recorrido y los mensajes |
| **Julio Blacio** | Interfaz, recursos y experiencia de uso | Escenas de mesa y carta, tema común, ayuda, selección, controles, foco y desglose; primero con datos simulados y después con el controlador | Kenned revisa integración; Ariel revisa fidelidad al GDD |

Las pruebas acompañan al trabajo de cada responsable. Julio organiza el piloto de usabilidad y mantiene el tablero; Kenned coordina la integración y Ariel comprueba los cálculos de la versión integrada. Las fechas se fijarán según la disponibilidad real de los tres.

### Límites para evitar trabajo duplicado

- **Ariel:** `datos/`, fábrica, modelo de cartas y evaluador. Define la estructura de `EstadoPartida` antes de que los demás dependan de ella. Los Resources de definición no se alteran al cambiar un intento.
- **Kenned:** `dominio/comandos/`, `dominio/estados/` y `mesa/controlador_mesa.gd`. Aquí se aceptan o rechazan acciones y se descuentan campanadas una sola vez. La devolución de Llave pertenece al comando; Ariel revisa y prueba sus condiciones.
- **Julio:** escenas y scripts de presentación en `mesa/` y `cartas/`, temas y recursos. La UI solicita acciones y representa la vista del controlador; no modifica por su cuenta puntos, campanadas ni cartas.
- Kenned coordina los cambios de `project.godot`, entradas y configuración de exportación. Antes de editar archivos compartidos, avisar al equipo. Integrar cambios pequeños revisados.

Las rutas corresponden al proyecto previsto en `2P/Desarrollo/juego/`; todavía no son archivos implementados. El contrato de integración está en [ITERACION_01.md](ITERACION_01.md#contrato-mínimo-de-integración).

## Tablero de trabajo

**Pendiente:** no iniciado. **En curso:** trabajo iniciado por su responsable. **Por revisar:** existe una entrega que puede revisar otra persona. **Completado:** cumple el criterio, está integrado y tiene revisión y evidencia. **Bloqueado:** se registra el impedimento y quién puede resolverlo.

No se cambia un estado por intención de empezar ni por haber preparado una captura. Mantener una tarea principal en curso por integrante.

| ID | Tarea | Responsable | Revisor | Estado | Entrega que permite avanzar |
| --- | --- | --- | --- | --- | --- |
| I1-00 | Crear la base y comprobar los tres entornos | Kenned coordina; cada integrante comprueba su equipo | Revisión cruzada | Pendiente | Un solo proyecto común abre, ejecuta, exporta y corre el runner de pruebas; versiones registradas |
| I1-01 | Aceptar el diseño del Custodio y sus reglas | Julio | Ariel; Kenned revisa viabilidad | Por revisar | Coinciden acciones, costes, información oculta y puntuación con el GDD; observaciones registradas |
| I1-02 | Implementar catálogo y datos del intento | Ariel | Kenned | Pendiente | Se crean las 24 cartas sin duplicados y se conservan correctamente entre mano, mazo y descarte |
| I1-03 | Implementar comandos y fases | Kenned | Ariel | Pendiente | Las acciones legales avanzan y pagan una sola vez; las rechazadas no cambian el estado |
| I1-04 | Implementar efectos y puntuación | Ariel | Kenned | Pendiente | Cuatro palos y cinco patrones verificados; Kenned implementa la devolución y Ariel revisa sus casos |
| I1-05 | Construir la interfaz en Godot | Julio | Kenned; Ariel revisa reglas | Pendiente | Mesa, cartas y ayuda funcionan con vistas simuladas y después con la vista real del controlador |
| I1-06 | Integrar encuentro y reinicio | Kenned | Ariel y Julio | Pendiente | Victoria, derrota y reinicio funcionan; la meta se comprueba antes de declarar derrota con cero |
| I1-07 | Ejecutar piloto y corregir dificultades | Julio modera; Kenned toma notas | Los tres | Pendiente | Tres participantes, revisión con teclado y corrección comprobada de bloqueos; Ariel apoya las correcciones de reglas |
| I1-08 | Exportar y cerrar el incremento | Kenned | Ariel prueba en otro equipo; Julio revisa UI | Pendiente | Ejecutable Windows, evidencia del segundo equipo y registro de cierre con versión o commit |

Cada entrega registra: responsable, revisor, versión o commit, pasos, resultado esperado, resultado observado y pendientes. Una revisión de diseño no marca como completadas las tareas de implementación.

## Orden para empezar

1. **Kenned prepara la base común (I1-00).** Ariel y Julio la obtienen del repositorio y registran la comprobación de su propio entorno. Acordar el contrato de datos, acciones y vista antes de conectar módulos.
2. **Ariel revisa el diseño con Julio (I1-01) y comienza I1-02.** Confirmar el catálogo, los costes y el ejemplo de 102 puntos. Kenned prepara el diagrama de estados y las interfaces de comandos; su implementación se conecta después al modelo de datos.
3. **Julio avanza con la UI usando vistas simuladas (I1-05).** Puede construirla mientras Ariel desarrolla las reglas y Kenned las acciones. Los datos simulados respetan el contrato y no se confunden con un evaluador funcional.
4. **Integrar una primera mano en cuanto estén disponibles las partes necesarias.** Usar el ejemplo R11 descrito debajo. Corregir diferencias entre datos, acciones, cálculo y presentación antes de ampliar el recorrido.
5. **Completar el encuentro.** Añadir los casos restantes, las manos de Quiebra, las Llaves, los cierres y el reinicio. Después realizar el piloto y la exportación en otro equipo.

### Primera demostración que deben conseguir

**Iniciar → Llaves 4 y Relojes 6 → pedir una Máscara 8 oculta → plantarse → 102 puntos.**

- Iniciar reduce las campanadas de 10 a 9; pedir las reduce a 8; plantarse es gratis.
- Antes de resolver se muestran `9 + ?` y el intervalo `10–19`, sin filtrar el 8.
- Al resolver, los valores efectivos son 4, 5 y 8. Punto exacto y Ascenso producen `17 × (1 + 3 + 2) = 102`.
- La interfaz muestra el resultado calculado por el dominio y conserva recursos coherentes.

Esta demostración comprueba la conexión entre los tres trabajos; aún no cierra la iteración. Para aceptarla completa deben pasar R01–R20, el recorrido de tres manos con 221 puntos y tres campanadas restantes, victoria, derrota, reinicio, revisión de UI, piloto y prueba del ejecutable en otro equipo.

## Siguiente incremento

Después de aceptar la mesa local, el siguiente objetivo será una ronda por LAN con el mismo núcleo. La campaña, tienda, amuletos y nuevas salas siguen el orden del [plan general](PLAN_DE_TRABAJO.md). El acabado visual puede mejorar en cada ciclo según las pruebas.
