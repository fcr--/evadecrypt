# evadecrypt

## Reconocimiento.

Para el reconocimiento de la imagen escribí el programa [viewer.tcl](viewer.tcl), el cual toma como único argumento (en la ejecución) el nombre de un archivo de configuración. Dicho archivo de configuración tiene la siguiente sintaxis:

| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Parámetro&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Descripción |
|-----|-----|
| `image <fileName>` | Le indica al programa cuál es el archivo que contiene la imagen a mostrar. |
| `output <fileName>` | Determina el archivo de texto sobre el cual se escribe la salida con los códigos de color. |
| `p00 <x> <y>` | Indica las coordenadas en píxeles del centro del círculo superior izquierdo con respecto al borde superior izquierdo de la imagen. |
| `pw0 <x> <y>` | Indica las coordenadas en píxeles del centro del círculo superior derecho  con respecto al borde superior izquierdo de la imagen. |
| `p0h <x> <y>` | Indica las coordenadas en píxeles del centro del círculo inferior izquierdo con respecto al borde superior izquierdo de la imagen. |
| `pwh <x> <y>` | Indica las coordenadas en píxeles del centro del círculo inferior derecho con respecto al borde superior izquierdo de la imagen. |
| `width <w>` | Cantidad de círculos menos 1 por cada fila. Si hay 30 círculos en una fila, se debería ingresar: `width 29` |
| `height <h>` | Cantidad de círculos menos 1 por cada columna. |
| `force <x> <y> <color>` | Obliga a que el círculo (x,y) se reconozca con el color indicado por parámetro. Las cordenadas hacen referencia a los círculos y no a los píxeles de la imagen (0,0) siendo el círculo superior izquierdo y (1,0) el que está a su derecha. |
| `color <r> <g> <b> <c>` | Asocia el nombre de color `<c>` al color indicado por los tres enteros entre 0 y 255 con las componentes rojo, verde y azul respectivamente. Si el color es `error` se tratará de evitar asignar ese color a los círculos, y en caso de no haber más remedio se indicará un aviso por salida estándar. |

## Análisis.

Frecuencias de los colores:

    awk '{for(i=1;i<=length;i++){C[substr($0,i,1)]++}}END{for(k in C)print C[k],k}' < back.txt | sort -nr

| Ocurrencias | Color |
|-------------|-------|
| 1499 | k (negro) |
| 1497 | m (magenta) |
| 622 | y (amarillo) |
| 466 | g (verde) |
| 424 | c (cian) |
| 396 | n (marrón) |
| 350 | o (naranja) |
| 293 | r (rojo) |
| 4 | _ (esquina) |
