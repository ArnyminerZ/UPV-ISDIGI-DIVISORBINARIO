module Divisor_Segmentado 

// Declaramos aquí los parameters que vayamos a usar -->
#(
    parameter tamanyo = 4 ,        // El tamaño es de 32 bits o 16 bits (Por lo que lo iniciamos a 32 inicialmente)
    localparam etapas = 2**tamanyo , // el numero de etapas es 2^4 (16 etapas en total)
)

// Declaramos aquí entradas y salidas --> 
(

	// Entradas --> 
    input logic CLK , RSTa , START ,  // Declaramos la entrada de reloj , el Reset high lvl y la entrada higg lvl de comienza
    input logic [tamanyo-1:0] Num , Den , // Declaramos las entradas del numerador(Num) y del denominador (Den)
    input logic [7:0] X , // X es la señal de la cual yo quiero sacar la raiz cuadrada
    // Outputs -->
    output logic FIN , // Señal que determina el fin de la cuenta
    output logic [3:0] COUNT , // La señal de contador de 4 bits ya que cuenta hasta 15 como máximo [0:15]
    output logic Done ,  // Declaramos la salida Done para ver cuando justo acaba de hacer el divisor
    output logic [tamanyo-1:0] Coc , Res    // Declaramos las salidas del cociente (Coc) 
                                            // y  del Resto (Res) del resultado de la división entre 
                                            // el numerador y el divisor

);

/* Queremos realizar un Divisor Segmentado, es decir un divisor algoritmico pero que realize dicha 
   operación por ciclo de reloj.

   Observando el esquema del ASM, necesitaríamos 4 estados, es decir 2^2 combinaciones, con 2 bits.
   El número de etapas que están imvolucradas son 16 etapas, es decir se hacen 15 iteraciones en el loop
   más la etapa del 'idle'.
   Los estados van a ser 'START' , 'Reg' , 'Sal' , 'X_reg'

   ! ¿ Como organizamos el Control Path ?
El control path al final es quien organiza, administra y controla el estado.
La señal se sensibilidad del control path será la propia entrada start que se va a alimentar en su etapa inicial.

   ! ¿ Como organizamos el Data Path ?
El data path al final es quien ejecuta tods los cambios en tods las variables existentes en el diseño.
*/

// Declaramos los estados en base logic -->

logic [etapas-1:0] start ;  // Estado de inicio
logic [etapas:0][3:0] Sal ; // Estado de salida
logic [etapas-1:0][8:0] Reg ;    // Estado del registro ( por donde vamos)
logic [etapas-1:0][8:0] X_reg ;  // Estado del registro de X (la señal de a cual se quiere hacer la raiz cuadrada)

always_ff @(posedge CLK or negedge RSTa) // En este always solo se llegarán a cambiar los estados. ( Es decir actuará como control path)
begin
    if(!RSTa) //En este caso reiniciamos cada estado  a 0.
      begin
         Reg <= 0 ;           // El valor del estado registro a  cero.
         start <= 0 ;          // El valor del estado start a cero.
         Sal <=  0 ;          // El valor del estado Sal a cero.
         X_reg <=  0 ;        // El valor del estado X_reg a cero.
      end
   else        // Si no se presiona el reset --> incrementamos el estado start de 16 etapas con el valor inicial START
      begin
         start[etapas-1:0] <= START ;      // Una vez inicializado trabajamos trabajamos
         if(START) // Si el valor de START se activa --> cambian los valores de los estados -->
            begin
               Reg[etapas-1:0] <= 8'b1 ;           // El valor del estado registro coge un 1 en el tamaño de 8 bits que tiene.
               start[etapas-1:0] <= START ;          // El valor del estado start coge el bit START.
               Sal[etapas-1:0] <=  8'b0 ;          // El valor del estado Sal a cero ya que aun no ha llegado a su final de cuenta.
               X_reg[etapas-1:0] <=  X ;        // El valor del estado X_reg coge el valor del cable X       .

            end

// Ya habiendose fumado la primera etapa en lo anterior, procedemos con la funcionalidad de las demás etapas --> 

         for (int i=(etapas-2) ; i>-1 ; i=i-1) // Creamos un bucle for --> se empieza en i=14 , funciona siempre i>-1, ya que entonces ya terminaría, y a cada etapa le resta uno
            begin
               start[i] <= start[i+1] ; // Guardamos en la etapa actual del estado, la del estado justo anterior.
               if(start[i+1]) // Si nos han mandado el estadoa anterior --> actualizamos con los estados previos, los demás estados
                  begin
                     X_reg[i] <= X_reg[i+1] ; // El registro de la señal a analizar tendrá el valor del registro siguiente.
                  end


            end


      end

assign COUNT <= Reg[0] ; // Asignamos el valor del registro en la etapa 0 al contador.
assign FIN <= start[0;] ; // Asignamos el valor del estador start en la etapa inicial al fin de la cuenta [FIN].

endmodule 