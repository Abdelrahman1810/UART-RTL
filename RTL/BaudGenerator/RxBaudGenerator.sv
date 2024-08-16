
module RxBaudgenerator #(
    parameter OVERSAMBLE = 16,          // Rx sampling
    parameter CLK_FREQ   = 10_000_000   // 10 MHz system clock
)(
    input           clk         ,   // System clock anr reset
    input           rst         ,   // System clock anr reset
    input [1:0]     SelBaudRate ,
    output reg      Rx_clk          // Baud rate clock output
);
    localparam BRD48 = 'b00; // 4800
    localparam BRD96 = 'b01; // 9600
    localparam BRD57 = 'b10; // 57600
    localparam BRD11 = 'b11; // 115200

integer Rx_Divisor;
reg [14:0] Rx_counter = 0;

always @(*) begin
    case (SelBaudRate)
        BRD48: begin
            Rx_Divisor = (CLK_FREQ/(4800 * OVERSAMBLE * 2)) + 1;
        end
        BRD96: begin
            Rx_Divisor = (CLK_FREQ/(9600 * OVERSAMBLE * 2)) + 1;
        end
        BRD57: begin
            Rx_Divisor = (CLK_FREQ/(57600 * OVERSAMBLE * 2)) + 1;
        end
        BRD11: begin
            Rx_Divisor = (CLK_FREQ/(115200 * OVERSAMBLE * 2)) + 1;
        end
        default: begin
            Rx_Divisor = 0;
        end
    endcase
end

/////////////// Rx ///////////////
always @(posedge clk or posedge rst) begin
    if (rst) begin
        Rx_counter <= 0;
        Rx_clk <= 0;
    end else begin
        if (Rx_counter == Rx_Divisor) begin
            Rx_counter <= 0;
            Rx_clk <= ~Rx_clk;
        end else begin
            Rx_counter <= Rx_counter + 1;
        end
    end
end

endmodule
