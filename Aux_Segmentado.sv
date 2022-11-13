module Aux_Segmentado #(
    parameter integer tamanyo = 32
)(
    // ! Entradas ! \\
    input CLK, RSTa, Start,
    input signNum, signDen,
    input [tamanyo-1:0] Num, Den,
    input [tamanyo-1:0] Q,
    input [tamanyo-1:0] Den_abs, Den_c2s,
    input [tamanyo-1:0] Num_c2s,

    // ! Salidas ! \\
    output logic signNum_out, signDen_out,
    output logic [tamanyo-1:0] Coc, Res,
    output logic [tamanyo-1:0] Q_out,
    output logic [tamanyo-1:0] Den_abs_out, Den_c2s_out,
    output logic [tamanyo-1:0] Num_c2s_out,
    output logic Done
);

always_ff @(posedge CLK, negedge RSTa) begin
    // Para reiniciar el módulo, borramos el valor de todas las salidas
    if (!RSTa)
        {signNum_out, signDen_out, Coc, Res, Q_out, Den_abs_out, Den_c2s_out, Num_c2s_out, Done} = '0;
    else begin
        // Transferimos el estado
        Done <= Start;

        if (Num_c2s < Den_abs)
            Num_c2s_out <= Num_c2s + Den_c2s;
        else
        begin
            Q_out <= Q + 1;
            Coc <= (signNum == signDen) ? Q            : (~Q+1);
            Res <= (!signNum)           ? (~Num_c2s+1) : Num_c2s;
            Done <= 1'b1;
        end
    end
end

endmodule
