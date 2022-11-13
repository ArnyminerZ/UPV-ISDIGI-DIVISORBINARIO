module Divisor_Algoritmico #(
    // El tamaño en bits del divisor
    parameter integer tamanyo = 32,

    // Constantes de estado
    parameter S0 = 2'd0,
    parameter S1 = 2'd1,
    parameter S2 = 2'd2,
    parameter S3 = 2'd3
)(
    // ! Entradas ! \\
    input CLK, RSTa, Start,
    input logic [tamanyo-1:0] Num, Den,

    // ! Salidas ! \\
    output logic [tamanyo-1:0] Coc, Res,
    output logic Done
);
// Contenedor del estado
logic [1:0] state;

// Contenedor del valor de 2s complement que se está usando (ver README.md)
logic [tamanyo-1:0] num_c2s, den_c2s;

// Contenedor del contador para el cociente
logic [tamanyo-1:0] q;

// Para guardar el valor absoluto del denominador
logic [tamanyo-1:0] den_abs;

// Guardamos el signo de los valores de entrada
logic signNum, signDen;

// Aquí viene lo chido
always_ff @(posedge CLK, negedge RSTa) begin
    // Reinicia el sistema si se llama por RSTa
    if (!RSTa) begin
        // Reiniciamos todas las salidas a 0
        {Coc, Res, Done} <= '0;
        // Para reiniciar establecemos el estado en el inicial
        state <= S0;
    end
    else
    case (state)
        // * Estado 1 - Standby
        S0: begin
        Done <= 1'b0;
        // Esperamos a que se de la orden de iniciar
        if (Start == 1'b1) begin
            // Guardamos el signo de ambos operandos
            signNum <= !Num[tamanyo-1];
            signDen <= !Den[tamanyo-1];

            // Si el denominador es positivo, calculamos el 2s complement
            // del número, y guardamos el denominador dado tal cual.
            if (!Den[tamanyo-1]) begin
                den_c2s <= (~Den+1);
                den_abs <= Den;
            end
            // Si el denominador es negativo, el 2s complement ya está hecho
            // pero debemos deshacerlo para guardar el valor absoluto, es
            // decir, como positivo.
            else begin
                den_c2s <= Den;
                den_abs <= (~Den+1);
            end

            // Repetimos el mismo procedimiento que antes, pero ahora no es
            // necesario guardar el 2s complement.
            if (!Num[tamanyo-1]) begin
                num_c2s <= Num;
            end
            else begin
                num_c2s <= (~Num+1);
            end

            // Reiniciamos el contador de cociente
            q <= 0;
            // Cambiamos al siguiente estado
            state <= S1;
        end
        end

        // * Estado 2 - Actualización de los valores
        S1: begin
        // Si el 2s complement el numerador es menor al valor absoluto del
        // numerador, hemos terminado, pasa al último estado.
        if (num_c2s < den_abs)
            state <= S3;
        else
        // De lo contrario, augmenta el cuociente, y cambia al siguiente estado
        begin
            q <= q + 1;
            state <= S2;
        end
        end

        // * Estado 3 - Operación de suma
        S2: begin
        // Sumamos el 2s complement del denominador al del numerador
        num_c2s <= num_c2s + den_c2s; // Realizamos la suma
        // Volvemos al estado anterior
        state <= S1;
        end
        
        // * Estado 4 - Fin
        S3: begin
        // Recordamos como comprobamos que una división es correcta:
        //   Coc*Den+Res = Num
        // Por lo tanto, el cociente va a ser negativo si el signo del
        // numerador es igual al denominador.
        Coc <= (signNum == signDen) ? q : (~q+1);
        // El residuo va a ser negativo si el numerador es positivo
        Res <= (!signNum) ? (~num_c2s+1) : num_c2s;
        // Notificamos que se ha terminado
        Done <= 1'b1;
        // Reiniciamos el estado
        state <= S0;
        end
    endcase
end
endmodule
