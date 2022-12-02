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
	output Ready_o,
	input [7:0] TextRegEnable_ib,
	input [9:0] KeyRegEnable_ib
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
	assign regEnable = running;

	// input muxes
	assign keyMux  = (running | starting) ? keyNew : Key_ib;
	assign dataMux = (running | starting) ? dataNew : PlainText_ib;
	
	genvar i;

	// key register
	generate
		for (i = 0; i < 10; i = i + 1) begin
			register #(
				.g_Width(8)
			) i_keyReg (
				.Clk_ik(Clk_ik),
				.Reset_ir(1'b0),
				.Data_ib(keyMux[i*8 +: 8]),
				.Data_ob(keyReg[i*8 +: 8]),
				.Enable_i(regEnable | KeyRegEnable_ib[i])
			);
		end
	endgenerate

	// data register
	generate
		for (i = 0; i < 8; i = i + 1) begin
			register #(
				.g_Width(8)
			) i_dataReg (
				.Clk_ik(Clk_ik),
				.Reset_ir(1'b0),
				.Data_ib(dataMux[i*8 +: 8]),
				.Data_ob(dataReg[i*8 +: 8]),
				.Enable_i(regEnable | TextRegEnable_ib[i])
			);
		end
	endgenerate

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
			count <= 5'b00000;
			running <= 0;
		end else if (running) begin
			count <= count + 1;
			running <= 1;
			if (count == 5'b11111) begin
				running <= 0;
			end
		end else if (Start_i) begin
			count <= 5'b00000;
			running <= 1;
		end
	end

	// final phase
	assign CipherText_ob = dataReg ^ keyReg[79:16];

endmodule
