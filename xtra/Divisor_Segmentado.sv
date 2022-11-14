module Divisor_Segmentado
 

#(parameter tamanyo=32)           
(input CLK,
input RSTa,
input Start,
input logic [tamanyo-1:0] Num,
input logic [tamanyo-1:0] Den,

output logic [tamanyo-1:0] Coc,
output logic [tamanyo-1:0] Res,
output logic Done);


logic [tamanyo-1:0] ACCU_sig,Q_sig,M_sig[tamanyo-1:0];
logic [tamanyo-1:0] SignNum_sig,SignDen_sig,Done_sig;
   

genvar i;
generate 
  for(i = 0; i<(tamanyo+1) ; i = i+1)
   begin :divider
	  case(i)

	  0:
	  Divisor_D12 #(.tamanyo(tamanyo)) div_uno (
	           .CLK(CLK),
	           .RSTa(RSTa),
				  .Start(Start),
				  .SignNum(Num[tamanyo-1]),
				  .SignDen(Den[tamanyo-1]),
				  .ACCU('0),
				  .Q(Num[tamanyo-1]?(~Num+1):Num),
				  .M(Den[tamanyo-1]?(~Den+1):Den),
				  .ACCU_out(ACCU_sig[0]),
				  .Q_out(Q_sig[0]),
				  .M_out(M_sig[0]),
				  .SignNum_out(SignNum_sig[0]),
				  .SignDen_out(SignDen_sig[0]),
				  .Done(Done_sig[0]));   
     
	  
	  (tamanyo):  
	  always_ff @(posedge CLK,negedge RSTa)
     if(!RSTa)
       begin
       Coc <= '0;
		 Res <= '0;
		 Done <= 1'b0;
	    end
     else
      begin 
		Coc <=(SignNum_sig[i-1]^SignDen_sig[i-1])?(~Q_sig[i-1]+1):Q_sig[i-1];
		Res <=SignNum_sig[i-1]?(~ACCU_sig[i-1]+1):ACCU_sig[i-1];
		Done <=Done_sig[i-1]; 
		end
	       
	  default:
	  Divisor_D12 #(.tamanyo(tamanyo)) div_dos (
	           .CLK(CLK),
	           .RSTa(RSTa),
				  .Start(Done_sig[i-1]),
				  .SignNum(SignNum_sig[i-1]),
				  .SignDen(SignDen_sig[i-1]),
				  .ACCU(ACCU_sig[i-1]),  
				  .Q(Q_sig[i-1]),
				  .M(M_sig[i-1]),
				  .ACCU_out(ACCU_sig[i]),
				  .Q_out(Q_sig[i]),
				  .M_out(M_sig[i]),
				  .SignNum_out(SignNum_sig[i]),
				  .SignDen_out(SignDen_sig[i]),
				  .Done(Done_sig[i]));   
     
	  endcase
	
	
	
   end
	
endgenerate
	


endmodule
