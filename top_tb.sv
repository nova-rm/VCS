`timescale 1ns/1ps
module top_tb;
 logic CLK=0, Reset=0, SEL15=0, SEL25=0, B20=0, B10=0, B5=0;
 wire MODE15, MODE25, IMPRIME15, IMPRIME25, COMPLETE, C5, C10, C15;
 wire [2:0] C, P;
 wire [7:0] observed={MODE15,MODE25,IMPRIME15,IMPRIME25,COMPLETE,C5,C10,C15};
 sistema dut(.*);
 always #5 CLK=~CLK;
 // Oraculo obtenido de compuertas/conexiones XML, independiente del RTL aritmetico.
 logic [13:0] reference [0:2047];
 integer rc=0, rp=0, checks=0, cycles=0;
 bit visited[0:4][0:7][0:31];
 task automatic check_outputs(input integer u);
   integer addr;
   begin
     addr=(rc*8+rp)*32+u;
     if ({C,P} !== {3'(rc),3'(rp)} || observed !== reference[addr][7:0])
       $fatal(1,"Mismatch t=%0t C=%0d P=%0d u=%0d observed=%h expected=%h",$time,C,P,u,observed,reference[addr]);
     checks++;
   end
 endtask
 task automatic step(input logic [4:0] u);
   logic [13:0] expected;
   begin
     @(negedge CLK);
     {SEL15,SEL25,B20,B10,B5}=u;
     #1; check_outputs(u);
     visited[rc][rp][u]=1;
     expected=reference[(rc*8+rp)*32+u];
     @(posedge CLK);
     rc=expected[13:11];rp=expected[10:8];
     #1; check_outputs(u);cycles++;
   end
 endtask
 task automatic reset_dut;
   begin
     @(negedge CLK); {SEL15,SEL25,B20,B10,B5}=0;
     #2;Reset=1;rc=0;rp=0;
     #1;check_outputs(0);
     @(negedge CLK);Reset=0;
   end
 endtask
 integer mode, balance, u, i, count;
 logic [31:0] rng=32'h51af1234;
 initial begin
   $readmemh("referencia.mem",reference);
   $dumpfile("ondas.vcd");$dumpvars(0,top_tb);
`ifdef FSDB
   $fsdbDumpfile("ondas.fsdb");$fsdbDumpvars(0,top_tb);
`endif
   reset_dut();
`ifdef SAIF
   $set_gate_level_monitoring("rtl_on", "sv");
   $set_toggle_region(top_tb.dut);
   $toggle_start();
`endif
   // Ventana legible: ticket15 con 20+20; ticket25 con 5+10+5+20.
   step(16);step(4);step(0);step(4);step(0);step(0);
   step(8);step(1);step(2);step(1);step(4);step(0);step(0);
   // Todos los saldos alcanzables y las 32 combinaciones de entradas.
   for(mode=1;mode<=2;mode++)
     for(balance=0;balance<8;balance++)
       for(u=0;u<32;u++) begin
         reset_dut();step(mode==1?16:8);
         if(balance!=0) step(5'(balance));
         step(5'(u));step(0);step(0);
       end
   // Inactividad, doble seleccion, reset durante pago e impresion, secuencias continuas.
   for(u=0;u<32;u++) begin reset_dut();step(5'(u));end
   for(i=0;i<2000;i++) begin
     rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
     step(rng[4:0]);
     if(i%47==0) reset_dut();
   end
   reset_dut();
`ifdef SAIF
   $toggle_stop();
   $toggle_report("fsm.saif",1.0e-9,top_tb.dut);
`endif
   count=0;
   for(mode=1;mode<=2;mode++)
     for(balance=0;balance<8;balance++)
       for(u=0;u<32;u++) count+=int'(visited[mode][balance][u]);
   $display("PASS: %0d checks, %0d cycles; waiting-state input cases %0d/512",checks,cycles,count);
   if(count!=512) $fatal(1,"Incomplete directed stimulus coverage");
   $finish;
 end
 initial begin #200000;$fatal(1,"Timeout");end
endmodule
