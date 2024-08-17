module RxUnit #(
    parameter FIFO_WIDTH = 8,
    parameter NBITS = FIFO_WIDTH + 1,
    parameter FIFO_DEPTH = 8
) (
    input  logic                  clk           ,
    input  logic                  rst           ,
    input  logic                  Rx_clk        ,
    input  logic                  rx            ,
    input  logic                  ren           ,
    
    output logic [FIFO_WIDTH-1:0] read_data     ,
    output logic                  rx_done       ,
    output logic                  rx_full       ,
    output logic                  rx_empty
);
    wire [NBITS-1:0] data_out;
    wire data_correct;

/*********************************************************/
/************************** SIPO *************************/
/*********************************************************/

    ReceiverSIPO #(
        .NBITS (NBITS)
    )sipo(
        // Inputs
        .Rx_clk(Rx_clk),
        .rst(rst),
        .rx(rx),

        // Outputs
        .rx_done(rx_done),
        .data_out(data_out)
    );

/*********************************************************/
/******************* EvenParityCheck *********************/
/*********************************************************/            
            
    EvenParityCheck #(
        .NBITS(NBITS)
    )paritychk( 
        // inputs
        .data_out(data_out),
        .rx_done(rx_done),
        
        // outputs
        .data_correct(data_correct)
    );
    
/*********************************************************/
/************************** FIFO *************************/
/*********************************************************/
    
    wire wen_a;
    assign wen_a = rx_done & data_correct;

    FIFO #(
        .FIFO_WIDTH(FIFO_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    )
    Rx_fifo(
        // Inputs
        .clk_w(Rx_clk),
        .clk_r(clk),
        .rst(rst),
        .wen_a(wen_a),
        .ren_b(ren),
        .din_a(data_out[8:1]),

        // Outputs
        .dout_b(read_data),
        .full(rx_full),
        .empty(rx_empty)
    );
endmodule