/////////////////////////////////////////////////////////////////////////////////
// Company: 武汉芯路恒科技有限公司
// Engineer: 小梅哥团队
// Web: www.corecourse.cn
// 
// Create Date: 2019/05/01 00:00:00
// Design Name: 
// Module Name: char_extract
// Project Name: 
// Target Devices: XC7A35T-2FGG484I
// Tool Versions: Vivado 2018.3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module char_extract
#(
  parameter H_Visible_area    = 800, //屏幕显示区域宽度
  parameter V_Visible_area    = 480, //屏幕显示区域高度
  parameter CHAR_WIDTH        = 16 , //单个字符显示宽度
  parameter CHAR_HEIGHT       = 32 , //单个字符显示高度
  parameter ROW_DISP_CHAR_NUM = 32 , //一行显示字符个数
  parameter COL_DISP_CHAR_NUM = 8  , //显示字符行数
  parameter CHAR_ROM_ADDR_W   = 5  , //存储字符ROM地址位宽，log2(CHAR_HEIGHT * COL_DISP_CHAR_NUM)
  parameter DISP_DATA_W       = 16   //图片像素点数据位宽
)
(
  clk_ctrl,
  reset_n,
  //char_disp_hbegin,
  //char_disp_vbegin,
  disp_back_color,
  disp_char_color,
  Frame_Begin,
  rom_addra,
  rom_data,
  disp_data_req,
  visible_hcount,
  visible_vcount,
  disp_data,
  fifo_empty,
  fifo_data,
  rd_clk,
  rd_en
);

  input                         clk_ctrl;         //时钟输入，与TFT屏时钟保持一致
  input                         reset_n;          //复位信号，低电平有效
  input                         rd_clk;
  reg   [15:0]                 char_disp_hbegin; //待显示图片左上角第一个像素点在TFT屏的行向坐标
  reg   [15:0]                 char_disp_vbegin; //待显示图片左上角第一个像素点在TFT屏的场向坐标
  input  [DISP_DATA_W-1:0]      disp_back_color;  //显示的背景颜色
  input  [DISP_DATA_W-1:0]      disp_char_color;  //显示字符的颜色

  input                         Frame_Begin;      //一帧图像起始标识信号，clk_ctrl时钟域
  output reg[11:0] rom_addra;        //读字符数据rom地址                  
  input [15:0] rom_data;         //读出字符数据
  input                         disp_data_req;    //
  input  [11:0]                 visible_hcount;   //TFT可见区域行扫描计数器
  input  [11:0]                 visible_vcount;   //TFT可见区域场扫描计数器
  output [DISP_DATA_W-1:0]      disp_data;        //待显示数据
  input 	                     fifo_empty;       //fifo空标志
  input [7:0] 	                 fifo_data;        //fifo数据输入
  output               reg       rd_en;            //fifo读使能
  //reg [11:0]                   rom_addra;        //读字符数据rom地址
  //reg  [CHAR_ROM_ADDR_W-1:0]   rom_addra;        //读图片数据rom地址  
  wire                         h_exceed;
  wire                         v_exceed;
  wire                         char_h_disp;
  wire                         char_v_disp;
  wire                         char_disp;
  wire [15:0]                  hcount_max;
  reg  [15:0] char_flag;

  reg [7:0]data_tmp;
  reg [7:0]data_tmp_dly1;
  reg [7:0]data_tmp_dly2;
  reg [7:0]data_tmp_dly3;
  reg [7:0]data_tmp_dly4;
  reg [8:0]data_tmp_cnt;
  reg [8:0]data_tmp_cnt_dly1;
  reg [8:0]data_tmp_cnt_dly2;
  reg [8:0]data_tmp_cnt_dly3;
  reg [8:0]data_tmp_cnt_dly4;
  wire [7:0]data_locked;//锁存数据
  reg [8:0]data_locked_cnt; 
  reg data_lock_rd;
  reg locked;
  reg data_lock_rd_dly1;
  reg data_lock_rd_dly2;
  reg data_lock_rd_dly3;
  reg tmp_valid;
  reg tmp_valid_dly1;
  reg tmp_valid_dly2;
  reg tmp_valid_dly3;
  reg r_rd_en;
  reg r_r_rd_en;
  reg store_end;

  reg [7:0]lock_cnt;
  wire [7:0]char_rom_disp_address;
  wire [6:0]char_rom_disp_data;
  wire char_rom_disp_data_valid;

  wire ram_reset;

  
  reg [7:0]data_locked_dly1;
  reg [7:0]data_locked_dly2;
  reg [7:0]data_locked_dly3;
  reg [7:0]data_locked_dly4;
  reg [7:0]data_locked_dly5;
  reg [7:0]data_locked_dly6;
  reg [7:0]lock_cnt_dly1;
  reg [7:0]lock_cnt_dly2;
  reg [7:0]lock_cnt_dly3;
  reg [7:0]lock_cnt_dly4;
  reg [7:0]lock_cnt_dly5;
  reg [7:0]lock_cnt_dly6;
  
  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)
      begin
        data_locked_dly1<=0;
        data_locked_dly2<=0;
        data_locked_dly3<=0;
        data_locked_dly4<=0;
        data_locked_dly5<=0;
        data_locked_dly6<=0;
        lock_cnt_dly1<=0;
        lock_cnt_dly2<=0;
        lock_cnt_dly3<=0;
        lock_cnt_dly4<=0;
        lock_cnt_dly5<=0;
        lock_cnt_dly6<=0;
      end
    else 
      begin
        data_locked_dly1<=data_locked;
        data_locked_dly2<=data_locked_dly1;
        data_locked_dly3<=data_locked_dly2;
        data_locked_dly4<=data_locked_dly3;
        data_locked_dly5<=data_locked_dly4;
        data_locked_dly6<=data_locked_dly5;
        lock_cnt_dly1<=lock_cnt;
        lock_cnt_dly2<=lock_cnt_dly1;
        lock_cnt_dly3<=lock_cnt_dly2;
        lock_cnt_dly4<=lock_cnt_dly3;
        lock_cnt_dly5<=lock_cnt_dly4;
        lock_cnt_dly6<=lock_cnt_dly5;
      end
end

  char_SDPB char_tmp(
        .dout(data_locked), //output [7:0] dout
        .clka(rd_clk), //input clka
        .cea(tmp_valid_dly2), //input cea
        .clkb(clk_ctrl), //input clkb
        .ceb(data_lock_rd_dly1), //input ceb
        .oce(1'b1), //input oce
        .reset(!reset_n), //input reset
        .ada(data_tmp_cnt_dly3[7:0]), //input [7:0] ada
        .din(data_tmp), //input [7:0] din???????????????????????????????data_tmp_dly
        .adb(lock_cnt_dly1) //input [7:0] adb
    );
  reg [7:0]fifo_data_dly;
  reg [7:0]fifo_data_dly2;
  always @(posedge rd_clk or negedge reset_n) begin
    if(!reset_n)
    begin
      r_rd_en<=0;
      r_r_rd_en<=0;
      data_tmp_cnt_dly1<=0;
      data_tmp_cnt_dly2<=0;
      data_tmp_cnt_dly3<=0;
      data_tmp_cnt_dly4<=0;
      data_tmp_dly1<=0;
      data_tmp_dly2<=0;
      data_tmp_dly3<=0;
      data_tmp_dly4<=0;
      tmp_valid_dly1<=0;
      tmp_valid_dly2<=0;
      tmp_valid_dly3<=0;
      fifo_data_dly<=0;
      fifo_data_dly2<=0;
    end/*
    else if((data_tmp_cnt_dly3>=255)||(r_store_end_dly))begin
      fifo_data_dly<=fifo_data;
      fifo_data_dly2<=fifo_data_dly;
      r_rd_en<=rd_en;
      r_r_rd_en<=r_rd_en;
      data_tmp_cnt_dly1<=0;
      data_tmp_cnt_dly2<=0;
      data_tmp_cnt_dly3<=0;//?????????????????????
      data_tmp_cnt_dly4<=0;
      data_tmp_dly1<=data_tmp;
      data_tmp_dly2<=data_tmp_dly1;
      data_tmp_dly3<=data_tmp_dly2;
      data_tmp_dly4<=data_tmp_dly3;
      tmp_valid_dly1<=0;
      tmp_valid_dly2<=0;
      tmp_valid_dly3<=0;
    end*/
    else
    begin
      fifo_data_dly<=fifo_data;
      fifo_data_dly2<=fifo_data_dly;
      r_rd_en<=rd_en;
      r_r_rd_en<=r_rd_en;
      data_tmp_cnt_dly1<=data_tmp_cnt;
      data_tmp_cnt_dly2<=data_tmp_cnt_dly1;
      data_tmp_cnt_dly3<=data_tmp_cnt_dly2;//?????????????????????
      data_tmp_cnt_dly4<=data_tmp_cnt_dly3;
      data_tmp_dly1<=data_tmp;
      data_tmp_dly2<=data_tmp_dly1;
      data_tmp_dly3<=data_tmp_dly2;
      data_tmp_dly4<=data_tmp_dly3;
      tmp_valid_dly1<=tmp_valid;
      tmp_valid_dly2<=(data_tmp_cnt_dly3>=255)?0:tmp_valid_dly1;
      tmp_valid_dly3<=tmp_valid_dly2;
    end
  end
  reg [3:0]r_store_end;
  reg [3:0]r_store_end_dly; 
  reg [3:0]r_store_end_dly2;
  reg [8:0]next_cnt;
  always @(posedge rd_clk or negedge reset_n) begin
    if(!reset_n)begin
      r_store_end_dly<=0;
      r_store_end_dly2<=0;

    end
    else begin
      r_store_end_dly<=r_store_end;
      r_store_end_dly2<=r_store_end_dly;
    end
      
  end
  
  always @(posedge rd_clk or negedge reset_n) begin
    if(!reset_n)
      begin
        locked<=0;
        data_tmp_cnt<=0;
        data_tmp<= 8'h00;
        tmp_valid<=0;
      end
    else if(r_store_end_dly) //读完数据后锁定数据
      begin
        locked<=0;
        data_tmp_cnt<=0;
        data_tmp<=0;
        tmp_valid<=0;
      end
    else if((rd_en==0&&r_rd_en==1) && (data_tmp_cnt >= 9'd1)) //读完数据后锁定数据
      begin
        locked<=1;
        data_tmp_cnt<=data_tmp_cnt;
        data_tmp<=fifo_data_dly2;
        tmp_valid<=0;
      end
    else if(rd_en)
      begin
      if(data_tmp_cnt_dly3>=255)//???????????????????
        begin
          data_tmp_cnt<=data_tmp_cnt;
          data_tmp<=fifo_data_dly2;
          locked<=0;
          tmp_valid<=0;
        end
      else 
        begin
          if(fifo_data==8'h0a)begin
            data_tmp_cnt<={(data_tmp_cnt[7:5]+1),5'b00000};//换行符，行数加1，列数清0
            data_tmp<=fifo_data_dly2;
            tmp_valid<=1;
            locked<=0;
          end
    
          else 
          begin  
            data_tmp_cnt<=data_tmp_cnt+1;
            data_tmp<=fifo_data_dly2;
            locked<=0;
            tmp_valid<=1;
          end

        end
      end

  end
  wire ram_address_reset;

  assign ram_address_reset=(locked&&Frame_Begin);
  
  
  reg lock_state;
  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      data_locked_cnt<=0;
      lock_state<=0;
    end
    else if(locked&&Frame_Begin)begin
      lock_state<=1;
      data_locked_cnt<=(data_tmp_cnt-1'b1>=256)?9'h100:data_tmp_cnt-1'b1;
    end
    else if(store_end)begin
      lock_state<=0;
      data_locked_cnt<=data_locked_cnt;
    end
    else begin
      data_locked_cnt<=data_locked_cnt;
      lock_state<=lock_state;
    end
  end   
 /* reg data_lock_rd_flag;
   always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      data_lock_rd_flag<=0;
    end
    else if(data_locked==8'h0A)
      data_lock_rd_flag<=1;
    else  
      data_lock_rd_flag<=0;
  end*/
  always@(*)begin
    if(!reset_n)
      data_lock_rd=0;
    else if(lock_state)begin
      if(data_locked_cnt==1)
          data_lock_rd=1;
      else if(lock_cnt_dly1>=data_locked_cnt-1)begin
          data_lock_rd=0;
        end
      else begin
          data_lock_rd=1;
        end
    end
     else begin
      data_lock_rd=0;
    end
  end
  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      store_end<=0;
      lock_cnt<=0;
    end
    else if(lock_state)begin
        if(lock_cnt_dly3>=data_locked_cnt-1)begin
          store_end<=1;
          lock_cnt<=lock_cnt;
        end
        else begin
          lock_cnt<=lock_cnt+1;
          store_end<=0;
        end
    end
    else begin
      store_end<=0;
      lock_cnt<=0;
    end
    end
 

    reg [6:0]rom_address_saved;
    reg rom_address_saved_valid;
    reg rom_address_saved_valid_dly1;
    reg [7:0]next_row_cnt;
    reg [1:0]rom_state;
    reg next_row_end;
    reg [15:0]store_end_dly;
    reg next_row_end_dly;
    wire next_row_end_flag;
    assign next_row_end_flag=next_row_end_dly&next_row_end;
    always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      r_store_end<=0;
      data_lock_rd_dly1<=0;
      data_lock_rd_dly2<=0;
      data_lock_rd_dly3<=0;
      rom_address_saved_valid_dly1<=0;
      store_end_dly<=16'b0;
      next_row_end_dly<=1;
    end
    else begin
      r_store_end<={r_store_end[2:0],store_end};
      data_lock_rd_dly1<=data_lock_rd;
      data_lock_rd_dly2<=data_lock_rd_dly1;
      data_lock_rd_dly3<=data_lock_rd_dly2;
      rom_address_saved_valid_dly1<=rom_address_saved_valid;
      store_end_dly<={store_end_dly[14:0],store_end};
      next_row_end_dly<=next_row_end;
    end
    end
    always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)
      begin
        rom_state<=0;
        next_row_cnt<=0;
      end
    else if(data_lock_rd|data_lock_rd_dly1|data_lock_rd_dly2|data_lock_rd_dly3)begin
      if(store_end)
        begin
          rom_state<=0;
          next_row_cnt<=0;
        end
      else if(data_locked_dly1 >= 8'h20 && data_locked_dly1 <= 8'h7E&&next_row_end_flag)
        begin  
          rom_state<=1;
          next_row_cnt<=0;
        end
      else if(data_locked_dly1 == 8'h0A)
        begin
          rom_state<=2;
          next_row_cnt<={(lock_cnt[7:5]+1),5'b00000};
        end
      else 
        begin
          rom_state<=rom_state;  
          next_row_cnt<=next_row_cnt;
        end
    end
    else begin
        rom_state<=0;
        next_row_cnt<=0;
      end
    end


    always@(*)begin
        next_row_end=1;
      if(!reset_n)
        next_row_end=1;
      else  
      case(rom_state)
      2'b0:begin
            next_row_end=1;
        end
      2'b1:begin
            next_row_end=1;
          end 
      2'b10:
          begin
            if(lock_cnt_dly2<=next_row_cnt-1)begin
              next_row_end=0;
            end 
            else begin
              next_row_end=1;
            end
          end
      default:begin
            next_row_end=1;
          end
      endcase
    end
    always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)
      begin
        rom_address_saved_valid<=0;
        rom_address_saved<=0;
        //next_row_end<=1;
      end
    else 
    case(rom_state)
      2'b0:begin
          rom_address_saved_valid<=0;
          rom_address_saved<=0;
          //next_row_end<=1;
        end
      2'b1:begin
            rom_address_saved_valid<=1;
            rom_address_saved<=(data_locked_dly2>=8'h20)?(data_locked_dly2 - 8'h20):8'h00;
            //next_row_end<=1;
          end 
      2'b10:
          begin
            if(lock_cnt_dly2<=next_row_cnt-1)begin
              rom_address_saved<=0; // 换行符显示为空格
              rom_address_saved_valid<=1;
              //next_row_end<=0;
            end 
            else begin
              rom_address_saved<=0;
              rom_address_saved_valid<=1;
              //next_row_end<=1;
            end
          end
      default:begin
            rom_address_saved_valid<=0;
            rom_address_saved<=0;
            //next_row_end<=1;
          end
      endcase
    end  
 
//求出行数列数，每行最大显示32个字符，最多8行
  reg [3:0]row_cnt;//行数
  reg [5:0]row_last_cnt;//最后一行的字符数
  reg center_signal;
  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      row_cnt<=0;
      row_last_cnt<=0;
      center_signal<=0;
    end
    else if(store_end)begin
      row_cnt<=data_locked_cnt>>5;//除以32
      row_last_cnt<=data_locked_cnt[4:0];//取余
      center_signal<=1;
    end
    else begin
      row_cnt<=row_cnt;
      row_last_cnt<=row_last_cnt;
      center_signal<=0;
    end  
  end
  //设置显示区域为正中心
  wire [15:0]DISP_CHAR_TOTAL_W;
  wire [15:0]DISP_CHAR_TOTAL_H;
  assign DISP_CHAR_TOTAL_W = CHAR_WIDTH  * (row_cnt?32:row_last_cnt);
  assign DISP_CHAR_TOTAL_H = CHAR_HEIGHT * (row_last_cnt?row_cnt+1:row_cnt);

  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)begin
      char_disp_hbegin<=(16'd800  - 16'd512)>>1;
      char_disp_vbegin<=(16'd600 - 16'd256)>>1;
    end
    else if(center_signal)begin
      char_disp_hbegin<=(16'd800  - (row_cnt?DISP_CHAR_TOTAL_W:CHAR_WIDTH*row_last_cnt))>>1;
      char_disp_vbegin<=(16'd600 - (row_last_cnt?CHAR_HEIGHT*(row_cnt+1):CHAR_HEIGHT*(row_cnt)))>>1;
    end
  end

  //判断设置的显示的起始位置是否会导致显示超出范围
  assign h_exceed = char_disp_hbegin + DISP_CHAR_TOTAL_W > H_Visible_area - 1'b1;
  assign v_exceed = char_disp_vbegin + DISP_CHAR_TOTAL_H > V_Visible_area - 1'b1;
  //不同的设置情况，显示区域做不同的处理
  assign char_h_disp = h_exceed ? (visible_hcount >= char_disp_hbegin && visible_hcount < H_Visible_area):
                                  (visible_hcount >= char_disp_hbegin && visible_hcount < char_disp_hbegin + DISP_CHAR_TOTAL_W);  
  
  assign char_v_disp = v_exceed ? (visible_vcount >= char_disp_vbegin && visible_vcount < V_Visible_area):
                                  (visible_vcount >= char_disp_vbegin && visible_vcount < char_disp_vbegin + DISP_CHAR_TOTAL_H);
  
  assign char_disp = disp_data_req && char_h_disp && char_v_disp;
  
  assign hcount_max = h_exceed ? (H_Visible_area - 1'b1):(char_disp_hbegin + DISP_CHAR_TOTAL_W - 1'b1);
  reg [63:0]empty_dly;
  /*
  always @(posedge rd_clk or negedge reset_n) begin
  if(!reset_n) 
   empty_dly<=64'b0;
  else  
   empty_dly<={empty_dly[62:0],(!fifo_empty)};
 end*/

 reg [1:0] rd_fifo_state;
 reg [7:0] rd_fifo_cnt;
  assign ram_reset=(rd_fifo_state==2'b01)?1:0;
// 状态机：00=空闲，01=计数延时（FIFO非空时计数到255），10=开始读FIFO
always @(posedge rd_clk or negedge reset_n) begin
  if (!reset_n)
    rd_fifo_state <= 2'b00;  // 复位后进入空闲
  else if (locked)  // 外部锁定信号，强制回到空闲
    rd_fifo_state <= 2'b00;
  else case (rd_fifo_state)
    2'b00: begin
      // 空闲状态：FIFO非空时，进入计数延时状态
      if (!fifo_empty)
        rd_fifo_state <= 2'b01;
      else
        rd_fifo_state <= 2'b00;
    end
    2'b01: begin
      // 计数延时状态：计数到255后，进入读状态；若FIFO变空，回到空闲
      if (rd_fifo_cnt >= 8'hff)  // 计数满255，结束延时
        rd_fifo_state <= 2'b10;
      else if (fifo_empty)  // 计数中途FIFO空，放弃延时
        rd_fifo_state <= 2'b00;
      else
        rd_fifo_state <= 2'b01;  // 继续计数
    end
    2'b10: begin
      // 读状态：FIFO空时结束读，回到空闲；否则持续读
      if (fifo_empty)
        rd_fifo_state <= 2'b00;
      else
        rd_fifo_state <= 2'b10;  // 保持读状态
    end
    default: rd_fifo_state <= 2'b00;
  endcase
end

// 计数逻辑：仅在计数延时状态（01）时递增，其他状态清零
always @(posedge rd_clk or negedge reset_n) begin
  if (!reset_n)
    rd_fifo_cnt <= 8'h00;
  else if (rd_fifo_state == 2'b01) begin  // 计数延时阶段
    if (rd_fifo_cnt >= 8'hff)
      rd_fifo_cnt <= 8'hff;  // 保持最大值，避免溢出
    else
      rd_fifo_cnt <= rd_fifo_cnt + 8'h01;  // 每时钟加1，直到255
  end
  else
    rd_fifo_cnt <= 8'h00;  // 非计数状态时清零
end

// 读使能逻辑：仅在读完延时（进入10状态）且FIFO非空时，才触发读
always @(posedge rd_clk or negedge reset_n) begin
  if (!reset_n)
    rd_en <= 1'b0;
  else
    // 读状态（10）且FIFO非空时，使能读；其他情况关闭
    rd_en <= (rd_fifo_state == 2'b10) && (!fifo_empty);
end
  
  reg [4:0]char_h_cnt;//列计数器
  reg [3:0]char_v_cnt;//行计数器
  reg [3:0]cnt_16_h;//每16个像素点，字符数据右移一位
  reg [4:0]cnt_32_v;//每32个像素点，字符数据下移一行
  reg rom_signal;
  // 新增：提前1个周期的地址计数器（预更新）
reg [4:0] char_h_cnt_next;
reg [4:0] char_h_cnt_next_dly1;
reg [4:0] char_h_cnt_next_dly2;
reg [3:0] char_v_cnt_next;
 
always @(posedge clk_ctrl or negedge reset_n) begin
  if(!reset_n) begin
    char_h_cnt_next <= 0;
    char_v_cnt_next <= 0;
    rom_signal<=1'b0;
  end else if(Frame_Begin) begin
    char_h_cnt_next <= 0;
    char_v_cnt_next <= 0;
    rom_signal<=1'b0;
  end 
  else if(store_end_dly[15])
    begin
      char_h_cnt_next <= 0;
      char_v_cnt_next <= 0;
      rom_signal<=1'b1;
    end
  else if(char_disp) begin
    // 与原计数器逻辑完全一致，但提前1周期更新
    if(cnt_32_v==31&&visible_hcount==hcount_max) begin
      char_v_cnt_next <=  char_v_cnt_next + 1'b1 ;
      char_h_cnt_next <= 0;
      rom_signal<=1'b1;
    end else if(visible_hcount>=hcount_max) begin
      char_h_cnt_next <= 0;
      char_v_cnt_next <= char_v_cnt_next;
      rom_signal<=1'b1;
    end else if(cnt_16_h==13) begin  
      char_h_cnt_next <= char_h_cnt_next + 1'b1;
      rom_signal <= 1'b1;
    end else begin
      char_h_cnt_next <= char_h_cnt_next;
      char_v_cnt_next <= char_v_cnt_next;
      rom_signal<=1'b0;
    end
  end else begin
    char_h_cnt_next <= 0;
    char_v_cnt_next <= char_v_cnt_next;
    rom_signal<=1'b0;
  end
end

  assign char_rom_disp_address = (char_h_cnt_next < ROW_DISP_CHAR_NUM) ? 
                              (char_h_cnt_next + char_v_cnt_next * ROW_DISP_CHAR_NUM) : 8'd0;
  //assign char_rom_disp_address = (char_h_cnt_next + char_v_cnt_next*32);
  assign char_rom_disp_data_valid = rom_signal;
   char_rom_address char_rom_address(
        .dout(char_rom_disp_data), //output [6:0] dout
        .clka(clk_ctrl), //input clka
        .cea(rom_address_saved_valid), //input cea
        .clkb(clk_ctrl), //input clkb
        .ceb(char_rom_disp_data_valid), //input ceb
        .oce(1'b1), //input oce
        .reset(!reset_n), //input reset
        .ada(lock_cnt_dly5), //input [7:0] ada
        .din(rom_address_saved), //input [6:0] din   
        .adb(char_rom_disp_address) //input [7:0] adb
    );
    reg Frame_Begin_dly;
    wire [7:0]char_rom_disp_address_next;
    assign char_rom_disp_address_next = (char_h_cnt_next_dly1 < ROW_DISP_CHAR_NUM) ? 
                                   (char_h_cnt_next_dly1 + char_v_cnt_next * ROW_DISP_CHAR_NUM) : 8'd0;
    //assign char_rom_disp_address_next=(char_h_cnt_next_dly1 + char_v_cnt_next*32);
always @(posedge clk_ctrl or negedge reset_n) begin
  if(!reset_n)begin
    Frame_Begin_dly <= 0;
    char_h_cnt_next_dly1<=0;
    char_h_cnt_next_dly2<=0;
    end
  else begin
    Frame_Begin_dly <= Frame_Begin; // 延迟1拍，延长复位信号
    char_h_cnt_next_dly1<=char_h_cnt_next;
    char_h_cnt_next_dly2<=char_h_cnt_next_dly1;
  end
end
  always @(posedge clk_ctrl or negedge reset_n) begin
    if(!reset_n)
      begin
        char_h_cnt<=0;
        char_v_cnt<=0;
        cnt_16_h<=0;
        cnt_32_v<=0;
        
      end
    else if(Frame_Begin|Frame_Begin_dly)
      begin
        char_h_cnt<=0;
        char_v_cnt<=0;
        cnt_16_h<=0;
        cnt_32_v<=0;
        
      end
    else if(char_disp)
      begin
        if(cnt_32_v==31&&visible_hcount==hcount_max)
          begin
            char_v_cnt <=  char_v_cnt + 1'b1 ;   
            char_h_cnt<=0;
            cnt_16_h<=0;
            cnt_32_v<=0;
            
          end
        else if(visible_hcount==hcount_max)
          begin
            char_v_cnt<=char_v_cnt;
            char_h_cnt<=0;
            cnt_16_h<=0;
            cnt_32_v<=cnt_32_v+1'b1;
            
          end
        else if(cnt_16_h==15)
          begin
            char_h_cnt<=char_h_cnt+1'b1;
            char_v_cnt<=char_v_cnt;
            cnt_16_h<=0;
            cnt_32_v<=cnt_32_v;
            
          end
        else
          begin
            char_h_cnt<=char_h_cnt;
            char_v_cnt<=char_v_cnt;
            cnt_16_h<=cnt_16_h+1'b1;
            cnt_32_v<=cnt_32_v;
            
          end
      end
    else
      begin
        char_h_cnt<=0;
        char_v_cnt<=char_v_cnt;
        cnt_16_h<=0;
        cnt_32_v<=cnt_32_v;
        
      end
  end

  always@(posedge clk_ctrl or negedge reset_n)
  begin
    if(!reset_n)
      rom_addra <= 'd0;
    else if(Frame_Begin)
      rom_addra <= 'd0; 
    else 
      rom_addra <= {char_rom_disp_data,cnt_32_v[4:0]};
  end
  // 新增：延迟1拍的ROM锁存信号，匹配ROM读取延迟
 reg rom_signal_dly1, rom_signal_dly2,rom_signal_dly3;
always @(posedge clk_ctrl or negedge reset_n) begin
  if(!reset_n) begin
    rom_signal_dly1 <= 1'b0;
    rom_signal_dly2 <= 1'b0;
    rom_signal_dly3<=1'b0;
  end else begin
    rom_signal_dly1 <= rom_signal;
    rom_signal_dly2 <= rom_signal_dly1; // 2拍延迟
    rom_signal_dly3<=rom_signal_dly2;
  end
end
  always@(posedge clk_ctrl or negedge reset_n)
  begin
    if(!reset_n)
      char_flag <= 'd0;
    else if(Frame_Begin)
      char_flag <= 16'b0;
    else if(char_rom_disp_address_next>=data_locked_cnt)
      char_flag<=16'b0;
    else if(rom_signal_dly3)//每次读出新的数据，进行更新
      char_flag <= rom_data;
    else if(char_disp)
          char_flag <= {char_flag[14:0],1'b0};
    else
      char_flag <= char_flag;
  end
  assign disp_data = (char_disp &&char_flag[15]) ? disp_char_color : disp_back_color;

 endmodule