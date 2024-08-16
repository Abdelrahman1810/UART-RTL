module TxUnit #(
    parameter FIFO_WIDTH = 8,
    parameter NBITS = FIFO_WIDTH + 1,
    parameter FIFO_DEPTH = 8
) (
    input  logic                      clk           ,
    input  logic                      rst           ,
    input  logic                      Tx_clk        ,
    input  logic                      tx_begin      ,
    input  logic                      wen           ,
    input  logic [FIFO_WIDTH - 1 : 0] wr_data       ,

    output logic                      tx            ,
    output logic                      tx_done       ,
    output logic                      tx_empty      ,
    output logic                      tx_full
);
logic [FIFO_WIDTH-1:0]  fifo_dout     ;
logic                   parity        ;
logic                   tx_begin_prev ;
logic                   read          ;
logic                   tx_start      ;


/*********************************************************/
/************************** PISO *************************/
/*********************************************************/

and(tx_start, !tx_empty, tx_begin);

TransmitterPISO #(
    .NBITS(NBITS), 
    .FIFO_WIDTH(FIFO_WIDTH)
)piso(
    // inputs
    .Tx_clk(Tx_clk),
    .rst(rst),
    .din(fifo_dout),
    .tx_start(tx_start),
    .parity(parity),

    // outputs
    .tx(tx),
    .tx_done(tx_done)
);

/*********************************************************/
/********************* EvenParityCreat *******************/
/*********************************************************/

EvenParityCreat #(
    .NBITS(NBITS)
)paritycrt(
    .din(fifo_dout),
    .parity(parity)
);

/*********************************************************/
/************************** FIFO *************************/
/*********************************************************/

FIFO #(
    .FIFO_WIDTH(FIFO_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
)txfifo(
    .clk_w(clk),
    .clk_r(Tx_clk),
    .rst(rst),
    .wen_a(wen),
    .ren_b(tx_done),
    .din_a(wr_data),

    .dout_b(fifo_dout),
    .full(tx_full),
    .empty(tx_empty)
);

endmodule