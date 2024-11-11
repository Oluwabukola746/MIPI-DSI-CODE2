`timescale 1ns/1ps

module tb_mipi_dsi;

    reg clk;
    reg [23:0] pixel_data;
    wire hsync;
    wire vsync;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;

    // Instantiate the top module
    mipi_dsi_top uut (
        .clk(clk),
        .pixel_data_in(pixel_data),
        .hsync(hsync),
        .vsync(vsync),
        .r(r),
        .g(g),
        .b(b)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test procedure
    initial begin
        pixel_data = 24'hFF0000; // Red color
        #10000;
        
        pixel_data = 24'h00FF00; // Green color
        #10000;
        
        pixel_data = 24'h0000FF; // Blue color
        #10000;
        
        $stop;
    end

    // Monitor output
    initial begin
        $display("Time\t\tPixel Data\tSerial Data\tHSYNC\tVSYNC\tR\tG\tB");
        $monitor("Time: %0t | Pixel Data: %h | HSYNC: %b | VSYNC: %b | R: %h | G: %h | B: %h",
                 $time, pixel_data, hsync, vsync, r, g, b);
    end
endmodule

module tb_RGBExtractor;

    reg clk;
    reg reset;
    reg [23:0] pixel_data;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire hsync;
    wire vsync;

    // Instantiate the module
    RGBExtractor uut (
        .clk(clk),
        .reset(reset),
        .pixel_data(pixel_data),
        .r(r),
        .g(g),
        .b(b),
        .hsync(hsync),
        .vsync(vsync)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench procedure
    initial begin
        // Reset the design initially
        reset = 1;
        #10;
        reset = 0;

        // Input pixel data sequence
        #10 pixel_data = 24'hFF0000; // Red
        #5000 pixel_data = 24'h00FF00; // Green
        #5000 pixel_data = 24'h0000FF; // Blue
        #5000 pixel_data = 24'hFFFF00; // Yellow
        #5000 pixel_data = 24'hFF00FF; // Magenta
        #5000 pixel_data = 24'h00FFFF; // Cyan
        #5000 pixel_data = 24'h000000; // Black

        // End the simulation
        #10000 $stop;
    end

    // Monitor output signals for debugging
    initial begin
        $monitor("Time: %0t | Pixel Data: %h | HSYNC: %b | VSYNC: %b | R: %02x | G: %02x | B: %02x", 
                  $time, pixel_data, hsync, vsync, r, g, b);
    end
endmodule

