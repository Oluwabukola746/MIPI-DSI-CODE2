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
