module EvenParityCheck #(
    parameter NBITS = 8 + 1 // data is 8 bits and one bit for Parity
) (
    // inputs
    input logic [NBITS-1:0] data_out    ,
    input logic             rx_done     ,
    
    // outputs
    output logic data_correct
);
    always @(*) begin
        data_correct = 0;
        if (rx_done) begin
            if ((^data_out[8:1]) == data_out[0]) begin
                data_correct = 1;
            end
        end
    end
endmodule