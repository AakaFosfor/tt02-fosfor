`default_nettype none
`timescale 1ns/1ps

module s_box (
	input [3:0] Data_ib,
	output reg [3:0] Data_ob
);

	always @(*) begin
		case (Data_ib)
			4'h0: Data_ob = 4'hC;
			4'h1: Data_ob = 4'h5;
			4'h2: Data_ob = 4'h6;
			4'h3: Data_ob = 4'hB;
			4'h4: Data_ob = 4'h9;
			4'h5: Data_ob = 4'h0;
			4'h6: Data_ob = 4'hA;
			4'h7: Data_ob = 4'hD;
			4'h8: Data_ob = 4'h3;
			4'h9: Data_ob = 4'hE;
			4'hA: Data_ob = 4'hF;
			4'hB: Data_ob = 4'h8;
			4'hC: Data_ob = 4'h4;
			4'hD: Data_ob = 4'h7;
			4'hE: Data_ob = 4'h1;
			4'hF: Data_ob = 4'h2;
		endcase
	end

endmodule
