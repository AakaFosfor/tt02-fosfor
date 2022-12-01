`default_nettype none
`timescale 1ns/1ps

module register #(
	parameter g_Width = 1,
	parameter g_ResetValue = 0
) (
	input Clk_ik,
	input Reset_ir,
	input [g_Width-1:0] Data_ib,
	output reg [g_Width-1:0] Data_ob,
	input Enable_i
);

	always @(posedge Clk_ik) begin
		if (Reset_ir) begin
			Data_ob <= g_ResetValue;
		end else if (Enable_i) begin
			Data_ob <= Data_ib;
		end
	end

endmodule
