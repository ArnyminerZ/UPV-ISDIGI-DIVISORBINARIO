module Divisor_Segmentado 

// Declaramos aquí los parameters que vayamos a usar -->
#(
    parameter tamanyo = 32 ,        // El tamaño es de 32 bits o 16 bits (Por lo que lo iniciamos a 32 inicialmente)
)

// Declaramos aquí entradas y salidas --> 
(

	// Entradas --> 
    input logic CLK , RSTa , Start ,  // Declaramos la entrada de reloj , el Reset high lvl y la entrada higg lvl de comienza
    input logic [tamanyo-1:0] Num , Den , // Declaramos las entradas del numerador(Num) y del denominador (Den)

    // Outputs -->
    output logic Done ,  // Declaramos la salida Done para ver cuando justo acaba de hacer el divisor
    output logic [tamanyo-1:0] Coc , Res    // Declaramos las salidas del cociente (Coc) 
                                            // y  del Resto (Res) del resultado de la división entre 
                                            // el numerador y el divisor

);

/* Queremos realizar un Divisor Segmentado, es decir un divisor algoritmico pero que realize dicha 
   operación por ciclo de reloj.

   Observando el esquema del ASM, necesitaríamos 4 estados, es decir 2^2 combinaciones, con 2 bits.
   El número de etapas que están imbolucradas son 16 etapas, es decir se hacen 15 iteraciones en el loop
   más la etapa del 'idle'.
   Los estados van a ser 'START' , 'Reg' , 'Sal' , 'X_reg'

   ! ¿ Como organizamos el Control Path ?
El control path al final es quien organiza, administra y controla el estado.
La señal se sensibilidad del control path será la propia entrada start que se va a alimentar en su etapa inicial.

   ! ¿ Como organizamos el Data Path ?
El data path al final es quien ejecuta tods los cambios en tods las variables existentes en el diseño.
*/

// Declaramos los estados como base logic -->

logic [etapas-1:0] START ;  // Estado de inicio
logic [etapas:0][3:0] Sal ; // Estado de salida
logic [etapas-1:0][8:0] Reg ;    // Estado de 
logic [etapas-1:0][8:0] X_reg ;  // Estado de

always_ff @(posedge CLK or posedge RSTa) 
begin
    
end 