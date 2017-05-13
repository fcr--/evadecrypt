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

Probabilidad de que un caracter y el lindante (vertical u horizontalmente) sean el mismo:

    awk '{for(i=1;i<=length;i++)T[i,NR]=substr($0,i,1);w=length}END{n=(w-1)*(NR-1);for(y=1;y<NR;y++)for(x=1;x<w;x++){if(T[x,y]==T[x+1,y])hc++;if(T[x,y]==T[x,y+1])vc++}printf("horizontal: %.2f%%, vertical: %.2f%%\n", hc*100/n, vc*100/n)}' back.txt

> horizontal: 0.72%, vertical: 18.19%

Entropy as horizontal and vertical markov processes: [[ref]](http://math.ubbcluj.ro/~tradu/TI/coverch4.pdf)

    awk 'function entropy(P2, n2) { s=0;
      for (i in CS) { ci = CS[i]
        for (j in CS) { cj = CS[j]
          if (!P2[cj,ci]) continue
          s -= P[ci]/n*P2[cj,ci]/n2*log(P2[cj,ci]/n2)/log(2)
        }
      }
      return s
    }
    { for (x = 1; x <= length; x++) {
      T[x,NR] = c = substr($0,x,1);
      P[c]++
    } w=length }
    END {
      split("kmygcnor", CS, ""); n = w*NR;
      for (y=1;y<=NR;y++)
        for(x=1;x<=w;x++) {
          if(x<w)P2h[T[x+1,y],T[x,y]]++
          if(y<NR)P2v[T[x,y+1],T[x,y]]++
        }
      print "horizontal second order entropy = "entropy(P2h,(w-1)*NR)
      print "vertical second order entropy = "entropy(P2v,w*(NR-1))
    }' back.txt
    horizontal second order entropy = 0.843335
    vertical second order entropy = 0.900969
