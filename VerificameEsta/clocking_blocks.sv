program estimulos
  (input CLK,
   input FIN,
   input [3:0] COUNT,
   output logic START,
   output reg [7:0] X);
  
  reg [3:0] cola_targets   [$];
  reg [3:0] target,pretarget,salida_obtenida;
  reg FINAL;
  //definimos el clocking de test
 clocking sd @(posedge CLK);
   default input #1ns output #1ns;
   input   COUNT,FIN ;
   output START, X;
 endclocking:sd
  //definimos el clocking de monitorizacion
  clocking md @(posedge CLK);
   default input #1ns output #1ns;
   input   COUNT,FIN,START,X ;
 endclocking:md

  default clocking sd; //esto nos permitirá utilziar el operador ## para los ciclcos de reloj
  
covergroup valores_X;    
  coverpoint  X;
endgroup;                       
//declaraciones de dos objetos
  Bus busInst;
  valores_X veamos; 
  initial
begin
    busInst = new;//construimos la case de valores random
    veamos=new;//construimos el covergroup
    fork
      monitor_input; //lanzo el procedimiento de monitorizacion cambio entrada y calculo del vor target
      monitor_output;//lanzo el procedimiento de monitorizacion cambio salida y comparacion ideal
    join_none
	sd.START <= 1'b0;
	sd.X <= 8'd25;
	##3	sd.START <= 1'b1;
	##1
	sd.START <= 1'b0;
  	@(negedge sd.FIN);
  while ( veamos.get_coverage()<40)
	begin
	   busInst.pares.constraint_mode(0);
	   $display("pruebo con impares");
	   assert (busInst.randomize()) else    $fatal("randomization failed");
    	sd.X <= busInst.valor;	
    	veamos.sample();
    	##1
	   sd.START <= 1'b1;
	   ##1
	   sd.START <= 1'b0;
	   @(negedge sd.FIN);
   end
  while ( veamos.get_coverage()<90)
	begin
 	   busInst.impares.constraint_mode(0);
	   busInst.pares.constraint_mode(1);
	   $display("pruebo con pares");
	   assert (busInst.randomize()) else    $fatal("randomization failed");
    	sd.X <= busInst.valor;	
    	veamos.sample();  
    	##1  	
	   sd.START <= 1'b1;
	   ##1
	   sd.START <= 1'b0;
	   @(negedge sd.FIN);
   end
   $stop;
end
  
 task monitor_input; //cada vez que habilito el start, meto en la cola el valor de la raiz cuadrada calculada de modo ideal con una funcion preestablecida
   begin
     while (1)
       begin       
         @(md);
         if (md.START==1'b1)
           begin
             pretarget=$floor($sqrt(md.X));
		 	cola_targets={pretarget,cola_targets};//meto el vaor deseado en la cola
           end
		end
   end
 endtask
  task monitor_output;//caada vez que habilito el fin, extraigo de la cola el valor de la raiz cuadrada calculada de modo ideal con una funcion preestablecida y lo comparo con el que da nuestro disenyo
   begin
     while (1)
       begin       
         @(md);
         if (md.FIN==1'b1)
           begin
         	FINAL=md.FIN;
         	target= cola_targets.pop_back();
         	salida_obtenida=md.COUNT;
             assert (salida_obtenida==target) else $error("operacion mal realizada: la raiz cuadrada de %d es %d y tu diste %d",md.X,target,salida_obtenida);
           end
		end
   end
 endtask 
endprogram