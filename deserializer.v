module deserializer (
    input wire clk,                  // Clock input
    input wire serial_data,          // Serial data input
    output reg [23:0] pixel_data     // Parallel pixel data output (RGB)
);

    reg [23:0] shift_reg;
    integer bit_count;

    initial begin
        bit_count = 0;
        shift_reg = 0;
    end

    always @(posedge clk) begin
        shift_reg <= {shift_reg[22:0], serial_data}; // Shift in serial data

        if (bit_count < 23) begin
            bit_count <= bit_count + 1;
        end else begin
            pixel_data <= shift_reg; // Update pixel_data after 24 bits are received
            bit_count <= 0;
        end
    end
endmodule