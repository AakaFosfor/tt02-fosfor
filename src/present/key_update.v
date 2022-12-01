`default_nettype none
`timescale 1ns/1ps

module key_update (
	input [79:0] Data_ib,
	output [79:0] Data_ob,
	input [4:0] RoundCount_ib
);

	wire [3:0] fromSBox;
	wire [3:0] fromXOR;

	s_box i_s_box (
		.Data_ib(Data_ib[18:15]),
		.Data_ob(fromSBox)
	);

	assign fromXOR = Data_ib[38:34] ^ RoundCount_ib;
	
	assign Data_ob = {fromSBox, Data_ib[14:0], Data_ib[79:39], fromXOR, Data_ib[33:19]};

endmodule
