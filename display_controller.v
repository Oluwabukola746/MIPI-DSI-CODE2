module display_controller (
    input wire clk, 
    input wire [23:0] pixel_data,    // Pixel data input from Frame Buffer
    output reg hsync,                // Horizontal sync signal
    output reg vsync,                // Vertical sync signal
    output reg [7:0] r,              // Red color
    output reg [7:0] g,              // Green color
    output reg [7:0] b               // Blue color
);

    reg [10:0] h_count;
    reg [9:0] v_count;

    initial begin
        h_count = 0;
        v_count = 0;
        hsync = 0;
        vsync = 0;
        r = 0;
        g = 0;
        b = 0;
    end

    always @(posedge clk) begin
        // Sync counters
        if (h_count < 800) begin
            h_count <= h_count + 1;
        end else begin
            h_count <= 0;
            if (v_count < 600) begin
                v_count <= v_count + 1;
            end else begin
                v_count <= 0;
            end
        end

        // Assign RGB values from pixel_data
        {r, g, b} <= pixel_data;

        // Generate sync pulses
        hsync <= (h_count < 16);
        vsync <= (v_count < 2);
    end
endmodule
