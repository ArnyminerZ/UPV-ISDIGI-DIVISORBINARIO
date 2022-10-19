# Divisor binario en 2s-complement
Para realizar una división en 2s-complement, debemos seguir el siguiente algoritmo; por ejemplo, para `19/6`, que debería dar `3` y un residuo de `1`:
1. `19` en binario es `0001 0011`, y `6` es `0000 0110`.
2. `-6` en 2-s complement es `1111 1010`.
3. Sumamos el numerador y el `-6` (descartando el carry):
```
 0001 0011
+1111 1010
----------
 0000 1101 (q=1)
```
4. Comprobamos si el resultado que nos ha dado es menor a nuestro denominador (`0000 0110`).\
   En este caso, `0000 1101 > 0000 0110`, así que debemos volver a realizar la suma, con el resultado.
```
 0000 1101
+1111 1010
----------
 0000 0111 (q=2)
```
   En todos los ciclos, debemos aumentar `q` en 1, que será nuestro cociente.
5. Volvemos a realizar la comprobación. Como `0000 0111 > 0000 0110` realizamos otra vez el cálculo.
```
 0000 0111
+1111 1010
----------
 0000 0001 (q=3)
```
6. Ahora sí que sí, `0000 0001 < 0000 0110`, así que podemos dar nuestra operación como finalizada.
7. Nuestro cociente será por lo tanto `3`, y nuestro resto `1`.
