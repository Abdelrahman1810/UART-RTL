`timescale 100ns/100ns

module uart_tb();
parameter OVERSAMBLE = 16             ;
parameter CLK_FREQ   = 10_000_000     ;
parameter FIFO_WIDTH = 8              ;
parameter FIFO_DEPTH = 8              ;
parameter NBITS      = FIFO_WIDTH + 1 ;

logic                       clk            ;
logic                       rst            ;
logic [1:0]                 SelBaudRate    ;

// Rx 
logic                       rx             ;
logic                       rx_ren         ;

logic [FIFO_WIDTH - 1 : 0]  rx_read_data   ;
logic                       rx_done        ;
logic                       rx_empty       ;
logic                       rx_full        ;

// Tx
logic                       tx_begin       ;
logic                       tx_wen         ;
logic [FIFO_WIDTH - 1 : 0]  tx_write_data  ;

logic                       tx             ;
logic                       tx_done        ;
logic                       tx_empty       ;
logic                       tx_full        ;

UART #(
    // parameters
    .OVERSAMBLE(OVERSAMBLE)         ,   // Rx sampling
    .CLK_FREQ(CLK_FREQ)             ,   // 10 MHz system clock
    .FIFO_WIDTH(FIFO_WIDTH)         ,
    .FIFO_DEPTH(FIFO_DEPTH)         ,
    .NBITS(NBITS)                   // data is 8 bits and one bit for Parity
)uart(
    .clk(clk)                       ,
    .rst(rst)                       ,
    .SelBaudRate(SelBaudRate)       ,

    // Rx 
    .rx(rx)                         ,
    .rx_ren(rx_ren)                 ,
    .rx_read_data(rx_read_data)     ,
    .rx_done(rx_done)               ,
    .rx_empty(rx_empty)             ,
    .rx_full(rx_full)               ,

    // Tx
    .tx_begin(tx_begin)             ,
    .tx_wen(tx_wen)                 ,
    .tx_write_data(tx_write_data)   ,
    .tx(tx)                         ,
    .tx_done(tx_done)               ,
    .tx_empty(tx_empty)             ,
    .tx_full(tx_full)   
);

bit tx_finish, rx_finish;
always_comb begin
    if (tx_finish & rx_finish)
        $finish;
end

initial begin
`ifdef BRD48
    SelBaudRate = 2'b00; // 4800
`elsif BRD96
    SelBaudRate = 2'b01; // 9600
`elsif BRD57
    SelBaudRate = 2'b10; // 57600
`elsif BRD11
    SelBaudRate = 2'b11; // 115200
`endif

    clk = 0;
    forever begin
        #1 clk = ~clk;
    end
end

// ********************************************* //
// ...     ...     ... reset ...     ...     ... //
// ********************************************* //

initial begin
    rst = 1;
    // start_read = 0;
    tx_begin = 0;
    tx_wen = 0;
    tx_write_data = 0;
    rx = 1;
    rx_ren = 0;
    #5_000;
    rst = 0;
end

// **************************************************** //
// ...     ...     ... Tx testbench ...     ...     ... //
// **************************************************** //

initial begin
    #10000;
    #100;
    @(posedge uart.Tx_clk);

    for (int i=3; i>=0; --i) begin
        tx_wen = 1;
        repeat(1) begin
            // tx_write_data++;
            tx_write_data = $random;
            @(posedge clk);
        end

        if (!i) // last write need one more clk cycle before disable tx_wen
            @(posedge clk);

        tx_wen = 0;

        // Wait
            repeat(5) @(posedge uart.Tx_clk);
    end
end

// Transmit
initial begin
    $readmemb ("Txfifo.dat", uart.tx_unit.txfifo.rg.memory);
    #10000;
    #100;
    @(posedge uart.Tx_clk);
    // start_read = 1;
    @(posedge uart.Tx_clk);
    tx_begin = 1;
    @(posedge uart.Tx_clk);
    repeat(5) begin
        repeat(11) begin
            @(posedge uart.Tx_clk);
        end
    end
    @(posedge uart.Tx_clk);
    tx_finish = 1;
    // $stop;
end

// **************************************************** //
// ...     ...     ... Rx testbench ...     ...     ... //
// **************************************************** //

initial begin
    #10000;
    #100;
    repeat(2) @(posedge uart.Tx_clk);

    repeat(2) begin
        concatenate($random);
    end

    repeat(10) @(posedge uart.Tx_clk);

    repeat(2) begin
        concatenate($random);
    end
end

// Recive
initial begin
    $readmemb ("Rxfifo.dat", uart.rx_unit.Rx_fifo.rg.memory);
    #10000;
    // #100;

    repeat(20) @(posedge uart.Tx_clk);

    repeat(4) begin
        rx_ren = 1;
        @(posedge clk);
        rx_ren = 0;
        
        // Wait
        repeat(12) @(posedge uart.Tx_clk);
        rx_finish = 1;
    end

end

task concatenate(reg [7:0] concatenate_rx = 8'b10101010);
    rx = 0; 
    @(posedge uart.Tx_clk);
    for (int i=7; i>=0; --i) begin
        rx = concatenate_rx[i];
        @(posedge uart.Tx_clk);
    end
    rx = ($countones(concatenate_rx)%2 == 1)? 1'b1 : 1'b0;
    @(posedge uart.Tx_clk);
    rx = 1; 
    @(posedge uart.Tx_clk);
endtask

endmodule