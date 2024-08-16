module ReceiverSIPO #(
    parameter NBITS = 8 + 1 // data is 8 bits and one bit for Parity
) (
    input  logic Rx_clk,
    input  logic rst,
    input  logic rx,

    output logic rx_done,
    output logic [NBITS-1:0] data_out
);
    typedef enum reg [2:0] {IDLE, START, DATA, PARITY, STOP} state;
    state curr_state, next_state;

    reg [3:0] counter = 0;
    reg [3:0] n = 0;

    always @(posedge Rx_clk or posedge rst) begin
        if (rst) begin
            curr_state <= IDLE;
        end else begin
            curr_state <= next_state;
        end
    end


    always @(*) begin
        case (curr_state)
            IDLE: begin
                if (rx == 0) begin
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            START: begin
                if (counter == 15) begin
                    next_state = DATA;
                end else begin
                    next_state = START;
                end
            end
            DATA: begin
                if (n == NBITS - 1 /*&& counter == 15*/) begin
                    next_state = PARITY;
                end else begin
                    next_state = DATA;
                end
            end
            PARITY: begin
                if (counter == 15) begin
                    next_state = STOP;
                end else begin
                    next_state = PARITY;
                end
            end
            STOP: begin
                if (counter == 15) begin
                    next_state = IDLE;
                end else begin
                    next_state = STOP;
                end
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end

    always @(posedge Rx_clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            data_out <= 0;
            n <= 0;
            data_out <= 0;
            rx_done <= 0;
        end else begin
            case (curr_state)
                IDLE: begin
                    counter <= 0;
                    data_out <= 0;
                    n <= 0;
                    rx_done <= 0;
                end
                START: begin
                    counter <= counter + 1;
                end
                DATA: begin
                    if (counter == 7) begin
                        data_out <= rx | (data_out << 1);
                    end

                    // rx_done <= (n == NBITS)? 1'b1 : 1'b0;
                    counter <= counter + 1;
                    if (counter == 15) begin
                        n <= n + 1;
                    end
                end
                PARITY: begin
                    if (counter == 7) begin
                        data_out <= rx | (data_out << 1);
                        rx_done <=  1'b1;
                    end
                    if (counter == 8) begin
                        rx_done <=  1'b0;
                    end
                    counter <= counter + 1;
                end
                STOP: begin
                    counter <= counter + 1;
                    n <= 0;
                    rx_done <= 0;
                end
            endcase
        end
    end
endmodule