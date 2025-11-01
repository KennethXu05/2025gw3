module spi_module (
    input            I_clk,       // 全局时钟50MHz
    input            I_rst_n,     // 复位信号，低电平有效
    input            I_rx_en,     // 读使能信号
    input            I_tx_en,     // 发送使能信号
    input      [7:0] I_data_in,   // 要发送的数据
    output reg [7:0] O_data_out,  // 接收到的数据
    output reg       O_tx_done,   // 发送一个字节完毕标志位
    output reg       O_rx_done,   // 接收一个字节完毕标志位

    output reg       spi_tx_flag, // 发送标志位
    output reg       spi_rx_flag, // 接收标志位

    output reg       spi_finish_flag,  // 完成标志位

    input [7:0] spi_div,  // SPI时钟分频系数

    // 四线标准SPI信号定义
    input      I_spi_miso,  // SPI串行输入，用来接收从机的数据
    output reg O_spi_sck,   // SPI时钟
    output reg O_spi_mosi   // SPI输出，用来给从机发送数据          
);

    reg [3:0] R_tx_state;
    reg [3:0] R_rx_state;
    reg [7:0] spi_div_cnt;

    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            spi_div_cnt <= 8'd0;
        end else if (spi_div_cnt == spi_div - 1'b1) begin
            spi_div_cnt <= 8'd0;
        end else begin
            spi_div_cnt <= spi_div_cnt + 1'b1;
        end
    end


    always @(posedge I_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            R_tx_state <= 4'd0;
            R_rx_state <= 4'd0;

            O_spi_sck  <= 1'b0;
            O_spi_mosi <= 1'b0;
            O_tx_done  <= 1'b0;
            O_rx_done  <= 1'b0;
            O_data_out <= 8'd0;
            spi_finish_flag <= 1'b1;
        end else if (spi_div_cnt == spi_div - 1'b1) begin
            if(I_tx_en) // 发送使能信号打开的情况下
            begin
                spi_finish_flag <= 1'b0;
                spi_tx_flag <= 1'b1;
                spi_rx_flag <= 1'b0;
                case (R_tx_state)
                    4'd1, 4'd3 , 4'd5 , 4'd7  , 
                    4'd9, 4'd11, 4'd13, 4'd15 : //整合奇数状态
                        begin
                        O_spi_sck  <= 1'b1;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd0:    // 发送第7位
                        begin
                        O_spi_mosi <= I_data_in[7];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd2:    // 发送第6位
                        begin
                        O_spi_mosi <= I_data_in[6];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd4:    // 发送第5位
                        begin
                        O_spi_mosi <= I_data_in[5];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd6:    // 发送第4位
                        begin
                        O_spi_mosi <= I_data_in[4];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd8:    // 发送第3位
                        begin
                        O_spi_mosi <= I_data_in[3];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd10:    // 发送第2位
                        begin
                        O_spi_mosi <= I_data_in[2];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd12:    // 发送第1位
                        begin
                        O_spi_mosi <= I_data_in[1];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b0;
                    end
                    4'd14:    // 发送第0位
                        begin
                        O_spi_mosi <= I_data_in[0];
                        O_spi_sck  <= 1'b0;
                        R_tx_state <= R_tx_state + 1'b1;
                        O_tx_done  <= 1'b1;
                    end
                    default: R_tx_state <= 4'd0;
                endcase
            end
            else if(I_rx_en) // 接收使能信号打开的情况下
            begin
                spi_finish_flag <= 1'b0;
                spi_tx_flag <= 1'b0;
                spi_rx_flag <= 1'b1;
                case (R_rx_state)
                    4'd0, 4'd2 , 4'd4 , 4'd6  , 
                    4'd8, 4'd10, 4'd12 : //整合偶数状态
                        begin
                        O_spi_sck  <= 1'b0;
                        R_rx_state <= R_rx_state + 1'b1;
                        O_rx_done  <= 1'b0;
                    end
                    4'd1:    // 接收第7位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[7] <= I_spi_miso;
                    end
                    4'd3:    // 接收第6位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[6] <= I_spi_miso;
                    end
                    4'd5:    // 接收第5位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[5] <= I_spi_miso;
                    end
                    4'd7:    // 接收第4位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[4] <= I_spi_miso;
                    end
                    4'd9:    // 接收第3位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[3] <= I_spi_miso;
                    end
                    4'd11:    // 接收第2位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[2] <= I_spi_miso;
                    end
                    4'd13:    // 接收第1位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[1] <= I_spi_miso;
                    end
                    4'd14: begin
                        O_spi_sck  <= 1'b0;
                        R_rx_state <= R_rx_state + 1'b1;
                        O_rx_done  <= 1'b1;
                    end
                    4'd15:    // 接收第0位
                        begin
                        O_spi_sck     <= 1'b1;
                        R_rx_state    <= R_rx_state + 1'b1;
                        O_rx_done     <= 1'b0;
                        O_data_out[0] <= I_spi_miso;
                    end
                    default: R_rx_state <= 4'd0;
                endcase
            end else begin
                if(spi_tx_flag) begin
                    spi_tx_flag <= 1'b0;
                    if(spi_div != 8'd1) begin
                        O_spi_sck  <= 1'b1;
                    end
                    else begin
                        O_spi_sck  <= 1'b0;
                    end
                end
                else if(spi_rx_flag) begin
                    spi_rx_flag <= 1'b0;
                    if(spi_div != 8'd1) begin
                        O_spi_sck     <= 1'b1;
                        O_data_out[0] <= I_spi_miso;
                    end
                    else begin
                        O_spi_sck  <= 1'b0;
                    end
                end
                else begin
                    O_spi_sck  <= 1'b0;
                    spi_finish_flag <= 1'b1;
                    O_spi_mosi <= 1'b0;
                end
                R_tx_state <= 4'd0;
                R_rx_state <= 4'd0;
                O_tx_done  <= 1'b0;
                O_rx_done  <= 1'b0;


                //O_data_out <= 8'd0;
            end
        end
    end

endmodule
