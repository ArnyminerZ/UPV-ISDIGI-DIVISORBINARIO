class Bus;
randc logic [31:0] valor;
constraint positivos {valor[31] == 1'b1;}
constraint negativos {valor[31] == 1'b0;}
endclass

module banco_de_pruebas;

reg CLK, RSTa, Start;
reg [31:0] Num, Den;
wire Done;
wire [31:0] Coc, Res, target;

event comprobar;
covergroup Valores_num;
    coverpoint Num;
endgroup
covergroup Valores_den;
    coverpoint Den;
endgroup

// Declaración de objetos
Bus bus_inst;
Valores_num valn;
Valores_den vald;

// Declaración de módulos
Divisor_Algoritmico #(
    .tamanyo(32)
) divisor (
    .CLK(CLK),
    .RSTa(RSTa),
    .Start(Start),
    .Num(Num),
    .Den(Den),

    .Coc(Coc),
    .Res(Res),
    .Done(Done)
);
assign target=(Num/Den);

// Reloj
always begin
    CLK = 1'b0;
    CLK = #50 1'b1;
    #50;
end

// Reinicio inicial
initial begin
    RSTa = 1'b0;
    #1 RSTa = 1'b1;
    #99 RSTa = 1'b0;
end

// Bloque de código principal
initial begin
    $display("> Inicializando testbench...");

    // Instanciamos el generador de valores aleatorios
    bus_inst = new;
    // Instanciamos los covergroup
    valn = new;
    vald = new;
    Start = 0'b0;
    Num = 32'd64;
    Den = 32'd2;

    repeat (3) @(posedge CLK); // Esperamos tres ciclos

    $display("> Arrancando primer ciclo...");
    Start <= 0'b1;  // Iniciamos el programa
    @(posedge CLK)  // Esperamos un ciclo
    Start <= 0'b1;
    $display("  Esperando...");
    @(posedge Done); // Esperamos a que termine
    $display("  Comprobando...");
    -> comprobar;
    @(negedge Done);
    $display("  Primer ciclo completado!");

    while (valn.get_coverage() < 40) begin
        bus_inst.pares.constraint_mode(0);
        $display("> Probando con impares...");
        assert (bus_inst.randomize()) else $fatal("! Randomization failed");
        Num = bus_inst.valor;
        valn.sample();
        
        Start <= 0'b1;  // Iniciamos el programa
        @(posedge CLK)  // Esperamos un ciclo
        Start <= 0'b1;
        @(posedge Done); // Esperamos a que termine
        -> comprobar;
        @(negedge Done);
    end
    $display("  Impares completado!");
    $stop;
end

always @(comprobar) begin
    @(posedge CLK);
    assert (Coc == target) else $error("Operación mal realizada. %d/%d=%d != %d", Num, Den, target, Coc);
end

endmodule