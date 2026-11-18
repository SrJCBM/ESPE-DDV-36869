# Coste por mano y resolución de Máscaras

**14 de noviembre de 2026.** Julio eligió que las campanadas limiten las manos. Este ajuste sustituye el coste por carta analizado el 13 de noviembre. Se mantienen meta 200, umbral 17, diez manos, 24 cartas y las bonificaciones vigentes.

## Decisión y experiencia buscada

| Acción | Campanadas | Consecuencia |
| --- | ---: | --- |
| Iniciar | −1 | Reparte dos cartas y abre una mano |
| Pedir | 0 | Añade una carta; arriesga la validez de toda la mano |
| Devolver Llave | 0 | Un reemplazo legal por mano, confirmado junto a la carta |
| Plantarse | 0 | Cierra la mano; revela, calcula y muestra el resultado |

Con cero campanadas se sigue jugando la última mano: no se abre otra. La derrota se comprueba después de resolver, con prioridad de victoria si se alcanzó la meta.

El reto pasa a ser **arriesgar una mano para conseguir patrones**, en lugar de pagar repetidamente por intentarlo. No desaparece el riesgo: pedir de más puede convertir todos los puntos de esa mano en cero.

## Una revelación comprensible

Si el valor real de una Máscara supera el umbral pero la información pública no lo demuestra, permanece oculta y no provoca una derrota anticipada. Si incluso el mínimo posible excede el umbral, la mesa avisa honestamente de Quiebra segura y bloquea Pedir; conserva Plantarse y una posible Llave de rescate.

La mano nunca se cierra automáticamente al robar. Plantarse produce este recorrido visual:

**Decisión → revelar Máscaras → mostrar suma → confirmar patrones y puntos → anunciar resultado.**

La revelación es breve, se puede saltar con el botón de resultado, S o Esc y es inmediata con movimiento reducido. Reiniciar invalida la secuencia anterior. Una animación no descuenta recursos ni calcula puntos por segunda vez.

No se simula una posible victoria cuando las cotas públicas ya hacen segura la Quiebra. Se conserva la intriga únicamente cuando el resultado todavía es incierto para quien juega.

## Patrones visibles mientras se juega

La franja de la mano muestra los cinco objetivos, sus bonos y su progreso. Pulsar uno abre su explicación con ejemplos:

| Patrón | Explicación breve |
| --- | --- |
| Punto exacto +3 | Suma exactamente 17 |
| Al filo +2 | Suma 16 |
| Ascenso +2 | Tres cartas o más, todas subiendo: 2 < 5 < 8 |
| Mano larga +2 | Conserva cinco cartas o más |
| Racha +2 | Las tres últimas cartas son del mismo palo |

Los indicadores distinguen progreso, listo, pendiente de revelación y condición no cumplida. Solo emplean información pública. Racha o Mano larga pueden tener su condición formada con una Máscara oculta, pero su bono sigue condicionado a no quebrar. La ayuda mantiene esa distinción.

El pulido posterior reduce explicaciones permanentes y cajas en la franja. Al señalar un patrón con ratón o teclado se resaltan las cartas correspondientes y su explicación sustituye la única pista contextual; Racha marca las últimas tres. Abrir ayuda, elegir una Llave o revelar retira el resaltado. Los valores impresos permanecen legibles; solo el arte de las otras cartas se atenúa.

La cuenta resuelta muestra total, multiplicador y aporte, con los bonos debajo. En Quiebra muestra el exceso y cero puntos. El cierre separa ese resultado del resumen de todo el intento y ofrece Volver a jugar en la acción principal. No se añaden ventanas obligatorias ni bonificaciones nuevas.

## Balance medido con el nuevo coste

Controlador real, 1.000 semillas compartidas por política y decisiones exclusivamente públicas. Se mantuvo la regla simple de Llave del diagnóstico anterior. Las políticas estiman Máscaras mediante la media del catálogo público y no son estrategias óptimas.

| Política | Victorias en diez manos | Puntos medios | Manos restantes al ganar |
| --- | ---: | ---: | ---: |
| Plantarse sin pedir | 8,8 % | 147,85 | 0,89 |
| Pedir hasta estimación 9 | 79,8 % | 212,78 | 2,09 |
| Pedir hasta estimación 11 | 89,3 % | 222,14 | 2,94 |
| Pedir hasta estimación 13 | 89,2 % | 223,57 | 3,28 |
| Pedir hasta estimación 15 | 76,7 % | 216,09 | 3,28 |

Pedir moderadamente ya tiene una ventaja clara sobre repetir manos cortas. Diez manos ofrecen una introducción permisiva para estos bots. La diferencia de 0,1 puntos porcentuales entre las políticas 11 y 13 no acredita superioridad.

Presupuestos alternativos medidos, **sin aplicarlos**:

| Política | 6 manos | 7 manos | 8 manos | 10 actuales |
| --- | ---: | ---: | ---: | ---: |
| Sin pedir | 0,4 % | 1,1 % | 2,1 % | 8,8 % |
| Hasta 9 | 13,8 % | 28,6 % | 47,0 % | 79,8 % |
| Hasta 11 | 33,3 % | 49,7 % | 68,6 % | 89,3 % |
| Hasta 13 | 39,7 % | 59,1 % | 71,3 % | 89,2 % |
| Hasta 15 | 36,2 % | 48,9 % | 59,5 % | 76,7 % |

Mantendría diez para aprender la mesa y probaría siete u ocho como variantes de dificultad después del piloto. No elevaría bonos al mismo tiempo: mezclar ambos cambios dificultaría saber qué mejora la experiencia. Las cifras no miden diversión ni representan tasas de victoria humanas.

El diagnóstico reproducible está en `Analisis/diagnostico_balance.gd`; usa el núcleo actual. Los datos del informe del 13 de noviembre corresponden al coste anterior y se conservan como antecedente, no como resultados actuales.

Para reproducir desde la raíz, con `$GodotExe` apuntando a Godot 4.7.2:

```powershell
$Analisis = (Resolve-Path '2P/Desarrollo/Analisis/diagnostico_balance.gd').Path
& $GodotExe --headless --path '2P/Desarrollo/juego' --script $Analisis -- --muestras=1000 --manos=10
```

Cambiar `--manos` a 7 u 8 modifica únicamente el encuentro del diagnóstico. Los JSON se guardan en `juego/exportaciones/analisis/`; el juego sigue iniciando con diez manos.

## Qué falta observar con personas

Los comentarios de I1-07 están pendientes. Además del protocolo existente, comprobar:

1. Que distingue manos restantes de cartas que puede pedir.
2. Que identifica un patrón cercano y explica por qué pedir podría ayudar.
3. Que entiende la advertencia de Quiebra segura y la diferencia con una Máscara incierta.
4. Que ve el valor revelado antes de interpretar victoria o derrota.
5. Que el resultado le permite explicar qué haría distinto al volver a jugar.

El ciclo buscado es breve y claro: decidir, asumir un riesgo, descubrir el resultado y aprender para el siguiente intento. La repetición debe resultar interesante por esas decisiones; aprobar pruebas automáticas no valida esa experiencia.

## Documentación y límites

El Word vigente se editó en su mismo archivo, sin crear otra versión entregable. Se actualizaron costes, último turno, revelación, interfaz, criterios y el ejemplo de 221 puntos, que ahora deja siete campanadas. Se conservaron estilos, tablas y campos, se actualizaron índice y referencias en Word y se revisó la paginación exportada.

El cambio también afecta a la campaña futura: la antigua garantía de quince fichas del Recaudador dependía de limitar las peticiones mediante campanadas y ya no queda demostrada. Se señala como pendiente de balance sin inventar nuevas comisiones. Las mesas futuras y sus presupuestos requieren su propia revisión antes de implementarse.

La implementación y las revisiones se mantienen en la rama de trabajo, sin nuevo commit ni publicación. La validación técnica actual figura en [REVISION_I1.md](REVISION_I1.md).
