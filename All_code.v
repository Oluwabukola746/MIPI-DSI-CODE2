`timescale 1ns/1ps

// Serializer Module
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

// D-PHY Interface Module
module dphy_interface (
    input wire clk,                  // Clock input
    input wire serial_data_in,       // Serial data input from Host SoC
    output reg serial_data_out,      // Serial data output to Display Panel
    input wire [3:0] data_lanes_in,  // Data Lanes D0-D3 Input
    output reg [3:0] data_lanes_out  // Data Lanes D0-D3 Output
);

    always @(posedge clk) begin
        serial_data_out <= serial_data_in;
        data_lanes_out <= data_lanes_in;
    end
endmodule

// Deserializer Module
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

// Frame Buffer Module
module frame_buffer (
    input wire clk,
    input wire [23:0] pixel_in,      // Parallel pixel data input
    output reg [23:0] pixel_out      // Parallel pixel data output
);

    reg [23:0] buffer_mem [0:1023];  // Simple memory buffer
    integer i;

    initial begin
        i = 0;
    end

    always @(posedge clk) begin
        buffer_mem[i] <= pixel_in;    // Store incoming pixel data into buffer
        pixel_out <= buffer_mem[i];   // Read data from buffer
        i = i + 1;
        if (i == 1024)
            i = 0;
    end
endmodule

// Display Controller Module
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

// Top Module
module mipi_dsi_top (
    input wire clk,
    input wire [23:0] pixel_data_in,
    output wire hsync,
    output wire vsync,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

    wire serial_data;
    wire [23:0] pixel_data_out;
    
    serializer u_serializer (
        .clk(clk),
        .pixel_data(pixel_data_in),
        .serial_data(serial_data)
    );

    deserializer u_deserializer (
        .clk(clk),
        .serial_data(serial_data),
        .pixel_data(pixel_data_out)
    );

    display_controller u_display_controller (
        .clk(clk),
        .pixel_data(pixel_data_out),
        .hsync(hsync),
        .vsync(vsync),
        .r(r),
        .g(g),
        .b(b)
    );

endmodule

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
