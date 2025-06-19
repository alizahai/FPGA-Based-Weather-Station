module sevenSegDisplay(
	input clk_in, 
	input [27:0] number_in, //4x 7-seg data cluster
	output reg [6:0] segment_out, 
	output reg [3:0] anode_out
);

	reg [15:0] freq_div = 16'b0; 
	
	// create a slower clock for display multiplexing
	always @(posedge clk_in)
		freq_div <= freq_div + 1'b1; 

	always @(*) begin  
		case(freq_div[15:14]) 
			2'h0: begin 
				anode_out <= 4'b1110; 
				segment_out <= number_in[6:0];
			end 
			2'h1: begin 
				anode_out <= 4'b1101; 
				segment_out <= number_in[13:7];
			end 
			2'h2: begin 
				anode_out <= 4'b1011; 
				segment_out <= number_in[20:14];
			end 
			2'h3: begin 
				anode_out <= 4'b0111; 
				segment_out <= number_in[27:21];
			end  
			default: begin 
				anode_out <= 4'b1111; 
				segment_out <= 7'b1111111;
			end 
		endcase 
	end 

endmodule