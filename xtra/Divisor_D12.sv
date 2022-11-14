module Divisor_D12
 

#(parameter tamanyo=32)           
(input CLK,
input RSTa,
input Start,
input SignNum,
input SignDen,
//input logic [tamanyo-1:0] Num,
//input logic [tamanyo-1:0] Den,
input logic [tamanyo-1:0]  ACCU,
input logic [tamanyo-1:0]   Q,
input logic [tamanyo-1:0]   M,

output logic [tamanyo-1:0]  ACCU_out,
output logic [tamanyo-1:0]   Q_out,
output logic [tamanyo-1:0]   M_out,
output logic SignNum_out,
output logic SignDen_out,

output logic Done);

logic [tamanyo-1:0] ACCU_AUX;
logic [tamanyo-1:0] Q_AUX;
 

assign {ACCU_AUX,Q_AUX} = {ACCU[tamanyo-2:0],Q,1'b0};

always_ff @(posedge CLK,negedge RSTa)
begin

if (!RSTa)
begin
  {ACCU_out,Q_out,M_out,SignNum_out,SignDen_out,Done} = '0;
end

else
begin

begin
  Done <= Start;
  M_out <=  M;
  SignNum_out <= SignNum;
  SignDen_out <= SignDen;
end


begin

  if(ACCU_AUX >= M)
  begin
  Q_out <= Q_AUX+1;
  ACCU_out <= ACCU_AUX-M;   
  end
  else
  begin
  Q_out <=Q_AUX;
  ACCU_out <= ACCU_AUX;
  end
end

end

end

  

endmodule

