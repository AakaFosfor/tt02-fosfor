`default_nettype none
`timescale 1ns/1ps

module fosfor_present_top_tb;
  
  task sendCommand(input [3:0] command);
  begin
    Address_b = 1;
    DataIn_b = command;
    @(posedge Clk_k);
    Address_b = 0;
    @(posedge Clk_k);
  end
  endtask
    
  task sendData(input [7:0] data);
  begin
    Address_b = 2;
    DataIn_b = data[3:0];
    @(posedge Clk_k);
    Address_b = 3;
    DataIn_b = data[7:4];
    @(posedge Clk_k);
    Address_b = 0;
  end
  endtask
  
  task receiveData;
  begin
    Address_b = 2;
    @(posedge Clk_k);
    Address_b = 0;
  end
  endtask
  
  task write(input [7:0] address, input [7:0] data);
  begin
    $display("WRITE [0x%0h] = 0x%0h", address, data);
    sendData(address);
    sendCommand('b0001);
    sendData(data);
    sendCommand('b0100);
  end
  endtask

  task read(input [7:0] address);
  begin
    sendData(address);
    sendCommand('b0001);
    sendCommand('b0010);
    receiveData();
    $display("READ [0x%0h] = 0x%0h", address, DataOut_b);
  end
  endtask

  integer i;

  task writeKey(input [79:0] key);
  begin
    for (i = 0; i < 10; i = i+1) begin
      // write('h10 + i, key[i*8+7:i*8]);
      write('h10 + i, key[7:0]);
      // TODO
    end
  end
  endtask
  
  initial begin
    $dumpfile ("fosfor_present_top_tb.vcd");
    $dumpvars (0, fosfor_present_top_tb);
    
    Address_b = 0;
    DataIn_b = 0;
    
    @(negedge Reset_r);
    @(posedge Clk_k);
    
    // test test register write/read
    write(8, 'hA5);
    read(8);

    #20;

    // test PRESENT
    // write key
    writeKey('h1234567890);
    
    #100;
    
    $finish();
  end
  
  initial begin
    #1000;
    $display("Timeout!");
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

  reg [1:0] Address_b;
  reg [3:0] DataIn_b;
  wire [7:0] inputs = {DataIn_b, Address_b, Reset_r, Clk_k};
  wire [7:0] DataOut_b;

  fosfor_present_top dut_i (
    .io_in (inputs),
    .io_out (DataOut_b)
  );

endmodule

