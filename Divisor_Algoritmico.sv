module Divisor_Algoritmico #(
    // El tamaño en bits del divisor
    parameter tamanyo = 32,
    // El módulo del tamaño { sqrt(t_mod)=tamanyo }
    parameter t_mod = 5,

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
    output logic [tamanyo-1:0] Coc, Rec,
    output logic Done
);
logic fin, SignNum, SignDen;
logic [1:0] state;
logic [tamanyo-1:0] ACCU;
logic [t_mod-1:0] CONT;

always_ff @(posedge CLK) begin
    case (state)
        D0:
        fin <= 1'b0;
        if (Start == 1'b1) begin
            ACCU <= '0;
            CONT <= tamanyo-1;
        end
        D1:

        D2:

        D3:

    endcase
end
endmodule
