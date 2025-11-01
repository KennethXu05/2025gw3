`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/29 09:47:09
// Design Name: 
// Module Name: FX2_CDC_UART_SPI
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FX2_CDC_UART_SPI (
    input       clk,
    input       reset_n,
    inout [7:0] fx2_fdata,  //  FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勬暟鎹嚎
    input       fx2_flagb,  //  FX2鍨婾SB2.0鑺墖鐨勭�??2 OUT绌烘爣蹇楋紝1涓洪潪绌猴紝0涓虹�?
    input       fx2_flagc,  //  FX2鍨婾SB2.0鑺墖鐨勭�??6 IN婊℃爣蹇楋紝1涓洪潪婊★紝0涓烘�?
    input       fx2_ifclk,  //  FX2鍨婾SB2.0鑺墖鐨勬帴鍙ｆ椂閽熶俊�??

    output [1:0] fx2_faddr,  //  FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨凢IFO鍦板潃绾?
    output fx2_sloe,  //  FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勮緭鍑轰娇鑳戒俊鍙凤紝浣庣數骞虫湁�??
    output fx2_slwr,  //  FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勫啓鎺у埗淇″彿锛屼綆鐢靛钩鏈夋�?
    output fx2_slrd,  //  FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勮鎺у埗淇″彿锛屼綆鐢靛钩鏈夋�?
    output fx2_pkt_end,  //鏁版嵁鍖呯粨鏉熸爣蹇椾俊�??
    output fx2_slcs,
    //FPGA涓嶧X2涔嬮棿鐨凷PI鎺ュ彛锛岀敤鏉ヤ紶杈撶鐐?0鐨勭壒瀹氭暟鎹寘
    input  FX2_SPI_CS,
    input  FX2_SPI_SCLK,
    input  FX2_SPI_MOSI,
    output FX2_SPI_MISO,

    input uart_recv_done,
    input  tx_fifo_pop,
    input [7:0] uart_rx_data,
    output tx_fifo_empty,
    output [7:0] byte_tx_data,
    //鎷ㄧ爜寮€鍏崇敤鏉ュ垏鎹㈡暟鐮佺鐨勬樉绀哄唴瀹瑰拰SPI/UART鍔熻�?
    //UART杩炴帴鍒版澘杞界殑USB杞覆鍙ｈ姱�??
    /*output uart_tx,
    input  uart_rx,
    //SPI杩炴帴鍒版澘杞界殑ADC128S
    output SPI_M_CS,
    output SPI_M_SCLK,
    output SPI_M_MOSI,
    input  SPI_M_MISO*/
    input ctrl,
    input switch,
    input hdmi_fifo_rd_en_usb,
    output [7:0]hdmi_fifo_data_usb,
    output hdmi_fifo_empty_usb
);

  wire [7:0] Param0;
  wire [7:0] Param1;
  wire [7:0] Param2;
  wire [7:0] Param3;
  wire [7:0] Param4;
  wire [7:0] Param5;
  wire [7:0] Param6;
  reg rst_n;
  User_Param User_Param_inst (
      .clk     (fx2_ifclk),
      .reset_n (rst_n & reset_n),
      .SPI_CS  (FX2_SPI_CS),
      .SPI_SCLK(FX2_SPI_SCLK),
      .SPI_MOSI(FX2_SPI_MOSI),
      .SPI_MISO(FX2_SPI_MISO),
      .Param0  (Param0),
      .Param1  (Param1),
      .Param2  (Param2),
      .Param3  (Param3),
      .Param4  (Param4),
      .Param5  (Param5),
      .Param6  (Param6)
  );


  // 涓夋€佸鐞?
  wire [7:0] fx2_fdata_in;
  wire [7:0] fx2_fdata_out;
  assign fx2_fdata_in = fx2_slrd ? 8'h00 : fx2_fdata;
  assign fx2_fdata    = fx2_slwr ? 8'hZZ : fx2_fdata_out;

  wire byte_rx_done;

  wire [7:0] byte_rx_data;

  //wire uart_send_en;
  

  wire spi_trans_en;
  wire spi_trans_done;

  wire [7:0] spi_tx_data;
  wire [7:0] spi_rx_data;

  //assign uart_send_en =  byte_send_en ;
  assign spi_trans_en =  1'b0 ;
  assign spi_tx_data = 8'h00 ;
  assign byte_rx_done = uart_recv_done ;
  assign byte_rx_data = uart_rx_data ;

  wire rx_fifo_full;
  wire rx_fifo_empty;
  wire rx_fifo_pop;

  wire tx_fifo_full;
  wire tx_fifo_push;

  
assign fx2_slcs = 1'b0;

usb_mtos_fifo usb_mtos_fifo(
	.Data(fx2_fdata_in), //input [7:0] Data
	.Reset(!reset_n), //input Reset
	.WrClk(fx2_ifclk), //input WrClk
	.RdClk(clk), //input RdClk
	.WrEn(tx_fifo_push), //input WrEn
	.RdEn(tx_fifo_pop), //input RdEn
	.Q(byte_tx_data), //output [7:0] Q
	.Empty(tx_fifo_empty), //output Empty
	.Full(tx_fifo_full) //output Full
);/*
  fifo_1024x8 tx_fifo (
      .din       (fx2_fdata_in),
      .write_busy(tx_fifo_push),
      .fifo_full (tx_fifo_full),
      .dout      (byte_tx_data),
      .read_busy (tx_fifo_pop),
      .fifo_empty(tx_fifo_empty),
      .fifo_clk  (fx2_ifclk),
      .reset_    (rst_n & reset_n),
      .fifo_flush(1'b0)
  );*/

  // rx fifo
  usb_stom_fifo usb_stom_fifo(
		.Data(byte_rx_data), //input [7:0] Data
		.Reset(!reset_n), //input Reset
		.WrClk(clk), //input WrClk
		.RdClk(fx2_ifclk), //input RdClk
		.WrEn((byte_rx_done & (~rx_fifo_full))), //input WrEn
		.RdEn(rx_fifo_pop), //input RdEn
		.Q(fx2_fdata_out), //output [7:0] Q
		.Empty(rx_fifo_empty), //output Empty
		.Full(rx_fifo_full) //output Full
	);/*
  fifo_1024x8 rx_fifo (
      .din       (byte_rx_data),
      .write_busy((byte_rx_done & (~rx_fifo_full))),
      .fifo_full (rx_fifo_full),
      .dout      (fx2_fdata_out),
      .read_busy (rx_fifo_pop),
      .fifo_empty(rx_fifo_empty),
      .fifo_clk  (fx2_ifclk),
      .reset_    (rst_n & reset_n),
      .fifo_flush(1'b0)
  );*/


  fx2_fifo_crtl fx2_fifo_crtl_inst (
      .fx2_ifclk(fx2_ifclk),
      .reset_n(rst_n & reset_n),
      .fx2_flagb(fx2_flagb),  // FX2鍨婾SB2.0鑺墖鐨勭�??2 OUT绌烘爣蹇楋紝1涓洪潪绌猴紝0涓虹�?
      .fx2_flagc(fx2_flagc),  // FX2鍨婾SB2.0鑺墖鐨勭�??6 IN婊℃爣蹇楋紝1涓洪潪婊★紝0涓烘�?
      .fx2_faddr(fx2_faddr),  // FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨凢IFO鍦板潃绾?
      .fx2_sloe(fx2_sloe),  // FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勮緭鍑轰娇鑳戒俊鍙凤紝浣庣數骞虫湁�??
      .fx2_slwr(fx2_slwr),  // FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勫啓鎺у埗淇″彿锛屼綆鐢靛钩鏈夋�?
      .fx2_slrd(fx2_slrd),  // FX2鍨婾SB2.0鑺墖鐨凷laveFIFO鐨勮鎺у埗淇″彿锛屼綆鐢靛钩鏈夋�?
      .rx_fifo_empty(rx_fifo_empty),
      .rx_fifo_full(rx_fifo_full),
      .tx_fifo_full(tx_fifo_full),
      .tx_fifo_push(tx_fifo_push),
      .rx_fifo_pop(rx_fifo_pop),
      .fx2_pkt_end(fx2_pkt_end)
  );
/*
  byte_tx_control byte_tx_control(
    .clk(fx2_ifclk),
    .rst_n(rst_n & reset_n),
    .tx_fifo_empty(tx_fifo_empty),
    .byte_tx_done(byte_tx_done),
    .tx_fifo_pop(tx_fifo_pop),
    .byte_send_en(byte_send_en)
);*/


  wire [31:0] Baud_Rate;
  wire [31:0] SPI_M_Freq;

  assign Baud_Rate  = {Param3, Param2, Param1, Param0};
  assign SPI_M_Freq = {Param3, Param2, Param1, Param0};
/*
  uart_byte_tx uart_byte_tx (
      .Clk       (fx2_ifclk),
      .Rst_n     (rst_n & reset_n),
      .data_byte (uart_tx_data),
      .send_en   (uart_send_en),
      .Baud_Rate (Baud_Rate),
      .uart_tx   (uart_tx),
      .Tx_Done   (uart_send_done),
      .uart_state(uart_state)
  );


  uart_byte_rx uart_byte_rx (
      .Clk      (fx2_ifclk),
      .Rst_n    (rst_n & reset_n),
      .Baud_Rate(Baud_Rate),
      .uart_rx  (uart_rx),
      .data_byte(uart_rx_data),
      .Rx_Done  (uart_recv_done)
  );
*/

  /*Spi_Master_Ctrl #(
      .CPOL(1'b1),  //绌洪棽鏃禨CK鐢靛钩锛?1涓洪珮锛?0涓轰�?
      .CPHA(1'b1),  //鏁版嵁鎹曡幏杈规部锛?0涓虹涓€涓竟娌匡�?1涓虹�?2涓竟娌?
      .BITS_ORDER(1'b1)  //鏁版嵁浼犺緭浣嶅簭锛?1涓洪珮浣嶅湪鍓嶏�?0涓轰綆浣嶅湪�??
  ) Spi_Master_Ctrl (
      .clk(fx2_ifclk),
      .rst_n(rst_n & reset_n),
      .spi_freq(SPI_M_Freq),
      .SPI_CS(),
      .SPI_SCLK(),
      .SPI_MOSI(),
      .SPI_MISO(),
      .tx_data(spi_tx_data),
      .trans_en(spi_trans_en),
      .rx_data(spi_rx_data),
      .trans_done(spi_trans_done),
      .spi_busy(spi_busy)
  );*/

    reg [23:0]rst_cnt;


    always @(posedge clk,negedge reset_n)begin  //鐢变簬楂樹簯澶嶄綅瀵勫瓨鍣ㄩ棶棰橈紝澧炲姞鍔犱竴涓欢鏃跺浣?
    if(!reset_n)
        rst_cnt <= 0;
    else if(rst_cnt == 5_000_000)
        rst_cnt <= rst_cnt;
    else
        rst_cnt <= rst_cnt + 1;
    end

    always @(posedge clk ,negedge reset_n)begin
    if(!reset_n)
        rst_n <= 0;
    else if((rst_cnt >= 4_000_000) && (rst_cnt <= 4_500_000))
        rst_n <= 0;
    else
        rst_n <= 1;
    end

    usb_mtos_fifo usb_HDMI(
	.Data(fx2_fdata_in), //input [7:0] Data
	.Reset(switch | ctrl), //input Reset
	.WrClk(fx2_ifclk), //input WrClk
	.RdClk(clk), //input RdClk
	.WrEn(tx_fifo_push), //input WrEn
	.RdEn(hdmi_fifo_rd_en_usb), //input RdEn
	.Q(hdmi_fifo_data_usb), //output [7:0] Q
	.Empty(hdmi_fifo_empty_usb), //output Empty
	.Full() //output Full
);

endmodule
