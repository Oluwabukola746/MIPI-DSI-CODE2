module RGBExtractor(
    input wire clk,
    input wire reset,
    input wire [23:0] pixel_data,
    output reg [7:0] r,
    output reg [7:0] g,
    output reg [7:0] b,
    output reg hsync,
    output reg vsync
);

    reg [23:0] data_buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hsync <= 0;
            vsync <= 0;
            r <= 0;
            g <= 0;
            b <= 0;
            data_buffer <= 24'h000000;
        end else begin
            // HSYNC and VSYNC transition control logic
            hsync <= (pixel_data != 24'h000000);
            vsync <= (hsync && !vsync) ? 1 : (vsync && !hsync) ? 0 : vsync;

            // Sample RGB values based on stable data
            data_buffer <= pixel_data;
            r <= data_buffer[23:16];
            g <= data_buffer[15:8];
            b <= data_buffer[7:0];
        end
    end
endmodule

