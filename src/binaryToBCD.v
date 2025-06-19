module binarytoBCD(	
	input clk_in, 
	input [7:0] binary_in, 
	output [6:0] units_out, 
	output [6:0] tens_out, 
	output [6:0] hundreds_out
);

	reg [7:0] binary_reg = 8'b0; 	
	
	always @(posedge clk_in)
		binary_reg <= binary_in; 
	
	reg [3:0] units_reg; 
	reg [3:0] hundreds_reg; 
	reg [3:0] tens_reg; 
	
	integer i; 
	
	always @(*) begin
		units_reg = 4'b0; 
		tens_reg = 4'b0;
		hundreds_reg = 4'b0; 		

		for (i = 7; i >= 0; i = i - 1) begin 
			if (hundreds_reg >= 5)
				hundreds_reg = hundreds_reg + 3; 
			if (tens_reg >= 5)
				tens_reg = tens_reg + 3; 
			if (units_reg >= 5)
				units_reg = units_reg + 3;
				
			hundreds_reg = hundreds_reg << 1; 
			hundreds_reg[0] = tens_reg[3]; 
			tens_reg = tens_reg << 1; 
			tens_reg[0] = units_reg[3];
			units_reg = units_reg << 1; 
			units_reg[0] = binary_reg[i];  
		end
	end 

	BCDto7segment DECODE_units(units_reg, units_out);	//Decode BCD to 7-seg
	BCDto7segment DECODE_tens(tens_reg, tens_out);
	BCDto7segment DECODE_hundreds(hundreds_reg, hundreds_out);

endmodule