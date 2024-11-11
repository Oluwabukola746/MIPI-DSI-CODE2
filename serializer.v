module serializer (
    input wire clk,                 // Clock input
    input wire [23:0] pixel_data,   // Parallel pixel data (RGB 8 bits each)
    output reg serial_data          // Serial output data
);

    reg [23:0] shift_reg;
    integer bit_count;              // Counter for 24 cycles

    initial begin
        bit_count = 0;
        shift_reg = 24'b0;
    end

    always @(posedge clk) begin
        if (bit_count == 0) begin
            shift_reg <= pixel_data; // Load new pixel data into shift register
            bit_count <= 24;         // Reset bit counter to 24
        end else begin
            serial_data <= shift_reg[23]; // Output MSB of shift_reg
            shift_reg <= shift_reg << 1;  // Shift left by one bit
            bit_count <= bit_count - 1;
        end
    end
endmodule