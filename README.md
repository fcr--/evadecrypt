# evadecrypt
Trying to decipher a text encoded in a color matrix

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
