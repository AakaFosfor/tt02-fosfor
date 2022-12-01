`default_nettype none
`timescale 1ns/1ps

module fosfor_present_top_tb;

  initial begin
    $dumpfile ("fosfor_present_top_tb.vcd");
    $dumpvars (0, fosfor_present_top_tb);
    #1000;
    $finish();
  end

  reg Clk_k;
  reg Reset_r;
  
  initial begin
    Reset_r = 1;
    #20 Reset_r = 0;
  end

  initial begin
    Clk_k = 0;
    forever 
       #5 Clk_k = ~Clk_k;
  end

  wire [7:0] inputs = {6'b0, Reset_r, Clk_k};
  wire [7:0] outputs;

  fosfor_present_top dut_i (
    .io_in (inputs),
    .io_out (outputs)
  );

endmodule

