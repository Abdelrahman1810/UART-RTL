module TxBaudgenerator #(
    parameter OVERSAMBLE = 16  // Rx sampling
)(
    input   Rx_clk      ,              // System clock anr reset
    input   rst         ,              // System clock anr reset
    output  Tx_clk
);

reg [$clog2(OVERSAMBLE) - 1 :0] counter = 0;

/////////////// Tx ///////////////
always @(posedge Rx_clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end

assign Tx_clk = counter[$clog2(OVERSAMBLE) - 1];
endmodule
