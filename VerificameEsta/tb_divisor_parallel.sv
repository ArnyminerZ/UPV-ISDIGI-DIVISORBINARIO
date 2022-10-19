module tb_divisor_parallel();
logic RSTa, Start, Done, CLK;
logic [15:0] Num, Den, Coc, Res;
localparam T=20;

Divisor_Algoritmico d1(
	.CLK(CLK),
	.Start(Start),
    .Done(Done),
    .Num(Num),
    .Den(Den),
    .Coc(Coc),
    .Res(Res),
    .RSTa(RSTa));

initial
begin
    RSTa=1'b0;
	 CLK=1'b0;
    Start=1'b0;
    Num=16'b0;
    Den=16'b0;
    #(T*2);
    RSTa=1'b1;

    //Ambos operandos positivos con resto
    Num=16'd17;
    Den=16'd3;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0; 
    //Ambos operandos negativos con resto
    Num=-16'd23;
    Den=-16'd5;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0;  
    //Ambos operandos positivos sin resto
    Num=16'd15;
    Den=16'd3;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0; 
    //Ambos operandos negativos sin resto
    Num=-16'd20;
    Den=-16'd5;
    #(T);
    Start=1'b1;
    @(posedge Done);
    Start=1'b0; 
    // Numerador positivo y Denominador negativo con resto
    Num = 16'd17;
    Den = -16'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;

    // Numerador positivo y Denominador negativo sin resto

    Num = 16'd18;
    Den = -16'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;

    // Numerador negativo y Denominador positivo con resto

    Num = -16'd17;
    Den = 16'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0;

    // Numerador negativo y Denominador positivo sin resto

    Num = -16'd18;
    Den = 16'd3;
    #(T);
    Start = 1'b1;
    @(posedge Done);
    Start = 1'b0; 

	$stop;
end

always 
begin
    #(T/2) CLK<=~CLK;
end
endmodule 