module Divisor_Algoritmico #(
    // El tamaño en bits del divisor
    parameter integer tamanyo = 32,

    // Constantes de estado
    parameter D0 = 2'd0,
    parameter D1 = 2'd1,
    parameter D2 = 2'd2,
    parameter D3 = 2'd3
)(
    // ! Entradas ! \\
    input CLK, RSTa, Start,
    input logic [tamanyo-1:0] Num, Den,

    // ! Salidas ! \\
    output logic [tamanyo-1:0] Coc, Res,
    output logic Done
);
logic SignNum, SignDen;
logic [1:0] state;
logic [tamanyo-1:0] ACCU, Q, M;
logic [tamanyo-1:0] CONT;

// Aquí viene lo chido
always_ff @(posedge CLK, negedge RSTa) begin
    // Reinicia el sistema si se llama por RSTa
    if (!RSTa) begin
        state <= D0;
    end

    case (state)
        // * Estado 1
        D0: begin
        Done <= 1'b0;
        if (Start == 1'b1) begin
            ACCU <= '0;
            // Reiniciamos el contador al número máximo de ciclos a realizar
            CONT <= tamanyo-1;

            // Como trabajamos en 2s complement, el primer bit representa el signo del número
            SignNum <= Num[tamanyo-1];
            SignDen <= Den[tamanyo-1];

            // Se obtiene el 2s complement del número.
            // Si es positivo, no se hace nada, de lo contrario, se invierte y se le añade 1
            Q <= Num[tamanyo-1] ? (~Num+1) : Num;
            M <= Den[tamanyo-1] ? (~Den+1) : Den;
        end
        state <= D1;
        end

        // * Estado 2
        D1: begin
        {ACCU, Q} <= {ACCU[tamanyo-2:0], Q, 1'b0};
        state <= D2;
        end

        // * Estado 3
        D2: begin
        CONT <= CONT - 1;
        if (ACCU >= M) begin
            Q <= Q + 1;
            ACCU <= ACCU - M;
        end
        // Si el contador llega a 0, finaliza
        if (CONT != 0)
            state <= D1;
        else
            state <= D3;
        end

        // * Estado 4
        D3: begin
        Done <= 1'b1;
        Coc <= (SignNum^SignDen) ? (~Q+1) : Q;
        Res <= SignNum ? (~ACCU + 1) : ACCU;
        end
    endcase
end
endmodule
