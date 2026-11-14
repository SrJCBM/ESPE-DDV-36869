# Arquitectura y patrones de La Última Mesa

Estas decisiones guían la implementación en **Godot 4.7.2 con GDScript**, conforme al diseño v2.4 y los tres PDF del curso. Estado al **13 de noviembre de 2026**: State, Command, Observer mediante señales y la fábrica simple están implementados y probados. Los módulos del dominio no dependen de la UI. [Revisión y evidencia](REVISION_I1.md).

## Material del curso y aplicación

Las páginas indicadas corresponden a la posición dentro del PDF, empezando en 1. Se conservaron copias idénticas de los tres archivos en Referencias/Clase para que el equipo pueda consultarlos desde el repositorio.

| Documento | Páginas relevantes | Aplicación al proyecto |
| --- | --- | --- |
| [Ingeniería de software en videojuegos](<../Referencias/Clase/Desarrollo_de_VideoJuegos-Ing_Software.pdf>) | 10 y 22: modelo iterativo incremental; 12–19: disciplinas, configuración y gestión; 40–41: verificación y QA | Ciclos cortos con análisis, diseño, implementación y pruebas; versión común y registro de cambios; evaluar funcionalidad, compatibilidad, jugabilidad, usabilidad y balance por separado |
| [Creación de videojuegos con un Game Engine](<../Referencias/Clase/3.Desarrollo_de_VideoJuegos Creacion.pdf>) | 4–10: programa principal y motor lógico; 12–22: datos; 25–29: módulos | Separar coordinación, reglas, datos e interfaz; distinguir catálogo, estado temporal y ajustes persistentes |
| [Patrones y motores de juegos](<../Referencias/Clase/Desarrollo_de_VideoJuegos Patrones -Motores de juegos.pdf>) | 3–6: patrones; 10–13: componentes y elección del motor | Aplicar patrones a problemas concretos y justificar cada dependencia del motor |

El primer documento contiene muchas diapositivas como imágenes; se revisaron visualmente el conjunto y las páginas citadas. Los ejemplos de plataformas, Unity y otros motores del material se adaptan al juego de cartas y a Godot. Sus ejercicios no añaden vidas, enemigos de plataformas ni APIs de Unity al alcance de La Última Mesa.

## Módulos y límites

| Módulo de clase | Implementación prevista | Responsabilidad y límite |
| --- | --- | --- |
| Programa principal | Escena principal y controlador de mesa | Inicia, coordina estados y conecta sistemas; Godot ejecuta el Game Loop |
| Motor lógico | Evaluador, comandos y estados | Valida acciones y calcula costes, patrones, puntuación y cierre |
| Datos estáticos | Resources de cartas, objetos y condiciones de mesa | Definiciones compartidas que se tratan como inmutables durante el juego |
| Datos temporales | EstadoPartida y cartas del intento | Mazo, descarte, mano, recursos, sellos e inventario mientras dura el intento |
| Datos persistentes | Servicio de ajustes, cuando se incorpore | Volumen, accesibilidad y preferencias previstas; la campaña sigue reiniciándose al cerrar según el GDD |
| Interfaz | Control, Containers, Theme y escenas de cartas | Presenta una vista autorizada y emite solicitudes; no modifica reglas |
| Red, en el siguiente incremento | Adaptador de comandos y vistas | Anfitrión valida; cada cliente recibe la información que le corresponda |

El módulo de datos no exige una base de datos, cuentas o servicios en nube para este alcance. La lógica por turnos recibe acciones; los frames actualizan la representación y, después, el movimiento de exploración. Una animación no concede puntos ni gasta campanadas por sí misma.

```mermaid
flowchart LR
    Persona[Jugador] --> UI[Interfaz de la mesa]
    UI -->|ComandoMesa| Control[Controlador]
    Control --> Estado[Estado activo]
    Estado --> Reglas[Reglas y evaluador]
    Reglas --> Datos[Estado del intento]
    Control -->|señal con vista autorizada| UI
    Catalogo[Catálogo de Resources] --> Fabrica[Fábrica de cartas]
    Fabrica --> Datos
    Red[Adaptador LAN futuro] -. ComandoMesa .-> Control
```

La vista que recibe la UI excluye el orden futuro del mazo y los valores de Máscaras todavía ocultos. El estado interno conserva esos datos para resolver; la UI no los recibe para después esconderlos.

## Patrones de clase y decisiones

| Patrón | Problema del juego y aplicación | Momento y evidencia |
| --- | --- | --- |
| **State** | Las acciones legales cambian según la fase. Un contexto delega a estados concretos preparado, decisión, resolución y final | Iteración 1. Diagrama de transiciones, clases y pruebas de aceptación/rechazo por fase |
| **Observer** | Cartas, indicadores e historial reaccionan al mismo cambio. El controlador emite señales y la UI se suscribe | Iteración 1. Una acción actualiza la vista una vez; reiniciar no duplica conexiones |
| **Command** | La misma intención debe poder provenir de un botón, teclado, prueba y después red. Cada comando concreto encapsula una operación y la ejecuta sobre el receptor del estado activo | Iteración 1. Comandos aceptados/rechazados reproducibles; adaptación LAN en la 2 |
| **Factory** | Crear cartas de manera consistente a partir del catálogo y asignar identidades de instancia | Iteración 1 con una fábrica simple. Se documenta como simplificación, no como una jerarquía completa de Factory Method |
| **Strategy** | Los crupieres comparten el ciclo de cartas y cambian reglas de entrada, comisión o cierre | Al integrar las mesas de campaña. Políticas intercambiables y pruebas del Recaudador, Coleccionista y Dueño |
| **Prototype** | Preparar variantes del intento sin alterar las definiciones originales al ajustar cartas | Al implementar modificaciones de baraja. Copia controlada de datos y prueba de independencia entre catálogo e intentos |
| **Singleton** | Un servicio de ajustes/audio necesita estar disponible entre escenas | Evaluar al incorporar ajustes. Autoload limitado a ese servicio y política de instancia única; el núcleo de cartas sigue siendo instanciable para pruebas |

La tabla distingue aplicación inmediata de incorporación posterior. Un patrón se acepta si se puede señalar el problema, el código que lo resuelve y la prueba que evita una regresión.

### State y flujo de la mesa

```mermaid
stateDiagram-v2
    [*] --> Preparado
    Preparado --> Decision: iniciar y pagar una campanada
    Decision --> Decision: pedir o devolver Llave legal
    Decision --> Resolucion: plantarse o Quiebra confirmada
    Resolucion --> Finalizada: alcanza meta o agota oportunidades
    Resolucion --> Preparado: faltan puntos y quedan oportunidades
    Finalizada --> Preparado: reiniciar con estado nuevo
```

Las guardas validan coste, disponibilidad de cartas y uso de Llave. Antes de confirmar una Quiebra demostrable se respeta la devolución legal de la Llave recién recibida. Resolución revela, calcula una sola vez y comprueba primero la meta. Cada estado puede rechazar un comando sin modificar recursos. El estado preparado tras reiniciar es el de un encuentro nuevo.

### Command y cierre irreversible

Command encapsula la solicitud, pero no obliga a ofrecer deshacer. Las reglas vigentes cierran la mano de forma irreversible y el jugador no puede retroceder tras conocer una Máscara. Registrar comandos para repetir pruebas tampoco significa habilitar una revancha de acciones dentro de la mano.

El anfitrión de LAN validará además remitente, turno y datos. Un identificador o valor enviado por el cliente será una solicitud para comprobar, no una puntuación autorizada.

### Resources, Prototype y separación de datos

Resources son contenedores de datos y pueden compartirse entre cargas. Se mantendrán como catálogo. Las fichas, puntos, posiciones en la baraja y marcas de revelación pertenecen a cada intento.

En la primera iteración, la fábrica crea estados propios a partir de definiciones. La incorporación posterior de Prototype debe precisar qué datos se copian y cuáles se comparten; usar una copia superficial sin comprobar referencias anidadas no acredita independencia. El test consiste en modificar una carta del intento A y verificar que el catálogo y el intento B no cambian.

### Autoload y Singleton

Godot advierte que Autoload **no impide crear otra instancia**. Facilita un servicio global, pero no garantiza por sí solo el Singleton estricto. El equipo documentará la política de instancia única si adopta ese servicio. Las reglas, la mano y los puntos no se convertirán en variables globales necesarias para ejecutar un test.

## Revisión de arquitectura por tarea

- [x] La regla puede comprobarse sin abrir la escena visual.
- [x] La UI recibe una vista y emite una intención; no consulta ni modifica el mazo privado.
- [x] Una solicitud ilegal deja el estado igual.
- [x] Las transiciones de State tienen una causa y una guarda verificables.
- [x] Las señales comunican resultados y no provocan cobros o puntuaciones duplicados.
- [x] Un intento nuevo tiene estado propio y conserva el catálogo.
- [x] Los patrones implementados coinciden con su nombre; las simplificaciones se reconocen.
- [x] La versión del motor y de los addons coincide con la guía de entorno.

La primera iteración se acepta con State, Observer, Command y la fábrica simple. Strategy, Prototype y el posible servicio global quedan ubicados en el plan de evolución; incorporarlos exige una necesidad y sus pruebas, no solo una mención en un diagrama.

## Fuentes técnicas

- [Godot, organización de escenas](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html): responsabilidades y comunicación entre escenas.
- [Godot, Resources](https://docs.godotengine.org/en/stable/classes/class_resource.html): datos compartidos y caché.
- [Godot, Autoload](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): alcance y límite respecto de Singleton.
- [Godot, multijugador de alto nivel](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html): autoridad, remitentes y mensajes dirigidos.

Las correspondencias de módulos y patrones son decisiones de este proyecto. Las fuentes oficiales de Godot se consultaron mediante Context7 y documentación oficial; el material de clase define los conceptos académicos de referencia.
