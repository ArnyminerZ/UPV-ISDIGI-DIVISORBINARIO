module Aux_Segmentado #(
    parameter integer tamanyo = 32
)(
    // ! Entradas ! \\
    input logic CLK, RSTa, Start,
    input logic [tamanyo-1:0] Q,
    input logic [tamanyo-1:0] Den_abs, Den_c2s,
    input logic [tamanyo-1:0] Num_c2s,

    // ! Salidas ! \\
    output logic [tamanyo-1:0] Q_out,
    output logic [tamanyo-1:0] Num_c2s_out,
    output logic Done
);

always_ff @(posedge CLK, negedge RSTa) begin
    // Para reiniciar el módulo, borramos el valor de todas las salidas
    if (!RSTa)
        {Q_out, Num_c2s_out, Done} = '0;
    else begin
        // Transferimos el estado
        Num_c2s_out <= (Num_c2s < Den_abs) ? (Num_c2s + Den_c2s) : Num_c2s;
        Q_out       <= (Num_c2s < Den_abs) ? Q                   : (Q + 1);
        Done        <= (Num_c2s < Den_abs) ? 1'b0                : 1'b1;
    end
end

endmodule
