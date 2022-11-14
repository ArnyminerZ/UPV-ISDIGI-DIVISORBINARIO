
/**
 * ARCHIVO MODELO DE TESTBENCH
 * REQUIERE ALGUNOS DEFINE PARA FUNCIONAR.
 * SE DEFINEN EN testbench_algoritmico y testbench_segmentado
 */


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

// Objetivo de coverage secundario, intentaremos probar cuantas mas posibles soluciones mejor sabiendo que hay algunas que no son posibles de obtener marcaremos un 70% como meta
`define TB_COVERAGE2 70

// El tamaño de bits que probar
`define BIT_SIZE 8  //probamos con ocho bits para que los coverpoints se encuentren dentro del margen que puede manejar esta construccion


// * NO CAMBIAR
`define LAST_BIT `BIT_SIZE-1
// TODO: Debería adaptarse a TEST_*
`define BIN_SIZE 2**`BIT_SIZE
// * FIN NO CAMBIAR


// Importamos la clase generadora
`include "SCSG.sv"

// No definimos un nombre específico para el testbench, usamos el definido en
// testbench_algoritmico.sv y testbench_segmentado.sv para generalizar el testbench
// y no tener duplicados
module `NOMBRE_TESTBENCH;

logic CLK, RSTa, Start;
logic signed [`LAST_BIT:0] Num, Den;
logic Done;
logic signed [`LAST_BIT:0] Coc, Res, target_coc, target_res;

event reset;
event comprobado;

covergroup ValoresEntrada;
    num_positiv: coverpoint Num {bins binsNumPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
	den_positiv: coverpoint Den {bins binsDenPos[(`BIN_SIZE)/2-1] = {[1:((`BIN_SIZE)/2)-1]};
                                illegal_bins zero[1] ={0};}     //denominador = 0 es un estado ilegal
	den_negativ: coverpoint Den {bins binsDenNeg[(`BIN_SIZE)/2] ={[-((`BIN_SIZE)/2):-1]};}
    num_negativ: coverpoint Num {bins binsNumNeg[(`BIN_SIZE)/2] ={[-((`BIN_SIZE)/2):-1]};}

    crosspoint1: cross num_positiv,den_positiv; //combinatoria de numerador positivo y denominador positivo
    crosspoint2: cross num_positiv,den_negativ; //combinatoria de numerador positivo y denominador negativo
    crosspoint3: cross num_negativ,den_positiv; //combinatoria de numerador negativo y denominador positivo
    crosspoint4: cross num_negativ,den_negativ; //combinatoria de numerador negativo y denominador negativo
endgroup
covergroup ValoresSalida @(negedge Done);
    cocientes1: coverpoint Coc {bins binsCocPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
    cocientes2: coverpoint Coc {bins binsCocNeg[(`BIN_SIZE)/2] = {[-((`BIN_SIZE)/2)-1:-1]};}
    restos1: coverpoint Res {bins binsResPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
    restos2: coverpoint Res {bins binsResNeg[(`BIN_SIZE)/2] = {[-((`BIN_SIZE)/2)-1:-1]};}    
    soluciones1: cross cocientes1,restos1;    //combinatoria cocientes positivos y restos positivos
    soluciones2: cross cocientes1,restos2;    //combinatoria cocientes positivos y restos negativos
    soluciones3: cross cocientes2,restos1;    //combinatoria cocientes negativos y restos positivos
    soluciones4: cross cocientes2,restos2;    //combinatoria cocientes negativos y restos negativos
endgroup 
// Declaración de objetos
RCSG bus_inst;
ValoresEntrada vals;
ValoresSalida valo;

// Declaración de módulos
// Nota: el nombre del módulo instanciado se define en testbench_algoritmico.sv y
// testbench_segmentado.sv.
`MODULO #(
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

// Le ordena al módulo iniciar el cálculo
task iniciar;
    Start <= 1'b0;
    @(posedge CLK); // Esperamos un ciclo
    Start <= 1'b1;  // Iniciamos el reinicio
    @(posedge CLK); // Esperamos un ciclo
    Start <= 1'b0;
endtask

// Le ordena al módulo que se reinicie
task reiniciar;
    $display("> Reiniciando circuito...");
    RSTa = 1'b0;
    repeat (3) @(posedge CLK); 
    RSTa = 1'b1;
    -> reset;

    repeat (3) @(posedge CLK); // Esperamos tres ciclos
endtask

// Espera a que el módulo haya terminado, y el testbench haya completado la comprobación
task esperaAComprobar;
    @(posedge Done); // Esperamos a que termine
    @(negedge Done);
    @(comprobado);
endtask

// Actualiza los targets de cociente y residuo
task actualizarTargets;
    target_coc=$signed(Num)/$signed(Den);
    target_res=$signed(Num)%$signed(Den);
endtask

// La rutina de randomización. Genera valores, actualiza targets, calcula y comprueba
task rutina;
    reiniciar();
    assert (bus_inst.randomize()) else $fatal("! Randomization failed");
    Num = bus_inst.num;
    assert (bus_inst.randomize()) else $fatal("! Randomization failed");
    Den = bus_inst.den;
    vals.sample();

    actualizarTargets();

    iniciar();
    esperaAComprobar();
endtask

// Reinicia el módulo nada más empezar
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
    valo = new;

    // Start = 1'b0;

    // Num = 'd64;
    // Den = -'d2;
    // actualizarTargets();

    // $display("> Arrancando primer ciclo...");
    // iniciar();
    // $display("  Esperando...");
    // esperaAComprobar();
    // $display("  Primer ciclo completado!");

    reiniciar();
    $display("> Simulando...");

    `ifdef TEST_NUM_POS_DEN_POS
    while ((vals.crosspoint1.get_inst_coverage() < `TB_COVERAGE)) begin
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);
        bus_inst.den_nozero.constraint_mode(1); //este modo debe estar siempre activo para no correr el riesgo de caer en estados ilegales

        rutina();
    end
    `endif

    `ifdef TEST_NUM_NEG_DEN_POS
    while ((vals.crosspoint2.get_inst_coverage() < `TB_COVERAGE)) begin   
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);

        rutina();
    end
    `endif

    `ifdef TEST_NUM_POS_DEN_NEG
    while ((vals.crosspoint3.get_inst_coverage() < `TB_COVERAGE)) begin    
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);

        rutina();
    end
    `endif

    `ifdef TEST_NUM_NEG_DEN_NEG
    while ((vals.crosspoint4.get_inst_coverage() < `TB_COVERAGE)) begin
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);

        rutina();
    end
    `endif

    $display("  Completado!");

    $stop;
end


always @(posedge Done) begin
    @(negedge Done);
    @(posedge CLK);
    `ifdef DEBUG
    $display("  - %d(%b)/%d(%b)", Num, Num, Den, Den);
    $display("    %d(%b),%d(%b)", $signed(Coc), Coc, $signed(Res), Res);
    `endif
    //notificamos el progreso del coverage
    $display("Coverage Entradas = %0.2f %%", vals.get_inst_coverage());
    $display("Coverage Salidas = %0.2f %%", valo.get_inst_coverage());

    assert (Coc == target_coc) else $error("Operacion mal realizada. %d/%d=%d != %d", Num, Den, target_coc, Coc);
    assert (Res == target_res) else $fatal("Operacion mal realizada. %d%%%d=%d != %d", Num, Den, target_res, Res);
    -> comprobado;
end

endmodule