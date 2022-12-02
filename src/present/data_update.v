`default_nettype none
`timescale 1ns/1ps

module data_update (
	input [63:0] Data_ib,
	output reg [63:0] Data_ob,
	input [63:0] RoundKey_ib
);

	wire [63:0] fromXOR;
	wire [63:0] fromSBox;

	genvar i;

	assign fromXOR = Data_ib ^ RoundKey_ib;

	generate
		for (i = 0; i < 16; i = i + 1) begin
			// sBoxLayer
			s_box i_s_box (
				.Data_ib(fromXOR[i*4+3:i*4]),
				.Data_ob(fromSBox[i*4+3:i*4])
			);
			// pLayer
			always @(*) begin
				Data_ob[ 0+i] = fromSBox[0+i*4];
				Data_ob[16+i] = fromSBox[1+i*4];
				Data_ob[32+i] = fromSBox[2+i*4];
				Data_ob[48+i] = fromSBox[3+i*4];
			end
		end
	endgenerate

endmodule
