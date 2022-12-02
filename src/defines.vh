`ifndef DEFINES_VH
`define DEFINES_VH

`define ADDR_IDLE 2'b00
`define ADDR_CMD 2'b01
`define ADDR_LOW 2'b10
`define ADDR_HIGH 2'b11

`define CMD_LATCH_ADDRESS_BIT 0
`define CMD_RES_BIT 1
`define CMD_WRITE_BIT 2
`define CMD_START_BIT 3

`define CMD_LATCH_ADDRESS (1<<`CMD_LATCH_ADDRESS_BIT)
`define CMD_RES (1<<`CMD_RES_BIT)
`define CMD_WRITE (1<<`CMD_WRITE_BIT)
`define CMD_START (1<<`CMD_START_BIT)

`define TEST_REG_ADDR 8'h08
`define KEY_OFFSET 8'h10

// comment to not include a test register
`define TEST_REG

`endif
