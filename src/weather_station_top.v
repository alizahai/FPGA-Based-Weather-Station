module weather_station_top(
    input clk_in,           // 100 MHz FPGA clock
    inout dht11_io,         // bidirectional DHT11 wire
    output [6:0] segment, 
    output [3:0] anode,	
    output transfer_done,
    output led_o            // LED that blinks at each transfer
);

    // Internal wires for DHT11 outputs
    wire [7:0] temperature;
    wire [7:0] humidity;
    wire data_request;
    
    // DHT11 sensor instance
    DHT11 DHT11_sensor ( 
        .clk_in(clk_in),
        .dht11_io(dht11_io),
        .transfer_done_out(transfer_done),
        .temperature_out(temperature),      
        .humidity_out(humidity),            
        .data_req_out(data_request)         
    ); 
    
    // BCD conversion wires
    wire [6:0] temp_units, temp_tens, temp_hundreds;
    wire [6:0] hum_units, hum_tens, hum_hundreds;
    
    // Temperature BCD converter
    binarytoBCD temp_converter (	 
        .clk_in(clk_in), 
        .binary_in(temperature),            
        .units_out(temp_units), 
        .tens_out(temp_tens),
        .hundreds_out(temp_hundreds)        
    );
    
    // Humidity BCD converter
    binarytoBCD humidity_converter(
        .clk_in(clk_in), 
        .binary_in(humidity),               
        .units_out(hum_units), 
        .tens_out(hum_tens),
        .hundreds_out(hum_hundreds)         
    ); 
    
    // Slow clock divider for display switching
    reg [26:0] div = 27'b0;
    always @(posedge clk_in)
        div <= div + 1'b1; 
    
    // Display switching logic
    reg switchDisp = 1'b0; 
    always @(posedge div[26])              
        switchDisp <= ~switchDisp; 
    
    // Display data multiplexer
    reg [6:0] degree_symbol = 7'b0011100; // degree symbol (°)
    reg [6:0] char_C = 7'b1000110;        // letter C
    reg [6:0] char_H = 7'b0001001;        // letter H
    reg [6:0] char_r = 7'b0101111;        // letter r (lowercase)
    reg [6:0] blank = 7'b1111111;         // blank display

    reg [27:0] numdisp = 28'b0;
    always @(*) begin
        if(switchDisp)
            // Display temperature: XX°C (tens, units, degree, C)
            numdisp = {temp_tens, temp_units, degree_symbol, char_C};
        else
            // Display humidity: XXHr (tens, units, H, r)
            numdisp = {hum_tens, hum_units, char_H, char_r};
    end
    
    // Seven segment display controller
    sevenSegDisplay display(
        .clk_in(clk_in), 
        .number_in(numdisp),
        .segment_out(segment), 
        .anode_out(anode)
    ); 
    
    // LED output - blinks when data is being requested
    assign led_o = data_request;
    
endmodule