module logic_analyzer_top (
    input clk,
    input rst_n,

    input trigger,
    input [1:0] trigger_ch,
    input edge_type, // 0: falling, 1: rising
    input en0,
    input en1,
    input en2,
    input en3,
    input [15:0] div_cnt,
    input [11:0] sample_depth,
    input [3:0] data_in,  //4个通道的数据输入

    input uart_tx_done,
    output uart_send_en,
    output [7:0] uart_tx_data
);

    wire wrfifo_pulse;
    wire [7:0] wrfifo_data0;
    wire [7:0] wrfifo_data1;
    wire [7:0] wrfifo_data2;
    wire [7:0] wrfifo_data3;
    wire [7:0] fifo_ch0_data;
    wire [7:0] fifo_ch1_data;
    wire [7:0] fifo_ch2_data;
    wire [7:0] fifo_ch3_data;
    wire fifo_empty0;
    wire fifo_empty1;
    wire fifo_empty2;
    wire fifo_empty3;
    wire [3:0] fifo_rd_req;


    logic_analyzer_sampling u_logic_analyzer_sampling(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .trigger      (trigger      ),
        .trigger_ch   (trigger_ch   ),
        .edge_type    (edge_type    ),
        .div_cnt      (div_cnt      ),
        .sample_depth (sample_depth ),
        .data_in      (data_in      ),
        .wrfifo_pulse (wrfifo_pulse ),
        .wrfifo_data0 (wrfifo_data0 ),
        .wrfifo_data1 (wrfifo_data1 ),
        .wrfifo_data2 (wrfifo_data2 ),
        .wrfifo_data3 (wrfifo_data3 )
    );


    fifo_sc_top_logic_ch0 logic_ch0(
		.Data(wrfifo_data0), //input [7:0] Data
		.Clk(clk), //input Clk
		.WrEn(wrfifo_pulse), //input WrEn
		.RdEn(fifo_rd_req[0]), //input RdEn
		.Reset(!rst_n), //input Reset
		.Q(fifo_ch0_data), //output [7:0] Q
		.Empty(fifo_empty0), //output Empty
		.Full() //output Full
	);

    fifo_sc_top_logic_ch1 logic_ch1(
        .Data(wrfifo_data1), //input [7:0] Data
        .Clk(clk), //input Clk
        .WrEn(wrfifo_pulse), //input WrEn
        .RdEn(fifo_rd_req[1]), //input RdEn
        .Reset(!rst_n), //input Reset
        .Q(fifo_ch1_data), //output [7:0] Q
        .Empty(fifo_empty1), //output Empty
        .Full() //output Full
    );

    fifo_sc_top_logic_ch2 logic_ch2(
        .Data(wrfifo_data2), //input [7:0] Data
        .Clk(clk), //input Clk
        .WrEn(wrfifo_pulse), //input WrEn
        .RdEn(fifo_rd_req[2]), //input RdEn
        .Reset(!rst_n), //input Reset
        .Q(fifo_ch2_data), //output [7:0] Q
        .Empty(fifo_empty2), //output Empty
        .Full() //output Full
    );

    fifo_sc_top_logic_ch3 logic_ch3(
        .Data(wrfifo_data3), //input [7:0] Data
        .Clk(clk), //input Clk
        .WrEn(wrfifo_pulse), //input WrEn
        .RdEn(fifo_rd_req[3]), //input RdEn
        .Reset(!rst_n), //input Reset
        .Q(fifo_ch3_data), //output [7:0] Q
        .Empty(fifo_empty3), //output Empty
        .Full() //output Full
    );


    uart_logic_analyzer_ctrl u_uart_logic_analyzer_ctrl(
        .clk           (clk           ),
        .reset_p       (!rst_n        ),
        .en0           (en0           ),
        .en1           (en1           ),
        .en2           (en2           ),
        .en3           (en3           ),
        .fifo_ch0_data (fifo_ch0_data ),
        .fifo_ch1_data (fifo_ch1_data ),
        .fifo_ch2_data (fifo_ch2_data ),
        .fifo_ch3_data (fifo_ch3_data ),
        .fifo_empty0   (fifo_empty0   ),
        .fifo_empty1   (fifo_empty1   ),
        .fifo_empty2   (fifo_empty2   ),
        .fifo_empty3   (fifo_empty3   ),
        .uart_tx_done  (uart_tx_done  ),
        .fifo_rd_req   (fifo_rd_req   ),
        .uart_send_en  (uart_send_en  ),
        .uart_tx_data  (uart_tx_data  )
    );
    



endmodule