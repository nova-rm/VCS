`timescale 1ns/1ps
module sistema(input logic CLK, Reset, SEL15, SEL25, B20, B10, B5,
 output logic MODE15, MODE25, IMPRIME15, IMPRIME25,
 output logic COMPLETE, C5, C10, C15,
 output logic [2:0] C, P);
 moore u_moore(.CLK, .Reset, .SEL15, .SEL25, .COMPLETE,
               .MODE15, .MODE25, .IMPRIME15, .IMPRIME25, .C);
 mealy u_mealy(.CLK, .Reset, .MODE15, .MODE25, .B20, .B10, .B5,
               .COMPLETE, .C5, .C10, .C15, .P);
endmodule
