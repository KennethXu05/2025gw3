module adda_dsp(
    input clk,
    input rst_n,

    input [7:0] data_adc,

    input uart_rx,

    output uart_tx,

    output clk_35M,
    output clk_125M_n,

    output reg [7:0] data_dac
);

    parameter DATA_WIDTH = 32;
    parameter MSB_FIRST = 1;

    wire [DATA_WIDTH-1:0] rx_data;
    wire Rx_Done;

    reg hand_drawn_cea;
    reg hand_drawn_ceb;
    reg [9:0] addra_hand_drawn_in;
    reg [9:0] addrb_hand_drawn_out;
    reg [7:0] hand_drawn_data_temp;    //截取串口传来数据的最低八位即可
    wire hand_drawn_data_ready;
    

    uart_data_rx 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)        
    )
    uart_data_rx(
        .Clk(clk),
        .Rst_n(rst_n),
        .uart_rx(uart_rx),
        
        .data(rx_data),
        .Rx_Done(Rx_Done),
        .timeout_flag(),
        
        .Baud_Set(3'd4)
    );

    /****************************DA控制逻辑***********************************/
    reg [10:0] rom_addr;
    wire [7:0] data_dac_sin;
    wire [7:0] data_dac_squ;
    wire [7:0] data_dac_tri;
    wire [7:0] data_dac_saw;
    wire [7:0] data_dac_pul;
    wire [7:0] data_hand_drawn; //手绘波形输出

    //定义输入触发
    localparam [15:0] TRIGGER_SIN = 16'hFFF1;
    localparam [15:0] TRIGGER_SQU = 16'hFFF2;
    localparam [15:0] TRIGGER_TRI = 16'hFFF3;
    localparam [15:0] TRIGGER_SAW = 16'hFFF4;
    localparam [15:0] TRIGGER_PUL = 16'hFFF5;
    localparam [31:0] TRIGGER_FFT = 32'hFFBBFFBB;    //ADC接收与FFT触发信号
    
    localparam [31:0] TRIGGER_HAND_DRAWN = 32'hFFFFAAAA; //手绘波形启动接受信号
    localparam [31:0] TRIGGER_HAND_DRAWN_OUT = 32'hFFFFBBBB; //手绘波形触发输出信号


    //ADC/DAC时钟
    Gowin_PLL_ADDA u_pll_adda(
        .clkin(clk), //input  clkin
        .init_clk(clk), //input  init_clk
        .clkout0(clk_35M), //output  clkout0
        .clkout1(clk_125M) //output  clkout1
    );

    assign clk_125M_n = ~clk_125M; //125MHz时钟取反，适应DAC建立时间和保持时间要求
     
    //波形使能输出标志位
    reg sin_en;
    reg squ_en;
    reg tri_en;
    reg saw_en;
    reg pul_en;
    reg hand_drawn_en;
    
    //检测接收到的数据是否为特殊值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sin_en <= 0;
            squ_en <= 0;
            tri_en <= 0;
            saw_en <= 0;
            pul_en <= 0;
            hand_drawn_en <= 0;
        end 
        else if (Rx_Done) begin
            if (rx_data[31:16] == TRIGGER_SIN) begin
                sin_en <= 1'b1;
                squ_en <= 0;
                tri_en <= 0;
                saw_en <= 0;
                pul_en <= 0;
                hand_drawn_en <= 0;
            end 
            else if (rx_data[31:16] == TRIGGER_SQU) begin
                sin_en <= 0;
                squ_en <= 1'b1;
                tri_en <= 0;
                saw_en <= 0;
                pul_en <= 0;
                hand_drawn_en <= 0;
            end 
            else if (rx_data[31:16] == TRIGGER_TRI) begin
                sin_en <= 0;
                squ_en <= 0;
                tri_en <= 1'b1;
                saw_en <= 0;
                pul_en <= 0;
                hand_drawn_en <= 0;
            end 
            else if (rx_data[31:16] == TRIGGER_SAW) begin
                sin_en <= 0;
                squ_en <= 0;
                tri_en <= 0;
                saw_en <= 1'b1;
                pul_en <= 0;
                hand_drawn_en <= 0;
            end 
            else if (rx_data[31:16] == TRIGGER_PUL) begin
                sin_en <= 0;
                squ_en <= 0;
                tri_en <= 0;
                saw_en <= 0;
                pul_en <= 1'b1;
                hand_drawn_en <= 0;
            end 
            else if (rx_data == TRIGGER_HAND_DRAWN_OUT) begin
                sin_en <= 0;
                squ_en <= 0;
                tri_en <= 0;
                saw_en <= 0;
                pul_en <= 0;
                hand_drawn_en <= 1'b1;
            end
            else begin
                sin_en <= sin_en;
                squ_en <= squ_en;
                tri_en <= tri_en;
                saw_en <= saw_en;
                pul_en <= pul_en;
                hand_drawn_en <= hand_drawn_en;
            end
        end
    end


    
    //手绘波形的存储与输出
    //1 获取上位机传来的手绘波形数据，存入ram中
    //1.1 检测触发信号，给一个脉冲
    reg trigger_flag;
    reg trigger_flag_prev;
    wire trigger_flag_pos;
    reg [9:0] byte_cnt;
    reg [9:0] byte_cnt_store; //存储byte_cnt，在另一状态机使用
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            trigger_flag <= 1'b0;
        end 
        else if(Rx_Done && (rx_data[31:0] == TRIGGER_HAND_DRAWN)) begin
            trigger_flag <= 1'b1; //每次接收到数据后，拉高使能
        end
        else
            trigger_flag <= 1'b0; //否则拉低
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trigger_flag_prev <= 1'b0;
        else
            trigger_flag_prev <= trigger_flag;
    end
    assign trigger_flag_pos = trigger_flag && !trigger_flag_prev; //检测上升沿

    //1.2 当检测到上升沿，cea拉高保持  FSM
    reg [1:0] CEA_STATE;
    parameter CEA_IDLE = 2'b00;
    parameter CEA_HIGH = 2'b01;
    parameter CEA_WAIT = 2'b10;
    parameter CEA_LOW = 2'b11; 

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            CEA_STATE <= CEA_IDLE;
            hand_drawn_cea <= 1'b0;
            addra_hand_drawn_in <= 10'b0;
            byte_cnt <= 10'b0;
            byte_cnt_store <= 10'd0;
        end 
        else begin
            case (CEA_STATE)
                CEA_IDLE: begin
                    hand_drawn_cea <= 1'b0;
                    addra_hand_drawn_in <= 10'b0;
                    byte_cnt <= 10'b0;
                    byte_cnt_store <= byte_cnt_store;
                    if(trigger_flag_pos) //当检测到上升沿时，拉高使能，此为第一个开始的逻辑，准备接收
                        CEA_STATE <= CEA_HIGH;
                end
                CEA_HIGH: begin
                    hand_drawn_cea <= 1'b1;
                    CEA_STATE <= CEA_WAIT;
                end
                CEA_WAIT: begin
                    hand_drawn_cea <= 1'b1;
                    if(rx_data[31:0] == TRIGGER_HAND_DRAWN_OUT)
                        CEA_STATE <= CEA_LOW;
                    else if(Rx_Done) begin   //当cea是拉高状态，且接收到数据时（若没有Rx_Done信号，地址不自增）
                        hand_drawn_data_temp <= rx_data[7:0]; //截取串口传来数据的最低八位即可
                        addra_hand_drawn_in <= addra_hand_drawn_in + 1'b1; //每次接收到数据后，地址自增，不设置上限，直到接收到TRIGGER_HAND_DRAWN_OUT信号
                        byte_cnt <= byte_cnt + 1'b1;
                        CEA_STATE <= CEA_WAIT;
                    end
                    else
                        CEA_STATE <= CEA_WAIT; //保持高电平，直到接收到TRIGGER_HAND_DRAWN_OUT信号
                end
                CEA_LOW: begin
                    byte_cnt_store <= byte_cnt;
                    hand_drawn_cea <= 1'b0;
                    CEA_STATE <= CEA_IDLE; //保持一个时钟周期后拉低
                end
                default: CEA_STATE <= CEA_IDLE;
            endcase
        end
    end

    //整合进状态机
    // //1.3 写入地址与写入数据控制
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         addra_hand_drawn_in <= 10'b0;
    //         hand_drawn_data_temp <= 8'b0;
    //         byte_cnt <= 10'd0;
    //     end 
    //     else if(hand_drawn_cea  && Rx_Done) begin   //当cea是拉高状态，且接收到数据时（若没有Rx_Done信号，地址不自增）
    //         hand_drawn_data_temp <= rx_data[7:0]; //截取串口传来数据的最低八位即可
    //         addra_hand_drawn_in <= addra_hand_drawn_in + 1'b1; //每次接收到数据后，地址自增，不设置上限，直到接收到TRIGGER_HAND_DRAWN_OUT信号
    //         byte_cnt <= byte_cnt + 1'b1;
    //     end
    // end

    //2 手绘波形的输出
    //2.1 输出使能控制
    reg trigger_out_flag;
    reg trigger_out_flag_prev;
    wire trigger_out_flag_pos;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            trigger_out_flag <= 1'b0;
        end 
        else if(Rx_Done && (rx_data[31:0] == TRIGGER_HAND_DRAWN_OUT)) begin
            trigger_out_flag <= 1'b1; //每次接收到数据后，拉高使能
        end
        else
            trigger_out_flag <= 1'b0; //否则拉低
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trigger_out_flag_prev <= 1'b0;
        else
            trigger_out_flag_prev <= trigger_flag;
    end
    assign trigger_out_flag_pos = trigger_out_flag && !trigger_out_flag_prev; //检测上升沿

    //当检测到上升沿，ceb拉高保持  FSM
    reg [1:0] CEB_STATE;
    parameter CEB_IDLE = 2'b00;
    parameter CEB_HIGH = 2'b01;
    parameter CEB_WAIT = 2'b10;
    parameter CEB_LOW = 2'b11; 

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            CEB_STATE <= CEB_IDLE;
            hand_drawn_ceb <= 1'b0;
        end 
        else begin
            case (CEB_STATE)
                CEB_IDLE: begin
                    hand_drawn_ceb <= 1'b0;
                    if(trigger_out_flag_pos) //当检测到上升沿时，拉高使能，此为第一个开始的逻辑，准备输出
                        CEB_STATE <= CEB_HIGH;
                end
                CEB_HIGH: begin
                    hand_drawn_ceb <= 1'b1;
                    CEB_STATE <= CEB_WAIT;
                end
                CEB_WAIT: begin
                    hand_drawn_ceb <= 1'b1;
                    if(rx_data[31:0] != TRIGGER_HAND_DRAWN_OUT ) begin//保持一个时钟周期后继续拉高
                    CEB_STATE <= CEB_LOW;
                    end
                    else
                        CEB_STATE <= CEB_WAIT; //保持高电平，直到接收到TRIGGER_HAND_DRAWN信号
                end
                CEB_LOW: begin
                    hand_drawn_ceb <= 1'b0;
                    CEB_STATE <= CEB_IDLE; //保持一个时钟周期后拉低
                end
                default: CEB_STATE <= CEB_IDLE;
            endcase
        end
    end


    //2.2 输出地址控制
    always @(posedge clk_125M or negedge rst_n) begin
        if(!rst_n) begin
            addrb_hand_drawn_out <= 10'b0;
        end 
        else if(rx_data <= TRIGGER_HAND_DRAWN_OUT && Rx_Done)
            addrb_hand_drawn_out <= 10'b0;
        else if(hand_drawn_ceb) begin   //当ceb是拉高状态，地址开始自增
            if(addrb_hand_drawn_out >= 10'd10 && addrb_hand_drawn_out == byte_cnt_store) //地址到达某个值且若对应存储值为0后回到0继续循环
                addrb_hand_drawn_out <= 10'b0;
            else
                addrb_hand_drawn_out <= addrb_hand_drawn_out + 1'b1; //每次时钟上升沿地址自增
        end
    end


    Gowin_SDPB_hand_drawn u_hand_drawn_wave_mem(
        .dout(data_hand_drawn), //output [7:0] dout
        .clka(clk), //input clka
        .cea(hand_drawn_cea), //input cea
        .clkb(clk_125M), //input clkb
        .ceb(hand_drawn_ceb), //input ceb
        .oce(1'b1), //input oce
        .reset(!rst_n), //input reset
        .ada(addra_hand_drawn_in), //input [9:0] ada
        .din(hand_drawn_data_temp), //input [7:0] din
        .adb(addrb_hand_drawn_out) //input [9:0] adb
    );









    //DAC(正弦方波三角波等频率(125MHz/1250))
    reg [10:0] step;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            step <= 11'd1; // 默认步进值
        else if (Rx_Done) begin
            if (rx_data[31:16] == TRIGGER_SIN ||
                rx_data[31:16] == TRIGGER_SQU ||
                rx_data[31:16] == TRIGGER_TRI ||
                rx_data[31:16] == TRIGGER_SAW ||
                rx_data[31:16] == TRIGGER_PUL)
                step <= rx_data[10:0];
        end
    end

    always @(posedge clk_125M or negedge rst_n) begin
        if(!rst_n)
            rom_addr <= 11'd0;
        else if(sin_en || squ_en || tri_en || saw_en || pul_en) begin
            if(rom_addr + step > 11'd1249)
                rom_addr <= (rom_addr + step) - 11'd1250;
            else
                rom_addr <= rom_addr + step;
        end 
        else
            rom_addr <= rom_addr; //无波形使能时保持不变
    end

    //正弦产生
    sin_pROM u_sin_pRom(
        .dout(data_dac_sin), //output [7:0] dout
        .clk(clk_125M), //input clk
        .oce(1'b1), //input oce
        .ce(sin_en), //input ce
        .reset(!rst_n), //input reset
        .ad(rom_addr) //input [10:0] ad
    );

    //方波产生
    squ_pROM u_squ_pROM(
        .dout(data_dac_squ), //output [7:0] dout
        .clk(clk_125M), //input clk
        .oce(1'b1), //input oce
        .ce(squ_en), //input ce
        .reset(!rst_n), //input reset
        .ad(rom_addr) //input [10:0] ad
    );

    //三角波产生
    tri_pROM u_tri_pROM(
        .dout(data_dac_tri), //output [7:0] dout
        .clk(clk_125M), //input clk
        .oce(1'b1), //input oce
        .ce(tri_en), //input ce
        .reset(!rst_n), //input reset
        .ad(rom_addr) //input [10:0] ad
    ); 

    //锯齿波产生
    saw_pROM u_saw_pROM(
        .dout(data_dac_saw), //output [7:0] dout
        .clk(clk_125M), //input clk
        .oce(1'b1), //input oce
        .ce(saw_en), //input ce
        .reset(!rst_n), //input reset
        .ad(rom_addr) //input [10:0] ad
    ); 

    //脉冲波产生
    pul_pROM u_pul_pROM(
        .dout(data_dac_pul), //output [7:0] dout
        .clk(clk_125M), //input clk
        .oce(1'b1), //input oce
        .ce(pul_en), //input ce
        .reset(!rst_n), //input reset
        .ad(rom_addr) //input [10:0] ad
    ); 

    
    //多路选择器输出信号
    always @(*) begin
            if(!rst_n) begin
            data_dac = 8'b0;
        end else begin
            case(1'b1)  // 使用case语句实现并行选择
                sin_en: data_dac = 8'hff - data_dac_sin;
                squ_en: data_dac = 8'hff - data_dac_squ;
                tri_en: data_dac = 8'hff - data_dac_tri;
                saw_en: data_dac = 8'hff - data_dac_saw;
                pul_en: data_dac = 8'hff - data_dac_pul;
                hand_drawn_en: data_dac = 8'hff - data_hand_drawn;
                default: data_dac = 8'b0;
            endcase
        end
    end



    //FFT相关内容改用上位机实现
    // /****************************ADC数据FFT处理逻辑***********************************/
    // wire [11:0] ram_fft_addr; //fft向ram请求地址
    reg [11:0] addra_adc_ram_in; //adc数据存储地址

    // // wire [7:0] data_ram_fft_out; //ram输出数据给fft
    reg ram_fin_flag; //ram读取4096个点完毕(脉冲)
    reg cea; //adc->ram输入时钟使能
    // reg fft_start; //根据串口输入数据判断是否启动fft，至少持续一个时钟周期高电平

    //1.1 counter4096 当检测到对应的串口输入数据后，从0计到4097并保持
    reg [12:0] cnt4096;
    always @(posedge clk_35M or negedge rst_n) begin
        if(!rst_n)
            cnt4096 <= 13'd0;
        else if((rx_data == TRIGGER_FFT) && Rx_Done) //再次接收到串口信号后清零(优先级高于第四五个elseif)
            cnt4096 <= 13'd0;
        else if(rx_data != TRIGGER_FFT)
            cnt4096 <= 13'd0;
        else if(cnt4096 == 13'd4097) //多计两位(0>1>2> >4095>4096>4097>4097)便于后续cea使能逻辑，同时不会重复刷新第4096个地址
            cnt4096 <= 13'd4097;
        else if(rx_data == TRIGGER_FFT)
            cnt4096 <= cnt4096 + 1'b1;
    end

    //1.2 cea使能端，到4096后永久拉低
    always @(posedge clk_35M or negedge rst_n) begin
        if(!rst_n)
            cea <= 1'b0;
        else if((cnt4096 <= 13'd4096) && (cnt4096 >= 13'd1))
            cea <= 1'b1;
        else
            cea <= 1'b0;
    end

    //2.1 cea有效时，传入ram的地址按照adc采样频率递增
    always @(posedge clk_35M or negedge rst_n) begin
        if(!rst_n)
            addra_adc_ram_in <= 12'b0;
        else if(cea) //当输入时钟被使能，则开始根据时钟信号进行地址的自增，此为第二个开始的逻辑
            addra_adc_ram_in <= addra_adc_ram_in + 1'b1;
        else 
            addra_adc_ram_in <= 0;
    end

    //2.2 ram地址传递完毕产生脉冲
    always @(posedge clk_35M or negedge rst_n) begin
        if(!rst_n) begin
            ram_fin_flag <= 0;
        end
        else if(addra_adc_ram_in == 12'd4095) //当地址自增到4095，则使能ram_fin信号，此为第三个开始的逻辑
            ram_fin_flag <= 1;
        else 
            ram_fin_flag <= 0;
    end

    // //3 FFT启动相关FSM
    // reg [2:0] FFT_STATE; //fft是否进行的状态机
    // parameter FFT_IDLE = 3'b010;
    // parameter FFT_START = 3'b010;
    // parameter FFT_DELAY = 3'b100;

    // always @(posedge clk_35M or negedge rst_n) begin
    //    if(!rst_n)
    //         fft_start <= 1'b0;
    //     else begin
    //         casex (FFT_STATE)
    //             FFT_IDLE: begin
    //                 fft_start <= 1'b0;
    //                 if(pos_edge_ram_fin) //当ram读取完毕4096个点后，再启动fft进行从ram中读取数据的操作，此为第四个开始的逻辑
    //                     FFT_STATE <= FFT_START;
    //                 else 
    //                     FFT_STATE <= FFT_IDLE;
    //             end
    //             FFT_START: begin
    //                 fft_start <= 1'b1;
    //                 FFT_STATE <= FFT_DELAY;
    //             end
    //             FFT_DELAY:
    //                 FFT_STATE <= FFT_IDLE; //相当于fft_start延迟一个时钟周期(2个时钟周期的高电平)再置为0(由于触发是35MHz时钟，避免错过FFT的50MHz时钟，多拉高一会)
    //             default: 
    //                 FFT_STATE<= FFT_IDLE;
    //         endcase
    //     end 
    // end

	// FFT_Top u_fft_top(
	// 	.idx(ram_fft_addr), //output [11:0] idx
	// 	.xk_re(xk_re_o), //output [7:0] xk_re
	// 	.xk_im(xk_im_o), //output [7:0] xk_im
	// 	.sod(), //output sod
	// 	.ipd(), //output ipd
	// 	.eod(), //output eod
	// 	.busy(), //output busy
	// 	.soud(), //output soud
	// 	.opd(), //output opd
	// 	.eoud(), //output eoud
	// 	.xn_re(data_ram_fft_out), //input [7:0] xn_re
	// 	.xn_im(8'b0), //input [7:0] xn_im
	// 	.start(fft_start), //input start(根据串口输入数据，判断是否需要进行fft)
	// 	.clk(clk), //input clk
	// 	.rst(!rst_n) //input rst
	// );
    	
    // adc_fft_SDPB u_adc_fft_sdpb(
    //     .dout(data_ram_fft_out), //output [7:0] dout
    //     .clka(clk_35M), //input clka
    //     .cea(cea), //input cea(输入时钟使能)
    //     .clkb(clk), //input clkb
    //     .ceb(1'b1), //input ceb(输出时钟使能)
    //     .oce(1'b1), //input oce(useless in bypass mode)
    //     .reset(!rst_n), //input reset
    //     .ada(addra_adc_ram_in), //input [11:0] ada
    //     .din(data_adc), //input [7:0] din
    //     .adb(ram_fft_addr) //input [11:0] adb
    // );



    /*****************adc采集的数据传给串口************************/
    reg [11:0] adc_uart_rd_addr;      //读取地址
    reg adc_uart_send_en;             //发送使能
    reg [1:0] ADC_UART_STATE;
    parameter ADC_UART_IDLE = 2'b00;
    parameter ADC_UART_SEND = 2'b01;
    parameter ADC_UART_WAIT = 2'b10;

    wire adc_uart_tx_done;            //串口发送完成信号
    // reg [39:0] adc_uart_data_byte;     //串口发送数据
    reg [7:0] adc_uart_data_byte;
    wire [7:0] dout;                  //ram输出数据
    // reg [7:0] ascii_high;              //高四位ASCII码
    // reg [7:0] ascii_medium;            //中四位ASCII码
    // reg [7:0] ascii_low;               //低四位ASCII码

    // //八位二进制数对应的十进制数转换为24位ASCII码
    // reg [7:0] bin_data;
    // reg [7:0] hundreds, tens, ones;
    
    // always @(*) begin
    //     bin_data = dout; // dout为8位二进制输入
    //     hundreds = bin_data / 100;
    //     tens     = (bin_data % 100) / 10;
    //     ones     = bin_data % 10;
    //     ascii_high   = hundreds + 8'h30;
    //     ascii_medium = tens + 8'h30;
    //     ascii_low    = ones + 8'h30;
    // end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ADC_UART_STATE <= ADC_UART_IDLE;
            adc_uart_rd_addr <= 12'd0;
            adc_uart_send_en <= 1'b0;
        end 
        else begin
            case (ADC_UART_STATE)
                ADC_UART_IDLE: begin
                    adc_uart_send_en <= 1'b0;
                    adc_uart_rd_addr <= 12'd0;
                    if(ram_fin_flag) //采集完成后开始发送(整合进FFT触发逻辑)
                        ADC_UART_STATE <= ADC_UART_SEND;
                end
                ADC_UART_SEND: begin
                    adc_uart_send_en <= 1'b1;
                    // adc_uart_data_byte <= {ascii_high, ascii_medium, ascii_low, 16'h0D0A}; //读取RAM数据
                    adc_uart_data_byte <= dout; //读取RAM数据
                    ADC_UART_STATE <= ADC_UART_WAIT;
                end
                ADC_UART_WAIT: begin
                    if(adc_uart_tx_done) begin
                        if(adc_uart_rd_addr < 12'd4095) begin
                            adc_uart_rd_addr <= adc_uart_rd_addr + 1'b1;
                            ADC_UART_STATE <= ADC_UART_SEND;
                        end
                        else begin
                            adc_uart_send_en <= 1'b0;
                            ADC_UART_STATE <= ADC_UART_IDLE; //发送完毕，回到空闲状态
                        end
                    end
                end
                default: ADC_UART_STATE <= ADC_UART_IDLE;
            endcase
        end
    end

    adc_uart_SDPB u_adc_uart_sdpb(
        .dout(dout), //output [7:0] dout
        .clka(clk_35M), //input clka
        .cea(cea), //input cea
        .clkb(clk), //input clkb
        .ceb(1'b1), //input ceb
        .oce(1'b1), //input oce
        .reset(!rst_n), //input reset
        .ada(addra_adc_ram_in), //input [11:0] ada
        .din(data_adc), //input [7:0] din
        .adb(adc_uart_rd_addr) //input [11:0] adb
    );

    // 串口发送模块
    
    // uart_data_tx
    // #(
	//     .DATA_WIDTH(40),
	//     .MSB_FIRST(1)
    // )
    // uart_data_tx(
	//     .Clk(clk),
	//     .Rst_n(rst_n),
	//     .data(adc_uart_data_byte), 
	//     .send_en(adc_uart_send_en),   
	//     .Baud_Set(3'd4),  
	//     .uart_tx(uart_tx),  
	//     .Tx_Done(adc_uart_tx_done),   
	//     .uart_state()
    // );

    uart_byte_tx adda_uart_byte_tx(
        .clk        (clk        ),
        .reset_n    (rst_n    ),
        .data_byte  (adc_uart_data_byte  ),
        .send_en    (adc_uart_send_en    ),
        .baud_set   (3'd4   ),
        .uart_tx    (uart_tx    ),
        .tx_done    (adc_uart_tx_done    ),
        .uart_state ( )
    );
    

endmodule