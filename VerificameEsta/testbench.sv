`include "../Divisor_Algoritmico.sv"

// Se puede definir debug para obtener registros más detallados
`define DEBUG

// Qué valores deben ser probados?
// Numerador positivo, denominador positivo
`define TEST_NUM_POS_DEN_POS
// Numerador positivo, denominador negativo
`define TEST_NUM_POS_DEN_NEG
// Numerador negativo, denominador positivo
`define TEST_NUM_NEG_DEN_POS
// Numerador negativo, denominador negativo
`define TEST_NUM_NEG_DEN_NEG

// El objetivo de coverage
`define TB_COVERAGE 90

// El tamaño de bits que probar
`define BIT_SIZE 16


// * NO CAMBIAR
`define LAST_BIT `BIT_SIZE-1
// TODO: Debería adaptarse a TEST_*
`define BIN_SIZE 2**`LAST_BIT
// * FIN NO CAMBIAR


// La clase bus nos proporciona las constraints que nos permiten
// detallar qué queremos comprobar.
class Bus;
randc logic signed [`LAST_BIT:0] num;
randc logic signed [`LAST_BIT:0] den;

// Para limitar a sólo denominadores positivos o negativos
constraint num_positivo {num[`LAST_BIT] == 1'b0;}
constraint num_negativo {num[`LAST_BIT] == 1'b1;}

// Para limitar a sólo numeradores positivos o negativos
constraint den_positivo {den[`LAST_BIT] == 1'b0;}
constraint den_negativo {den[`LAST_BIT] == 1'b1;}

// Para limitar a resultados sin residuo
constraint div_exactaaa {num%den == 0;}

// Limitamos el valor máximo, para dejar sitio para el signo. No
// desactivar esta constraint.
// Nota:
// - 2^15 = 32768      -> 16 bits
// - 2^31 = 2147483648 -> 32 bits
// constraint lim_grandeee {(abs(num)<32768) && (abs(den)<32768);}
endclass

module banco_de_pruebas;

logic CLK, RSTa, Start;
logic signed [`LAST_BIT:0] Num, Den;
logic Done;
logic signed [`LAST_BIT:0] Coc, Res, target_coc, target_res;

event reset;
event comprobado;

covergroup Valores;
    coverpoint1: coverpoint Num {bins bins1[`BIN_SIZE] = {[0:$]};}
	coverpoint2: coverpoint Den {bins bins2[`BIN_SIZE] = {[0:$]};}
	coverpoint3: cross coverpoint1,coverpoint2;
endgroup

// Declaración de objetos
Bus bus_inst;
Valores vals;

// Declaración de módulos
Divisor_Algoritmico #(
    .tamanyo(`BIT_SIZE)
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

// Reloj
always begin
    CLK = 1'b0;
    CLK = #50 1'b1;
    #50;
end

task iniciar;
    Start <= 1'b0;
    @(posedge CLK); // Esperamos un ciclo
    Start <= 1'b1;  // Iniciamos el reinicio
    @(posedge CLK); // Esperamos un ciclo
    Start <= 1'b0;
endtask

task reiniciar;
    $display("> Reiniciando circuito...");
    RSTa = 1'b0;
    repeat (3) @(posedge CLK); 
    RSTa = 1'b1;
    -> reset;

    repeat (3) @(posedge CLK); // Esperamos tres ciclos
endtask

task esperaAComprobar;
    @(posedge Done); // Esperamos a que termine
    @(negedge Done);
    @(comprobado);
endtask

task actualizarTargets;
    target_coc = (Num/Den);
    target_res = (Num%Den);
endtask

task rutina;
    assert (bus_inst.randomize()) else $fatal("! Randomization failed");
    Num = bus_inst.num;
    assert (bus_inst.randomize()) else $fatal("! Randomization failed");
    Den = bus_inst.den;
    vals.sample();

    actualizarTargets();

    iniciar();
    esperaAComprobar();
endtask

initial reiniciar();

// Bloque de código principal
initial begin
    @(reset); // Esperamos a que se reinicie el sistema

    $display("> Inicializando testbench...");
    $display("  Objetivo coverage:           %d %%", `TB_COVERAGE);
    $display("  Las bin tienen un tamaño de: %d", `BIN_SIZE);

    // Instanciamos el generador de valores aleatorios
    bus_inst = new;
    // Instanciamos los covergroup
    vals = new;
    Start = 1'b0;

    Num = 'd64;
    Den = -'d2;
    actualizarTargets();

    $display("> Arrancando primer ciclo...");
    iniciar();
    $display("  Esperando...");
    esperaAComprobar();
    $display("  Primer ciclo completado!");

    $display("> Simulando...");
    // $display("> Probando con numerador y denominador positivos, division exacta...");
    while (vals.get_inst_coverage() < `TB_COVERAGE) begin
        `ifdef TEST_NUM_POS_DEN_POS
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);
        bus_inst.div_exactaaa.constraint_mode(1);

        rutina();
        `endif
        
        `ifdef TEST_NUM_NEG_DEN_POS
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);
        bus_inst.div_exactaaa.constraint_mode(1);

        rutina();
        `endif
        
        `ifdef TEST_NUM_POS_DEN_NEG
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);
        bus_inst.div_exactaaa.constraint_mode(1);

        rutina();
        `endif
        
        `ifdef TEST_NUM_NEG_DEN_NEG
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);
        bus_inst.div_exactaaa.constraint_mode(1);

        rutina();
        `endif
    end

    $display("  Completado!");

    $stop;
end

// Notifica sobre el progreso de coverage
initial begin
    repeat (100) @(posedge CLK);
    $display("Coverage = %0.2f %%", vals.get_inst_coverage());
end

always @(posedge Done) begin
    @(negedge Done);
    @(posedge CLK);
    `ifdef DEBUG
    $display("  - %d(%b)/%d(%b)", Num, Num, Den, Den);
    $display("    %d(%b),%d(%b)", Coc, Coc, Res, Res);
    `endif
    assert (Coc == target_coc) else $error("Operacion mal realizada. %d/%d=%d != %d", Num, Den, target_coc, Coc);
    assert (Res == target_res) else $error("Operacion mal realizada. %d%%%d=%d != %d", Num, Den, target_res, Res);
    -> comprobado;
end

endmodule
