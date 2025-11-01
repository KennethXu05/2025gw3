module freq_uart_top(
    clk,
    rst_n,
    uart_rx,
    digit_in,
    uart_tx
);
 
    parameter DATA_WIDTH = 32;
    parameter MSB_FIRST = 1;
    
    //定义触发值
    parameter TRIGGER_VALUE = 32'hFFFFA5A5;
    
    input clk;
    input rst_n;
    input uart_rx;
    input digit_in;
    output uart_tx;
    
    wire [DATA_WIDTH-1:0] rx_data;
    wire Rx_Done;
    wire [7:0] data_byte;
    wire [15:0] high_cnt;
    wire [15:0] low_cnt;
    reg send_enable;
    wire [DATA_WIDTH-1:0] freq_data;

    uart_data_rx 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)        
    )
    u1_uart_data_rx(
        .Clk(clk),
        .Rst_n(rst_n),
        .uart_rx(uart_rx),
        
        .data(rx_data),
        .Rx_Done(Rx_Done),
        .timeout_flag(),
        
        .Baud_Set(3'd4)
     );

    //判断逻辑：当接收到特定值时使能发送
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            send_enable <= 1'b0;
        end else if (Rx_Done) begin
            if (rx_data == TRIGGER_VALUE) begin
                send_enable <= 1'b1;
            end 
            else begin
                send_enable <= 1'b0;
            end
        end 
        else begin
            send_enable <= 1'b0;
        end
    end
    
    //发送的数据
    assign freq_data = send_enable ? {high_cnt, low_cnt} : {DATA_WIDTH{1'b0}};

    uart_data_tx 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)
    )
    u2_uart_data_tx(
        .Clk(clk),
        .Rst_n(rst_n),
      
        .data(freq_data),          // 使用选择后的数据
        .send_en(send_enable),   // 使用条件使能信号
        .Baud_Set(3'd4),  
        
        .uart_tx(uart_tx),  
        .Tx_Done(),   
        .uart_state()
    );
    
    freq_measure u3_freq_measure(
        .clk(clk),
        .rst_n(rst_n),
        .digit_in(digit_in),
        .high_cnt(high_cnt),
        .low_cnt(low_cnt)
    );
endmodule