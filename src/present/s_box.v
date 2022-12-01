`default_nettype none
`timescale 1ns/1ps

module s_box (
	input [3:0] Data_ib,
	output reg [3:0] Data_ob
);

	always @(Data_ib) begin
		case (Data_ib)
			4'h0: Data_ob = 4'b1100;
			4'h1: Data_ob = 4'b0101;
			4'h2: Data_ob = 4'b0110;
			4'h3: Data_ob = 4'b1011;
			4'h4: Data_ob = 4'b1001;
			4'h5: Data_ob = 4'b0000;
			4'h6: Data_ob = 4'b1010;
			4'h7: Data_ob = 4'b1101;
			4'h8: Data_ob = 4'b0011;
			4'h9: Data_ob = 4'b1110;
			4'hA: Data_ob = 4'b1111;
			4'hB: Data_ob = 4'b1000;
			4'hC: Data_ob = 4'b0100;
			4'hD: Data_ob = 4'b0111;
			4'hE: Data_ob = 4'b0001;
			4'hF: Data_ob = 4'b0010;
		endcase
	end

endmodule
