/*
    Declaramos el módulo auxiliar que realiza los módulos desde el primero hasta el justo último de los estados
    que vayamos a implementar según el número de bits que se vayan a asignar (tamaño del array)
*/
module Aux_Segmentado (
    // ! Entradas ! \\
    input logic CLK, RSTa, Start,                   // Declaramos las variables lógicas de reloj, reset y comienzo de la operación de división
    input logic SignNum, SignDen,                   // Declaramos las variables de único bit de los signos del Denominador(Den) y Numerador(Num) {0-->Positivo ; 1-->Negativo}
    input logic [`LAST_BIT:0] Q, M, ACCU,           // Declaramos las variables (Q,M,ACCU) de tamaño a elegir con la definición "LAST_BIT"

    // ! Salidas ! \\
    output logic [`LAST_BIT:0] Q_out, M_out, ACCU_out,  // Declaramos las variables de salidas de (Q,M,ACCU) de igual tamaño a las entradas
    output logic SignNum_out, SignDen_out,              // Declaramos las variables de salida de los signos del numerador y denominador
    output logic Done                                   // Declaramos la variables de salida(Done) que actúa como valor de Start a partir del módulo 1 en adelante
);

logic [`LAST_BIT:0] ACCU_int, Q_int;        // Declaramos los registros internos del acumulador(ACCU) y del cociente(Q), siempre de igual tamaño

assign {ACCU_int, Q_int} = {ACCU[`BIT_SIZE-2:0],Q,1'b0};

always_ff @(posedge CLK, negedge RSTa) begin
    // Para reiniciar el módulo, borramos el valor de todas las salidas
    if (!RSTa)
        {Q_out, M_out, ACCU_out, SignNum_out, SignDen_out, Done} = '0;    // Llenamos a cero todas las variables si se activa la señal de RESET
    else begin      // Si no se pulsa el reset y el reloj Actúa -->
        M_out <= M;                 // El valor del resto de la división queda registrada en la salida(M_out)
        SignNum_out <= SignNum;     // Las salidas de los signos cogen ahora los valores previos/iniciales que tenían
        SignDen_out <= SignDen;     //

        Q_out <= (ACCU_int >= M) ? Q_int + 1 : Q_int;   // Si (ACCU_int>=M) se le asignará a la salida de Q(Q_out) un valor más al valor de Q_interno, y si la condición no se cumple Q_out pillará el valor interno actual de Q sin aumentar nada.
        ACCU_out <= (ACCU_int >= M) ? ACCU_int-M : ACCU_int;    // Si (ACCU_int>=M) le asignamos a la salida del acumulador(ACCU_out) justo el calor interno del acumulador menos el valor del resto, sino se cumple dicha condición coge el valor interno del acumulador.

        Done <= Start;      // Guardamos en Done la señal de start, y ahora Done actuará como el propio Start
    end
end

endmodule
