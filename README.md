# Divisor binario en 2s-complement
Para realizar una división en 2s-complement, debemos seguir el siguiente algoritmo; por ejemplo, para `19/6`, que debería dar `3` y un residuo de `1`:
1. `19` en binario es `0001 0011`, y `6` es `0000 0110`.
2. `-6` en 2-s complement es `1111 1010`.
3. Sumamos el numerador y el `-6` (descartando el carry):
```
 0001 0011 <- numerador
+1111 1010 <- 2sc 6
----------
 0000 1101 (q=1)
```
4. Comprobamos si el resultado que nos ha dado es menor a nuestro denominador (`0000 0110`).\
   En este caso, `0000 1101 > 0000 0110`, así que debemos volver a realizar la suma, con el resultado.
```
 0000 1101 <- resultado op1
+1111 1010 <- 2sc 6
----------
 0000 0111 (q=2)
```
   En todos los ciclos, debemos aumentar `q` en 1, que será nuestro cociente.
5. Volvemos a realizar la comprobación. Como `0000 0111 > 0000 0110` realizamos otra vez el cálculo.
```
 0000 0111 <- resultado op2
+1111 1010 <- 2sc 6
----------
 0000 0001 (q=3)
```
6. Ahora sí que sí, `0000 0001 < 0000 0110`, así que podemos dar nuestra operación como finalizada.
7. Nuestro cociente será por lo tanto `3`, y nuestro resto `1`.

# Algoritmo
Para obtener el 2s complement en Verilog, usamos la instrucción `~` (que invierte los bits), y sumamos `1`. Por ejemplo, la instrucción para obtener el 2s-complement de `Den` va a ser:
```verilog
(~Den+1)
```
## Estados
Vamos a definir cuatro estados en los cuales va a poder estar el chip:
1. Estado `S0`: Standby. Espera al estímulo de `Start` para empezar a computar.
2. Estado `S1`: Configuración inicial. Se obtiene el 2s-complement del denominador, y se inicializan los contadores.
3. Estado `S2`: Se realiza la operación de suma. Comprueba el resultado, y cambia al siguiente estado (`S2`) en caso de haber terminado la operación.
4. Estado `S3`: Actualiza la salida con el resultado de la operación. Notifica con `Done`, y reinicia al estado `S0`.
