`timescale 1ns/1ps
// Ecuaciones equivalentes a la red combinacional del archivo .circ.
// P expresa unidades de 5; ambos modos cobran 40.
module mealy(input logic CLK, Reset, MODE15, MODE25, B20, B10, B5,
 output logic COMPLETE, C5, C10, C15, output logic [2:0] P);
 logic enabled;
 logic [3:0] total;
 logic [2:0] next_P;
 assign enabled = MODE15 | MODE25;
 assign total = {1'b0,P} + {1'b0,B20,B10,B5};
 assign COMPLETE = enabled && total >= 4'd8;
 // Se conservan los nombres originales: C15 refleja B20, no cambio de 15.
 assign C5 = enabled & B5;
 assign C10 = enabled & B10;
 assign C15 = enabled & B20;
 always_comb begin
   next_P = P;
   if (enabled) begin
     if (COMPLETE) next_P = 3'd0;
     else next_P = total[2:0];
   end
 end
 always_ff @(posedge CLK or posedge Reset)
   if (Reset) P <= 3'd0;
   else P <= next_P;
endmodule
