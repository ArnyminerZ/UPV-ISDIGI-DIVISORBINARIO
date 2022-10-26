module tb_divisor_parallel #(
    parameter integer tamanyo = 32
)();
logic RSTa, Start, Done, CLK;
logic [tamanyo-1:0] Num, Den, Coc, Res;
localparam T=20;

Divisor_Algoritmico #(
    .tamanyo(tamanyo)
) d1 (
	.CLK(CLK),
	.Start(Start),
    .Done(Done),
    .Num(Num),
    .Den(Den),
    .Coc(Coc),
    .Res(Res),
    .RSTa(RSTa)
);

initial
begin
    $display("Ejecutando tests para", tamanyo, "bits");

    RSTa=1'b0;
	CLK=1'b0;
    Start=1'b0;
    Num='b0;
    Den='b0;
    #(T*2);
    RSTa=1'b1;

    // Ambos operandos positivos sin resto
    Num='d15;
    Den='d3;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0;
    assert (Coc == 5) else $error("El cociente deberia ser 5");
    assert (Res == 0) else $error("El residuo deberia ser 0");

    // Ambos operandos positivos con resto
    Num='d17;
    Den='d3;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0;
    assert (Coc == 5) else $error("El cociente deberia ser 5");
    assert (Res == 2) else $error("El residuo deberia ser 2");


    // Numerador positivo y Denominador negativo sin resto
    Num = 'd15;
    Den = -'d3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;
    assert (Coc == -5) else $error("El cociente deberia ser -5");
    assert (Res == 0) else $error("El residuo deberia ser 0");

    // Numerador positivo y Denominador negativo con resto
    Num = 'd17;
    Den = -'d3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;
    assert (Coc == -5) else $error("El cociente deberia ser -5");
    assert (Res == 2) else $error("El residuo deberia ser 2");


    // Ambos operandos negativos sin resto
    Num=-'d15;
    Den=-'d3;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0; 
    assert (Coc == 5) else $error("El cociente deberia ser 5");
    assert (Res == 0) else $error("El residuo deberia ser 0");

    // Ambos operandos negativos con resto
    Num=-'d23;
    Den=-'d5;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0;  
    assert (Coc == 4) else $error("El cociente deberia ser 4");
    assert (Res == -3) else $error("El residuo deberia ser -3");

    // Numerador negativo y Denominador positivo con resto
    Num = -'d17;
    Den = 'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;
    assert (Coc == -5) else $error("El cociente deberia ser -5");
    assert (Res == -2) else $error("El residuo deberia ser -2");

    // Numerador negativo y Denominador positivo sin resto

    Num = -'d18;
    Den = 'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0; 
    assert (Coc == -6) else $error("El cociente deberia ser -6");
    assert (Res == 0) else $error("El residuo deberia ser 0");

	$stop;
end

always 
begin
    #(T/2) CLK<=~CLK;
end
endmodule 