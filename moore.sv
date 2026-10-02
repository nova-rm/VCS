`timescale 1ns/1ps
module moore(input logic CLK, Reset, SEL15, SEL25, COMPLETE,
 output logic MODE15, MODE25, IMPRIME15, IMPRIME25,
 output logic [2:0] C);
 typedef enum logic [2:0] {IDLE=0, PAGO15=1, PAGO25=2,
                           PRINT15=3, PRINT25=4} state_t;
 state_t state, next_state;
 assign C = state;
 always_ff @(posedge CLK or posedge Reset)
   if (Reset) state <= IDLE;
   else state <= next_state;
 always_comb begin
   next_state = IDLE;
   case (state)
     IDLE: begin
       if (SEL15 && !SEL25) next_state = PAGO15;
       else if (!SEL15 && SEL25) next_state = PAGO25;
     end
     PAGO15: next_state = COMPLETE ? PRINT15 : PAGO15;
     PAGO25: next_state = COMPLETE ? PRINT25 : PAGO25;
     PRINT15: next_state = IDLE;
     PRINT25: next_state = IDLE;
     default: next_state = IDLE;
   endcase
 end
 assign MODE15 = (state == PAGO15);
 assign MODE25 = (state == PAGO25);
 assign IMPRIME15 = (state == PRINT15);
 assign IMPRIME25 = (state == PRINT25);
endmodule
