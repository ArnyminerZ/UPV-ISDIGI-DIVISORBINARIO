`include "Aux_Segmentado.sv"

module Dividor_Segmentado #(
    parameter integer tamanyo = 32
) (
   // Declaramos aquí entradas y salidas --> 

	// ! Entradas --> 
    input CLK , RSTa , Start ,  // Declaramos la entrada de reloj , el Reset high lvl y la entrada higg lvl de iniciación de la operación(Start)
    input logic [tamanyo-1:0] Num , Den , // Declaramos las entradas del numerador(Num) y del denominador (Den) de 32 bits de tamaño [31:0]
    // ! Outputs -->
    output logic Done ,  // Declaramos la salida Done para ver cuando justo acaba de hacer la división
    output logic [tamanyo-1:0] Coc , Res    // Declaramos las salidas del cociente (Coc) 
                                            // y  del Resto (Res) del resultado de la división entre 
                                            // el numerador y el divisor   (32 bits también)      
);

localparam etapas=tamanyo; //2**tamanyo;

logic [etapas-1:0][tamanyo-1:0] ACCU, Q, M;  // Declaramos el acumulador, el contador del cociente y el del resto
logic [etapas-1:0] SignNum, SignDen, Done_mem;  // Declaramos los array del signo del numerador, denominador y el estado de paso realizado en memoria

/* 
   Queremos realizar un Divisor Segmentado, es decir un divisor algoritmico pero que realize dicha 
   operación completa por ciclo de reloj , en vez de cada parte de la operación por ciclo de reloj.

   Este divisor segmentado lo realizaremos haciendo uso de un bucle 'for' para que cada vez que se quiera hacer 
   la operación se haga en dicho golpe de reloj cada paso hasta comletar el resultado completo de la división.

   Para ello, también implementamos la función generate que ayuda  a la implementación de varias acciones de forma única.
   Es ahí donde atacaremos con los bucles 'for'.

*/

// Declaramos la variable del generate (i)
genvar i ;
generate
   for(i = 0; i<(etapas+1) ; i = i+1)  // Empezamos con i=0 hasta que i llegue como máximo a 32, va incrementando el bit de 1 en 1 (i=i+1)
      begin :generador
         //  Como se van a generar 32 módulos, usaremos un case/default para realizarlo, donde solo
         // se llegarán a declarar los módulos 0 y 32 de forma directa y en el default estarán los
         // 30 módulos restantes ya que estos dependen dirécatemente del módulo anterior y operan de igual forma
         // (Los únicos módulos en los que se procede de forma diferente son en el primero(0) y úlimo(tamanyo) ).

         case(i)  // En caso de estar en módulo 'i' se realiza las siguientes acciones.
 
            0:    // Módulo en cuanto la cuenta está sin empezar y justo se Activa la señal de cmoienzo.
               Aux_Segmentado #(
                  .tamanyo(tamanyo)
               ) Comienzo_Division (     // Declaramos la primera instancia del divisor auxiliar que permite
                                                                           // iniciar la cadena de sumadores.
                  .CLK(CLK),                             // Conectamos el CLK de la instancia al del módulo.
                  .RSTa(RSTa),                           // Conectamos el RSTa de la instancia al del módulo.
                  .Start(Start),                         // Conectamos el Start de la instancia al del módulo.
                  .SignNum(Num[tamanyo-1]),              // Conectamos SignNum con el valor de Num y solo buscamos para el bit más significativo , es decir, el que nos determina si es un valor positivo (0) 0 negativo (1).
                  .SignDen(Den[tamanyo-1]),              // De igaul forma que la anterior pero para el signo del denominador .
                  .ACCU('0),                             // El acumulador al principio está a cero total ya que no se ha realizado de momento ninguna acción, pero si que cambiará el valor para la salida del propio acumulador.
                  .Q(Num[tamanyo-1] ? (~Num+1) : Num),   //
                  .M(Den[tamanyo-1] ? (~Den+1) : Den),   //
                  .ACCU_out(ACCU[i]),                    // La salida del ACCU está conectada con el valor que tenga de entrada para el estado en el que se encuentre, que en este caso (i=0)
                  .Q_out(Q[i]),                          // Q_out coge la salida de Q a instancia de (i = 0)
                  .M_out(M[i]),                          // M_out se conecta a la propia entrada en el estado inicial (i = 0)
                  .SignNum_out(SignNum[i]),              // La salida del signo en Num y Den coge los valor de las entradas para (i = 0)
                  .SignDen_out(SignDen[i]),
                  .Done(Done_mem[i])                     // El valor que se guarda en Done va ha ser el valor que tenga asignado a primer momento (i = 0)
               );

            etapas:    // Módulo en cuanto la cuenta llega a su fin y se completa la división, aquí asignamos el valor final -->
               always_ff @(posedge CLK,negedge RSTa) // Declaramos un bloque procedurar always_ff en el que se activa a ciclo de reloj ascendente
               begin                                 // o cuando se active el reseteo de la operación. 
                  if(!RSTa)            // Si se quiere resetear -->
                     begin
                        Coc <= '0;     // Llenamos el cociente de ceros (ya que se inicia toda la operación se queda a full ceros)
                        Res <= '0;     // Ocurre lo mismo con los bits del 'resto'
                        Done <= 1'b0;  // Ponemos a cero el output de 'trabajo realizado'
                     end
                  else                 // Si no se activa el reset , sino que la operación va a quedar como concluida -->
                     begin 
                        Coc <= (SignNum[i-1]^SignDen[i-1]) ? (~Q[i-1]+1) : Q[i-1];  // Si se cumple que ((SignNum[i-1] XOR SignDen[i-1]) == 1) entonces el valor de cociente cogerá el resultado negado del contador del cociente en ese instante (~Q[i-1]), pero con un aumento (~Q[i-1]+1), y si no se cumple coge tal cual el valor en ese instante del cociente.
                        Res <= (SignNum[i-1]) ? (~ACCU[i-1]+1) : ACCU[i-1];         // Si se cumple que el signo está activo en ese instante, se le asiganrá al resto el valor negado y aumentado del acumulador en ese instante de tiempo y si no se cumple, cogerá el valor actual de (ACCU[i-1])
                        Done <= Done_mem[i-1];        // Actualizamos el valor del start con el valor que se haya guardado en el último módulo realizado en el default.
                     end
               end

            default:    // Con el default entramos en cualquier módulo diferente del inicial(0) y el final(etapas)
               Aux_Segmentado #(
                  .tamanyo(tamanyo)
               ) Siguiendo_Division (     // Declaramos la segunda instancia del divisor auxiliar que permite
                                                                           // continuar la cadena de sumadores desde i=1 hasta i=31.
                  .CLK(CLK),                    // Conectamos el CLK de la instancia al del módulo
                  .RSTa(RSTa),                  // Conectamos el RSTa de la instancia al del módulo
                  .Start(Done_mem[i-1]),        // Conectamos el Start de la instancia al valor anterior asignado en Done_mem (ya que Done_mem actúa como start para los demás procesos que no sean el inicial)
                  .SignNum(SignNum[i-1]),       // Como estamos en los módulo comprendidos en [1,LAST_BIT], el valor de signo actual será otorgado por su justo inmediato anterior
                  .SignDen(SignDen[i-1]),       // Igual ocurrirá con el signo del denominador
                  .ACCU(ACCU[i-1]),             // Igual ocurre con el bit del acumulador
                  .Q(Q[i-1]),                   // Guardamos  Q como su valor previo
                  .M(M[i-1]),                   // Guardamos  M como su valor previo
                  .ACCU_out(ACCU[i]),           // En cambio, para la salida se guardará el que justo vayamos a utilizar para el siguiente módulo
                  .Q_out(Q[i]),                 // La salida del registro Q se le asignará el valor justo que tenga en ese preciso módulo (Que fue asignado en el módulo justo anterior)
                  .M_out(M[i]),                 // Lo mismo ocurre con la salida del registro M
                  .SignNum_out(SignNum[i]),     // Las salidas de los signos tienen el valor actual
                  .SignDen_out(SignDen[i]),     // Las salidas de los signos tienen el valor actual  
                  .Done(Done_mem[i])            // Guardamos el último valor de lo que haya guardado en Done_mem

               );


         endcase     // Terminamos el bucle case/default
      end
endgenerate          // Terminamos la función generate

endmodule 
