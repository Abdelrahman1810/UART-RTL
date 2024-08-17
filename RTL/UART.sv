module UART #(
    // parameters
    parameter OVERSAMBLE = 16             ,   // Rx sampling
    parameter CLK_FREQ   = 10_000_000     ,   // 10 MHz system clock
    parameter FIFO_WIDTH = 8              ,
    parameter FIFO_DEPTH = 8              ,
    parameter NBITS      = FIFO_WIDTH + 1     // data is 8 bits and one bit for Parity
) (
    input   logic                       clk            ,
    input   logic                       rst            ,
    input   logic [1:0]                 SelBaudRate    ,

// Rx 
    input   logic                       rx             ,
    input   logic                       rx_ren         ,

    output  logic [FIFO_WIDTH - 1 : 0]  rx_read_data   ,
    output  logic                       rx_done        ,
    output  logic                       rx_empty       ,
    output  logic                       rx_full        ,

// Tx
    input   logic                       tx_begin       ,
    input   logic                       tx_wen         ,
    input   logic [FIFO_WIDTH - 1 : 0]  tx_write_data  ,

    output  logic                       tx             ,
    output  logic                       tx_done        ,
    output  logic                       tx_empty       ,
    output  logic                       tx_full
);

    logic Tx_clk  ;
    logic Rx_clk  ;

BaudRateGenerator #(
    .OVERSAMBLE(OVERSAMBLE)     ,    // Rx sampling
    .CLK_FREQ(CLK_FREQ)              // 10 MHz system clock
)baud_generator(
    .clk(clk)                   ,    // system clock
    .rst(rst)                   ,    // system clock reset
    .SelBaudRate(SelBaudRate)   ,    // baud rate selector

    .Rx_clk(Rx_clk)             ,
    .Tx_clk(Tx_clk)      
);



TxUnit #(
    .FIFO_WIDTH(FIFO_WIDTH)  ,
    .NBITS(NBITS)            ,
    .FIFO_DEPTH(FIFO_DEPTH)
)tx_unit(
    .clk(clk),
    .rst(rst),
    .Tx_clk(Tx_clk),
    .tx_begin(tx_begin),
    .wen(tx_wen),
    .wr_data(tx_write_data),

    .tx(tx),
    .tx_done(tx_done),
    .tx_empty(tx_full),
    .tx_full(tx_empty)
);

RxUnit #(
    .NBITS(NBITS)           ,
    .FIFO_WIDTH(FIFO_WIDTH) ,
    .FIFO_DEPTH(FIFO_DEPTH)
)rx_unit(
    .clk(clk),
    .rst(rst),
    .Rx_clk(Rx_clk),
    .rx(rx),
    .ren(rx_ren),

    .read_data(rx_read_data),
    .rx_done(rx_done),
    .rx_full(rx_full),
    .rx_empty(rx_empty)
);

endmodule