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
