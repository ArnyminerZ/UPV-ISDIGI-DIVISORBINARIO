`include "Aux_Segmentado.sv"

module Dividor_Segmentado 

// Declaramos aquí los parameters que vayamos a usar -->
#(
    parameter integer tamanyo = 32         // El tamaño es de 32 bits
)

// Declaramos aquí entradas y salidas --> 
(

	// Entradas --> 
    input logic CLK , RSTa , Start ,  // Declaramos la entrada de reloj , el Reset high lvl y la entrada higg lvl de iniciación de la operación(Start)
    input logic [tamanyo-1:0] Num , Den , // Declaramos las entradas del numerador(Num) y del denominador (Den) de 32 bits de tamaño [31:0]
    // Outputs -->
    output logic Done ,  // Declaramos la salida Done para ver cuando justo acaba de hacer la división
    output logic [tamanyo-1:0] Coc , Res,    // Declaramos las salidas del cociente (Coc) 
                                            // y  del Resto (Res) del resultado de la división entre 
                                            // el numerador y el divisor   (32 bits también)
   logic [tamanyo-1:0] Num_c2s [tamanyo-1:0],
   logic [tamanyo-1:0] Q       [tamanyo-1:0] , 
                                                
   logic [tamanyo-1:0] Done_mem       
);

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
   for(i = 0; i<(tamanyo+1) ; i = i+1)  // Empezamos con i=0 hasta que i llegue como máximo a 32, va incrementando el bit de 1 en 1 (i=i+1)
      begin
         //  Como se van a generar 32 módulos, usaremos un case/default para realizarlo, donde solo
         // se llegarán a declarar los módulos 0 y 32 de forma directa y en el default estarán los
         // 30 módulos restantes ya que estos dependen dirécatemente del módulo anterior y operan de igual forma
         // (Los únicos módulos en los que se procede de forma diferente son en el primero(0) y úlimo(tamanyo) ).

         case(i)

            0:    // Módulo en cuanto la cuenta está sin empezar y justo se Activa la señal de cmoienzo
               Aux_Segmentado #(.tamanyo(tamanyo)) Comienzo_Division (     // Declaramos la primera instancia del divisor auxiliar que permite
                                                                           // iniciar la cadena de sumadores
                  .CLK(CLK),     // Conectamos el CLK de la instancia al del módulo
                  .RSTa(RSTa),   // Conectamos el RSTa de la instancia al del módulo
                  .Start(Start), // Conectamos el Start de la instancia al del módulo
                  .Q('0),
                  .Den_abs(!Den[tamanyo-1] ? Den : (~Den+1)),
                  .Den_c2s(!Den[tamanyo-1] ? (~Den+1) : Den),
                  .Num_c2s(!Num[tamanyo-1] ? Num : (~Num+1)), // Es el sumador para el residuo
                  .Q_out(Q[0]),
                  .Num_c2s_out(Num_c2s[0]),
                  .Done(Done_mem[0])
               );

            (tamanyo):    // Módulo en cuanto la cuenta llega a su fin y se completa la división, aquí asignamos el valor final -->
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
                        Coc <= (!Num[tamanyo-1] == Den[tamanyo-1]) ? Q[i-1] : (~Q[i-1]+1);
                        Res <= (!Num[tamanyo-1]) ? (~Num_c2s[i-1]+1) : Num_c2s[i-1];
                        Done <= Done_mem[i-1]; 
                     end
               end

            default:
               Aux_Segmentado #(.tamanyo(tamanyo)) Siguiendo_Division (     // Declaramos la segunda instancia del divisor auxiliar que permite
                                                                           // continuar la cadena de sumadores desde i=1 hasta i=31.
                  .CLK(CLK),     // Conectamos el CLK de la instancia al del módulo
                  .RSTa(RSTa),   // Conectamos el RSTa de la instancia al del módulo
                  .Start(Done_mem[i-1]),  // Conectamos el Start de la instancia al ---------
                  .Q(Q[i-1]),
                  .Den_abs(!Den[tamanyo-1] ? Den : (~Den+1)),
                  .Den_c2s(!Den[tamanyo-1] ? (~Den+1) : Den),
                  .Num_c2s(Num_c2s[i-1]),
                  .Q_out(Q[i]),
                  .Num_c2s_out(Num_c2s[i]),
                  .Done(Done_mem[i])

               );


         endcase
      end
endgenerate

endmodule 
