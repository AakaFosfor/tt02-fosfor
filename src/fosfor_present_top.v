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
  reg [7:0] Data_ob;

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
      
      command (self clearing):
      bit 0 - write address from input
      bit 1 - read register
      bit 2 - write register
      bit 3 - start PRESENT engine
      
      address map (256 positions):
      0 - plain text 7:0 when writing, cipher text when reading
      1 - plain text 15:8
      ...
      7 - plain text 63:56
      
      0x08 - test register, write/read
      
      0x10 - key 7:0 writing only
      ...
      0x19 - key 79:72 writing only
      
   */
   
  // ********************************************************
  // first stage registes, 8bit, no addressing
  // ********************************************************
  
  reg [3:0] Command_b; // self-clearing
  wire CommandWriteAddress;
  wire CommandRead;
  wire CommandWrite;
  wire CommandStart;
  wire [7:0] Status_b;
  reg [7:0] InputData_b;
  reg [7:0] OutputData_b;
  reg [7:0] RegAddress_b;
  
  assign CommandWriteAddress = Command_b[0];
  assign CommandRead = Command_b[1];
  assign CommandWrite = Command_b[2];
  assign CommandStart = Command_b[3];
  assign Status_b = {6'b0, Ready};

  // read
  always @(posedge Clk_ik) begin
    case (Addr_ib[1])
      0: Data_ob = Status_b;
      1: Data_ob = OutputData_b;
    endcase
  end
   
  // write
  always @(posedge Clk_ik) begin
    Command_b = 0; // self clearing
    case (Addr_ib)
      // 0: ; IDLE
      1: Command_b = Data_ib;
      2: InputData_b[3:0] = Data_ib;
      3: InputData_b[7:4] = Data_ib;
    endcase
  end
  
  // registers
  always @(posedge Clk_ik)
    if (CommandWriteAddress)
      RegAddress_b = InputData_b;
   
  // ********************************************************
  // second stage registes, addressing
  // ********************************************************

  reg [7:0] TestRegister_b;
  reg [63:0] PlainText_b;
  reg [79:0] Key_b;
  wire [63:0] CipherText_b;
  
  // register write 
  always @(posedge Clk_ik) begin
    if (CommandWrite) begin
      case (RegAddress_b)
        'h00: PlainText_b[ 7: 0] = InputData_b;
        'h01: PlainText_b[15: 8] = InputData_b;
        'h02: PlainText_b[23:16] = InputData_b;
        'h03: PlainText_b[31:24] = InputData_b;
        'h04: PlainText_b[39:32] = InputData_b;
        'h05: PlainText_b[47:40] = InputData_b;
        'h06: PlainText_b[55:48] = InputData_b;
        'h07: PlainText_b[63:56] = InputData_b;
        
        'h08: TestRegister_b = InputData_b;
      
        'h10: Key_b[ 7: 0] = InputData_b;
        'h11: Key_b[15: 8] = InputData_b;
        'h12: Key_b[23:16] = InputData_b;
        'h13: Key_b[31:24] = InputData_b;
        'h14: Key_b[39:32] = InputData_b;
        'h15: Key_b[47:40] = InputData_b;
        'h16: Key_b[55:48] = InputData_b;
        'h17: Key_b[63:56] = InputData_b;
        'h18: Key_b[71:64] = InputData_b;
        'h19: Key_b[79:72] = InputData_b;
      endcase
    end
  end
  
  // register read
  always @(posedge Clk_ik) begin
    if (CommandRead) begin
      case (RegAddress_b)
        'h00: OutputData_b = CipherText_b[ 7: 0];
        'h01: OutputData_b = CipherText_b[15: 8];
        'h02: OutputData_b = CipherText_b[23:16];
        'h03: OutputData_b = CipherText_b[31:24];
        'h04: OutputData_b = CipherText_b[39:32];
        'h05: OutputData_b = CipherText_b[47:40];
        'h06: OutputData_b = CipherText_b[55:48];
        'h07: OutputData_b = CipherText_b[63:56];
        'h08: OutputData_b = TestRegister_b;
      endcase
    end
  end

  // ********************************************************
  // PRESENT engine
  // ********************************************************

  wire Ready;

  core_serial i_present (
    .Clk_ik(Clk_ik),
    .Reset_ir(Reset_ir),
    // crypto
    .PlainText_ib(PlainText_b),
    .Key_ib(Key_b),
    .CipherText_ob(CipherText_b),
    // controls
    .Start_i(CommandStart),
    .Ready_o(Ready)
  );

endmodule
