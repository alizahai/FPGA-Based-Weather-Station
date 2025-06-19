module DHT11(
    input clk_in,
    inout dht11_io,
    output reg transfer_done_out,
    output reg [7:0] temperature_out,
    output reg [7:0] humidity_out,
    output data_req_out
);

    reg dht_out = 1'b1;
    reg dht_oe = 1'b0;  // Output enable (1 = output, 0 = input)
    
    assign dht11_io = dht_oe ? dht_out : 1'bZ;
    assign data_req_out = dht_oe;  // LED shows when FPGA is driving the line

    // Create 1MHz clock (1탎 period)
    reg [6:0] clk_div = 0;
    reg clk_1mhz = 0;
    
    always @(posedge clk_in) begin
        clk_div <= clk_div + 1;
        if (clk_div >= 49) begin  // 100MHz/50 = 2MHz, toggle = 1MHz
            clk_div <= 0;
            clk_1mhz <= ~clk_1mhz;
        end
    end

    // Microsecond counter
    reg [19:0] us_counter = 0;
    reg counter_reset = 0;
    
    always @(posedge clk_1mhz) begin
        if (counter_reset)
            us_counter <= 0;
        else
            us_counter <= us_counter + 1;
    end

    // Main state machine
    reg [3:0] state = 0;
    reg [5:0] bit_count = 0;
    reg [39:0] data_buffer = 0;
    reg [7:0] bit_duration = 0;
    
    // States
    localparam IDLE = 0;
    localparam START_LOW = 1;
    localparam START_HIGH = 2;
    localparam WAIT_RESPONSE = 3;
    localparam WAIT_RESPONSE_HIGH = 4;
    localparam WAIT_BIT_LOW = 5;
    localparam WAIT_BIT_HIGH = 6;
    localparam MEASURE_BIT = 7;
    localparam PROCESS_DATA = 8;
    localparam DELAY = 9;
    localparam ERROR = 10;

    always @(posedge clk_1mhz) begin
        case (state)
            IDLE: begin
                dht_oe <= 1;
                dht_out <= 1;
                counter_reset <= 1;
                transfer_done_out <= 0;
                bit_count <= 0;
                data_buffer <= 0;
                
                if (us_counter == 0)  // Start immediately after reset
                    state <= START_LOW;
            end
            
            START_LOW: begin
                dht_oe <= 1;
                dht_out <= 0;  // Pull low
                counter_reset <= 0;
                
                if (us_counter >= 20000) begin  // 20ms low pulse
                    state <= START_HIGH;
                    counter_reset <= 1;
                end
                else if (us_counter >= 100000)  // 100ms timeout
                    state <= ERROR;
            end
            
            START_HIGH: begin
                dht_oe <= 1;
                dht_out <= 1;  // Release line
                counter_reset <= 0;
                
                if (us_counter >= 40) begin  // 40탎 high
                    dht_oe <= 0;  // Switch to input mode
                    state <= WAIT_RESPONSE;
                    counter_reset <= 1;
                end
                else if (us_counter >= 1000)  // 1ms timeout
                    state <= ERROR;
            end
            
            WAIT_RESPONSE: begin
                dht_oe <= 0;  // Input mode
                counter_reset <= 0;
                
                if (!dht11_io) begin  // DHT11 pulls low
                    state <= WAIT_RESPONSE_HIGH;
                    counter_reset <= 1;
                end
                else if (us_counter >= 100)  // 100탎 timeout
                    state <= ERROR;
            end
            
            WAIT_RESPONSE_HIGH: begin
                dht_oe <= 0;
                counter_reset <= 0;
                
                if (dht11_io) begin  // DHT11 releases line
                    state <= WAIT_BIT_LOW;
                    counter_reset <= 1;
                end
                else if (us_counter >= 100)  // 100탎 timeout
                    state <= ERROR;
            end
            
            WAIT_BIT_LOW: begin
                dht_oe <= 0;
                counter_reset <= 0;
                
                if (!dht11_io) begin  // Start of bit transmission
                    state <= WAIT_BIT_HIGH;
                    counter_reset <= 1;
                end
                else if (us_counter >= 100)  // 100탎 timeout
                    state <= ERROR;
            end
            
            WAIT_BIT_HIGH: begin
                dht_oe <= 0;
                counter_reset <= 0;
                
                if (dht11_io) begin  // High part of bit
                    state <= MEASURE_BIT;
                    counter_reset <= 1;
                end
                else if (us_counter >= 100)  // 100탎 timeout
                    state <= ERROR;
            end
            
            MEASURE_BIT: begin
                dht_oe <= 0;
                counter_reset <= 0;
                
                if (!dht11_io) begin  // End of high pulse
                    // Determine bit value based on high pulse duration
                    if (us_counter > 50)  // > 50탎 = bit 1
                        data_buffer <= {data_buffer[38:0], 1'b1};
                    else  // <= 50탎 = bit 0
                        data_buffer <= {data_buffer[38:0], 1'b0};
                    
                    bit_count <= bit_count + 1;
                    
                    if (bit_count >= 39) begin  // All 40 bits received
                        state <= PROCESS_DATA;
                    end else begin
                        state <= WAIT_BIT_LOW;
                    end
                    counter_reset <= 1;
                end
                else if (us_counter >= 100)  // 100탎 timeout
                    state <= ERROR;
            end
            
            PROCESS_DATA: begin
                dht_oe <= 0;
                
                // Extract data 
                humidity_out <= data_buffer[39:32];       // Humidity integer
                temperature_out <= data_buffer[23:16];    // Temperature integer
                
                transfer_done_out <= 1;
                state <= DELAY;
                counter_reset <= 1;
            end
            
            DELAY: begin
                dht_oe <= 0;
                counter_reset <= 0;
                transfer_done_out <= 0;
                
                if (us_counter >= 500000) begin  // 500ms delay 
                    state <= IDLE;
                    counter_reset <= 1;
                end
            end
            
            ERROR: begin
                dht_oe <= 0;
                counter_reset <= 1;
                
                // Set error values for debugging
                if (humidity_out == 0 && temperature_out == 0) begin
                    humidity_out <= 8'hFF;      // Error indicator
                    temperature_out <= 8'hFF;   // Error indicator
                end
                
                state <= DELAY;  // Try again after delay
            end
            
            default: begin
                state <= IDLE;
                counter_reset <= 1;
            end
        endcase
    end

    // Initialize outputs
    initial begin
        temperature_out = 8'd25;  // Default values
        humidity_out = 8'd60;
        transfer_done_out = 0;
    end

endmodule