module BCDto7segment(
    input [3:0] bcd_in,
    output reg [6:0] segment_out
);

    always @(*) begin
        case(bcd_in)
            4'h0: segment_out = 7'b1000000; // 0
            4'h1: segment_out = 7'b1111001; // 1
            4'h2: segment_out = 7'b0100100; // 2
            4'h3: segment_out = 7'b0110000; // 3
            4'h4: segment_out = 7'b0011001; // 4
            4'h5: segment_out = 7'b0010010; // 5
            4'h6: segment_out = 7'b0000010; // 6
            4'h7: segment_out = 7'b1111000; // 7
            4'h8: segment_out = 7'b0000000; // 8
            4'h9: segment_out = 7'b0010000; // 9
            4'hA: segment_out = 7'b0001000; // A
            4'hB: segment_out = 7'b0000011; // b
            4'hC: segment_out = 7'b1000110; // C
            4'hD: segment_out = 7'b0100001; // d
            4'hE: segment_out = 7'b0000110; // E
            4'hF: segment_out = 7'b0001110; // F
            default: segment_out = 7'b1111111; // blank (all off)
        endcase
    end

endmodule