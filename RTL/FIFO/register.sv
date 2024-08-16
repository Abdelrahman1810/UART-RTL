module register #(
    parameter FIFO_WIDTH = 8,
    parameter FIFO_DEPTH = 8
)(
    input clk_w, clk_r, rst,
    input w_en, r_en,
    input [FIFO_WIDTH-1:0] w_addr, r_addr,
    input [FIFO_WIDTH-1:0] din_a,

    output reg [FIFO_WIDTH-1:0] dout_b
);
    reg [FIFO_WIDTH-1:0] memory [(2 ** FIFO_DEPTH) - 1:0];

    always @(posedge clk_r or posedge rst)
        if (rst)
            dout_b <= 0;
        else if (r_en)
            dout_b <= memory[r_addr];
    
    always @(posedge clk_w)
        if (w_en) 
            memory[w_addr] <= din_a;
endmodule