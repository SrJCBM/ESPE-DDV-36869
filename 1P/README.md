# La Última Mesa

Proyecto académico de Desarrollo de Videojuegos de la Universidad de las Fuerzas Armadas ESPE.

**Integrantes:** Julio Blacio, Kenned Sigcha y Ariel Llumiquinga.

**Asignatura:** 36869-DESARROLLO DE VIDEOJUEGOS.

**Docente:** Hector Paul Pinto Pachacama.

## Contenido

- `prototipo/`: blackjack básico jugable, con reparto animado, fichas ficticias y pruebas.
- `Entregables/`: documento de conceptualización en Word y captura del prototipo.
- `Referencias/PROPUESTAS_BLACKJACK.md`: propuestas iniciales y alcance del proyecto elegido.
- `Referencias/`: documentos utilizados como referencia académica.

## Ejecutar el prototipo

Abrir `prototipo/index.html` en un navegador. Mantener la carpeta completa; funciona sin internet.

También se puede utilizar el servidor local desde la raíz del proyecto:

```sh
node prototipo/serve.cjs
```

Abrir `http://127.0.0.1:8766`. Detener el servidor con Ctrl+C.

## Verificar las reglas y el reparto

Con Node.js instalado:

```sh
node --test prototipo/game.test.cjs prototipo/presenter.test.cjs
```

## Desarrollo previsto

El prototipo actual utiliza HTML, CSS y JavaScript. La siguiente fase se desarrollará con Phaser, TypeScript y Vite para incorporar amuletos, consumibles, encuentros y progresión narrativa.

Las capturas de Balatro incluidas en el documento se identifican con su fuente. Los documentos de referencia y los recursos de terceros conservan sus respectivas autorías y licencias.
