 module uiwave_buf
 (
 input         I_wave_clk,    //写数据输入时钟，和ADC采集时钟同步
 input  [7 :0] I_wave_data,   //写数据
 input         I_wave_data_de,//写数据有效
 input         I_vtc_clk,     //VTC时序发生器时钟输入
 input         I_vtc_rstn,    //VTC时序发生器复位 
 input         I_vtc_vs,      //VTC时序发生器的VS同步信号输入
 input         I_vtc_de_r,    //VTC时序发生器的de有效区域输入
 input  [7 :0] I_vtc_vcnt,    //vtc的数据偏移，主要对有符号数据进行调整
 output        O_pixel_en,     //输出输出使能
 input         single_flag,
 input  [7:0 ] trigger_line,
 input         trigger_edge//0上升沿，1下降沿

 );
 
 //BRAM 简单双口BRAM
 reg  [9 :0] addra = 0;  //BRAM 通道A地址     
 //reg         ena   = 0;  //BRAM 通道A使能 
 reg         wea   = 0;  //BRAM 通道A写使能
 reg  [9 :0] addrb = 0;  //BRAM 通道B地址
 reg         enb   = 0;  //BRAM 通道B读使能
 reg  [0 :0] WR_S,RD_S;  //写状态机，读状态机
 reg         buf_flag;//buf_flag用于乒乓地址缓存切换
 reg         addr0_en;//用于设置写第一个数据相对地址0
 
 wire [7 :0] wave_data;//写波形数据到BRAM
 reg  [3 :0] async_vtc_vs =0; //同步信号
 reg        trigger_select;
 always @(posedge I_wave_clk)begin //对异步I_vtc_vs采样
     async_vtc_vs <= {async_vtc_vs[2:0],I_vtc_vs};
 end
 reg wave_data_de;
 reg [7:0]r_I_wave_data;
 always @(posedge I_wave_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn == 1'b0)
      r_I_wave_data<=0;
    else
      r_I_wave_data<=I_wave_data;
 end

 wire trigger_flag;
 /*wire I_wave_data_around_min;
 wire I_wave_data_around_max;
 assign I_wave_data_around_max=(I_wave_data>=250)?255:I_wave_data+5;
 assign I_wave_data_around_min=(I_wave_data<=6)?1:I_wave_data-5; */
 assign trigger_flag=(trigger_line==I_wave_data)&&(((trigger_edge==0&&(r_I_wave_data<I_wave_data))||(trigger_edge==1)&&(r_I_wave_data>I_wave_data))?1'b1:1'b0);
 always @(posedge I_wave_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn == 1'b0)begin
            wave_data_de<=0;
    end
    else if((WR_S==0)&&trigger_flag)begin
            wave_data_de<=I_wave_data_de;
    end
    else if(WR_S==1)begin
            wave_data_de<=0;
    end
    else
      wave_data_de<=wave_data_de;
 end
 //绘制波形数据点使能，绘制原理:
 //当匹配到存储的ADC数据和正在扫描的Y坐标值一致就输出，每个X坐标方向绘制1个波形点

 assign   O_pixel_en  = I_vtc_de_r&(I_vtc_vcnt[7:0] == wave_data[7:0]);
 
 reg [21:0]trigger_cnt;
 always @(posedge I_wave_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn == 1'b0)
      trigger_cnt<=0;
    else if((WR_S==0)&&trigger_flag)
      trigger_cnt<=0;
    else if(trigger_cnt>=22'd3_333_332)
      trigger_cnt<=trigger_cnt;
    else
      trigger_cnt<=trigger_cnt+1;
 end
 always @(posedge I_wave_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn == 1'b0)begin
      trigger_select<=0;
    end
    else if((WR_S==0)&&trigger_flag)begin
      trigger_select<=1;
    end
    else if(trigger_cnt>=22'd3_333_332)begin
      trigger_select<=0;
    end
    else
      trigger_select<=trigger_select;
 end
 wire r_wave_data_de;
 assign r_wave_data_de=(trigger_select)?wave_data_de:I_wave_data_de;
 //写BRAM 状态机
 always @(posedge I_wave_clk or negedge I_vtc_rstn)begin
     if(I_vtc_rstn == 1'b0)begin //复位重置所有寄存器
        addra      <= 10'd0;
        addr0_en   <= 1'b1;
        wea        <= 1'b0; 
        buf_flag   <= 1'b0;
        WR_S       <= 1'd0;
     end
     else begin
         case(WR_S) //写状态机
         0:begin 
               if(r_wave_data_de)begin //有效波形数据点
                if(addra == 749)begin //1024个数据写完
                  wea      <= 1'b0; //停止写
                  addra    <= 0;    //相对地址设置0
                  addr0_en <= 1'b1;
                  WR_S     <= 1'd1;//进入状态机1
                end
                else begin //写入1024个数据
                  wea      <= 1'b1; //写使能
                  addr0_en <= 1'b0;
                  addra    <= (addr0_en == 1'b0) ? (addra + 1'b1) : 0;//相对地址递增
                end
             end
             else begin
               wea <= 1'b0;
             end
         end
         1:begin //等待VTC时序同步
             if(single_flag)begin
                buf_flag<=buf_flag;
                if(async_vtc_vs[3:2] == 2'b10)begin//当数据同步后，准备下一次写
                WR_S     <= 1'd0; //回到状态0
             end
             end
             else if(async_vtc_vs[3:2] == 2'b10)begin//当数据同步后，准备下一次写
                WR_S     <= 1'd0; //回到状态0
                buf_flag <= ~buf_flag;//乒乓地址切换
             end
         end
         default:WR_S   <= 2'd0;
         endcase
      end
 end
 
 //读BRAM 状态机
 always @(posedge I_vtc_clk or negedge I_vtc_rstn)begin
     if(I_vtc_rstn == 1'b0)begin//复位重置所有寄存器
        addrb   <= 10'd0;
        RD_S    <= 1'd0;
     end
     else begin
         case(RD_S)
         0:begin
             if(I_vtc_de_r)begin //I_vtc_de_r代表了有效绘制区域
                if(addrb == 749)begin //1024个数据读完
                  addrb <= 0;    //相对地址设置0
                  RD_S  <= 1'd1; //进入状态1
                end
                else //没一样都会扫描所有的ADC数据
                  addrb   <= addrb + 1'b1;//相对地址递增
             end
         end
         1:begin
             if(I_vtc_de_r == 0) //等待de变为0
                 RD_S <= 0; //回到状态0重新扫描
                 
         end
         default:RD_S   <= 1'd0;
         endcase
      end
 end   
 wave_ram buf_inst(
        .dout(wave_data), //output [7:0] dout
        .clka(I_wave_clk), //input clka
        .cea(wea), //input cea
        .clkb(I_vtc_clk), //input clkb
        .ceb(1'b1), //input ceb
        .oce(1'b1), //input oce
        .reset(!I_vtc_rstn), //input reset
        .ada({buf_flag,addra}), //input [9:0] ada
        .din(I_wave_data), //input [7:0] din
        .adb({~buf_flag,addrb}) //input [9:0] adb
    );/*
 wave_ram buf_inst( 
 .dina(I_wave_data), //写入波形数据
 .addra({buf_flag,addra}), //写地址，其中addra是相对地址，buf_flag是地址高位，用于读写的乒乓切换
 .wea(wea), //写使能
 .clka(I_wave_clk),//写时钟
 .doutb(wave_data), //读出的波形数据
 .addrb({~buf_flag,addrb}), //写地址，其中addrb是相对地址，buf_flag是地址高位，用于读写的乒乓切换
 .clkb(I_vtc_clk)//读时钟
 );*/
 endmodule