`include "../Dividor_Segmentado.sv"

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

// Como bien sabemos denominador nulo implica un estado ilegalisimo ya que no podemos dividir entre 0, evitando asi uno de los estados mas ilegales que podamos imaginar
constraint den_nozero {den != 0;}

// Para limitar a resultados sin residuo
constraint div_exactaaa {num%den == 0;}

// Limitamos el valor máximo, para dejar sitio para el signo. No
// desactivar esta constraint.
// Nota:
// - 2^15 = 32768      -> 16 bits
// - 2^31 = 2147483648 -> 32 bits
// constraint lim_grandeee {(abs(num)<32768) && (abs(den)<32768);}
endclass

module testbench_segmentado;

logic CLK, RSTa, Start;
logic signed [`LAST_BIT:0] Num, Den;
logic Done;
logic signed [`LAST_BIT:0] Coc, Res, target_coc, target_res;

event reset;
event comprobado;

covergroup ValoresEntrada;
    coverpoint1: coverpoint Num {bins binsNumPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
	coverpoint2: coverpoint Den {bins binsDenPos[(`BIN_SIZE)/2-1] = {[1:((`BIN_SIZE)/2)-1]};
                                illegal_bins zero[1] ={0};}     //denominador = 0 es un estado ilegal
	coverpoint3: coverpoint Den {bins binsDenNeg[(`BIN_SIZE)/2] ={[-((`BIN_SIZE)/2):-1]};}
    coverpoint4: coverpoint Num {bins binsNumPos[(`BIN_SIZE)/2] ={[-((`BIN_SIZE)/2):-1]};}
    coverpoint5: cross coverpoint1,coverpoint2; //combinatoria de numerador positivo y denominador positivo
    coverpoint6: cross coverpoint1,coverpoint3; //combinatoria de numerador positivo y denominador negativo
    coverpoint7: cross coverpoint4,coverpoint2; //combinatoria de numerador negativo y denominador positivo
    coverpoint8: cross coverpoint4,coverpoint3; //combinatoria de numerador negativo y denominador negativo
endgroup
covergroup ValoresSalida @(negedge Done);
    cocientes1: coverpoint Coc {bins binsCocPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
    cocientes2: coverpoint Coc {bins binsCocNeg[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
    restos1: coverpoint Res {bins binsResPos[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}
    restos2: coverpoint Res {bins binsResNeg[(`BIN_SIZE)/2] = {[0:((`BIN_SIZE)/2)-1]};}    
    soluciones1: cross cocientes1,restos1;    //combinatoria cocientes positivos y restos positivos
    soluciones2: cross cocientes1,restos2;    //combinatoria cocientes positivos y restos negativos
    soluciones3: cross cocientes2,restos1;    //combinatoria cocientes negativos y restos positivos
    soluciones4: cross cocientes2,restos2;    //combinatoria cocientes negativos y restos negativos
endgroup 
// Declaración de objetos
Bus bus_inst;
ValoresEntrada vals;
ValoresSalida valo;

// Declaración de módulos
Dividor_Segmentado #(
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
    target_coc=$signed(Num)/$signed(Den);
    target_res=$signed(Num)%$signed(Den);
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
//assert (!RSTa) else $error("No se ha reiniciado correctamente")//Comprobamos que se ha reiniciado correctamente

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

    // $display("> Probando con numerador y denominador positivos, division exacta...");
    while ((vals.coverpoint5.get_inst_coverage() < `TB_COVERAGE)) begin
        `ifdef TEST_NUM_POS_DEN_POS
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);
        bus_inst.den_nozero.constraint_mode(1); //este modo debe estar siempre activo para no correr el riesgo de caer en estados ilegales

        rutina();
        `endif
    end
    while ((vals.coverpoint6.get_inst_coverage() < `TB_COVERAGE)) begin   
        `ifdef TEST_NUM_NEG_DEN_POS
        bus_inst.num_positivo.constraint_mode(1);
        bus_inst.num_negativo.constraint_mode(0);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);

        rutina();
        `endif
    end
    while ((vals.coverpoint7.get_inst_coverage() < `TB_COVERAGE)) begin    
        `ifdef TEST_NUM_POS_DEN_NEG
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(1);
        bus_inst.den_negativo.constraint_mode(0);

        rutina();
        `endif
    end
    while ((vals.coverpoint8.get_inst_coverage() < `TB_COVERAGE)) begin    
        `ifdef TEST_NUM_NEG_DEN_NEG
        bus_inst.num_positivo.constraint_mode(0);
        bus_inst.num_negativo.constraint_mode(1);
        bus_inst.den_positivo.constraint_mode(0);
        bus_inst.den_negativo.constraint_mode(1);

        rutina();
        `endif
    end

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
    assert (Res == target_res) else $error("Operacion mal realizada. %d%%%d=%d != %d", Num, Den, target_res, Res);
    -> comprobado;
    -> comprobado;
end

endmodule