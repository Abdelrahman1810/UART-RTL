module TransmitterPISO #(
    parameter NBITS = 8 + 1, // data is 8 bits and one bit for Parity
    parameter FIFO_WIDTH = 8 // data is 8 bits and one bit for Parity
) (
    // inputs
    input logic Tx_clk,
    input logic rst,
    input logic [FIFO_WIDTH - 1:0] din,
    input logic tx_start,
    input logic parity,

    // outputs
    output logic tx,
    output logic tx_done
);
    typedef enum reg[2:0] {IDLE, START, DATA, PARITY, STOP} state;
    state current_state, next_state;
    logic [FIFO_WIDTH - 1:0] data;
    reg [3:0] Tx_counter = 0;

    always @(posedge Tx_clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (tx_start) begin
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                if (Tx_counter == NBITS-1) begin
                    next_state = PARITY;
                end else begin
                    next_state = DATA;
                end
            end
            PARITY: begin
                next_state = STOP;
            end
            STOP: begin
                if (tx_start) begin
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge Tx_clk or posedge rst) begin
        if (rst) begin
            Tx_counter <= 0;
            tx_done <= 0;
            tx <= 1'b1;
        end 
        else begin
            if (current_state == START) begin
                data = din;
            end
            case (next_state)
                START: begin
                    Tx_counter <= 0;
                    tx_done <= 0;
                    tx <= 0;
                end
                DATA: begin
                    tx <= data[FIFO_WIDTH - 1];
                    data <= data << 1;
                    Tx_counter <= Tx_counter + 1;
                end
                PARITY: begin
                    tx <= parity;
                end
                STOP: begin
                    tx <= 1'b1;
                    tx_done <= 1'b1;
                    Tx_counter <= 0;
                end
                default: begin
                    tx <= 1'b1;
                    Tx_counter <= 0;
                    tx_done <= 0;
                end
            endcase
        end
    end
endmodule