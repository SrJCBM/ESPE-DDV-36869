# Balance de la campaña · Coleccionista y Dueño

**22 de noviembre de 2026 · Kenned.** Se ajustan meta y campanadas de las dos últimas mesas y, a propuesta de Julio, el Sello del prudente pasa a un uso por mesa y el Dueño solo baja el umbral tras una mano sin Quiebra. Precios y umbrales iniciales no cambian: las fichas siguen siendo escasas para que comprar sea una decisión.

## Cambio

| Mesa | Antes (umbral · meta · campanadas) | Ahora | Motivo |
|---|---|---|---|
| La Coleccionista | 25 · 600 · 14 | **25 · 700 · 12** | La superaba el 100 % de quienes llegaban, con o sin compras: no era un reto |
| El Dueño de la Casa | 25 · 800 · 16 | **25 · 750 · 17** | Sin compras solo la superaba el 13 %: la tienda era obligatoria |
| Regla del Dueño | Baja uno tras cada mano, incluida una Quiebra | **Baja uno solo tras una mano sin Quiebra** | Comentario de Damián; decisión de Julio |
| Sello del prudente | Dos usos por mesa | **Un uso por mesa** | Las mesas ya tienen campanadas de sobra, en especial el Dueño |

Objetivo acordado: que el Dueño se pueda superar **sin comprar** entre el 30 % y el 40 % de las veces, y que la tercera mesa exija algo más que la segunda.

## Resultado

1.000 campañas por fila con las mismas semillas. Cada celda indica cuántos intentos superan la mesa entre los que llegan a ella. Margen 6: pide carta si el punto medio del intervalo visible queda seis o más por debajo del umbral.

| Reglas | Estrategia | Custodio | Recaudador | Coleccionista | Dueño | Campañas ganadas |
|---|---|---:|---:|---:|---:|---:|
| Anteriores | Sin compras | 89 % | 88 % | 100 % | 13 % | 10 % |
| Anteriores | Lente, Corona y Sello | 91 % | 87 % | 100 % | 84 % | 67 % |
| Dueño 750 · 18, regla anterior | Sin compras | 89 % | 88 % | 94 % | 35 % | 26 % |
| Dueño 750 · 18, regla anterior, Sello con dos usos | Lente, Corona y Sello | 91 % | 87 % | 100 % | 96 % | 76 % |
| Dueño 750 · 18, regla anterior | Lente, Corona y Sello | 91 % | 85 % | 100 % | 94 % | 73 % |
| **Vigentes** (Dueño 750 · 17, sin bajar tras Quiebra) | Sin compras | 89 % | 88 % | **94 %** | **34 %** | 25 % |
| **Vigentes** | Lente, Corona y Sello | 91 % | 85 % | 100 % | **96 %** | 74 % |

Quien no compra no usa el Sello, así que su fila no cambia con ese ajuste. Primera búsqueda de meta y campanadas del Dueño, con la regla anterior, la Coleccionista ya ajustada y el Sello todavía con dos usos:

| Dueño (meta · campanadas) | Sin compras | Con compras |
|---|---:|---:|
| 700 · 16 | 31 % | 95 % |
| 700 · 17 | 39 % | 97 % |
| **750 · 18** | **35 %** | **96 %** |
| 700 · 18 | 44 % | 98 % |
| 650 · 18 | 62 % | 100 % |

Se eligió 750 · 18 por quedar en el centro del objetivo.

### El Dueño solo baja tras una mano sin Quiebra

Damián no notó que el umbral bajaba y propuso que no bajara si se excedía; Julio decidió aplicarlo. Contra lo esperado, **la regla facilita la mesa**: tras una Quiebra el umbral se queda alto, y un umbral alto da más margen y totales mayores. Con 750 · 18 el Dueño sin compras pasó del 35 % al 42 %, fuera del objetivo. Variantes medidas con la regla nueva:

| Dueño (meta · campanadas) | Sin compras | Con compras |
|---|---:|---:|
| 750 · 18 | 42 % | 97 % |
| **750 · 17** | **34 %** | **96 %** |
| 800 · 18 | 30 % | 95 % |
| 800 · 17 | 23 % | 92 % |
| 850 · 18 | 19 % | 91 % |

Se eligió 750 · 17: vuelve al centro del objetivo quitando una sola campanada. Con margen 4 el Dueño sin compras queda en 43 % y con margen 8 en 10 %: arriesgar de más sigue costando.

## Límites conocidos

- **Quien compra Corona y Sello supera la Coleccionista siempre y el Dueño el 96 % de las veces.** Ningún ajuste de meta o campanadas cambia lo primero (con meta 800 seguía en 99 %). Reducir el Sello a un uso solo resta dos puntos al Dueño: la mayor parte de la ventaja viene de la Corona, que se mantiene hasta observar a jugadores.
- Las tablas de [BALANCE_RECAUDADOR.md](BALANCE_RECAUDADOR.md) se midieron con el Sello de dos usos; sus filas con amuletos ya no son exactas.
- La comisión del Recaudador no cambia qué estilo conviene. Con saldo de sobra, permitir una o dos peticiones gratis por mano dio exactamente las mismas victorias (178 y 89 de 200). Solo influye cuando faltan fichas, como ya mostraba [BALANCE_RECAUDADOR.md](BALANCE_RECAUDADOR.md).
- Son bots con una regla fija: detectan desequilibrios grandes, no miden diversión ni cómo aprende una persona. El piloto debe confirmar si la Coleccionista se siente más tensa y si el Dueño es alcanzable sin comprar.
- El Word del diseño (v2.4) se actualizó en su mismo archivo con estas reglas, la regla nueva del Dueño, el coste por mano y la Quiebra segura.

## Repetir la prueba

Desde `2P/Desarrollo/juego`, con `$GodotExe` apuntando a Godot 4.7.2:

```powershell
& $GodotExe --headless --path . --script res://tests/sim_campana.gd -- --semillas=1000
& $GodotExe --headless --path . --script res://tests/sim_campana.gd -- --semillas=1000 --variantes
```

El primero barre márgenes 4, 6 y 8 con las reglas vigentes; el segundo compara las variantes de `VARIANTES` con margen 6. La simulación usa `CampanaCasino`, `ControladorMesa` y los comandos reales, compra en la tienda real y solo decide con la vista pública. `tests/test_casino.gd` fija las reglas nuevas.
