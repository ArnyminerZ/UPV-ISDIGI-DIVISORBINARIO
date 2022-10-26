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
logic [tamanyo-1:0] mem, c2s;

// Contenedor del contador para el cociente
logic [tamanyo-1:0] q;

logic [tamanyo-1:0] posDen;

logic signNum, signDen;

// Aquí viene lo chido
always_ff @(posedge CLK, negedge RSTa) begin
    // Reinicia el sistema si se llama por RSTa
    if (!RSTa) begin
        state <= S0;
    end
    else
    case (state)
        // * Estado 1 - Standby
        S0: begin
        Done <= 1'b0;
        if (Start == 1'b1) begin
            // Guardamos el signo de ambos operandos
            signNum <= !Num[tamanyo-1];
            signDen <= !Den[tamanyo-1];

            if (!Den[tamanyo-1]) begin
                c2s <= (~Den+1);
                posDen <= Den;
            end
            else begin
                c2s <= Den;
                posDen <= (~Den+1);
            end
            if (!Num[tamanyo-1]) begin
                mem <= Num;
            end
            else begin
                mem <= (~Num+1);
            end
            q <= 0;
            state <= S1;
        end
        end

        // * Estado 2 - Actualización de los valores
        S1: begin
        if (mem < posDen)
            state <= S3;
        else begin
            q <= q + 1;
            state <= S2;
        end
        end

        // * Estado 3 - Operación de suma
        S2: begin
        mem <= mem + c2s; // Realizamos la suma
        state <= S1;
        end
        
        // * Estado 4 - Fin
        S3: begin
        Done <= 1'b1;
        Coc <= (signNum == signDen) ? q : (~q+1);
        Res <= (!signNum) ? (~mem+1) : mem;
        state <= S0;
        end
    endcase
end
endmodule
