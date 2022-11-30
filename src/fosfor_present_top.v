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
  
  

endmodule
