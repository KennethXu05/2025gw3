
module uart_send_ctrl (
    input clk,
    input reset_p,
    input [7:0] fifo_rd_data,
    input fifo_empty,

    input uart_tx_done,
    output reg fifo_rd_req,
    output reg uart_send_en,
    output reg [7:0] uart_tx_data
);

    reg [1:0] state;
    always @(posedge clk or posedge reset_p)
        if (reset_p) begin
            state <= 1'd0;
            uart_tx_data <= 8'd0;
            fifo_rd_req <= 1'd0;
            uart_send_en <= 1'd0;
        end else begin
            case (state)
                0: begin
                    if (!fifo_empty) begin  //如果FIFO不为空，可以开始发送
                        fifo_rd_req <= 1'd1;
                        state <= 2'd1;
                    end else begin
                        fifo_rd_req <= 1'd0;
                        state <= 2'd0;
                    end
                end

                1: begin
                    fifo_rd_req <= 1'd0;
                    uart_send_en <= 1'd1;
                    uart_tx_data <= fifo_rd_data;
                    state <= 2'd2;
                end

                2: begin
                    uart_send_en <= 1'd0;
                    if (uart_tx_done) state <= 2'd0;
                    else state <= 2'd2;
                end

                default: ;
            endcase

        end
endmodule
