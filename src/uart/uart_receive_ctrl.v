module uart_receive_ctrl (
    input clk,
    input reset_p,
    input rx_done,
    output reg wr_pulse,
    output reg tx_en,
    output reg [15:0]data_length
);
    parameter max_cnt = 19'd500000;
    reg [18:0]cnt;
    reg [1:0] state;
    reg [15:0]data_length_reg;


    always@(posedge clk or posedge reset_p)
        if (reset_p) cnt <= 1'd0;
        else if (cnt == max_cnt) cnt <= 1'd0;
        else if(rx_done) cnt <= 1'd0;
        else cnt <= cnt + 1'b1;

    always @(posedge clk or posedge reset_p)
        if (reset_p) begin
            state <= 1'd0;
            wr_pulse <= 1'd0;
            data_length <= 1'd0;
            data_length_reg <= 1'd0;
        end else begin
            case (state)
                0: begin
                    tx_en <= 1'd0;
                    if (rx_done) begin  //接收到1byte数据，产生写使能脉冲
                        wr_pulse <= 1'd1;
                        data_length_reg <= data_length_reg + 1'b1;
                        state <= 2'd1;
                    end else begin
                        wr_pulse <= 1'd0;
                        state <= 2'd0;
                    end
                end

                1: begin
                    wr_pulse <= 1'd0;
                    if (!rx_done) state <= 2'd2;
                    else state <= 2'd1;
                end

                2: begin
                    if (cnt == max_cnt) begin
                        state <= 1'd0;
                        data_length <= data_length_reg;
                        data_length_reg <= 1'd0;
                        tx_en <= 1'd1;
                        
                    end else if(rx_done)begin
                        wr_pulse <= 1'd1;
                        data_length_reg <= data_length_reg + 1'b1;
                        state <= 2'd1;
                    end
                    else state <= 2'd2;
                end

                default: ;
            endcase

        end


endmodule
