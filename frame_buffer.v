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

