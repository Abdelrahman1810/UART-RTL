module BaudRateGenerator #(
    parameter OVERSAMBLE = 16,          // Rx sampling
    parameter CLK_FREQ   = 10_000_000   // 10 MHz system clock
) (
    input       clk         ,       // system clock
    input       rst         ,       // system clock reset
    input [1:0] SelBaudRate ,       // baud rate selector

    output      Rx_clk      ,
    output      Tx_clk      
);

// ... Rx Baud rate generator module ... //
    RxBaudgenerator #(
        .OVERSAMBLE(OVERSAMBLE) ,   // Rx sampling
        .CLK_FREQ(CLK_FREQ)         // 10 MHz system clock
    )rxbaud(
        // input
        .clk(clk)               ,   // Reciver clock
        .rst(rst)               ,   // Reciver clock reset
        .SelBaudRate(SelBaudRate),
        
        // output
        .Rx_clk(Rx_clk)             // Baud rate clock output
    );

// ... Tx Baud rate generator module ... //
    TxBaudgenerator #(
        .OVERSAMBLE(OVERSAMBLE)     // Rx sampling
    )txbaud(
        // inputs
        .Rx_clk(Rx_clk)         ,
        .rst(rst)               ,   // Transmitter clock reset
        
        // output
        .Tx_clk(Tx_clk)
    );
endmodule