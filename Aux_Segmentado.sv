module Aux_Segmentado (
    // ! Entradas ! \\
    input logic CLK, RSTa, Start,
    input logic SignNum, SignDen,
    input logic [`LAST_BIT:0] Q, M, ACCU,

    // ! Salidas ! \\
    output logic [`LAST_BIT:0] Q_out, M_out, ACCU_out,
    output logic SignNum_out, SignDen_out,
    output logic Done
);

logic [`LAST_BIT:0] ACCU_int, Q_int;

assign {ACCU_int, Q_int} = {ACCU[`BIT_SIZE-2:0],Q,1'b0};

always_ff @(posedge CLK, negedge RSTa) begin
    // Para reiniciar el módulo, borramos el valor de todas las salidas
    if (!RSTa)
        {Q_out, M_out, ACCU_out, SignNum_out, SignDen_out, Done} = '0;
    else begin
        M_out <= M;
        SignNum_out <= SignNum;
        SignDen_out <= SignDen;

        Q_out <= (ACCU_int >= M) ? Q_int + 1 : Q_int;
        ACCU_out <= (ACCU_int >= M) ? ACCU_int-M : ACCU_int;

        Done <= Start;
    end
end

endmodule
