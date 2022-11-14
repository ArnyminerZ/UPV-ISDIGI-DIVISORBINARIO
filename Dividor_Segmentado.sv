`ifdef BIT_SIZE
`else
// Parámetros para la sintésis. Sólo aplican si no se han definido ya, es decir,
// si no estamos ejecutando desde el testbench.
`define BIT_SIZE 16
`define LAST_BIT `BIT_SIZE-1
`define BIN_SIZE 2**`LAST_BIT
`endif

`include "Aux_Segmentado.sv"

module Dividor_Segmentado (
   // Declaramos aquí entradas y salidas --> 

	// Entradas --> 
    input CLK , RSTa , Start ,  // Declaramos la entrada de reloj , el Reset high lvl y la entrada higg lvl de iniciación de la operación(Start)
    input logic [`LAST_BIT:0] Num , Den , // Declaramos las entradas del numerador(Num) y del denominador (Den) de 32 bits de tamaño [31:0]
    // Outputs -->
    output logic Done ,  // Declaramos la salida Done para ver cuando justo acaba de hacer la división
    output logic [`LAST_BIT:0] Coc , Res    // Declaramos las salidas del cociente (Coc) 
                                            // y  del Resto (Res) del resultado de la división entre 
                                            // el numerador y el divisor   (32 bits también)      
);

localparam etapas=`BIT_SIZE; //2**`BIT_SIZE;

logic [etapas-1:0][`LAST_BIT:0] ACCU, Q, M;
logic [etapas-1:0] SignNum, SignDen, Done_mem;

/* 
   Queremos realizar un Divisor Segmentado, es decir un divisor algoritmico pero que realize dicha 
   operación completa por ciclo de reloj , en vez de cada parte de la operación por ciclo de reloj.

   Este divisor segmentado lo realizaremos haciendo uso de un bucle 'for' para que cada vez que se quiera hacer 
   la operación se haga en dicho golpe de reloj cada paso hasta comletar el resultado completo de la división.

   Para ello, también implementamos la función generate que ayuda  a la implementación de varias acciones de forma única.
   Es ahí donde atacaremos con lso bucles 'for'.

*/

// Declaramos la variable del generate (i)
genvar i ;
generate
   for(i = 0; i<(etapas+1) ; i = i+1)  // Empezamos con i=0 hasta que i llegue como máximo a 32, va incrementando el bit de 1 en 1 (i=i+1)
      begin :generador
         //  Como se van a generar 32 módulos, usaremos un case/default para realizarlo, donde solo
         // se llegarán a declarar los módulos 0 y 32 de forma directa y en el default estarán los
         // 30 módulos restantes ya que estos dependen dirécatemente del módulo anterior y operan de igual forma
         // (Los únicos módulos en los que se procede de forma diferente son en el primero(0) y úlimo(`BIT_SIZE) ).

         case(i)

            0:    // Módulo en cuanto la cuenta está sin empezar y justo se Activa la señal de cmoienzo
               Aux_Segmentado Comienzo_Division (     // Declaramos la primera instancia del divisor auxiliar que permite
                                                                           // iniciar la cadena de sumadores
                  .CLK(CLK),     // Conectamos el CLK de la instancia al del módulo
                  .RSTa(RSTa),   // Conectamos el RSTa de la instancia al del módulo
                  .Start(Start), // Conectamos el Start de la instancia al del módulo
                  .SignNum(Num[`LAST_BIT]),
                  .SignDen(Den[`LAST_BIT]),
                  .ACCU('0),
                  .Q(Num[`LAST_BIT] ? (~Num+1) : Num),
                  .M(Den[`LAST_BIT] ? (~Den+1) : Den),
                  .ACCU_out(ACCU[i]),
                  .Q_out(Q[i]),
                  .M_out(M[i]),
                  .SignNum_out(SignNum[i]),
                  .SignDen_out(SignDen[i]),
                  .Done(Done_mem[i])
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
                        Coc <= (SignNum[i-1]^SignDen[i-1]) ? (~Q[i-1]+1) : Q[i-1];
                        Res <= (SignNum[i-1]) ? (~ACCU[i-1]+1) : ACCU[i-1];
                        Done <= Done_mem[i-1];
                     end
               end

            default:
               Aux_Segmentado Siguiendo_Division (     // Declaramos la segunda instancia del divisor auxiliar que permite
                                                                           // continuar la cadena de sumadores desde i=1 hasta i=31.
                  .CLK(CLK),     // Conectamos el CLK de la instancia al del módulo
                  .RSTa(RSTa),   // Conectamos el RSTa de la instancia al del módulo
                  .Start(Done_mem[i-1]),  // Conectamos el Start de la instancia al ---------
                  .SignNum(SignNum[i-1]),
                  .SignDen(SignDen[i-1]),
                  .ACCU(ACCU[i-1]),
                  .Q(Q[i-1]),
                  .M(M[i-1]),
                  .ACCU_out(ACCU[i]),
                  .Q_out(Q[i]),
                  .M_out(M[i]),
                  .SignNum_out(SignNum[i]),
                  .SignDen_out(SignDen[i]),
                  .Done(Done_mem[i])

               );


         endcase
      end
endgenerate

endmodule 
