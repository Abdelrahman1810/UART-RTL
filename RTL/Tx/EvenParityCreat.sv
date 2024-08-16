module EvenParityCreat #(
    parameter NBITS = 8 + 1
) (
    input [NBITS - 2 : 0] din,
    output parity
);
    assign parity = (^din)? 1'b1 : 1'b0;
endmodule