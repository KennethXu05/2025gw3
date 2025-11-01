
 module uiwave
 (
 //波形1
 input         I_wave1_clk,      //波形1时钟
 input  [7 :0] I_wave1_data,     //波形1数据
 input         I_wave1_data_de,  //波形1数据有效
 
 //波形2
 input         I_wave2_clk,      //波形2时钟
 input  [7 :0] I_wave2_data,     //波形2数据
 input         I_wave2_data_de,  //波形2数据有效
 
 //VTC时序输入
 input         I_vtc_rstn,       //时序复位输入
 input         I_vtc_clk,        //时序时钟输入
 input         I_vtc_vs,         //VS-帧同步，信号同步输入
 input         I_vtc_de,         //de有效区域，信号同步输入
 
 //同步时序输出，以及像素输出
 output        O_vtc_vs,         //帧同步输出
 output        O_vtc_de,         //de信号同步后输出
 output reg [15:0] O_vtc_rgb,     //同步输出显示颜色
 input         single_flag,


 input trigger_edge,
 input trigger_button_flag
 );
 
 reg  [1 :0] vtc_vs_r; //vs寄存器
 reg  [1 :0] vtc_de_r; //de寄存器
 reg  [11 :0] vcnt,hcnt;//vcnt计数有多少行，hcnt计数有多少列
 
 reg    grid_de; //栅格绘制使能
 
 assign O_vtc_vs = vtc_vs_r[0]; //同步后输出O_vtc_vs
 assign O_vtc_de = vtc_de_r[0]; //同步后输出O_vtc_de
 
 //寄存,同步
 always @(posedge I_vtc_clk)begin
     vtc_vs_r <= {vtc_vs_r[0],I_vtc_vs};
     vtc_de_r <= {vtc_de_r[0],I_vtc_de};
 end
 /*
 reg [27:0]trigger_cnt;
 always @(posedge I_vtc_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn==0)
        trigger_cnt<=0;
    else if(trigger_button_flag)
        trigger_cnt<=trigger_cnt+1;
    else if(trigger_cnt>=28'd199_999_999)
        trigger_cnt<=0;
    else
        trigger_cnt<=0;
 end*/
 //以下hcnt用于计数列，vcnt用于计数行数
 
 //hcnt像素计数器
 always @(posedge I_vtc_clk)begin
     if(hcnt == 749)
         hcnt <= 12'd0;
     else if(vtc_de_r[0] && (hcnt != 749)) //hcnt计数列，共计512个像素
         hcnt <= hcnt + 1'b1;
 end
 
 //vcnt计数有多少行
 always @(posedge I_vtc_clk)begin
     if(vtc_vs_r == 2'b01)
         vcnt <= 12'd0;
     else if((vtc_de_r == 2'b10) && (vcnt != 255)) //以de信号用于计数行，共计256行
         vcnt <= vcnt + 1'b1;
 end
 
 //栅格绘制
   /*  wire h_grid = (hcnt[2:0] == 3'd7) && (vcnt[5:0] == 6'd63 || vcnt == 10'd0);
    // 条件2：纵向栅格线（虚线）
    // 每64列（0、64、128...608），且在第7行（每8行1个点）
    wire v_grid = (vcnt[2:0] == 3'd7) && (hcnt[5:0] == 6'd63 || hcnt == 10'd0);
    // 条件3：原点标记（0,0）
    wire origin = (hcnt == 10'd0) && (vcnt == 10'd0);
    
 // 栅格绘制（适配640×480有效显示区域）

always @(posedge I_vtc_clk) begin
    // 条件1：横向栅格线（虚线）
    // 每64行（0、64、128...448），且在第7列（每8列1个点）

    // 栅格有效信号：满足任一条件，且在显示有效区域内
    grid_de <= (h_grid || v_grid || origin) && O_vtc_de;
end*/
reg [7:0]trigger_line;
reg trigger_de;
always @(posedge I_vtc_clk or negedge I_vtc_rstn) begin
    if(I_vtc_rstn==1'b0)
        trigger_line<=8'h00;
    else if(trigger_button_flag)
        trigger_line<=trigger_line+1'b1;
    else
        trigger_line<=trigger_line;
end

 always @(posedge I_vtc_clk)begin
     if((hcnt[2:0]==7&&(vcnt[5:0]==63||vcnt == 0))||((hcnt[5:0]==63||hcnt==0)&&vcnt[2:0]==7)||(vcnt == 0 && hcnt==0)) 
         grid_de <= O_vtc_de;
     else 
         grid_de <= 1'b0;
 end 
 always @(posedge I_vtc_clk)begin
     if(hcnt[1:0]==3&&vcnt[7:0]==trigger_line) 
         trigger_de <= O_vtc_de;
     else 
         trigger_de <= 1'b0;
 end 
 //1--绘制波形曲线1，绿色点
 //2--绘制波形曲线2，黄色点
 //3--绘制栅格虚线，白色点
 //4--绘制背景色，黑色
 always @(posedge I_vtc_clk)begin
     casex({grid_de,trigger_de,wave1_pixel_en})
             3'bxx1:
                O_vtc_rgb <= {5'b00000,6'b111111,5'b00000};   //wave1信号显示像素颜色
             3'bx10:
                O_vtc_rgb <= {5'b11111,6'b000000,5'b11111};   //网格显示像素为白色点
             3'b100:
                O_vtc_rgb <= {5'b10010,6'b100101,5'b10010};   //网格显示像素为白色点
         default:
                O_vtc_rgb <= {5'b00000,6'b000000,5'b00000};   //黑色背景
     endcase
 end 
 
 //波形缓存1，以及波形绘制像素点输出使能
 uiwave_buf uiwave1_buf_inst
 (
 .I_wave_clk(I_wave1_clk),  //写数据输入时钟，和ADC采集时钟同步
 .I_wave_data(I_wave1_data),//写数据
 .I_wave_data_de(I_wave1_data_de),//写数据有效
 .I_vtc_clk(I_vtc_clk),    //VTC时序发生器时钟输入
 .I_vtc_rstn(I_vtc_rstn),  //VTC时序发生器复位 
 .I_vtc_de_r(vtc_de_r[0]), //VTC时序发生器的de有效区域输入
 .I_vtc_vs(I_vtc_vs),      //VTC时序发生器的VS同步信号输入
 .I_vtc_vcnt(vcnt),        //vtc的数据偏移，主要对有符号数据进行调整
 .O_pixel_en(wave1_pixel_en), //输出输出使能
 .single_flag(single_flag),
 .trigger_line(trigger_line),
 .trigger_edge(trigger_edge)//0上升沿，1下降沿
 );
 /*
 //波形缓存2，以及波形绘制像素点输出使能
 uiwave_buf uiwave2_buf_inst
 (
 .I_wave_clk(I_wave2_clk),   //写数据输入时钟，和ADC采集时钟同步
 .I_wave_data(I_wave2_data), //写数据
 .I_wave_data_de(I_wave2_data_de),//写数据有效
 .I_vtc_clk(I_vtc_clk),           //VTC时序发生器时钟输入
 .I_vtc_rstn(I_vtc_rstn),         //VTC时序发生器复位 
 .I_vtc_de_r(vtc_de_r[0]),        //VTC时序发生器的de有效区域输入
 .I_vtc_vs(I_vtc_vs),             //VTC时序发生器的VS同步信号输入
 .I_vtc_vcnt(vcnt),               //vtc的数据偏移，主要对有符号数据进行调整
 .O_pixel_en(wave2_pixel_en),      //输出输出使能
.single_flag(single_flag)
 );
 */
 endmodule