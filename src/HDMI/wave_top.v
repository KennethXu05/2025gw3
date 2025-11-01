module wave_top#(
  parameter H_Visible_area    = 800, //屏幕显示区域宽度
  parameter V_Visible_area    = 480, //屏幕显示区域高度
  parameter H2_ActiveSize  =   750,
  parameter V2_ActiveSize  =   256
)(
  input clk,
  input clk_ctrl,
  input reset_n,
  //char_disp_hbegin,
  //char_disp_vbegin,
  input Frame_Begin,
  input [11:0]visible_hcount,
  input [11:0]visible_vcount,
  //偏置量，原点（左上角）  
  input  [11:0]   I_vtc2_offset_x,//相对屏幕原点(左上角)X方向偏移
  input  [11:0]   I_vtc2_offset_y,//相对屏幕原点(左上角)Y方向偏移
  //通道1
  input I_wave1_clk,//采样时钟1
  input [7:0] I_wave1_data,//采样数据1
  input I_wave1_data_de,//采样数据有效1
  //通道2
  input I_wave2_clk,//采样时钟2
  input [7:0] I_wave2_data,//采样数据2
  input I_wave2_data_de,//采样数据有效2

  input I_vtc_vs,
  input I_vtc_hs,
  input I_vtc_de,

  output reg O_vtc_vs,
  output reg O_vtc_hs,
  output reg O_vtc_de,
  output [15:0]O_vtc_rgb,

  input  single,
  
  input trigger_edge,//switch
  input trigger_button//button
  
);
    wire trigger_button_minus_flag;
    key_filter_wave key_filter_wave_single(
	.clk(clk),
	.reset_n(reset_n),

	.key_in(single),
	.key_flag(),
	.key_state(key_state)
);
    key_filter_wave key_filter_wave_trigger_button(
	.clk(clk),
	.reset_n(reset_n),

	.key_in(trigger_button),
	.key_flag(trigger_button_minus_flag),
	.key_state(trigger_button_state)
);
    key_filter_wave key_filter_wave_trigger_edge(
	.clk(clk),
	.reset_n(reset_n),

	.key_in(trigger_edge),
	.key_flag(),
	.key_state(trigger_edge_state)
);
    reg r_key_state;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            r_key_state<=1;
        else
            r_key_state<=key_state;
    end
    reg single_flag;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            single_flag<=0;
        else if({r_key_state,key_state}==2'b10)
            single_flag<=!single_flag;
        else
            single_flag<=single_flag;
    end
//trigger_button
    reg r_trigger_button_state;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            r_trigger_button_state<=1;
        else
            r_trigger_button_state<=trigger_button_state;
    end
    reg trigger_button_flag;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            trigger_button_flag<=0;
        else if({r_trigger_button_state,trigger_button_state}==2'b10)
            trigger_button_flag<=!trigger_button_flag;
        else
            trigger_button_flag<=trigger_button_flag;
    end
    //trigger_edge
        reg r_trigger_edge_state;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            r_trigger_edge_state<=1;
        else
            r_trigger_edge_state<=trigger_edge_state;
    end
    reg trigger_edge_o;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            trigger_edge_o<=0;
        else if({r_trigger_edge_state,trigger_edge_state}==2'b10)
            trigger_edge_o<=!trigger_edge_o;
        else
            trigger_edge_o<=trigger_edge_o;
    end
    //画中画，波形绘制区域
    wire h_exceed;
    wire v_exceed;
    assign h_exceed = I_vtc2_offset_x + H2_ActiveSize > H_Visible_area - 1'b1;
    assign v_exceed = I_vtc2_offset_y + V2_ActiveSize > V_Visible_area - 1'b1;
    assign hs2_valid = h_exceed ? (visible_hcount >= I_vtc2_offset_x && visible_hcount < H_Visible_area):
                                  (visible_hcount >= I_vtc2_offset_x && visible_hcount < I_vtc2_offset_x + H2_ActiveSize);  
  
    assign vs2_valid = v_exceed ? (visible_vcount >= I_vtc2_offset_y && visible_vcount < V_Visible_area):
                                  (visible_vcount >= I_vtc2_offset_y && visible_vcount < I_vtc2_offset_y + V2_ActiveSize);
  
    wire vtc2_de    =  hs2_valid && vs2_valid; //画中画，数据有效绘制信号
    reg   O_vtc2_de;
    reg [2:0]rst_cnt;
    /*reg [4:0]frame_cnt;
    always @(posedge clk_ctrl or negedge reset_n)begin //通过计数器产生同步复位
       if(reset_n == 1'b0)
           frame_cnt <= 5'b11111;
        else if(Frame_Begin)
            frame_cnt<=5'b00000;
       else if(frame_cnt[4] == 1'b0)
           frame_cnt <= frame_cnt + 1'b1;
   end    
    wire frame_rst=(frame_cnt==5'b00000)?0:1;*/
    always @(posedge clk_ctrl or negedge reset_n)begin //通过计数器产生同步复位
       if(reset_n == 1'b0)
           rst_cnt <= 3'd0;
       else if(rst_cnt[2] == 1'b0)
           rst_cnt <= rst_cnt + 1'b1;
   end    
    wire rst_sync = rst_cnt[2]; //同步复位   
    //完一次寄存打拍输出，有利于改善时序，尤其对于高分辨率，高速的信号，打拍可以改善内部时序，以运行于更高速度
    always @(posedge clk_ctrl)begin
        if(rst_sync == 1'b0)begin
            O_vtc_vs <= 1'b0;
            O_vtc_hs <= 1'b0;
            O_vtc_de <= 1'b0;
            O_vtc2_de <= 1'b0;
        end
        else begin
            O_vtc_vs <= I_vtc_vs; //场同步信号打拍输出
            O_vtc_hs <= I_vtc_hs; //行同步信号打拍输出
            O_vtc_de <= I_vtc_de; //视频有效信号打拍输出
            O_vtc2_de <= vtc2_de; //画中画，数据有效绘制信号
        end
    end
    
    uiwave uiwave
    (
    //波形1
    .I_wave1_clk(I_wave1_clk),      //波形1时钟
    .I_wave1_data(I_wave1_data),     //波形1数据
    .I_wave1_data_de(I_wave1_data_de),  //波形1数据有效
    
    //波形2
    .I_wave2_clk(I_wave2_clk),      //波形2时钟
    .I_wave2_data(I_wave2_data),     //波形2数据
    .I_wave2_data_de(I_wave2_data_de),  //波形2数据有效
    
    //VTC时序输入
    .I_vtc_rstn(reset_n),       //时序复位输入
    .I_vtc_clk(clk_ctrl),        //时序时钟输入
    .I_vtc_vs(O_vtc_vs),         //VS-帧同步，信号同步输入
    .I_vtc_de(O_vtc2_de),         //de有效区域，信号同步输入
    
    //同步时序输出，以及像素输出
    .O_vtc_vs(),         //帧同步输出
    .O_vtc_de(),         //de信号同步后输出
    .O_vtc_rgb(O_vtc_rgb),     //同步输出显示颜色

    .single_flag(single_flag),
    .trigger_edge(trigger_edge_o),
    .trigger_button_flag(trigger_button_minus_flag)
    );
endmodule