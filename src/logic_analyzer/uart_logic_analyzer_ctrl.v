
module uart_logic_analyzer_ctrl (
    input clk,
    input reset_p,

    input en0,
    input en1,
    input en2,
    input en3,

    input [7:0] fifo_ch0_data,
    input [7:0] fifo_ch1_data,
    input [7:0] fifo_ch2_data,
    input [7:0] fifo_ch3_data,
    input fifo_empty0,
    input fifo_empty1,
    input fifo_empty2,
    input fifo_empty3,

    input uart_tx_done,
    output reg [3:0] fifo_rd_req,
    output reg uart_send_en,
    output reg [7:0] uart_tx_data
);

    reg [1:0] state;
    reg [1:0] flag;

    always @(posedge clk or posedge reset_p)
        if (reset_p) begin
            state <= 2'd0;
            uart_tx_data <= 8'd0;
            fifo_rd_req <= 4'd0;
            uart_send_en <= 1'd0;
            flag <= 2'd0;
        end else begin
            case (state)
                0:begin
                    if (en0) begin
                        flag <= 2'd0;
                        state <= 2'd1;
                    end
                    else if (en1) begin
                        flag <= 2'd1;
                        state <= 2'd1;
                    end
                    else if (en2) begin
                        flag <= 2'd2;
                        state <= 2'd1;
                    end
                    else if (en3) begin
                        flag <= 2'd3;
                        state <= 2'd1;
                    end
                    else state <= 2'd0;
                end

                1: begin
                    if (flag == 2'd0) begin
                        if (!fifo_empty0) begin
                            fifo_rd_req <= 4'b0001;
                            state <= 2'd2;
                        end else begin
                            fifo_rd_req <= 4'd0;
                            state <= 2'd0;
                        end
                    end
                    else if (flag == 2'd1) begin
                        if (!fifo_empty1) begin
                            fifo_rd_req <= 4'b0010;
                            state <= 2'd2;
                        end else begin
                            fifo_rd_req <= 4'd0;
                            state <= 2'd0;
                        end
                    end
                    else if (flag == 2'd2) begin
                        if (!fifo_empty2) begin
                            fifo_rd_req <= 4'b0100;
                            state <= 2'd2;
                        end else begin
                            fifo_rd_req <= 4'd0;
                            state <= 2'd0;
                        end
                    end
                    else if (flag == 2'd3) begin
                        if (!fifo_empty3) begin
                            fifo_rd_req <= 4'b1000;
                            state <= 2'd2;
                        end else begin
                            fifo_rd_req <= 4'd0;
                            state <= 2'd0;
                        end
                    end
                    else begin
                        fifo_rd_req <= 4'd0;
                        state <= 2'd0;
                    end
                end

                2: begin
                    fifo_rd_req <= 4'd0;
                    uart_send_en <= 1'd1;
                    if (flag == 2'd0) begin
                        uart_tx_data <= fifo_ch0_data;
                    end
                    else if (flag == 2'd1) begin
                        uart_tx_data <= fifo_ch1_data;
                    end
                    else if (flag == 2'd2) begin
                        uart_tx_data <= fifo_ch2_data;
                    end
                    else if (flag == 2'd3) begin
                        uart_tx_data <= fifo_ch3_data;
                    end
                    state <= 2'd3;
                end

                3: begin
                    uart_send_en <= 1'd0;
                    if (uart_tx_done) begin
                        if (flag == 2'd0 && fifo_empty0) begin
                            state <= 2'd0;
                        end
                        else if (flag == 2'd1 && fifo_empty1) begin
                            state <= 2'd0;
                        end
                        else if (flag == 2'd2 && fifo_empty2) begin
                            state <= 2'd0;
                        end
                        else if (flag == 2'd3 && fifo_empty3) begin
                            state <= 2'd0;
                        end
                        else state <= 2'd1;
                    end
                    else state <= 2'd3;
                end

                default: ;
            endcase

        end
endmodule
