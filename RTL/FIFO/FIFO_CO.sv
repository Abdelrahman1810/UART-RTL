module FIFO_CO #(
    parameter FIFO_WIDTH = 4,
    parameter FIFO_DEPTH = 8
)(
    input clk_w, clk_r, rst,
    input wen_a, ren_b,
    
    output reg full, empty,
    output [FIFO_WIDTH-1:0]w_addr, r_addr
);
    reg [FIFO_WIDTH-1:0] wr_ptr_cs, wr_ptr_ns;
    reg [FIFO_WIDTH-1:0] rd_ptr_cs, rd_ptr_ns;
    reg full_ns, empty_ns;

// Next State write
    always @(*) begin
        wr_ptr_ns =  wr_ptr_cs;
        rd_ptr_ns =  rd_ptr_cs;
        empty_ns = empty;
        full_ns = full;

        case ({wen_a, ren_b})
            2'b10: // write
            begin
                if (~full)
                begin
                    wr_ptr_ns =  wr_ptr_cs + 1;
                    empty_ns = 1'b0;
                    if (wr_ptr_ns == rd_ptr_cs)
                        full_ns = 1'b1;
                end
            end
            2'b01: // read
            begin
                if (~empty) begin
                    rd_ptr_ns = rd_ptr_cs + 1;
                    full_ns = 1'b0;
                    if (rd_ptr_ns == wr_ptr_cs) 
                        empty_ns = 1'b1;
                end
            end
            2'b11: 
            begin
                if (empty) begin
                    wr_ptr_ns =  wr_ptr_cs;
                    rd_ptr_ns =  rd_ptr_cs;
                end else begin
                    wr_ptr_ns =  wr_ptr_cs + 1;
                    rd_ptr_ns =  rd_ptr_cs + 1;
                end
            end
            default: ; 
        endcase
    end

// State memory write
    always @(posedge clk_w or posedge rst) begin
        if (rst) begin
            wr_ptr_cs = 0;
        end else begin
            wr_ptr_cs = wr_ptr_ns;
        end
    end

    always @(posedge clk_w or posedge clk_r or posedge rst) begin
        if (rst) begin
            full = 1'b0;
            empty = 1'b1;            
        end else begin
            full = full_ns;
            empty = empty_ns;
        end
    end

// State memory read
    always @(posedge clk_r or posedge rst) begin
        if (rst) begin
            rd_ptr_cs = 0;
        end
        else begin
            rd_ptr_cs = rd_ptr_ns;
        end
    end

// Output logical
    assign w_addr = wr_ptr_cs;
    assign r_addr = rd_ptr_cs;

endmodule