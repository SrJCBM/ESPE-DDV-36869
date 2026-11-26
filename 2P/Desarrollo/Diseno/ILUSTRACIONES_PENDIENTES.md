# La Última Mesa · Inventario de ilustraciones

**Estado al 25 de noviembre de 2026.** El arte definido en el [guion versión 4](GUION_PROLOGO_Y_DIALOGOS.md) está hecho. En Godot ya se ven las diez notas jugables, las CG del Custodio, el Recaudador y la Coleccionista, las figuras del recorrido y la placa de diálogo. El arte de los eventos, los finales y los tres puntos de examen futuros está disponible por id. Los recuerdos de I5-11 se encargarán con el guion de Kenned.

**Estilo:** el de la [dirección artística](DIRECCION_ARTISTICA.md). Grabado de libro antiguo de finales del siglo XIX, líneas finas, sombreado por tramado. Paleta de verde profundo `#0B2119`, latón `#D5B578` y marfil `#F1E4C9`. Para la novela visual se pide **más contraste, más negro y menos dorado**. Sin texto incrustado: rótulos, cartas y etiquetas se escriben en Godot para poder traducirlos. **Nada de sangre ni heridas:** el horror es frío, porcelana y silencio.

> **Personajes recortados.** Entregar retratos, expresiones y figuras de personaje con canal alfa, sin viñetas, sombras proyectadas ni marcos incrustados. La novela visual muestra el recorte directamente sobre el escenario y atenúa al personaje que escucha. Los fondos y las CG cubren el lienzo completo.

## Índice

1. [Formatos](#formatos)
2. [Arte que ya existe](#arte-que-ya-existe)
3. [El tiempo en las ilustraciones](#el-tiempo-en-las-ilustraciones)
4. [Fondos](#fondos)
5. [Ilustraciones de novela visual (CG)](#ilustraciones-de-novela-visual-cg)
6. [Hojas de expresiones](#hojas-de-expresiones)
7. [Notas examinables](#notas-examinables)
8. [Figuras de exploración](#figuras-de-exploración)
9. [Piezas de interfaz](#piezas-de-interfaz)
10. [Orden de encargo](#orden-de-encargo)

---

## Formatos

| Tipo | Tamaño | Formato | Notas |
| --- | --- | --- | --- |
| Fondo de exploración | 1672 × 941 o equivalente 16:9 | `.webp` | Los fondos jugables (`casino/arte/*.webp`) necesitan el suelo libre en la zona caminable. |
| CG de novela visual | 1920 × 1080 | `.webp` | Se escala al lienzo de 1440 × 810. Dejar libre el tercio inferior: ahí va el cuadro de texto. |
| Retrato de expresión | 900 × 1200, **fondo transparente** | `.webp` o `.png` con alfa | Busto en proporción 3:4. Se usa en escena (unos 600 px de alto en el lienzo de 1440 × 810) y como cara en el cuadro de texto. **Todas las expresiones de un personaje con el mismo encuadre y la misma escala**, para poder cambiarlas sin que el personaje salte. Recorte limpio del pelo y la ropa, sin halo claro alrededor; la figura llega hasta el borde inferior de la imagen. La cara en el tercio superior, centrada. |
| Figura de exploración | Hasta 175 px de ancho para figuras individuales y 340 px para grupos o muebles | `.webp` con alfa | Pies en el borde inferior y escala en Godot según el espacio. |
| Tarjeta de capítulo | 1920 × 1080 | `.webp` | Fondo de título; el texto lo pone el juego. |

Rutas que ya lee el juego (I5-10): **`juego/historia/ilustraciones/<id>.webp`** para fondos, CG y tarjetas, y **`juego/historia/retratos/<personaje>_<expresion>.webp`** para las expresiones (por ejemplo `anfitriona_seria.webp` o `dueno_interes.webp`). Basta con guardar el archivo con su id para que aparezca; mientras falte, el juego muestra «Ilustración pendiente» o el retrato general. Ids de personaje: `klein`, `anfitriona`, `custodio`, `recaudador`, `coleccionista`, `dueno`, `ignacio` y `farolero`.

## Arte que ya existe

| Pieza | Archivo | Uso en la novela visual |
| --- | --- | --- |
| Vestíbulo, tienda, Custodio, Recaudador, Coleccionista, Dueño, corredor | `casino/arte/<sala>.webp` | Fondos de las escenas en esas salas. |
| Retratos originales | `casino/arte/personaje_*.webp` y `recursos/arte/custodio-grabado.png` | Referencias de identidad y respaldo cuando falta un recorte neutral. |
| Figuras | `casino/arte/figura_*.webp` | Exploración. |
| Objetos de la oferta | `casino/arte/objeto_*.webp` | Iconos de la oferta inicial; ya están en el juego. |
| Taller de Ferrer | [`taller_ferrer.webp`](../juego/historia/ilustraciones/taller_ferrer.webp) | Fondo de P2–P3 a 1920 × 1080. |
| Hojas de expresiones | [`historia/retratos/`](../juego/historia/retratos) | 70 recortes a 900 × 1200 con alfa. Incluyen las 45 expresiones del elenco principal, 5 edades de Klein y 20 retratos de visitantes. |
| Klein, movimiento | [`klein_movimiento.webp`](../juego/casino/arte/klein_movimiento.webp) | Exploración. Hoja transparente con 8 filas y 5 columnas, celdas de 175 × 224. De arriba abajo: este, sureste, sur, suroeste, oeste, noroeste, norte y noreste. |

El taller, el retrato de Klein y su hoja de movimiento fueron generados con ImageGen. El taller conserva el tercio inferior oscuro para el cuadro de texto. El sprite reutiliza el diseño del retrato y alinea los pies dentro de cada celda.

---

## El tiempo en las ilustraciones

El guion establece que el tiempo de la Casa deforma a la gente. Son reglas para todos los encargos:

| Efecto | Cómo se dibuja | Quién lo muestra |
| --- | --- | --- |
| **Envejecer por campanadas** | La misma cara con más años: canas, arrugas, manchas en las manos, nudillos hinchados. La ropa no cambia. | Klein en los espejos (27, 35, 45 y 60 años); Ignacio en la apertura. |
| **Desfase de época** | Ropa de su siglo, pero desteñida, como un retrato expuesto al sol. Cuanto más antiguo, menos color y más tramado gris. | Jugadores del vestíbulo, Doña Amparo, los crupieres. |
| **Rostros que parpadean** | Dos versiones de la misma expresión, una joven y otra anciana, con idéntico encuadre para alternarlas. | La anfitriona (`joven` y `anciana`); la Coleccionista bajo la semimáscara. |
| **Mezcla de siglos** | Prendas de varias épocas superpuestas o cosidas; partes del cuerpo de edades distintas. | El Custodio (ropa de cuatro épocas), el Recaudador (manos jóvenes y cara vieja), la Coleccionista (media cara de niña y media de anciana). |
| **Porcelana** | Piel blanca, lisa y brillante como loza, sin poros, que avanza desde la punta de los dedos hacia la cara. A veces con una grieta fina. Nunca rota de forma sangrienta. | Quien pierde: visitantes, jugadores del vestíbulo, Ignacio, Klein en el fin del intento. |

---

## Fondos

Prioridad: **1** = necesario para el prólogo; **2** = eventos y decisiones; **3** = finales.

| Id | Prioridad | Escena | Descripción |
| --- | :---: | --- | --- |
| `sala_dueno_noche` | 1 | P0 | **Disponible.** La sala del Dueño vista desde detrás de la silla del visitante, en plano medio bajo. Suelo de mármol negro con un gran disco solar de rayos de latón, gastados donde la gente apoya los pies y con arañazos como de uñas. Al fondo, la verja del alba: barrotes con forma de rayos que nacen de un sol a medio esconder; tras ellos, una franja fina de luz rosada que no entra. Mesa de nogal con tapete negro y ribete dorado. Dos candelabros de siete brazos casi consumidos, con la cera chorreada hasta el suelo. Del techo cuelgan campanas sin badajo. En las paredes laterales, hileras de Máscaras de porcelana colgadas como trofeos, con los ojos cerrados. Negro y latón; un único punto rosado al fondo. |
| `negro_con_grabado` | 1 | P1 | **Disponible.** Tarjeta del capítulo: una invitación lacrada sobre terciopelo negro, con el lacre de un sol tras una verja. A su lado, una Máscara de porcelana boca abajo. Centro libre para el título. |
| `taller_ferrer` | 1 | P2–P3 | **Disponible y verificado en Godot.** Relojería estrecha de puerto, de noche. Mostrador de nogal rayado con una lámpara de aceite de pantalla verde sobre piezas desmontadas. Pared entera de relojes de péndulo, cucús y de mesa, **todos a las doce menos un minuto**. Banco con lupa articulada y pinzas. Estanterías medio vacías: faltan los relojes buenos. En la vitrina, un papel de embargo clavado (sin texto legible). Catre deshecho y maleta pequeña en un rincón. Ventana con niebla y halo de farola. Rótulo de la tienda visto del revés (sin letras: solo la forma del cartel). |
| `calle_niebla` | 1 | P4 | **Disponible.** Calle empedrada del puerto de Corvera con niebla a la cintura. Fachadas estrechas con balcones de hierro; tras algunas ventanas, siluetas inmóviles que miran. Al fondo, el mástil de un velero. Farola de gas con un halo enorme y, a sus pies, charcos que reflejan una luz dorada de interior que no corresponde, como si bajo el agua hubiera otro salón. Gris azulado y verde muy oscuro; el único punto cálido es la farola. |
| `fachada_casa` | 1 | P5 y sala de entrada | **Disponible.** Fachada neoclásica de piedra oscura, demasiado grande para la calle, entre dos almacenes que parecen de juguete. Cuatro pilastras con capiteles de latón; cornisa con espacio para el rótulo (lo pone el juego). **Sin ventanas:** marcos tapiados con mármol verde y, en relieve suave, rostros con los ojos cerrados. Puerta doble de nogal con luz dorada por la rendija, escalinata de tres peldaños, reloj a la medianoche exacta y dos farolas. La niebla rodea el edificio sin tocarlo. **Debe servir como sala jugable:** acera libre desde la mitad inferior. La entrada jugable comparte este fondo con el prólogo. |
| `sueno_hospicio` | 2 | E2 | **Archivo disponible.** Patio del hospicio de Santa Úrsula en un recuerdo. Muros grises, ropa tendida rígida por la escarcha, una fila de doce niños con batas grandes, una monja de espaldas. Todo desenfocado en los bordes, como una fotografía vieja; las caras de los niños sin rasgos. Tramado gris; ningún color salvo un toque verde en el fondo, donde está la levita de Ignacio. |
| `pasillo_custodio` | 2 | Exploración · primer sello | **Disponible.** Relojes, péndulos y placas de latón. Dejar a la vista el acceso oeste desde el vestíbulo, la mesa al norte y la salida al este. |
| `pasillo_recaudador` | 2 | E2, M2 | **Disponible.** Arte definitivo del pasillo (I5): granate, libros mayores, balanzas y una **caja fuerte empotrada con cristal** en la pared, donde Klein se ve reflejado. Banco de madera junto a la pared. |
| `pasillo_coleccionista` | 2 | E4 | **Disponible.** Arte definitivo del pasillo (I5): violeta, vitrinas con piezas expuestas y **una vitrina grande con cristal limpio** donde aparecen los reflejos del evento. Una rendija en el muro de piedra por la que puede entrar luz. |
| `pasillo_dueno` | 2 | Exploración · tres sellos | **Disponible.** Mármol oscuro, latón y una primera línea de amanecer tras la verja. La pantalla jugable se abre con tres sellos y solo conecta con la Coleccionista y la mesa del Dueño. |
| `vestibulo_amanecer` | 3 | Final A | **Archivo disponible.** El vestíbulo actual con luz blanca entrando por todas las rendijas del mármol. Los jugadores de porcelana deshaciéndose en polvo blanco. El reloj marca las seis. |
| `dormitorio_klein_viejo` | 3 | Final C | **Archivo disponible.** Dormitorio pequeño y ordenado de un relojero viejo: cama de hierro, una cómoda con los cajones entreabiertos llenos de sobres negros, relojes en todas las paredes, una ventana con niebla. Sirve de fondo antes del CG final. |
| `verja_alba` | 3 | Final A | **Archivo disponible.** La verja del alba abierta, vista desde dentro. Al otro lado, el puerto de Corvera al amanecer: muelle, mástiles y un cielo pálido, casi blanco, que entra en la sala y borra el tramado del mármol. En la oscuridad de la sala, las Máscaras de las paredes con los ojos abiertos. |

---

## Ilustraciones de novela visual (CG)

Ilustraciones a pantalla completa para la novela visual. Las escenas ya implementadas las cargan por id desde `juego/historia/ilustraciones/<id>.webp` y muestran «Ilustración pendiente» cuando falta el archivo. Las CG de eventos y finales se incorporarán al montar esas escenas. La galería se reserva para un lote posterior.

**Recuerdos de los jefes · I5-11.** Las preguntas posvictoria podrán abrir flashbacks. El encargo de arte se añade cuando Kenned escriba cada escena. Registrar el id del fondo o CG, el jefe y la pregunta que la activa, la acción que se ve y su prioridad. Los totales de este documento se actualizan al definir esas piezas. [Tarea I5-11](../ITERACION_05.md#i5-11--menús-posvictoria-de-los-jefes)

| Id | Prioridad | Escena | Descripción |
| --- | :---: | --- | --- |
| `cg_ignacio_mascara` | 1 | P0 | **Disponible.** Una mano envejecida y temblorosa sobre el tapete negro. Tres cartas abiertas: una Llave de 2, un Reloj de 7 y una Máscara recién volteada. El rostro de Ignacio se representa en porcelana grabada con la cinta granate y la filigrana del palo de Máscaras. Las llamas de los candelabros se inclinan hacia la carta. En el dorso de la mano, la piel se vuelve porcelana desde la punta de los dedos. |
| `cg_invitacion` | 1 | P3 | **Disponible.** Primer plano de dos manos manchadas de aceite que sostienen un sobre negro de papel grueso con el lacre del sol tras la verja. Sobre la palma, una ficha de marfil ennegrecido con una campana grabada. Detrás, desenfocado, el halo de la farola en la niebla. |
| `cg_libro_mayor` | 2 | Recaudador | **Integrada.** Libro mayor abierto bajo una lámpara de pantalla granate. Columnas de tinta negra y roja con letra de contable (ilegible salvo una línea subrayada, que el juego superpone). Sello negro de la Casa al margen. La sombra de las gafas del Recaudador y la mano de Klein abierta, sin tocar el papel. |
| `cg_vitrina_ignacio` | 2 | Coleccionista | **Integrada.** Vitrina de cristal biselado con marco de latón y terciopelo violeta. En el centro, sobre un atril, la Máscara de Ignacio con barba y cicatriz, los ojos cerrados y una grieta bajo el ojo derecho por la que baja una gota. Otras Máscaras alrededor con etiquetas en blanco. En el cristal, el reflejo tenue de Klein con la lupa al cuello. |
| `espejo_klein_35` | 2 | E1 | **Archivo disponible.** Klein reflejado en el cristal de la esfera del reloj del vestíbulo. Canas en las sienes. El minutero detrás de su reflejo. |
| `sueno_ignacio_elige` | 2 | E2 | **Archivo disponible.** Ignacio joven, de unos 40 años, agachado frente a un niño de nueve años en el patio del hospicio. Le sostiene las manos para mirarle los dedos. **La cara de Ignacio es de porcelana**; la del niño, en sombra. |
| `espejo_klein_45` | 2 | E2 | **Archivo disponible.** Klein reflejado en el cristal de la caja fuerte del pasillo. Unos 45 años: arrugas marcadas, ojeras, pelo gris. |
| `reflejo_dueno` | 2 | E4 sombra | **Archivo disponible.** Klein frente a una vitrina. En el reflejo, el Dueño detrás de él con una mano en su hombro, y sobre la cara de Klein **la máscara negra con la franja de luz**. Fuera del reflejo, Klein está solo. |
| `espejo_klein_60` | 2 | E5 | **Archivo disponible.** Klein reflejado en la plata de un candelabro, deformado por la curva: un hombre de 60 años con el chaleco y la lupa. |
| `mascara_rota` | 2 | M3 | **Archivo disponible.** Las manos de Klein con fragmentos de porcelana que se deshacen en polvo blanco. Un trozo con la cicatriz de la ceja todavía reconocible. |
| `fichas_dueno` | 3 | M4 | **Archivo disponible.** Montón de fichas de marfil sobre el tapete negro del Dueño, a la luz blanca de la verja abierta. En cada ficha, grabada, una cara diminuta. Algunas fichas con las iniciales *K. M.* La mano enguantada del Dueño empujándolas. |
| `amanecer_joven` | 3 | Final A devuelto | **Archivo disponible.** Klein con 27 años, con la levita y el sombrero de copa, en la calle del puerto todavía de noche, a punto de amanecer. Se mira las manos jóvenes. Al fondo, el farolero apagando su farola. Alivio, no alegría. |
| `amanecer_robado` | 3 | Final A robado | **Archivo disponible.** Klein con 20 años ante el escaparate del taller, de noche. Los bolsillos de la levita abultados de fichas que asoman. En el reflejo del cristal, sobre su cara, una franja de luz como la del Dueño. |
| `amanecer_muelle` | 3 | Final A sin fichas | **Archivo disponible.** Klein envejecido en el muelle, de espaldas, frente al sol que sale sobre el mar. Vetas grises bajo el sombrero; mira sus manos de viejo. A sus pies, la ficha antigua rajada por la mitad. Farolas eléctricas en el muelle: ha pasado mucho tiempo. |
| `farolero_ve` | 3 | Final A con clemencia | **Archivo disponible.** Al final del muelle, el farolero con su pértiga levanta la cabeza: sus ojos, por primera vez, no son blancos. Luz del amanecer en la cara. |
| `mascara_negra` | 3 | Final B | **Archivo disponible.** El Dueño, sin máscara (solo una franja de luz donde estaría la cara), tiende la máscara negra a Klein por encima del tapete. |
| `sobres_en_los_umbrales` | 3 | Final C | **Archivo disponible.** Montaje en tres paneles verticales: el mismo sobre negro en tres umbrales distintos (la puerta del taller, una pensión de otra ciudad, una casa con jardín). Klein envejece de un panel a otro, siempre con la mano en el picaporte sin abrir. |
| `anfitriona_en_el_lecho` | 3 | Final C | **Archivo disponible.** Dormitorio modesto de noche. Klein con 81 años en la cama, mirando a la silla de al lado, donde la anfitriona, igual que siempre, sostiene un sobre negro en el regazo. Todos los relojes de la pared parados a las doce menos un minuto. |
| `cg_relojes_parados` | 1 | P2 | **Disponible.** La pared de treinta y dos relojes del taller, todos a las doce menos un minuto; los péndulos detenidos a mitad de recorrido. Lámpara de pantalla verde en primer plano. |
| `cg_ventana_farola` | 1 | P2 · mirar por la ventana | **Disponible.** Ventana empañada del taller. Fuera, la farola encendida sin farolero y, bajo su halo, un hombre con levita verde que no tiene cara. Solo una silueta. |
| `cg_reloj_helado` | 1 | P2 · comprobar los relojes | **Disponible.** Las manos de Klein, manchadas de aceite, abren un reloj de bolsillo: el volante quieto, una escarcha fina sobre el metal y el vaho de su aliento. |
| `cg_invitacion_arde` | 1 | P3 · intentar quemarla | **Disponible.** La esquina de la invitación dentro de la llama de la lámpara. El fuego se ha vuelto verde y el papel sigue intacto; al fondo, las demás llamas del taller se apagan. |
| `cg_reverso_perdoname` | 1 | P3 · darle la vuelta | **Disponible.** El reverso de la tarjeta color hueso: una línea de dirección y, debajo, una letra temblorosa (sin palabras legibles; el texto lo pone el juego). |
| `cg_farolero` | 1 | P4 | **Disponible.** El farolero bajo su farola, apoyado en la pértiga, con los ojos blancos y la niebla a la cintura. No mira a Klein. |
| `cg_camino_farolas` | 1 | P4 | **Disponible.** Una hilera de farolas que se encienden hacia donde la calle debería acabar; detrás de Klein, las primeras ya están apagadas. |
| `cg_ficha_late` | 1 | P5 · tocar la ficha | **Disponible.** La ficha de marfil sobre la palma de Klein, con una campana grabada y un pulso de luz dorada que le ilumina los dedos. |
| `cg_calle_desaparece` | 1 | P5 · mirar atrás | **Disponible.** Klein de espaldas en la escalinata de la Casa; detrás, donde estaba la calle, solo negro. |
| `cg_jugadores_porcelana` | 1 | P6 | **Disponible.** Primer plano de manos que barajan en una mesa pequeña del vestíbulo: dedos blancos y lisos como loza; en una mano la porcelana llega a la muñeca. |
| `cg_reloj_ranuras` | 1 | P6 | **Disponible.** El gran reloj del vestíbulo parado a la medianoche, con tres ranuras vacías bajo el cristal del tamaño de un sello. |
| `cg_puerta_grabada` | 1 | Vestíbulo · al entregar la invitación | **Disponible.** Donde estaba la puerta, una pared de mármol verde con el contorno de una puerta grabado, sin picaporte ni bisagras. |
| `cg_cadena_custodio` | 2 | Custodio · «¿Puede levantarse de esa silla?» | **Integrada.** Bajo la mesa del Custodio, una cadena de hierro le sujeta los tobillos a las patas de la silla; eslabones gastados de tanto tirar. Solo se ven sus pies, la cadena y el borde del tapete. |
| `klein_dueno` | 3 | Final B | **Archivo disponible.** Klein sentado en la silla del Dueño, con la máscara negra puesta y el abrigo oscuro. A su lado, la anfitriona escribe con una pluma sobre un sobre negro. La verja cerrada detrás; ninguna luz. |

---

### `cg_derrota_manos` · Fin del intento (I6-11, guion §14.4)

Encuadre propuesto por Kenned para la derrota ilustrada. Una sola CG sirve para cualquiera de los cuatro crupieres, porque muestra a Klein y no la mesa concreta.

| Aspecto | Indicación |
| --- | --- |
| **Plano** | Primer plano cenital a tres cuartos, desde los ojos de Klein: sus dos manos apoyadas sobre el tapete, con los puños de la levita y el borde de la mesa en el tercio inferior. Formato 16:9, 1920 × 1080. |
| **Sujeto** | La porcelana avanza desde la punta de los dedos: dedos ya blancos, lisos y brillantes como loza, con una grieta fina en un nudillo; el dorso a medio cambiar; las muñecas todavía de carne, donde empieza el puño. La mano derecha intenta cerrarse y no puede. Sin sangre ni roturas violentas. |
| **Mesa** | Tapete oscuro y desenfocado con ribete de latón, sin el color propio de ninguna sala. Junto a la mano izquierda, la última mano boca arriba y la ficha de marfil. Ninguna Máscara boca abajo, para no sugerir su valor. |
| **Fondo** | Desenfocada, al fondo a la derecha, una vitrina vacía y limpia con una etiqueta en blanco (el nombre lo pone el juego). Un halo frío de vela sobre las manos; el resto, casi negro. |
| **Espacio para el texto** | El tercio inferior queda oscuro y sin detalles importantes: ahí va la narración NVL. La vitrina y las manos en los dos tercios superiores. |
| **Movimiento en el juego** | Acercamiento lento hacia las manos mientras se leen las dos frases del guion; al llegar a la vitrina, un fundido al ADV de la Anfitriona. |

**Secuencia que montará I6-11:** sonido de quiebra, porcelana que cruje y campana con eco; las dos frases NVL de §14.4 sobre esta CG; la variante «vitrina vacía» (la de la Coleccionista depende de `moral.sombra`, que aún no existe); la Anfitriona en ADV, «Ya la estoy escribiendo, señor.»; y la acción **Nuevo intento**. Se conserva la línea del crupier de la derrota antes de la secuencia.

**Variante para más adelante** (`cg_derrota_coleccionista`): el mismo encuadre con los guantes violeta de la Coleccionista entrando desde arriba para levantar las manos de Klein. Solo cuando exista la ruta de sombra.

## Notas examinables

Al examinar un elemento de una sala con **E**, se abre una escena con su ilustración y la nota del [guion](GUION_PROLOGO_Y_DIALOGOS.md#11-notas-examinables) (I5-10). Las diez variantes de la primera tabla están integradas. Los archivos WebP de 1920 × 1080 están en `juego/historia/ilustraciones/`. El texto lo dibuja Godot.

Algunas notas cambian con la historia y por eso tienen más de una ilustración.

| Id | Nota | Cuándo se ve | Texto del guion | Ilustración |
| --- | --- | --- | --- | --- |
| `nota_entrada` | Entrada · La farola | Sin hablar con el farolero, o si se le ignoró | «Una farola encendida en una calle que ya no existe. No da calor. No da sombra.» | La farola encendida sobre el empedrado vacío, sin calle alrededor: solo niebla y un halo que no proyecta sombra. Nadie bajo la luz. |
| `nota_entrada_escucho` | Entrada · La farola | Si se escuchó al farolero (`prologo.farolero = escucho`) | «…en el empedrado, alguien grabó con una uña: levántate a tiempo.» | Primer plano del empedrado bajo la farola, con unas palabras arañadas en la piedra (sin letras legibles; el texto lo pone el juego). Una uña rota junto a ellas. |
| `nota_entrada_ignacio` | Entrada · La farola | Si se preguntó por Ignacio (`pregunto_ignacio`) | «…un reloj de bolsillo aplastado, adelantado tres minutos. En la tapa: I. F. Dentro, un retrato tuyo de niño.» | Un reloj de bolsillo aplastado bajo la farola, con la tapa abierta: iniciales grabadas, las agujas tres minutos adelantadas y, dentro, el retrato de un niño de nueve años. |
| `nota_vestibulo` | Vestíbulo · El reloj detenido | Sin sellos | «Todas las agujas señalan la hora a la que llegaste. Bajo el cristal alguien grabó tres ranuras del tamaño de un sello.» | La esfera del reloj del vestíbulo de cerca: todas las agujas en la misma hora y tres ranuras vacías bajo el cristal. |
| `nota_vestibulo_sellos` | Vestíbulo · El reloj detenido | Con uno o más sellos | «Hay {n} sellos en las ranuras. Si acercas el oído, oyes un tic cada mucho tiempo. Cada tic suena como un hueso.» | La esfera vista en ángulo, con una luz bajo el vidrio y las ranuras en sombra. El texto muestra cuántos sellos hay. Las tres variantes visuales por cantidad son opcionales. |
| `nota_tienda` | Tienda · La vitrina de humo | Siempre | «La lámpara atraviesa la lente y dibuja dos rostros en el terciopelo. Uno desaparece cuando la luz toca el cristal. El otro sigue mirándote cuando apagas la lámpara.» | La lente de humo bajo la lámpara del Gabinete: dos rostros proyectados en el terciopelo; uno se deshace en humo y el otro mira al espectador. |
| `nota_custodio` | Custodio · El péndulo | Siempre | «Hay diez muescas en la caja. El péndulo solo avanza cuando alguien empieza una mano. Bajo cada muesca hay un nombre rayado.» | La caja del péndulo del Custodio con diez muescas talladas y, bajo cada una, un nombre rayado a punta de navaja (ilegible). El péndulo, quieto junto a la última. |
| `nota_recaudador` | Recaudador · El libro mayor | Siempre | «…Junto a cada petición posterior aparece una ficha de tinta roja. Una página tiene tu nombre en el encabezado y, debajo, otro nombre tachado.» | Una página del libro mayor bajo la lámpara granate: columnas de tinta negra, fichas dibujadas en rojo y un encabezado con un nombre tachado debajo de otro (sin letras legibles). |
| `nota_coleccionista` | Coleccionista · El expositor | Siempre | «…Hay una vitrina vacía, limpia, con una etiqueta en blanco.» | El estante superior del expositor con etiquetas fechadas y, al lado, una vitrina vacía y recién limpiada con la etiqueta en blanco, esperando. |
| `nota_dueno` | Dueño · La inscripción | Siempre | «El sol está tallado en el suelo, pero la luz que pasa bajo el portón es real. Alrededor del sol hay arañazos. Alguien intentó arrastrarse hasta él.» | El sol tallado en el mármol negro, rodeado de arañazos como de uñas que van hacia él, y la línea de luz real que pasa bajo el portón. |

**Ilustraciones disponibles para los tres puntos de examen que aún faltan.**

| Id | Nota | Texto del guion | Ilustración |
| --- | --- | --- | --- |
| `nota_jugadores` | Vestíbulo · Los jugadores | «No levantan la vista. Tienen los dedos de porcelana. Sobre sus mesas, todas las cartas son Máscaras, y algunas Máscaras tienen la cara de quien las juega.» | Una mesa pequeña del vestíbulo: jugadores con dedos de porcelana y cartas que son todas Máscaras; una de ellas tiene la cara de quien la sostiene. |
| `nota_pendulo_grande` | Pasillo del Custodio · El péndulo grande | «Un péndulo de latón cuelga sobre la puerta. No se mueve. En el marco hay rayas, una por cada visitante que entró…» | El péndulo de latón sobre la puerta del Custodio y el marco cubierto de cientos de rayas; las últimas, frescas. |
| `nota_caja_fuerte` | Pasillo del Recaudador · La caja fuerte | «Una caja fuerte empotrada con un rótulo: Años en depósito. Al apoyar la mano en el metal, se oye dentro un murmullo…» | La caja fuerte empotrada en el muro granate, con el rótulo en blanco para el juego y la mano de Klein apoyada en el metal. |

## Hojas de expresiones

Cada personaje necesita varias expresiones con **el mismo encuadre de busto**, para que el retrato cambie sin moverse. El guion usa exactamente estos ids (`[RETRATO: personaje · id]`). Si hay que recortar, la columna «Mínimo» indica las imprescindibles.

**Retratos disponibles.** La carpeta [`historia/retratos`](../juego/historia/retratos) contiene las expresiones y edades de Klein, las expresiones de los otros siete personajes principales y los tres grados de porcelana de Amparo, Tobías y Benavides. Se generaron con ImageGen y se exportaron como WebP de 900 × 1200 con alfa. Los diálogos ya escritos usan los recortes por su id. Las variantes de eventos y finales quedan preparadas para cuando se implementen esas escenas.

### Klein Moretti

**Diseño de referencia para el juego.** Joven relojero de silueta victoriana estilizada, con pelo oscuro al descubierto, levita azul noche y luz fría en el contorno. La lupa y la cadena del reloj identifican su oficio. El [retrato neutral](../juego/historia/retratos/klein_neutral.webp) fija el diseño para las expresiones y el sprite.

| Parte | Descripción |
| --- | --- |
| Cara | 27 años, delgado, pómulos marcados, mandíbula estrecha, sin barba. Ojos grises, cansados, con ojeras de trabajar de noche. Una pequeña cicatriz de quemadura en el pulgar derecho. |
| Pelo | Negro, corto y ondulado, con varios mechones sobre la frente. Se lleva al descubierto en el retrato base y en exploración. |
| Ropa | Levita azul noche hasta la rodilla, con una pequeña costura de latón en la solapa. Chaleco gris marengo de raya fina, camisa blanca y corbata negra recta. Pantalón oscuro y botas negras. |
| Detalles de relojero | Lupa monocular de latón oscuro colgada al cuello y cadena de plata. El reloj de bolsillo se para a las doce menos un minuto. |
| Bastón | Nogal oscuro con empuñadura de latón en forma de rueda dentada. Era el bastón de Ignacio. |
| Silueta | Alta y estrecha, ligeramente encorvada hacia delante, como quien mira siempre algo pequeño. |

La hoja de movimiento sustituye al sprite del visitante en exploración (ver [figuras](#figuras-de-exploración)).

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Mirada atenta, labios apretados; costumbre de quien observa un mecanismo. Una mano en la cadena del reloj. | ✓ |
| `asustado` | Ojos muy abiertos, la mano sobre el bolsillo donde lleva la ficha. | ✓ |
| `ironico` | Media sonrisa torcida, una ceja alzada. Para sus momentos de humor seco. | ✓ |
| `decidido` | Mandíbula firme, mirada al frente, el ala del sombrero bajada. | |
| `furioso` | Ceño fruncido, dientes apretados; los nudillos blancos sobre la empuñadura del bastón. | |
| `roto` | Mirada perdida y húmeda, hombros caídos, el sombrero en la mano. | ✓ |
| `vacio` | Ruta de sombra: cara inexpresiva, ojos sin brillo; una sombra donde estaría la máscara negra. | |

**Etapas de edad** (misma expresión `neutral`): `27`, `35` (canas en las sienes), `45` (arrugas, pelo gris), `60` (pelo blanco, piel fina, manos nudosas). Para el final A robado, una etapa más: `20` (un muchacho, casi demasiado joven para la ropa).

#### Prompts de generación

Para quien genere el arte con IA. Usar la misma descripción base en todas las peticiones para mantener la coherencia; cambiar solo la línea de expresión o edad.

**Sin fondo.** Todas las bases ya piden *isolated figure on transparent background*. Si la herramienta no exporta transparencia, pedir *plain flat solid light grey background, no shadow, no vignette* y quitar el fondo después con una herramienta de recorte. Revisar a tamaño real que no queden halos claros en el pelo, el sombrero ni los bordes de la ropa, y guardar en `.webp` o `.png` con canal alfa. La misma regla vale para todos los personajes de este documento.

**Base (retrato de busto):**

> Stylized Victorian game portrait with clean ink lines, soft cel shading and a restrained teal rim light. Slim 27-year-old watchmaker with grey-green eyes, clean-shaven face, short wavy black hair and a bare head. Midnight blue frock coat, charcoal pinstripe waistcoat, white pointed collar, slim black tie, brass watchmaker's loupe on a cord and a silver watch chain. Isolated on transparent background, no text or border, 3:4 framing, consistent bust crop. Match the neutral portrait.

**Línea de expresión** (añadir al final): `neutral, attentive gaze, one hand on the watch chain` · `frightened, wide eyes, hand pressed on waistcoat pocket` · `dry ironic half smile, one eyebrow raised` · `determined, jaw set, chin lowered` · `furious, clenched teeth, white knuckles on a cane with a brass gear handle` · `broken, wet unfocused eyes, shoulders slumped` · `empty, expressionless, faint shadow of a black mask over the face`.

**Línea de edad:** `aged 35, grey at the temples` · `aged 45, deep lines, greying hair` · `aged 60, white hair, thin skin, gnarled hands` · `aged 20, boyish face, clothes slightly too large`.

**Figura de cuerpo entero (exploración):**

> Same character, full body and bare head, navy coat and dark boots. Elevated three-quarter top-down camera, transparent backgrounds, consistent scale and feet aligned to the bottom of every cell. Eight directions, each with a standing pose and four walking frames. Keep the hands free for a readable arm swing.

### La anfitriona (Leonor)

Terciopelo verde, horquilla, aro de llaves pequeñas (de vitrinas, no de puertas). Palidez de enferma bajo el maquillaje.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Cortés, las manos juntas sobre el mostrador. | ✓ (ya existe una versión) |
| `sonrisa_leve` | Una sonrisa que no llega a los ojos. | ✓ |
| `seria` | Sin sonrisa, la mirada baja sobre una invitación. | ✓ |
| `compasiva` | Ojos tristes y suaves; inclina la cabeza. Se usa muy pocas veces. | ✓ |
| `tos` | Se cubre la boca con un pañuelo de encaje; los hombros encogidos. | ✓ |
| `joven` | La misma pose que `seria`, pero de unos veinte años y con color en las mejillas. | |
| `anciana` | La misma pose que `seria`, pero muy vieja, casi transparente. | |

### El Custodio (Mateo)

Máscara larga de latón con un ojo de reloj, halo de campanas, ropa de cuatro épocas cosida encima. Una cadena fina lo une a la silla.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Quieto, las manos sobre la mesa; las campanas inmóviles. | ✓ (ya existe una versión) |
| `aprobacion` | Inclina la máscara; una campana del halo se balancea. | ✓ |
| `duelo` | La máscara baja hacia el pecho; todas las campanas inclinadas. | ✓ |
| `alarma` | Las campanas vibran (líneas de movimiento en el grabado); la cadena tensa. | |
| `recuerdo` | La máscara se desliza un poco y deja ver un ojo humano cansado, enrojecido. | |

### El Recaudador (Ezequiel Varga)

Entradas pronunciadas, cabello gris peinado hacia atrás, gafas, libro mayor y ábaco. Manos de joven en una cara de viejo.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Escribe sin levantar la vista. | ✓ (ya existe una versión) |
| `satisfecho` | Una línea recta en la boca que en él es una sonrisa; la pluma en alto. | ✓ |
| `impaciente` | Golpea el libro con la pluma; mira el reloj de bolsillo. | |
| `mirada` | Levanta la vista por primera vez: ojos de muchacho tras las gafas. | ✓ |
| `tachando` | Traza una raya con la regla; la tinta es roja. | |

### La Coleccionista (Céleste Vautrin)

Semimáscara clara, guantes, vitrina portátil. Bajo la semimáscara, media cara de niña; la otra media, de anciana.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Lánguida, apoyada en la vitrina portátil. | ✓ (ya existe una versión) |
| `deleite` | Sonrisa amplia, los guantes juntos bajo la barbilla. | ✓ |
| `hastio` | Párpados caídos, abanico cerrado contra los labios. | |
| `codicia` | Inclinada sobre la mesa, los ojos clavados en las cartas. | ✓ |
| `madre` | La semimáscara resbala: se ve media cara de niña con los ojos llenos de lágrimas. | ✓ |
| `furia` | La boca torcida, un guante rasgado; la vitrina portátil agrietada. | |

### El Dueño de la Casa

Abrigo oscuro, máscara negra con una franja de luz. No tiene cara debajo.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Sentado, inmóvil, las manos enguantadas sobre el tapete. | ✓ (ya existe una versión) |
| `interes` | Inclina la cabeza; la franja de luz se estrecha como una pupila. | ✓ |
| `cansancio` | Hombros caídos, una mano sobre la máscara. | ✓ |
| `oferta` | Extiende la mano abierta por encima del tapete. | ✓ |
| `luz` | La franja se ensancha hasta cubrir la máscara entera; no queda cara. | ✓ |

### Ignacio Ferrer

Barba blanca recortada, cicatriz en la ceja, levita verde gastada, reloj de bolsillo abierto.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Sonrisa encantadora, el reloj en la mano. | |
| `orgullo` | Barbilla alta, sonrisa de jugador que cree que va a ganar. | ✓ |
| `culpa` | Mira hacia abajo, a un lado; la mano aprieta el reloj cerrado. | ✓ |
| `desesperado` | Envejecido por diecisiete campanadas, sudoroso, los ojos fijos en las cartas. | ✓ |
| `mascara_dormida` | Su rostro en porcelana, ojos cerrados. | ✓ |
| `mascara_llorando` | Igual, con una grieta bajo el ojo derecho y una gota. | ✓ |
| `mascara_ojos_abiertos` | Igual, con los ojos abiertos de porcelana pintada. | |

### El farolero

Pértiga con mecha, capa encerada, ojos blancos sin pupila, manos de anciano en un cuerpo de hombre joven.

| Id | Descripción | Mínimo |
| --- | --- | :---: |
| `neutral` | Apoyado en la pértiga, la cara hacia la farola. | ✓ |
| `ciego_sonrie` | Sonrisa torcida, la cabeza ladeada como quien escucha. | |
| `culpa` | La cara vuelta hacia el suelo, la mano en el ala del sombrero. | ✓ |

### Los otros visitantes

Cada uno en **tres grados de porcelana** (`p1`, `p2`, `p3`), que el juego elige según los sellos conseguidos, y dos expresiones: `neutral` y `triste`.

| Personaje | Aspecto | `p1` | `p2` | `p3` |
| --- | --- | --- | --- | --- |
| **Doña Amparo** | Dama de unos setenta años, luto de 1840 casi sin color, mitones de encaje. | Manos de porcelana | Hasta los codos | Hasta el cuello |
| **Tobías Lara** | Cadete naval de diecinueve años, chaqueta azul, botones sin brillo. | Mano izquierda | Media cara | Todo menos un ojo |
| **Señor Benavides** | Notario de unos cincuenta, levita negra, bombín, anteojos de pinza, portafolios vacío. | Cuello | Mandíbula | Toda la cara |

Variantes extra: **Tobías `saldado`** (porcelana entera con la palabra escrita en rojo en la mejilla, que el juego superpone) y **Benavides `dormido`** (porcelana con los ojos cerrados), para las decisiones M1 y M2.

---

## Figuras de exploración

Las cuatro figuras secundarias son poses estáticas con alfa. Amparo y los jugadores de porcelana están en el vestíbulo, Tobías en el pasillo del Custodio y Benavides en el del Recaudador. El recorte del farolero está listo para cuando se decida si se incorpora a la exploración.

| Id | Prioridad | Descripción |
| --- | :---: | --- |
| `figura_klein` | 1 | Integrada como `klein_movimiento.webp` con reposo y caminata en ocho direcciones. Ver los prompts en su hoja de expresiones. |
| `figura_amparo` | 2 | Doña Amparo sentada a un piano de cola pequeño (el piano puede ser pieza aparte). |
| `figura_tobias` | 2 | Tobías de pie, mirando hacia arriba, con la gorra en la mano. |
| `figura_benavides` | 2 | Benavides sentado, abrazando el portafolios. El banco forma parte del recorte generado con ImageGen para el pasillo del Recaudador. |
| `figura_jugador_porcelana` | 2 | Dos o tres jugadores sentados ante mesitas, con ropa de épocas distintas y manos de porcelana, para poblar el vestíbulo. |
| `figura_farolero` | 3 | Para la sala de entrada, bajo la farola, si se decide que aparezca también en exploración. |

---

## Piezas de interfaz

| Id | Prioridad | Descripción |
| --- | :---: | --- |
| `marco_nvl` | 1 | **Disponible en Godot.** Filete fino de latón con un degradado oscuro bajo la narración para dejar legible el arte. |
| `cuadro_adv` | 2 | **Integrado.** Fondo más oscuro, borde de latón gastado y [campana de la placa](../juego/casino/dialogos/arte/campana_adv.webp). |
| `tarjeta_galeria` | 3 | **Archivo disponible.** [Miniatura de latón sobre verde oscuro](../juego/historia/ilustraciones/tarjeta_galeria.webp) para escenas aún sin desbloquear en la futura galería. |

---

## Orden de encargo

| Lote | Estado | Piezas |
| --- | --- | --- |
| **1 · Prólogo jugable** | Integrado | Fondos, 14 CG, retratos y marco de narración. |
| **2 · Jefes y eventos** | Arte completo | Hospicio, CG de encuentros y eventos, 13 notas, cuadro ADV y cuatro figuras del recorrido. |
| **3 · Finales** | Arte completo | Tres fondos, CG de los desenlaces A–C y miniatura para la galería. |

**Lote final.** 42 recursos: cuatro fondos, 18 CG, 13 notas, cinco figuras contando al farolero y dos piezas de interfaz. Las CG de los eventos y finales, los tres puntos de examen adicionales, el farolero de exploración y la galería esperan su puesta en escena.

**Producción.** Las descripciones de las tablas sirvieron de encargo para ImageGen. El grabado de Ignacio fijó el tramado para las CG. El taller, el reloj, la calle y las salas existentes fijaron las paletas y el encuadre. Los retratos del elenco fijaron las caras y el arte de la anfitriona en el mapa sirvió de referencia para los recortes. La nota del reloj sin sellos reutiliza el grabado del prólogo. Los originales PNG de ImageGen se conservaron localmente y se importaron las versiones WebP del juego.
