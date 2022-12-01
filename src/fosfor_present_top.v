`default_nettype none
`timescale 1ns/1ps

module fosfor_present_top (
  input [7:0] io_in,
  output [7:0] io_out
);

  wire Clk_ik;
  wire Reset_ir;
  wire [1:0] Addr_ib;
  wire [3:0] Data_ib;
  wire [7:0] Data_ob;

  assign Clk_ik = io_in[0];
  assign Reset_ir = io_in[1];
  assign Addr_ib = io_in[3:2];
  assign Data_ib = io_in[7:4];

  assign io_out = Data_ob;
  
  /* address:
      00 - no write, output status
      01 - write to command register, output status
      10 - write to input_data[3:0] register, output output_data register
      11 - write to input_data[7:4] register, output output_data register
   */
   
  wire [7:0] Status_b;
  wire [7:0] InputData_b;
  wire [7:0] OutputData_b;
  
  wire [63:0] PlainText_b = 0;
  wire [79:0] Key_b = 1;
  wire [63:0] CipherText_b;

  wire Start = 1;
  wire Ready;

  assign Status_b = {6'b0, Ready};

  core_serial i_present (
    .Clk_ik(Clk_ik),
    .Reset_ir(Reset_ir),
    // crypto
    .PlainText_ib(PlainText_b),
    .Key_ib(Key_b),
    .CipherText_ob(CipherText_b),
    // controls
    .Start_i(Start),
    .Ready_o(Ready)
  );


endmodule
