`default_nettype none
`timescale 1ns/1ps

//`define DEBUG
`define LOG

module fosfor_present_top_tb;

  localparam ADDR_IDLE = 2'b00;
  localparam ADDR_CMD = 2'b01;
  localparam ADDR_LOW = 2'b10;
  localparam ADDR_HIGH = 2'b11;

  localparam CMD_LATCH_ADDRESS = 4'b0001;
  localparam CMD_READ = 4'b0010;
  localparam CMD_WRITE = 4'b0100;
  localparam CMD_START = 4'b1000;

  task err(input [8*256:1] description);
  begin
    $display("!!! ERROR: %0s", description);
    $finish();
  end
  endtask
  
  task sendCommand(input [3:0] command);
  begin
`ifdef DEBUG
    $display("DEBUG: sendCommand 0x%0h", command);
`endif
    @(posedge Clk_k);
    Address_b = ADDR_CMD;
    DataIn_b = command;
    @(posedge Clk_k);
    Address_b = ADDR_IDLE;
  end
  endtask
    
  task sendData(input [7:0] data);
  begin
`ifdef DEBUG
    $display("DEBUG: sendData 0x%0h", data);
`endif
    @(posedge Clk_k);
    Address_b = ADDR_LOW;
    DataIn_b = data[3:0];
    @(posedge Clk_k);
    Address_b = ADDR_HIGH;
    DataIn_b = data[7:4];
    @(posedge Clk_k);
    Address_b = ADDR_IDLE;
  end
  endtask
  
  task receiveData;
  begin
`ifdef DEBUG
    $display("DEBUG: receiveData");
`endif
    @(posedge Clk_k);
    Address_b = ADDR_LOW;
    @(posedge Clk_k);
    Address_b = ADDR_IDLE;
  end
  endtask
  
  task receiveStatus;
  begin
`ifdef DEBUG
    $display("DEBUG: receiveStatus");
`endif
    @(posedge Clk_k);
    Address_b = ADDR_IDLE;
    @(posedge Clk_k);
    Address_b = ADDR_IDLE;
  end
  endtask
  
  task write(input [7:0] address, input [7:0] data);
  begin
`ifdef LOG
    $display("WRITE [0x%0h] = 0x%0h", address, data);
`endif
    sendData(address);
    sendCommand(CMD_LATCH_ADDRESS);
    sendData(data);
    sendCommand(CMD_WRITE);
  end
  endtask

  task read(input [7:0] address, output [7:0] data);
  begin
`ifdef DEBUG
    $display("READ [0x%0h]", address);
`endif
    sendData(address);
    sendCommand(CMD_LATCH_ADDRESS);
    sendCommand(CMD_READ);
    receiveData();
`ifdef LOG
    $display("READ [0x%0h] = 0x%0h", address, DataOut_b);
`endif
    data = DataOut_b;
  end
  endtask

  task readStatus(output [7:0] status);
  begin
`ifdef DEBUG
    $display("READ status");
`endif
    receiveStatus();
`ifdef LOG
    $display("READ status = 0x%0h", DataOut_b);
`endif
    status = DataOut_b;
  end
  endtask

  task writeKey(input [79:0] key);
  begin : writeKey_body
    integer i;
`ifdef LOG
    $display("WRITE key = 0x%0h", key);
`endif
    for (i = 0; i < 10; i = i+1) begin
      write('h10 + i, key[i*8 +: 8]);
    end
  end
  endtask
  
  task writePlainText(input [63:0] plainText);
  begin : writePlainText_body
    integer i;
`ifdef LOG
    $display("WRITE plain text = 0x%0h", plainText);
`endif
    for (i = 0; i < 8; i = i+1) begin
      write(i, plainText[i*8 +: 8]);
    end
  end
  endtask

  task readCipherText(output [63:0] cipherText);
  begin : readCipherText_body
    integer i;
`ifdef DEBUG
    $display("READ cipher text");
`endif
    cipherText = 0;
    for (i = 0; i < 8; i = i+1) begin
      read(i, cipherText[i*8 +: 8]);
    end
`ifdef LOG
    $display("READ cipher text = 0x%0h", cipherText);
`endif
  end
  endtask

  task startPRESENT;
  begin
    sendCommand(CMD_START);
  end
  endtask

  task testPRESENT;
  begin : testPRESENT_body
    reg [7:0] data8;
    reg [63:0] data64;
    integer timeout;

    readStatus(data8);
    if (data8[0] != 1) err("PRESENT not ready!");

    // writeKey('h1234567890ABCDEF00AA);
    // writePlainText('h1122334455667788);
    writeKey(0);
    writePlainText(0);

    readStatus(data8);
    if (data8[0] != 1) err("PRESENT not ready!");
    startPRESENT();
    readStatus(data8);
    if (data8[0] == 1) err("PRESENT ready and not processing!");

    timeout = 350; // should be done in 320 ns (31+1 rounds at 10ns clock)
    while (!data8[0]) begin
      #100;
      timeout = timeout - 100;
      if (timeout < 0) err("PRESENT didn't finished in time!");
      readStatus(data8);
    end

    readCipherText(data64);
    if (data64 != 64'h5579C1387B228445) err("PRESENT calculated wrongly!");
  end
  endtask

  initial begin : test
    reg [7:0] data8;

    $dumpfile ("fosfor_present_top_tb.vcd");
    $dumpvars (0, fosfor_present_top_tb);
    
    Address_b = 0;
    DataIn_b = 0;
    
    @(negedge Reset_r);
    @(posedge Clk_k);

    // test test register write/read
    write(8, 'hA5);
    read(8, data8);
    if (data8 != 'hA5) err("wrong test register read!");

    #20;

    // test PRESENT
    testPRESENT();
    
    #20;
    $display("End of test.");
    $finish();
  end
  
  initial begin
    #10000;
    err("Timeout!");
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

  reg [1:0] Address_b;
  reg [3:0] DataIn_b;
  wire [7:0] inputs = {DataIn_b, Address_b, Reset_r, Clk_k};
  wire [7:0] DataOut_b;

  fosfor_present_top dut_i (
    .io_in (inputs),
    .io_out (DataOut_b)
  );

endmodule

