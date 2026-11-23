# Primera iteración de La Última Mesa

**Objetivo:** que una persona pueda completar una mesa local del Custodio, comprender sus decisiones y reiniciar la partida.

**Estado al 13 de noviembre de 2026:** implementación jugable y revisión técnica disponibles, versión 0.1.0. I1-02 e I1-04 (Ariel) Completado; I1-01, I1-03, I1-05, I1-06 e I1-08 Por revisar. I1-00 sigue En curso por la verificación del tercer equipo; I1-07 queda Pendiente y lo realizará Julio. La base de Kenned `5d73d50` se conserva en el historial y el incremento se integra en `main` local. [Resultados y límites](Archivo/I1/REVISION_I1.md).

**Coordinación actual:** [README con responsables, estados y primera demostración](README.md).

**Repositorio:** [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869).

**Arquitectura:** un controlador coordina la mesa; un núcleo independiente de la interfaz valida acciones y calcula resultados. Las acciones se representan con Command, las fases con State y las notificaciones con Observer mediante señales. Los datos de definición permanecen separados del estado de cada intento.

**Tecnologías acordadas:** Godot **4.7.2 estándar**, GDScript, Windows y plantillas de exportación **4.7.2**. GUT **9.7.1** ya está incorporado con licencia y procedencia; sus pruebas de arranque pasan con Godot 4.7.2 en Kenned y Julio. Queda pendiente completar la homologación de I1-00.

**Especificación:** [diseño v2.4](../../1P/Diseno_Videojuego/Documento_Diseno_La_Ultima_Mesa_v2_4.docx).

**Lecturas de apoyo:** [arquitectura y patrones](ARQUITECTURA_Y_PATRONES.md), [instalaciones y plugins](ENTORNO_Y_HERRAMIENTAS.md), [plan general](PLAN_DE_TRABAJO.md).

**Diseño para revisión de I1-01:** [Mesa del Custodio en Figma y alcance del prototipo](Diseno/FIGMA.md). Hay 37 estados, cuatro recorridos de revisión y una baraja de 24 cartas rediseñada; su aceptación, implementación y validación con usuarios siguen pendientes.

## Acuerdos para iniciar

- [ ] Los tres integrantes confirman disponibilidad, responsables y revisor de cada tarea.
- [ ] Se fija un ciclo corto; una semana es la propuesta inicial y todavía no es una fecha comprometida.
- [ ] Cada integrante abre el repositorio, comprueba su entorno y registra el resultado en la tabla de la guía de instalaciones.
- [ ] Se lee el ejemplo completo del Custodio del GDD y se confirma que el juego vigente utiliza umbrales y palos propios.
- [ ] Se estima cada tarea. Si no cabe en la capacidad disponible, se divide el incremento conservando las reglas del GDD y se registra lo pendiente.

La revisión de alcance no cambia por sí sola umbral, meta ni reglas. Un resultado parcial se presenta como parcial; el primer incremento completo se acepta únicamente al cumplir los criterios de este plan.

## Alcance y restricciones

- Mesa local: umbral **17**, meta **200 puntos**, **10 campanadas**, baraja de **24 cartas**, cuatro palos y cinco patrones.
- Iniciar una mano reparte dos cartas y cuesta una campanada. Pedir cuesta una. Plantarse y devolver una Llave cuestan cero.
- Las reglas de cartas iniciales y pedidas son las mismas. Solo puede devolverse una Llave por mano y debe existir otra carta disponible distinta de la devuelta.
- La puntuación utiliza valores efectivos y el orden real de las cartas conservadas. Una Quiebra produce cero puntos.
- Las Máscaras conservan su valor oculto hasta plantarse en esta iteración. El texto, los tooltips y las etiquetas accesibles tampoco deben revelarlo.
- Se comprueba primero si se alcanzó la meta; tener cero campanadas no invalida una victoria ya conseguida.
- La exploración, tienda, amuletos, Lente, otras mesas y duelo LAN corresponden a incrementos posteriores. El núcleo queda preparado para recibir acciones desde la futura red.
- Los repartos preparados se usan para pruebas. La partida normal baraja; no se fuerza una victoria al jugador.
- Godot administra su Game Loop. Las campanadas se descuentan al aceptar acciones y nunca por frame, animación o conexiones de señales duplicadas.
- I1-00 tiene una base técnica entregada y comprobaciones parciales; I1-01 tiene material listo para revisión. Las reglas y la UI jugable siguen pendientes. Las cuatro pruebas actuales cubren el arranque, no R01–R20. El código del prototipo web es un antecedente; sus pruebas no acreditan esta implementación.

## Organización del equipo

| Integrante | Responsabilidad en la iteración | Primera entrega | Revisor |
| --- | --- | --- | --- |
| **Kenned Sigcha** | Base del proyecto, acciones, costes, estados e integración | **I1-00:** proyecto común, escena mínima, pruebas y exportación; comprobarlo en los tres equipos. Después, **I1-03:** iniciar, pedir, devolver Llave y plantarse | Ariel revisa reglas; Julio revisa el recorrido y los mensajes |
| **Ariel Llumiquinga** | Baraja, datos del intento, efectos, patrones y puntuación | **I1-02 e I1-04:** catálogo exacto de 24 cartas, identidades, fábrica, conservación de cartas y evaluación de una mano, con pruebas | Kenned; Julio comprueba que el desglose sea comprensible |
| **Julio Blacio** | Interfaz, cartas, controles, ayuda y experiencia de uso | **I1-01:** revisión del diseño; **I1-05:** mesa en Godot basada en Figma, primero con vistas simuladas y después con la vista real del controlador | Kenned revisa integración; Ariel revisa fidelidad al GDD |

La responsabilidad cubre toda la iteración. La base de Kenned y los módulos jugables ya están disponibles; el [tablero](README.md#tablero-de-trabajo) distingue entregas técnicas de aceptación humana. Devolver Llave pertenece a Kenned y Ariel revisa sus condiciones. Progresión, objetos, exploración y LAN corresponden a incrementos posteriores.

Quien implementa no es la única persona que acepta el resultado. La devolución de Llaves se implementa en los comandos de Kenned; Ariel revisa sus casos y mantiene las pruebas de evaluación. El controlador de Kenned publica una vista que oculta las Máscaras; Julio solo representa esa vista. El descuento de campanadas ocurre en un único punto de aceptación de la acción. El [README](README.md) detalla archivos, estados y orden de integración.

Usar un tablero con **Pendiente → En curso → Por revisar → Completado**. Cada tarea registra ID, responsable, revisor, dependencias, criterio de aceptación y evidencia. Mantener como máximo una tarea principal en curso por integrante. Al empezar una sesión, dedicar unos minutos a comunicar avance, siguiente acción y bloqueo; si surge un bloqueo, comunicarlo en ese momento.

## Archivos previstos

La estructura siguiente está implementada. La base de Kenned se amplió con datos, dominio, controlador, mesa, cartas, temas, recursos y pruebas. El libro de ayuda se encuentra en `mesa/guia_custodio.gd`; [juego/README.md](juego/README.md) explica cómo ejecutar y exportar.

```text
2P/Desarrollo/juego/
  project.godot
  export_presets.cfg
  principal/principal.tscn           # escena mínima existente de I1-00
  principal/principal.gd             # identificación de la base; sin reglas
  tests/test_arranque.gd             # cuatro pruebas existentes de arranque
  addons/gut/                       # dependencia común, versión fijada
  datos/cartas/carta_def.gd          # definición estática Resource
  datos/cartas/baraja_inicial.tres   # catálogo de 24 cartas
  dominio/carta_en_partida.gd        # identidad y datos propios del intento
  dominio/fabrica_cartas.gd          # creación centralizada desde el catálogo
  dominio/estado_partida.gd          # mano, mazo, descarte y recursos
  dominio/evaluador_mano.gd          # valores, cinco patrones y puntos
  dominio/comandos/                 # iniciar, pedir, devolver y plantarse
  dominio/estados/                  # preparado, decisión, resolución y final
  mesa/controlador_mesa.gd          # recibe comandos y publica una vista
  mesa/mesa.tscn
  mesa/mesa_ui.gd                   # dibuja la vista y emite solicitudes
  cartas/carta.tscn
  cartas/carta_ui.gd
  temas/mesa.tres
  tests/                           # pruebas GUT y repartos preparados
```

Las carpetas agrupan responsabilidades. Un script del dominio no consulta botones ni decide colores. La interfaz no modifica directamente puntos, campanadas o baraja. En la primera tarea se podrá reducir el número de archivos si las responsabilidades e interfaces siguen claras.

## Contrato mínimo de integración

| Elemento | Entrada y salida acordadas |
| --- | --- |
| CartaDef | `id`, `palo`, `valor_impreso`; no se modifica durante la partida |
| CartaEnPartida | `id_instancia` y referencia a CartaDef; los cambios del intento no afectan al catálogo |
| EstadoPartida | mazo, mano ordenada, descarte, campanadas, puntos, umbral, meta y uso de Llave |
| ComandoMesa | Interfaz `ejecutar(receptor: EstadoMesaBase) -> ResultadoAccion`; comandos concretos para iniciar, pedir, devolver y plantarse; `carta_id` solo al devolver |
| EstadoMesaBase | Receptor con `iniciar()`, `pedir()`, `devolver_llave(carta_id: String)` y `plantarse()`, todos con ResultadoAccion; cada estado habilita o rechaza esas operaciones |
| ControladorMesa | `procesar_comando(comando: ComandoMesa) -> ResultadoAccion`; `reiniciar() -> void`; `obtener_vista() -> Dictionary` |
| ResultadoAccion | `aceptado: bool` y `motivo: String`; un rechazo deja intactos cartas, puntos y campanadas |
| Vista para UI | fase, acciones habilitadas, campanadas, puntos/meta, umbral y cartas visibles; las Máscaras sin revelar usan `valor: null` |
| Eventos | `vista_actualizada(vista: Dictionary)` y `encuentro_finalizado(victoria: bool)`; un evento por acción aceptada, sin conexiones duplicadas al reiniciar |

Cada comando concreto encapsula una operación y la solicita al estado receptor; el mismo comando sirve para ratón, teclado y pruebas. El controlador recibe el comando, lo ejecuta contra el estado activo y publica el resultado. Los estados tienen comportamientos concretos de State: una lista de nombres o un enum aislado no demuestra por sí solo la aplicación del patrón. El diagrama de transiciones y sus guardas se documentan antes de implementarlas.

## Secuencia de trabajo

**Estado:** consultar el [tablero actualizado](README.md#tablero-de-trabajo). Los criterios conservan el alcance de aceptación; el código y la evidencia técnica no sustituyen el piloto ni la prueba en otro equipo.

| ID | Responsable propuesto / revisor | Depende de | Resultado que se acepta |
| --- | --- | --- | --- |
| I1-00 | Kenned coordina; los tres comprueban su equipo / revisión cruzada | Acuerdo de disponibilidad | Godot 4.7.2 y plantillas coinciden; proyecto mínimo abre, ejecuta y exporta en Windows; GUT ejecuta una prueba y detecta un fallo preparado |
| I1-01 | Julio / Ariel; Kenned revisa viabilidad | Reglas del GDD | Prototipo con estados, reglamento y LUM; revisión de correspondencia entre acciones, costes, meta, Máscaras y puntuación. Material listo para revisar |
| I1-02 | Ariel / Kenned | I1-00 | Catálogo exacto, identidades de cartas, fábrica y estado por intento; robar y descartar conserva las 24 cartas |
| I1-03 | Kenned / Ariel | I1-02 | Estados y comandos validan fases y costes; una acción rechazada no cambia el estado |
| I1-04 | Ariel / Kenned; devolución implementada en I1-03 | I1-03 | Efectos de cuatro palos, devolución legal de Llaves, Máscaras y cinco patrones comprobados con repartos preparados |
| I1-05 | Julio / Kenned | I1-01; contrato mínimo | Mesa y cartas Control/Containers con tema común; funciona primero con vistas simuladas y después con datos reales |
| I1-06 | Kenned / Ariel | I1-04 e I1-05 | Meta, campanadas, victoria, derrota y reinicio integrados; la UI se actualiza mediante señales |
| I1-07 | Julio y otro integrante / equipo | I1-06 | Piloto de usabilidad, revisión con teclado, ventanas y corrección de bloqueos observados |
| I1-08 | Kenned / Julio y Ariel | I1-07 | Ejecutable Windows abre en un segundo equipo; demostración y registro de cierre completados |

Las siguientes actividades humanas son la prueba de Ariel, la revisión del equipo y el piloto I1-07 que realizará Julio. La mesa integrada ya permite revisar R01–R20 y la demostración 102 → Quiebra → 119 = 221 puntos con siete campanadas. Después del piloto se corrigen los hallazgos y se registra el cierre de I1-08.

Para cada tarea de reglas: escribir primero un caso que falle por la funcionalidad ausente, comprobar ese fallo, implementar, volver a ejecutar y solicitar revisión. La UI requiere comprobación visual y manual además de pruebas de estado. Registrar un commit de alcance pequeño al completar una parte revisable; publicar solo los archivos de la tarea.

## Casos de aceptación de reglas

| ID | Caso reproducible | Resultado esperado |
| --- | --- | --- |
| R01 | Crear baraja inicial | Velas 1,2,4,6,8,10; Llaves 1,2,3,4,5,9; Relojes 1,2,4,6,7,9; Máscaras 1,3,5,7,8,10. Son 24 cartas con identidades distintas |
| R02 | Iniciar desde preparado | Reparte dos cartas, reduce 10 a 9 campanadas y entra en decisión |
| R03 | Pedir durante una mano abierta | Añade una carta al final sin gastar campanadas, incluido un Reloj; también en la última mano con cero campanadas |
| R04 | Iniciar con cero campanadas o resolver dos veces la misma mano | Rechaza; no reparte, no descuenta ni suma puntos otra vez |
| R05 | Plantarse | No gasta campanadas; revela, calcula y cierra una sola vez |
| R06 | Reloj de valor impreso 1 y otro de valor 6 | Valores efectivos 1 y 5 respectivamente |
| R07 | Llave inicial y Llave recién pedida | Se permite elegir una inicial antes de actuar o devolver la recién recibida; un único reemplazo por mano, añadido al final y sin nuevo coste |
| R08 | Solo queda como posible reemplazo la propia Llave devuelta | No se permite usarla como su propio reemplazo |
| R09 | Suma conocida 8 y una Máscara oculta | La vista muestra intervalo 9–18; no expone valor ni patrones/puntos que lo revelen |
| R10 | El mínimo posible excede el umbral y hay devolución legal de la Llave recién recibida | Avisa de Quiebra segura y bloquea Pedir sin cerrar la mano; ofrece la devolución y, al plantarse sin evitarla, cierra con cero puntos |
| R11 | 4 de Llaves, 6 de Relojes y 8 de Máscaras; plantarse con umbral 17 | Valores 4,5,8; Punto exacto + Ascenso; `17 × (1+3+2) = 102` |
| R12 | 6 de Velas, 7 de Relojes y 10 de Máscaras; plantarse con umbral 17 | Total efectivo 22; Quiebra y cero puntos |
| R13 | 2,4 de Velas; 3 de Llaves; 8 de Velas; plantarse | Total 17, tres Velas y Punto exacto; `17 × 7 = 119`; no activa Ascenso |
| R14 | Cada uno de los cinco patrones, y combinaciones | Punto exacto +3, Al filo +2, Ascenso +2, Mano larga +2 y Racha +2; cada patrón una vez; los dos primeros son excluyentes |
| R15 | Secuencia preparada R11 → R12 → R13 | 221 puntos, victoria al cerrar la tercera mano y siete campanadas restantes; respetar la baraja sin duplicados |
| R16 | Alcanza la meta al cerrar con cero campanadas | Victoria; si faltan puntos y no quedan campanadas, derrota |
| R17 | Agotar mazo y volver a barajar descarte | No incorpora cartas de la mano; si no puede robar, permite plantarse |
| R18 | Reiniciar después de victoria o derrota | Restablece 24 cartas, 10 campanadas, cero puntos y uso de Llave; no duplica señales |
| R19 | Crear dos intentos y cambiar uno | El otro y el catálogo inicial permanecen iguales |
| R20 | Mantener la mesa abierta a distintas tasas de frames sin actuar | No cambian cartas, recursos ni puntuación |

Para R14 se prueban estas condiciones por separado:

- Punto exacto: total efectivo igual al umbral.
- Al filo: total efectivo exactamente uno por debajo del umbral.
- Ascenso: al menos tres cartas y valores efectivos estrictamente crecientes en toda la mano, según orden conservado; no necesitan ser consecutivos.
- Mano larga: cinco cartas conservadas o más.
- Racha: las tres últimas cartas conservadas tienen el mismo palo.

Los tests se agrupan por tema: `test_baraja.gd` (R01,R17,R19), `test_acciones_estados.gd` (R02–R05,R07,R08,R10,R16,R18,R20), `test_puntuacion.gd` (R06,R11–R16), `test_vista.gd` (R09). Cuando un caso tenga condiciones diferentes, crear un test por condición para identificar el fallo.

## Criterios de UI y accesibilidad

- [x] Nombre de mesa, umbral 17, puntos actuales/meta 200 y campanadas se distinguen sin abrir ayuda.
- [x] Los botones anuncian su coste: Iniciar mano (1 campanada), Pedir (gratis), Plantarse (gratis), Devolver Llave (gratis, una vez por mano).
- [x] Los palos se reconocen por nombre y símbolo, además de color.
- [x] Una Máscara usa signo de interrogación e intervalo; ni tooltip ni etiqueta accesible contienen el valor oculto.
- [x] La resolución explica suma efectiva, patrones, multiplicador y puntos. Quiebra identifica su causa.
- [x] Tab/Shift+Tab recorre acciones en orden; Enter/Espacio activa; el foco es visible y se recupera al cerrar la ayuda. No usar acciones `ui_*` para reglas de juego.
- [x] Textos, cartas y acciones no se cortan en 1280×720 y 1920×1080; revisar también una ventana redimensionada.
- [x] Se adopta como criterio del proyecto contraste mínimo 4.5:1 para texto informativo sobre su fondo. Es una referencia de diseño tomada de WCAG, no una certificación del juego.
- [x] La primera versión comunica toda la información necesaria sin depender de audio o animaciones. Si se incorporan animaciones, deben respetar la opción de reducción prevista por el GDD.

## Ajuste de jugabilidad del 14 de noviembre

Julio eligió que las campanadas limiten las **manos** y no las cartas. El cambio está implementado y sustituye al coste por carta de la revisión del 13 de noviembre. Se mantienen meta 200, umbral 17, diez campanadas, 24 cartas y las bonificaciones.

| Acción | Campanadas | Consecuencia |
| --- | ---: | --- |
| Iniciar | −1 | Reparte dos cartas y abre una mano |
| Pedir | 0 | Añade una carta; arriesga la validez de toda la mano |
| Devolver Llave | 0 | Un reemplazo legal por mano, confirmado junto a la carta |
| Plantarse | 0 | Cierra la mano; revela, calcula y muestra el resultado |

Con cero campanadas la última mano se juega completa, pero no se abre otra. La derrota se comprueba después de resolver, con prioridad de la victoria si se alcanzó la meta. El reto pasa a ser **arriesgar una mano para conseguir patrones**, en lugar de pagar repetidamente por intentarlo.

- **Quiebra segura.** La mano nunca se cierra sola al robar. Si incluso el mínimo posible supera el umbral, la mesa lo avisa y bloquea Pedir; conserva Plantarse y una posible Llave de rescate. Si la información pública no demuestra la Quiebra, la Máscara sigue oculta.
- **Revelación.** Plantarse recorre: revelar Máscaras → mostrar suma → confirmar patrones y puntos → anunciar resultado. Se puede saltar con el botón de resultado, S o Esc, y es inmediata con movimiento reducido. La animación no descuenta recursos ni calcula dos veces; las cartas y la cuenta de puntos dan además una respuesta visual breve.
- **Patrones visibles.** La franja de la mano muestra los cinco patrones con su bono y progreso usando solo información pública: progreso, listo, pendiente de revelación o no cumplido. Al señalar uno se resaltan sus cartas; pulsarlo abre ejemplos.
- **Resultado.** La cuenta muestra total, multiplicador y aporte con los bonos debajo; en Quiebra, el exceso y cero puntos. El cierre separa ese resultado del resumen del intento y ofrece Volver a jugar.

### Balance medido con el coste por mano

Controlador real, 1.000 semillas por política y decisiones solo con la vista pública. Las políticas piden hasta que la estimación de la mano alcanza el valor indicado; no son estrategias óptimas.

| Política | Victorias en diez manos | Puntos medios |
| --- | ---: | ---: |
| Plantarse sin pedir | 8,8 % | 147,85 |
| Pedir hasta estimación 9 | 79,8 % | 212,78 |
| Pedir hasta estimación 11 | 89,3 % | 222,14 |
| Pedir hasta estimación 13 | 89,2 % | 223,57 |
| Pedir hasta estimación 15 | 76,7 % | 216,09 |

Pedir con moderación tiene una ventaja clara y arriesgar de más vuelve a costar. Se mantienen diez manos para aprender la mesa; siete u ocho quedan como variantes de dificultad para después del piloto (con «hasta 11», 49,7 % y 68,6 % de victorias). El script de ese diagnóstico no se subió al repositorio; para la campaña completa se usa `juego/tests/sim_campana.gd` ([balance de la campaña](BALANCE_CAMPANA.md)).

## Piloto de usabilidad

Julio modera y otro integrante toma notas. Buscar **tres personas que no hayan diseñado las reglas**, en sesiones breves de unos 10–15 minutos. Es un primer piloto cualitativo; no demuestra que el juego completo sea usable o esté equilibrado.

Explicar que se prueba el juego, no a la persona. Pedir que comente lo que piensa. Usar identificadores P01–P03 y pedir autorización antes de grabar. Las notas pueden ser suficientes.

| Tarea planteada a la persona | Qué observamos |
| --- | --- |
| Antes de jugar, explica qué intentas conseguir y qué recursos ves | Distingue meta, umbral y campanadas |
| Juega una mano y cuéntanos cómo decides continuar o terminar | Encuentra acciones, entiende su coste y recibe una explicación del resultado |
| Con una Máscara en la mano, explica qué información conoces y qué arriesgas | Reconoce incertidumbre y posibilidad de Quiebra |
| Juega una mano usando solo el teclado | Mantiene orientación y puede activar las acciones legales |
| Después del final, empieza otra partida | Encuentra reinicio y reconoce que los recursos se restablecieron |
| Explica la diferencia entre manos restantes y cartas que puedes pedir | Entiende que solo iniciar cuesta campanadas |
| Ante un patrón cercano, explica si pedir podría ayudar | Identifica el patrón y el riesgo de la carta siguiente |
| Ante el aviso de Quiebra segura, explica qué ocurre | Lo distingue de una Máscara todavía incierta |
| Al resolver, explica qué harías distinto | Vio el valor revelado antes de interpretar el resultado y aprende para el siguiente intento |

No indicar dónde pulsar antes de observar el intento. Si necesita ayuda, registrarla; no contar esa tarea como éxito independiente. Anotar tiempo como línea base, errores, palabras confusas y ayuda recibida. Al terminar preguntar qué resultó claro, confuso y divertido, por separado.

| Persona | Tarea | Sin ayuda / con ayuda / no completada | Tiempo | Error o duda observada | Cambio propuesto |
| --- | --- | --- | --- | --- | --- |
| Por completar | Por completar | Por completar | Por completar | Por completar | Por completar |

Si una persona queda bloqueada para iniciar, resolver o reiniciar, corregir y repetir el recorrido afectado. Una confusión repetida por dos participantes se prioriza antes de ampliar contenido. La ausencia de observaciones en tres personas no sustituye pruebas posteriores. La diversión y el balance se registran como hallazgos, no como conclusiones basadas solo en puntuaciones.

## Definición de terminado

- [x] R01–R20 cubiertos por pruebas y verificaciones registradas; sin fallos que invaliden la mesa.
- [x] Recorrido completo con victoria, derrota y reinicio.
- [x] State, Observer y Command identificados en clases, conexiones y pruebas; creación de cartas centralizada.
- [ ] Revisión cruzada completada, sin acciones que dependan de desactivar validaciones para funcionar.
- [x] Criterios técnicos de UI revisados; evidencia en REVISION_I1.md.
- [ ] Bloqueos del piloto corregidos y comprobados de nuevo, después de las sesiones de Julio.
- [ ] Ejecutable abierto y jugado en un segundo equipo, con versión exacta anotada.
- [ ] Registro de cierre con commit, versión, resultados, problemas y objetivo siguiente.

Formato breve para el cierre: **Objetivo / Terminado / Pendiente / Pruebas / Hallazgos de usabilidad / Decisiones / Siguiente incremento**. Después de aceptar la mesa local, el objetivo siguiente será una ronda LAN con la misma lógica.

## Fuentes

- [Diseño v2.4](../../1P/Diseno_Videojuego/Documento_Diseno_La_Ultima_Mesa_v2_4.docx): reglas y ejemplos del Custodio.
- [Arquitectura y patrones](ARQUITECTURA_Y_PATRONES.md): referencias de clase con páginas verificadas y aplicación al proyecto.
- [GUT](https://github.com/bitwes/Gut): pruebas GDScript; comandos y preparación en la guía de entorno.
- [Godot, navegación y foco](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html).
- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/basic/).
- [W3C, contraste mínimo](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).
- [GOV.UK, pruebas moderadas de usabilidad](https://www.gov.uk/service-manual/user-research/using-moderated-usability-testing).

El alcance, reparto y orden de tareas pertenecen al proyecto. Las fuentes respaldan mecanismos y métodos; las pruebas técnicas de reglas, estados y UI ya se ejecutaron y constan en REVISION_I1.md. El piloto de usabilidad y la validación en otro equipo siguen pendientes.
