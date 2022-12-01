`default_nettype none
`timescale 1ns/1ps

module core_serial (
	input Clk_ik,
	input Reset_ir, // synchronous reset
	// crypto
	input [63:0] PlainText_ib,
	input [79:0] Key_ib,
	output [63:0] CipherText_ob,
	// controls
	input Start_i,
	output Ready_o
);

	wire readyInner;
	wire starting;
	reg running;
	wire regEnable;
	reg [4:0] count;
	wire [79:0] keyReg;
	wire [79:0] keyNew;
	wire [79:0] keyMux;
	wire [63:0] dataReg;
	wire [63:0] dataNew;
	wire [63:0] dataMux;

	assign Ready_o = readyInner;
	assign starting = Start_i & readyInner;
	assign readyInner = ~running;
	assign regEnable = running | starting;

	// input muxes
	assign keyMux = starting ? Key_ib : keyNew;
	assign dataMux = starting ? PlainText_ib : dataNew;
	
	// Key_ib register
	register #(
		.g_Width(80)
	) i_keyReg (
		.Clk_ik(Clk_ik),
		.Reset_ir(Reset_ir),
		.Data_ib(keyMux),
		.Data_ob(keyReg),
		.Enable_i(regEnable)
	);

	// data register
	register #(
		.g_Width(64)
	) i_dataReg (
		.Clk_ik(Clk_ik),
		.Reset_ir(Reset_ir),
		.Data_ib(dataMux),
		.Data_ob(dataReg),
		.Enable_i(regEnable)
	);

	// key update
	key_update i_KeyUpdate (
		.Data_ib(keyReg),
		.Data_ob(keyNew),
		.RoundCount_ib(count)
	);

	// data update
	data_update i_DataUpdate (
		.Data_ib(dataReg),
		.Data_ob(dataNew),
		.RoundKey_ib(keyReg[79:16])
	);

	// counter
	always @(posedge Clk_ik) begin
		if (Reset_ir) begin
			count <= 5'b00001;
			running <= 0;
		end else if (running) begin
			count <= count + 1;
			running <= 1;
			if (count == 5'b11111) begin
				running <= 0;
			end
		end else if (Start_i) begin
			count <= 5'b00001;
			running <= 1;
		end
	end

	// final phase
	assign CipherText_ob = dataReg ^ keyReg[79:16];

endmodule
