/////////////////////////////////////////////////////////////////////////////////
// Company: 姝︽眽鑺矾鎭掔鎶�鏈夐檺鍏徃
// Engineer: 灏忔鍝ュ洟锟???
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: rom_char_tft
// Module Name: rom_char_tft
// Project Name: rom_char_tft
// Target Devices: XC7A35T-2FGG484I
// Tool Versions: Vivado 2018.3
// Description: rom_char_tft椤圭洰鐨勯《灞傝皟搴︽枃浠讹紝鏀寔閿佺浉鐜紝娑叉櫠椹卞姩鍜屽瓧绗︽樉绀虹殑鍗忚皟宸ヤ綔
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module rom_char_tft_hdmi(
	clk50M,
	reset_n,

	TFT_rgb,
	TFT_hs,
	TFT_vs,
	TFT_clk,
	TFT_de,
	TFT_pwm,
	
	  //hdmi1 interface
    hdmi1_clk_p   ,
    hdmi1_clk_n   ,
    hdmi1_dat_p   ,
    hdmi1_dat_n   ,
    hdmi1_oe      ,
  //hdmi2 interface
    hdmi2_clk_p   ,
    hdmi2_clk_n   ,
    hdmi2_dat_p   ,
    hdmi2_dat_n   ,
    hdmi2_oe      ,

	fifo_empty    ,
	fifo_data     ,
	rd_en,


  I_vtc2_offset_x,//相对屏幕原点(左上角)X方向偏移
  I_vtc2_offset_y,//相对屏幕原点(左上角)Y方向偏移
  I_wave1_clk,//采样时钟1
  I_wave1_data,//采样数据1
  I_wave1_data_de,//采样数据有效1
  I_wave2_clk,//采样时钟2
  I_wave2_data,//采样数据2
  I_wave2_data_de,//采样数据有效2

  single,
  trigger_edge,//switch
  trigger_button//button

  
);

	input         clk50M;   //绯荤粺鏃堕挓杈撳叆锟???50M
	input         reset_n;  //澶嶄綅淇″彿杈撳叆锛屼綆鏈夋晥
	
	input 	   fifo_empty; //fifo绌烘爣锟??
	input [7:0] fifo_data;  //fifo鏁版嵁杈撳叆
	output      rd_en;     //fifo璇讳娇鑳戒俊锟??

	output [15:0] TFT_rgb;  //TFT鏁版嵁杈撳嚭
	output        TFT_hs;   //TFT琛屽悓姝ヤ俊锟???
	output        TFT_vs;   //TFT鍦哄悓姝ヤ俊锟???
	output        TFT_clk;  //TFT鍍忕礌鏃堕挓
	output        TFT_de;   //TFT鏁版嵁浣胯兘
	output        TFT_pwm;  //TFT鑳屽厜鎺у埗
	
  input [11:0]I_vtc2_offset_x;//相对屏幕原点(左上角)X方向偏移
  input [11:0]I_vtc2_offset_y;//相对屏幕原点(左上角)Y方向偏移
  //通道1
  input I_wave1_clk;//采样时钟1
  input [7:0] I_wave1_data;//采样数据1
  input I_wave1_data_de;//采样数据有效1
  //通道2
  input I_wave2_clk;//采样时钟2
  input [7:0] I_wave2_data;//采样数据2
  input I_wave2_data_de;//采样数据有效2

  input single;
    
  input trigger_edge;//switch
  input trigger_button;//button

  
   //hdmi1 interface
    output          hdmi1_clk_p   ;
    output          hdmi1_clk_n   ;
    output [2:0]    hdmi1_dat_p   ;
    output [2:0]    hdmi1_dat_n   ;
    output          hdmi1_oe      ;
	   //hdmi2 interface
    output          hdmi2_clk_p   ;
    output          hdmi2_clk_n   ;
    output [2:0]    hdmi2_dat_p   ;
    output [2:0]    hdmi2_dat_n   ;
    output          hdmi2_oe      ;
	
	//璁剧疆寰呮樉绀哄瓧绗﹀昂瀵革紝鍜屽瓨鍌ㄥ瓧绗OM鐨勫湴鍧�浣嶅
	parameter CHAR_WIDTH        = 16; //鍗曚釜瀛楃鏄剧ず瀹藉害
	parameter CHAR_HEIGHT       = 32; //鍗曚釜瀛楃鏄剧ず楂樺害
	//parameter ROW_DISP_CHAR_NUM = 14; //涓�琛屾樉绀哄瓧绗︿釜锟???
	//parameter COL_DISP_CHAR_NUM = 2 ; //鏄剧ず瀛楃琛屾暟
	parameter CHAR_ROM_ADDR_W   = 12 ; //瀛樺偍瀛楃ROM鍦板潃浣嶅锛宭og2(CHAR_HEIGHT * COL_DISP_CHAR_NUM)
	parameter DISP_BACK_COLOR = 16'hFFFF; //鑳屾櫙鐧借壊
	parameter DISP_CHAR_COLOR = 16'h0000; //鏄剧ず瀛楃榛戣壊
	//璁剧疆TFT灞忓箷灏哄
	parameter TFT_WIDTH  = 800;
	parameter TFT_HEIGHT = 600;
	//鏄剧ず瀛楃涓茬殑鎬荤殑鍍忕礌鐐瑰搴﹀拰楂樺害
	//localparam DISP_CHAR_TOTAL_W = CHAR_WIDTH  * ROW_DISP_CHAR_NUM;
	//localparam DISP_CHAR_TOTAL_H = CHAR_HEIGHT * COL_DISP_CHAR_NUM;
	//瀛楃鏄剧ず鍦ㄥ睆骞曚腑闂翠綅锟???
	//localparam DISP_HBEGIN = (TFT_WIDTH  - DISP_CHAR_TOTAL_W)/2;
	//DISP_VBEGIN = (TFT_HEIGHT - DISP_CHAR_TOTAL_H)/2;

	wire                         pll_locked;
	wire                         clk_ctrl;
	wire                         tft_reset_n;
	wire [15:0]                  disp_data;
	wire                         disp_data_req;
	wire [11:0]                  visible_hcount;
	wire [11:0]                  visible_vcount;

	wire [11:0] rom_addra;
	wire [15:0] rom_data;
  
	assign tft_reset_n = pll_locked;
	wire tft_reset_p;
    wire [4:0]Disp_Red;
    wire [5:0]Disp_Green;
    wire [4:0]Disp_Blue;
    wire [15:0]TFT_rgb;
    wire Frame_Begin;
    wire loc_clk33M;
    wire loc_clk165M;

    HDMI_PLL HDMI_PLL(
        .lock(pll_locked), //output lock
		.init_clk(clk50M), //input  init_clk
        .clkout0(loc_clk33M), //output clkout0
        .clkout1(loc_clk165M), //output clkout1
        .clkin(clk50M), //input clkin
        .reset(~reset_n) //input reset
    );
  
  assign clk_ctrl = loc_clk33M;
  

   /* Gowin_pROM Gowin_pROM(
        .dout(rom_data), //output [15:0] dout
        .clk(clk_ctrl), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~reset_n), //input reset
        .ad(rom_addra) //input [15:0] ad
    ); *//*
	char_rom char_rom(
        .dout(rom_data), //output [15:0] dout
        .clk(clk_ctrl), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~reset_n), //input reset
        .ad(rom_addra) //input [11:0] ad
    );*/
	asscii_rom asscii_rom(
        .dout(rom_data), //output [15:0] dout
        .clk(clk_ctrl), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~reset_n), //input reset
        .ad(rom_addra) //input [11:0] ad
    );
  char_extract
  #(
    .H_Visible_area   (TFT_WIDTH        ), //灞忓箷鏄剧ず鍖哄煙瀹藉害
    .V_Visible_area   (TFT_HEIGHT       ), //灞忓箷鏄剧ず鍖哄煙楂樺害
    .CHAR_WIDTH       (CHAR_WIDTH       ), //鍗曚釜瀛楃鏄剧ず瀹藉害
    .CHAR_HEIGHT      (CHAR_HEIGHT      ), //鍗曚釜瀛楃鏄剧ず楂樺害
    //.ROW_DISP_CHAR_NUM(ROW_DISP_CHAR_NUM), //涓�琛屾樉绀哄瓧绗︿釜锟???
    //.COL_DISP_CHAR_NUM(COL_DISP_CHAR_NUM), //鏄剧ず瀛楃琛屾暟
    .CHAR_ROM_ADDR_W  (CHAR_ROM_ADDR_W  ), //瀛樺偍瀛楃ROM鍦板潃浣嶅锛宭og2(CHAR_HEIGHT * COL_DISP_CHAR_NUM)
    .DISP_DATA_W      (     16          )  //鍥剧墖鍍忕礌鐐规暟鎹綅锟???

  )char_extract
  (
    .clk_ctrl        (clk_ctrl       ),
    .reset_n         (tft_reset_n    ),
    //.char_disp_hbegin(DISP_HBEGIN    ),
    //.char_disp_vbegin(DISP_VBEGIN    ),
    .disp_back_color (DISP_BACK_COLOR),
    .disp_char_color (DISP_CHAR_COLOR),
    .rom_addra       (rom_addra      ),
    .rom_data        (rom_data       ),
    .Frame_Begin     (Frame_Begin    ),
    .disp_data_req   (disp_data_req  ),
    .visible_hcount  (visible_hcount ),
    .visible_vcount  (visible_vcount ),
    .disp_data       (disp_data      ),
	.fifo_empty	     (fifo_empty     ),
	.fifo_data	     (fifo_data      ),
	.rd_clk          (clk50M         ),
	.rd_en		     (rd_en          )
  );

	disp_driver disp_driver
	(
		.ClkDisp(clk_ctrl),
		.Rst_p(tft_reset_p),

		.Data(disp_data),
		.DataReq(disp_data_req),

		.H_Addr(visible_hcount),
		.V_Addr(visible_vcount),
                            
		.Disp_HS(TFT_hs),
		.Disp_VS(TFT_vs),
		.Disp_Red(Disp_Red),
		.Disp_Green(Disp_Green),
		.Disp_Blue(Disp_Blue),
		.Frame_Begin(Frame_Begin),
                            
		.Disp_DE(TFT_de),
		.Disp_PCLK(TFT_clk)
	);
  wire O_vtc_vs;
  wire O_vtc_hs;
  wire O_vtc_de;
  wire [15:0]O_vtc_rgb;
  wave_top#(
  .H_Visible_area(TFT_WIDTH), //屏幕显示区域宽度
  .V_Visible_area(TFT_HEIGHT) //屏幕显示区域高度
  )wave_top(
  .clk_ctrl(clk_ctrl),
  .clk(clk50M),
  .reset_n(reset_n),
  .Frame_Begin(Frame_Begin),
  .visible_hcount(visible_hcount),
  .visible_vcount(visible_vcount),
  .I_vtc2_offset_x(I_vtc2_offset_x),//相对屏幕原点(左上角)X方向偏移
  .I_vtc2_offset_y(I_vtc2_offset_y),//相对屏幕原点(左上角)Y方向偏移
  .I_wave1_clk(I_wave1_clk),//采样时钟1
  .I_wave1_data(I_wave1_data),//采样数据1
  .I_wave1_data_de(I_wave1_data_de),//采样数据有效1
  .I_wave2_clk(I_wave2_clk),//采样时钟2
  .I_wave2_data(I_wave2_data),//采样数据2
  .I_wave2_data_de(I_wave2_data_de),//采样数据有效2
  .I_vtc_vs(TFT_vs),
  .I_vtc_hs(TFT_hs),
  .I_vtc_de(TFT_de),
  .O_vtc_vs(O_vtc_vs),
  .O_vtc_hs(O_vtc_hs),
  .O_vtc_de(O_vtc_de),
  .O_vtc_rgb(O_vtc_rgb),
  .single(single),
  .trigger_edge(trigger_edge),//switch
  .trigger_button(trigger_button)//button
);

	assign tft_reset_p = ~pll_locked; //閿佺浉鐜彁渚涚殑TFT灞忓浣嶄俊鍙疯繘琛屽彇鍙嶏紝婊¤冻楂樼數骞冲锟???	
	assign TFT_rgb={Disp_Red,Disp_Green,Disp_Blue};
//	assign TFT_clk=Disp_PCLK;淇″彿杞崲锛屾寜鍚勪笂灞傛枃浠剁殑鍙橀噺澹版槑鎯呭喌鍐冲畾鍙橀噺鍚嶇О鍜屽彇锟???
	assign TFT_pwm=1'b1;
	
  //HDMI鏄剧ず
  wire pixelclk;
  wire pixelclk5x;
  wire [7:0]disp_red;
  wire [7:0]disp_green;
  wire [7:0]disp_blue;
  wire disp_hs;
  wire disp_vs;
  wire disp_de;
  wire hdmi1_oe;
  
  wire [7:0]disp_red_wave;
  wire [7:0]disp_green_wave;
  wire [7:0]disp_blue_wave;
  wire disp_hs_wave;
  wire disp_vs_wave;
  wire disp_de_wave;

  assign pixelclk   = loc_clk33M;
  assign pixelclk5x = loc_clk165M;
  //hdmi1
  assign disp_red   = {TFT_rgb[15:11],3'b0};
  assign disp_green = {TFT_rgb[10:5],2'b0};
  assign disp_blue  = {TFT_rgb[4:0],3'b0};
  assign disp_hs    = TFT_hs;
  assign disp_vs    = TFT_vs;
  assign disp_de    = TFT_de;
  assign hdmi1_oe   = 1'b1;
  //hdmi2
  assign disp_red_wave   = {O_vtc_rgb[15:11],3'b0};
  assign disp_green_wave = {O_vtc_rgb[10:5],2'b0};
  assign disp_blue_wave  = {O_vtc_rgb[4:0],3'b0};
  assign disp_hs_wave    = O_vtc_hs;
  assign disp_vs_wave    = O_vtc_vs;
  assign disp_de_wave    = O_vtc_de;
  assign hdmi2_oe   = 1'b1;

	dvi_encoder u_dvi_encoder(
		.pixelclk   (pixelclk),// system clock
		.pixelclk5x (pixelclk5x),// system clock x5
		.rst_n      (pll_locked),// reset
		.blue_din   (disp_blue),// Blue data in
		.green_din  (disp_green),// Green data in
		.red_din    (disp_red),// Red data in
		.hsync      (disp_hs),// hsync data
		.vsync      (disp_vs),// vsync data
		.de         (disp_de),// data enable
		.tmds_clk_p (hdmi1_clk_p),
		.tmds_clk_n (hdmi1_clk_n),
		.tmds_data_p(hdmi1_dat_p),//rgb
		.tmds_data_n(hdmi1_dat_n) //rgb
	);
  dvi_encoder wave_dvi_encoder(
		.pixelclk   (pixelclk),// system clock
		.pixelclk5x (pixelclk5x),// system clock x5
		.rst_n      (pll_locked),// reset
		.blue_din   (disp_blue_wave),// Blue data in
		.green_din  (disp_green_wave),// Green data in
		.red_din    (disp_red_wave),// Red data in
		.hsync      (disp_hs_wave),// hsync data
		.vsync      (disp_vs_wave),// vsync data
		.de         (disp_de_wave),// data enable
		.tmds_clk_p (hdmi2_clk_p),
		.tmds_clk_n (hdmi2_clk_n),
		.tmds_data_p(hdmi2_dat_p),//rgb
		.tmds_data_n(hdmi2_dat_n) //rgb
	);


endmodule