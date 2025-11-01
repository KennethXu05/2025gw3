/////////////////////////////////////////////////////////////////////////////////
// Company       : 武汉芯路恒科技有限公司
//                 http://xiaomeige.taobao.com
// Web           : http://www.corecourse.cn
// 
// Create Date   : 2021/12/20 00:00:00
// Module Name   : eth_udp_loopback_rgmii
// Description   : 以太网rgmii环回测试顶层
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,     //50MHz
    input reset_n,

    //uart_computer
    input uart_rx_computer,
    output uart_tx_computer,

    //eth_rx
    input        rgmii_rx_clk_i,
    input  [3:0] rgmii_rxd,
    input        rgmii_rxdv,
    output       eth_rst_n,
    //output reg [3:0]  pkt_err_cnt,

    //eth_tx
    output       rgmii_tx_clk,
    output [3:0] rgmii_txd,
    output       rgmii_txen,
    //output reg   [3:0]ethernet_tx_cnt,

    //usb
    input fx2_ifclk, //  FX2型USB2.0芯片的接口时钟信号
    input fx2_flagc, //  FX2型USB2.0芯片的端点6满标志
    input fx2_flagb, //  FX2型USB2.0芯片的端点2空标志
    inout [7:0] fx2_fdata, //  FX2型USB2.0芯片的SlaveFIFO的数据线
    
    output fx2_pkt_end,	//数据包结束标志信号,低电平有效
    output fx2_slcs, // FX2型USB2.0芯片的SlaveFIFO的片选信号，当 SLCS 输出高时，不可进行数据传输
    output [1:0] fx2_faddr, //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    output fx2_slrd, //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
    output fx2_slwr, //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    output fx2_sloe, //  FX2型USB2.0芯片的    SlaveFIFO的输出使能信号，低电平有效
    output FX2_SPI_MISO,
    input  FX2_SPI_CS,
    input  FX2_SPI_SCLK,
    input  FX2_SPI_MOSI,


    //uart
    output uart_tx,
    input  uart_rx,

    //i2c
    inout i2c_sdat,
    output i2c_sclk,

    //i2c_slave
    inout i2c_sdat_slave,
    input i2c_sclk_slave,

    //spi
    input  I_spi_miso,
    output O_spi_sck,
    output O_spi_cs,
    output O_spi_mosi,

    //spi_slave
    output  spi_miso_slave,
    input   spi_clk_slave,
    input   spi_cs_slave,
    input   spi_mosi_slave,

    //pwm_spwm
    output reg pwm_spwm_ch1,
    output reg pwm_spwm_ch2,
    output reg pwm_spwm_ch3,

    //sequence
    output seq0,
    output seq1,
    output seq2,
    output seq3,
    output error,

    //bluetooth
    output bluetooth_tx,
    input  bluetooth_rx,

    //infrared
    input  iIR,

    //ADDA
    input [7:0] data_adc,
    output [7:0] data_dac,
    output clk_35M,
    output clk_125M_n,

    //digital_signal
    input digit_in,

    //logic_analyzer
    input [3:0] data_in,

    //HDMI
    input switch,
    output hdmi1_clk_p,
    output hdmi1_clk_n,
    output [2:0] hdmi1_dat_p,
    output [2:0] hdmi1_dat_n,
    output hdmi1_oe,

    input hdmi_trigger_edge,
    input hdmi_trigger_button,
    input stream_en,
    input single,
    output hdmi2_clk_p,
    output hdmi2_clk_n,
    output [2:0] hdmi2_dat_p,
    output [2:0] hdmi2_dat_n,
    output hdmi2_oe,

    //CAN
    input can_rx,
    output can_tx
);



    parameter DATA_WIDTH = 32;
    parameter MSB_FIRST = 1;

    wire        reset_p;

    /*-----ethernet-----*/
    parameter LOCAL_MAC = 48'h00_0a_35_01_fe_c0;
    parameter LOCAL_IP = 32'hc0_a8_00_02;
    parameter LOCAL_PORT = 16'd5000;
    parameter DST_MAC = 48'h08_8F_C3_FF_3C_82;
    parameter DST_IP = 32'hc0_a8_00_03;
    parameter DST_PORT = 16'd6102;
    //eth_rx
    wire        clk125m_o;
    wire [47:0] exter_mac;
    wire [31:0] exter_ip;
    wire [15:0] exter_port;
    wire [15:0] rx_data_length;
    wire        ethernet_data_overflow;
    wire [ 7:0] rx_payload_dat;
    wire        rx_payload_valid;
    wire        rx_pkt_done;
    wire        rx_pkt_err;
    //reg  [ 3:0] pkt_right_cnt;
    //reg  [ 3:0] pkt_err_cnt;
    //eth_tx
    wire        clk125m;
    wire        ethernet_tx_done;
    wire [ 7:0] ethernet_tx_payload_dat;
    wire        ethernet_tx_payload_req;
    //reg  [ 3:0] ethernet_tx_cnt;
    // gmii interface
    wire        gmii_rx_clk;
    wire [ 7:0] gmii_rxd;
    wire        gmii_rxdv;
    wire [ 7:0] gmii_txd;
    wire        gmii_txen;
    wire        rgmii_rx_clk;
    wire        pll_locked;
    assign eth_rst_n = 1;

    wire [47:0] dst_mac;
    wire [31:0] dst_ip;
    wire [15:0] dst_port;

    /*-----usb-----*/
    wire FX2_SPI_CLK_24M;





    /*-----uart-----*/
    wire [ 2:0] baud_set;
    //tx
    wire        uart_send_en;
    wire        uart_tx_done;
    wire [ 7:0] uart_tx_data;
    //rx
    wire        uart_rx_done;
    


    /*-----i2c-----*/
    wire        i2c_wrreg_req;
    wire        i2c_rdreg_req;
    wire [15:0] addr;
    wire        addr_mode;
    wire [ 7:0] i2c_wrdata;
    wire [ 7:0] i2c_rddata;
    wire [ 7:0] i2c_id;
    wire        i2c_rw_done;


    /*-----spi-----*/
    wire        spi_rx_en;
    wire        spi_tx_en;
    wire [ 7:0] spi_data_in;
    wire [ 7:0] spi_data_out;
    wire        spi_tx_done;
    wire        spi_rx_done;
    wire        spi_tx_flag;
    wire        spi_rx_flag;
    wire [ 7:0] spi_div;
    wire        spi_finish_flag;

    /*-----pwm-----*/
    wire        pwm_out1;
    wire        pwm_out2;
    wire        pwm_out3;

    /*-----spwm-----*/
    wire        spwm_out1;
    wire        spwm_out2;
    wire        spwm_out3;


    /*-----bluetooth-----*/
    //tx
    wire        bluetooth_send_en;
    wire        bluetooth_tx_done;
    wire [ 7:0] bluetooth_tx_data;
    //rx
    wire        bluetooth_rx_done;


    /*-----i2c_slave-----*/
    wire        sram_cs;
    wire        sram_rw;
    wire [ 7:0] sram_addr;
    wire [ 7:0] sram_odata;
    wire [ 7:0] sram_idata;
    wire        i2c_slave_byte_send_done;

    /*-----spi_slave-----*/
    wire        spi_slave_Send_Data_Valid;
    wire [ 7:0] spi_slave_Send_Data;
    wire        spi_slave_Recive_Data_Valid;
    wire [ 7:0] spi_slave_Recive_Data;
    wire [15:0] spi_slave_Trans_Cnt;
    wire        spi_slave_Trans_Start;
    wire        spi_slave_Trans_End;
    wire        spi_send_over_slave;
    wire        spi_read_flag_slave;

    /*-----adda-----*/
    wire        uart_tx_adda;

    /*-----digital_signal-----*/
    wire        uart_tx_freq;

    /*-----logic_analyzer-----*/
    wire        trigger;
    wire [ 1:0] trigger_ch;
    wire        edge_type;
    wire        en0;
    wire        en1;
    wire        en2;
    wire        en3;
    wire [15:0] logic_div_cnt;
    wire [11:0] sample_depth;
    wire        uart_tx_done_computer;
    wire        uart_send_en_computer;
    wire [7:0]  uart_tx_data_computer;
    wire        uart_tx_logic;
    wire        trigger_rst_n_add;
    wire        trigger_rst_n;
    assign      trigger_rst_n = trigger_rst_n_add & reset_n;

    /*-----HDMI-----*/
    wire        hdmi_fifo_empty;
    wire [7:0]  hdmi_fifo_data;
    wire        hdmi_fifo_rd_en;
    wire        hdmi_fifo_empty_ethernet;
    wire [7:0]  hdmi_fifo_data_ethernet;
    wire        hdmi_fifo_rd_en_ethernet;
    wire        hdmi_fifo_empty_usb;
    wire [7:0]  hdmi_fifo_data_usb;
    wire        hdmi_fifo_rd_en_usb;
    






    /*-----middle connection-----*/
    wire [4:0]  ctrl_signal;
    wire        rx_done_computer;
    wire [31:0] rx_data_computer;


    //ethernet_middle
    //rx
    wire        ethernet_fifowr_req;
    wire        ethernet_fifowr_empty;
    wire [ 7:0] ethernet_fifowr_data;
    //tx
    wire [ 7:0] ethernet_wrfifo_data;
    wire        ethernet_wrfifo_pulse;
    wire [15:0] ethernet_tx_data_length;
    wire        ethernet_tx_en;


    //usb_middle
    wire         usb_fifowr_req;
    wire         usb_fifowr_empty;
    wire  [7:0]  usb_fifowr_data;

    wire  [7:0]  usb_wrfifo_data;
    wire         usb_wrfifo_pulse;
    wire  [15:0] usb_tx_datalength;
    wire         usb_tx_en;

    //uart_middle
    //tx
    wire        uart_rdfifo_req;
    wire        uart_rdfifo_empty;
    wire [ 7:0] uart_rdfifo_data;
    //rx
    wire        uart_wrfifo_pulse;
    wire        uart_receive_cpl;
    wire [15:0] uart_data_length;
    wire [ 7:0] uart_wrfifo_data;


    //i2c_middle
    wire        i2c_rdfifo_req;
    wire        i2c_rdfifo_empty;
    wire [ 7:0] i2c_rdfifo_data;

    wire [ 7:0] i2c_wrfifo_data;
    wire        i2c_wrfifo_pulse;
    wire        i2c_wrfifo_over;
    wire [15:0] i2c_wrfifo_length;


    //spi_middle
    wire        spi_rdfifo_req;
    wire        spi_rdfifo_empty;
    wire [ 7:0] spi_rdfifo_data;

    wire [ 7:0] spi_wrfifo_data;
    wire        spi_wrfifo_pulse;
    wire        spi_receive_cpl;
    wire [15:0] spi_data_length;


    //pwm_middle
    wire        pwm_rdfifo_req;
    wire        pwm_rdfifo_empty;
    wire [ 7:0] pwm_rdfifo_data;


    //sequence_middle
    wire        sequence_rdfifo_req;
    wire        sequence_rdfifo_empty;
    wire [7:0]  sequence_rdfifo_data;


    //bluetooth_middle
    //tx
    wire        bluetooth_rdfifo_req;
    wire        bluetooth_rdfifo_empty;
    wire [ 7:0] bluetooth_rdfifo_data;
    //rx
    wire        bluetooth_wrfifo_pulse;
    wire        bluetooth_receive_cpl;
    wire [15:0] bluetooth_data_length;  
    wire [ 7:0] bluetooth_wrfifo_data;


    //infrared_middle
    wire        ir_wrfifo_pulse;
    wire        ir_receive_cpl;
    wire [15:0] ir_data_length;
    wire [ 7:0] ir_wrfifo_data;


    //spwm_middle
    wire        spwm_rdfifo_req;
    wire        spwm_rdfifo_empty;
    wire [ 7:0] spwm_rdfifo_data;


    //i2c_slave_middle
    wire        i2c_slave_rdfifo_req;
    wire        i2c_slave_rdfifo_empty;
    wire [ 7:0] i2c_slave_rdfifo_data;

    wire [ 7:0] i2c_slave_wrfifo_data;
    wire        i2c_slave_wrfifo_pulse;
    wire        i2c_slave_receive_cpl;
    wire [15:0] i2c_slave_data_length;


    //spi_slave_middle
    wire        spi_slave_rdfifo_req;
    wire        spi_slave_rdfifo_empty;
    wire [ 7:0] spi_slave_rdfifo_data;

    wire [ 7:0] spi_slave_wrfifo_data;
    wire        spi_slave_wrfifo_pulse;
    wire        spi_slave_receive_cpl;
    wire [15:0] spi_slave_data_length;

    //CAN_middle
    wire        can_rdfifo_req;
    wire        can_rdfifo_empty;
    wire [ 7:0] can_rdfifo_data;

    wire [ 7:0] can_wrfifo_data;
    wire        can_wrfifo_pulse;
    wire        can_receive_cpl;
    wire [15:0] can_data_length;





    //usb_ethernet_middle
    wire        usb2ethernet_fifowr_req;
    wire        usb2ethernet_fifowr_empty;
    wire [ 7:0] usb2ethernet_fifowr_data;

    wire [ 7:0] usb2ethernet_wrfifo_data;
    wire        usb2ethernet_wrfifo_pulse;
    wire        usb2ethernet_wrfifo_over;
    wire [15:0] usb2ethernet_wrfifo_length;


    wire        ethernet2usb_fifowr_req;
    wire        ethernet2usb_fifowr_empty;
    wire [ 7:0] ethernet2usb_fifowr_data;
    
    wire [ 7:0] ethernet2usb_wrfifo_data;
    wire        ethernet2usb_wrfifo_pulse;
    wire        ethernet2usb_wrfifo_over;
    wire [15:0] ethernet2usb_wrfifo_length;











    Gowin_PLL Gowin_PLL (
        .clkout0(rgmii_rx_clk),   //output clkout0
        .init_clk(rgmii_rx_clk_i), 
        .clkin  (rgmii_rx_clk_i)  //input clkin
    );

    Gowin_PLL_produce Gowin_PLL_produce(
        .lock(), //output lock
        .init_clk(clk), 
        .clkout0(clk125m), //output clkout0
        .clkin(clk), //input clkin
        .reset(reset_p) //input reset
    );

    USB_PLL USB_PLL(
        .clkin(FX2_SPI_SCLK), //input  clkin
        .init_clk(FX2_SPI_SCLK), //input  init_clk
        .clkout0(FX2_SPI_CLK_24M) //output  clkout0
    );

    assign reset_p = ~reset_n;


/*----------------------------------------ethernet--------------------------------------------*/

    rgmii_to_gmii rgmii_to_gmii (
        .reset(reset_p),

        .rgmii_rx_clk(rgmii_rx_clk),
        .rgmii_rxd(rgmii_rxd),
        .rgmii_rxdv(rgmii_rxdv),

        .gmii_rx_clk(gmii_rx_clk),
        .gmii_rxdv(gmii_rxdv),
        .gmii_rxd(gmii_rxd),
        .gmii_rxer()
    );

    //以太网接收
    eth_udp_rx_gmii eth_udp_rx_gmii (
        .reset_p(reset_p),

        .local_mac (LOCAL_MAC),
        .local_ip  (LOCAL_IP),
        .local_port(LOCAL_PORT),

        .clk125m_o      (clk125m_o),
        .exter_mac      (exter_mac),
        .exter_ip       (exter_ip),
        .exter_port     (exter_port),
        .rx_data_length (rx_data_length),
        .data_overflow_i(ethernet_data_overflow),
        .payload_valid_o(rx_payload_valid),
        .payload_dat_o  (rx_payload_dat),

        .one_pkt_done   (rx_pkt_done),
        .pkt_error      (rx_pkt_err),
        .debug_crc_check(),

        .gmii_rx_clk(gmii_rx_clk),
        .gmii_rxdv  (gmii_rxdv),
        .gmii_rxd   (gmii_rxd)
    );


    fifo_mtos_ethernet fifo_mtos_ethernet (
        .Data(rx_payload_dat),  //input [7:0] Data
        .Reset(reset_p),
        .WrClk(clk125m_o),  //input WrClk
        .RdClk(clk),  //input RdClk
        .WrEn(rx_payload_valid),  //input WrEn
        .RdEn(ethernet_fifowr_req),  //input RdEn
        .Q(ethernet_fifowr_data),  //output [7:0] Q
        .Empty(ethernet_fifowr_empty),  //output Empty
        .Full(ethernet_data_overflow)  //output Full
    );




    fifo_stom_ethernet fifo_stom_ethernet (
        .Data(ethernet_wrfifo_data),  //input [7:0] Data
        .Reset(reset_p),
        .WrClk(clk),  //input WrClk
        .RdClk(clk125m),  //input RdClk
        .WrEn(ethernet_wrfifo_pulse),  //input WrEn
        .RdEn(ethernet_tx_payload_req),  //input RdEn
        .Q(ethernet_tx_payload_dat),  //output [7:0] Q
        .Empty(),  //output Empty
        .Full()  //output Full
    );


    reg [15:0] ethernet_tx_data_length_reg;

    always @(posedge clk125m or posedge reset_p) begin
        if (reset_p) begin
            ethernet_tx_data_length_reg <= 16'b0;
        end else begin
            ethernet_tx_data_length_reg <= ethernet_tx_data_length;
        end
    end


    wire ethernet_tx_pulse;
    reg  ethernet_tx_en_dly;
    reg ethernet_tx_pulse_r;
    reg ethernet_tx_pulse_rr;

    always @(posedge clk125m or posedge reset_p) begin
        if (reset_p) begin
            ethernet_tx_en_dly <= 1'b0;
        end else begin
            ethernet_tx_en_dly <= ethernet_tx_en;
        end
    end
    assign ethernet_tx_pulse = ethernet_tx_en & ~ethernet_tx_en_dly;

    always @(posedge clk125m or posedge reset_p) begin
        if (reset_p) begin
            ethernet_tx_pulse_r <= 1'b0;
            ethernet_tx_pulse_rr <= 1'b0;
        end else begin
            ethernet_tx_pulse_r <= ethernet_tx_pulse;
            ethernet_tx_pulse_rr <= ethernet_tx_pulse_r;
        end
    end


    eth_udp_tx_gmii eth_udp_tx_gmii (
        .clk125m(clk125m),
        .reset_p(reset_p),

        .tx_en_pulse(ethernet_tx_pulse_rr),
        .tx_done    (ethernet_tx_done),

        .dst_mac (dst_mac),
        .src_mac (LOCAL_MAC),
        .dst_ip  (dst_ip),
        .src_ip  (LOCAL_IP),
        .dst_port(dst_port),
        .src_port(LOCAL_PORT),


        .data_length(ethernet_tx_data_length_reg),

        .payload_req_o(ethernet_tx_payload_req),
        .payload_dat_i(ethernet_tx_payload_dat),

        .gmii_txen  (gmii_txen),
        .gmii_txd   (gmii_txd)
    );

    gmii_to_rgmii gmii_to_rgmii (
        .reset_n(reset_n),

        .gmii_tx_clk(clk125m),
        .gmii_txd(gmii_txd),
        .gmii_txen(gmii_txen),
        .gmii_txer(1'b0),

        .rgmii_tx_clk(rgmii_tx_clk),
        .rgmii_txd(rgmii_txd),
        .rgmii_txen(rgmii_txen)
    );




/*-----------------------------------------usb----------------------------------------------*/
    FX2_CDC_UART_SPI u_FX2_CDC_UART_SPI(
        .clk            (clk            ),
        .reset_n        (reset_n        ),

        .fx2_fdata      (fx2_fdata      ),
        .fx2_flagb      (fx2_flagb      ),
        .fx2_flagc      (fx2_flagc      ),
        .fx2_ifclk      (fx2_ifclk      ),
        .fx2_faddr      (fx2_faddr      ),
        .fx2_sloe       (fx2_sloe       ),
        .fx2_slwr       (fx2_slwr       ),
        .fx2_slrd       (fx2_slrd       ),
        .fx2_pkt_end    (fx2_pkt_end    ),
        .fx2_slcs       (fx2_slcs       ),
        .FX2_SPI_CS     (FX2_SPI_CS     ),
        .FX2_SPI_SCLK   (FX2_SPI_CLK_24M),
        .FX2_SPI_MOSI   (FX2_SPI_MOSI   ),
        .FX2_SPI_MISO   (FX2_SPI_MISO   ),

        .uart_recv_done (usb_wrfifo_pulse ),
        .uart_rx_data   (usb_wrfifo_data   ),

        .tx_fifo_pop    (usb_fifowr_req    ),
        .tx_fifo_empty  (usb_fifowr_empty  ),
        .byte_tx_data   (usb_fifowr_data   ),

        .ctrl           (ctrl_signal[4]),
        .switch         (switch         ),
        .hdmi_fifo_rd_en_usb (hdmi_fifo_rd_en_usb),
        .hdmi_fifo_data_usb   (hdmi_fifo_data_usb   ),
        .hdmi_fifo_empty_usb  (hdmi_fifo_empty_usb  )
    );

    








/*-----------------------------------------uart----------------------------------------------*/
    uart_send_ctrl u_uart_send_ctrl (
        .clk    (clk),
        .reset_p(reset_p),

        .fifo_rd_data(uart_rdfifo_data),
        .fifo_empty  (uart_rdfifo_empty),
        .fifo_rd_req (uart_rdfifo_req),

        .uart_tx_done(uart_tx_done),
        .uart_send_en(uart_send_en),
        .uart_tx_data(uart_tx_data)
    );

    uart_byte_tx_multibaud u_uart_byte_tx_multibaud (
        .clk      (clk),
        .reset_n  (reset_n),
        .data_byte(uart_tx_data),
        .send_en  (uart_send_en),
        .baud_set (baud_set),

        .uart_tx   (uart_tx),
        .tx_done   (uart_tx_done),
        .uart_state()
    );


    uart_byte_rx_multibaud u_uart_byte_rx_multibaud (
        .Clk      (clk),
        .Rst_n    (reset_n),
        .baud_set (baud_set),
        .uart_rx  (uart_rx),
        .data_byte(uart_wrfifo_data),
        .Rx_Done  (uart_rx_done)
    );

    uart_receive_ctrl u_uart_receive_ctrl (
        .clk        (clk),
        .reset_p    (reset_p),
        .rx_done    (uart_rx_done),
        .wr_pulse   (uart_wrfifo_pulse),
        .tx_en      (uart_receive_cpl),
        .data_length(uart_data_length)
    );



/*---------------------------------------i2c-----------------------------------------*/
    i2c_rw u_i2c_rw(
        .Clk       (clk       ),
        .Rst_n     (reset_n     ),

        .wrreg_req (i2c_wrreg_req ),
        .rdreg_req (i2c_rdreg_req ),
        .addr      (addr      ),
        .addr_mode (addr_mode ),
        .wrdata    (i2c_wrdata    ),
        .rddata    (i2c_rddata    ),
        .device_id (i2c_id ),
        .RW_Done   (i2c_rw_done   ),
        .ack       (          ),
        .dly_cnt_max(250000-1),

        .i2c_sclk  (i2c_sclk  ),
        .i2c_sdat  (i2c_sdat  )
    );

    i2c_ctrl u_i2c_ctrl(
        .clk           (clk           ),
        .reset         (reset_p         ),

        .id            (i2c_id            ),
        .addr_mode     (addr_mode     ),
        .addr          (addr          ),
        .i2c_wrreg_req (i2c_wrreg_req ),
        .i2c_rdreg_req (i2c_rdreg_req ),
        .i2c_wrdata    (i2c_wrdata    ),
        .i2c_rddata    (i2c_rddata    ),
        .i2c_rw_done   (i2c_rw_done   ),

        .fifowr_data   (i2c_rdfifo_data   ),
        .fifowr_empty  (i2c_rdfifo_empty  ),
        .fifowr_req    (i2c_rdfifo_req    ),

        .wrfifo_data   (i2c_wrfifo_data   ),
        .wrfifo_pulse  (i2c_wrfifo_pulse  ),
        .wrfifo_over   (i2c_wrfifo_over   ),
        .wrfifo_length (i2c_wrfifo_length )
    );



/*---------------------------------------spi-----------------------------------------*/
    spi_module u_spi_module(
        .I_clk      (clk      ),
        .I_rst_n    (reset_n    ),

        .I_rx_en    (spi_rx_en    ),
        .I_tx_en    (spi_tx_en    ),
        .I_data_in  (spi_data_in  ),
        .O_data_out (spi_data_out ),
        .O_tx_done  (spi_tx_done  ),
        .O_rx_done  (spi_rx_done  ),

        .spi_tx_flag(spi_tx_flag  ),
        .spi_rx_flag(spi_rx_flag  ),

        .spi_finish_flag(spi_finish_flag),

        .spi_div     (spi_div     ),
        
        .I_spi_miso (I_spi_miso ),
        .O_spi_sck  (O_spi_sck  ),
        .O_spi_mosi (O_spi_mosi )
    );

    spi_ctrl u_spi_ctrl(
        .clk              (clk              ),
        .rst              (reset_p          ),

        .spi_rx_en        (spi_rx_en        ),
        .spi_tx_en        (spi_tx_en        ),
        .spi_data_in      (spi_data_in      ),
        .spi_data_out     (spi_data_out     ),
        .spi_tx_done      (spi_tx_done      ),
        .spi_rx_done      (spi_rx_done      ),
        .O_spi_cs         (O_spi_cs         ),

        .spi_tx_flag      (spi_tx_flag      ),
        .spi_rx_flag      (spi_rx_flag      ),

        .spi_finish_flag  (spi_finish_flag  ),

        .spi_rdfifo_data  (spi_rdfifo_data  ),
        .spi_rdfifo_empty (spi_rdfifo_empty ),
        .spi_rdfifo_req   (spi_rdfifo_req   ),

        .spi_wrfifo_data  (spi_wrfifo_data  ),
        .spi_wrfifo_pulse (spi_wrfifo_pulse ),
        .spi_receive_cpl  (spi_receive_cpl  ),
        .spi_data_length  (spi_data_length  )
    );







/*---------------------------------------pwm-----------------------------------------*/
    pwm_ctrl u_pwm_ctrl(
        .clk              (clk              ),
        .reset_n          (reset_n          ),
        .pwm_rdfifo_data  (pwm_rdfifo_data  ),
        .pwm_rdfifo_empty (pwm_rdfifo_empty ),
        .pwm_rdfifo_req   (pwm_rdfifo_req   ),
        .pwm_out1         (pwm_out1         ),
        .pwm_out2         (pwm_out2         ),
        .pwm_out3         (pwm_out3         )
    );



/*---------------------------------------sequence-----------------------------------------*/
    customized_sequence_ctrl u_customized_sequence_ctrl(
        .clk                   (clk                   ),
        .rst_n                 (reset_n               ),
        .sequence_rdfifo_data  (sequence_rdfifo_data  ),
        .sequence_rdfifo_empty (sequence_rdfifo_empty ),
        .sequence_rdfifo_req   (sequence_rdfifo_req   ),
        .error                 (error                 ),
        .seq0                  (seq0                  ),
        .seq1                  (seq1                  ),
        .seq2                  (seq2                  ),
        .seq3                  (seq3                  )
    );





/*-----------------------------------------bluetooth----------------------------------------------*/
    bluetooth_send_ctrl u_bluetooth_send_ctrl (
        .clk    (clk),
        .reset_p(reset_p),

        .fifo_rd_data(bluetooth_rdfifo_data),
        .fifo_empty  (bluetooth_rdfifo_empty),
        .fifo_rd_req (bluetooth_rdfifo_req),

        .uart_tx_done(bluetooth_tx_done),
        .uart_send_en(bluetooth_send_en),
        .uart_tx_data(bluetooth_tx_data)
    );

    bluetooth_byte_tx u_bluetooth_byte_tx (
        .clk      (clk),
        .reset_n  (reset_n),
        .data_byte(bluetooth_tx_data),
        .send_en  (bluetooth_send_en),
        .baud_set (3'd0),

        .uart_tx   (bluetooth_tx),
        .tx_done   (bluetooth_tx_done),
        .uart_state()
    );


    bluetooth_byte_rx u_bluetooth_byte_rx (
        .Clk      (clk),
        .Rst_n    (reset_n),
        .baud_set (3'd0),
        .uart_rx  (bluetooth_rx),
        .data_byte(bluetooth_wrfifo_data),
        .Rx_Done  (bluetooth_rx_done)
    );

    bluetooth_receive_ctrl u_bluetooth_receive_ctrl (
        .clk        (clk),
        .reset_p    (reset_p),
        .rx_done    (bluetooth_rx_done),
        .wr_pulse   (bluetooth_wrfifo_pulse),
        .tx_en      (bluetooth_receive_cpl),
        .data_length(bluetooth_data_length)
    );




/*---------------------------------------infrared-----------------------------------------*/
    ir_control u_ir_control(
        .clk         (clk         ),
        .reset_n     (reset_n     ),
        .iIR         (iIR         ),
        .dec_done_r  (ir_wrfifo_pulse  ),
        .data        (ir_wrfifo_data        ),
        .stop        (ir_receive_cpl        ),
        .data_length (ir_data_length )
    );




/*---------------------------------------spwm-----------------------------------------*/
    spwm_ctrl u_spwm_ctrl(
        .clk               (clk               ),
        .reset_n           (reset_n           ),
        .spwm_rdfifo_data  (spwm_rdfifo_data  ),
        .spwm_rdfifo_empty (spwm_rdfifo_empty ),
        .spwm_rdfifo_req   (spwm_rdfifo_req   ),
        .spwm_out1         (spwm_out1         ),
        .spwm_out2         (spwm_out2         ),
        .spwm_out3         (spwm_out3         )
    );



/*---------------------------------------i2c_slave-----------------------------------------*/
    i2c_slave u_i2c_slave(
        .SCL            (i2c_sclk_slave            ),
        .SDA            (i2c_sdat_slave            ),
        .i_rstn         (reset_n         ),
        .i_ck           (clk           ),
        .sram_cs        (sram_cs        ),
        .sram_rw        (sram_rw        ),
        .sram_addr      (sram_addr      ),
        .sram_odata     (sram_odata     ),
        .sram_idata     (sram_idata     ),
        .byte_send_done (i2c_slave_byte_send_done )
    );
    
    i2c_slave_ctrl u_i2c_slave_ctrl(
        .clk                    (clk                    ),
        .rst_n                  (reset_n                  ),
        .sram_cs                (sram_cs                ),
        .sram_rw                (sram_rw                ),
        .sram_addr              (sram_addr              ),
        .sram_odata             (sram_odata             ),
        .sram_idata             (sram_idata             ),
        .byte_send_done         (i2c_slave_byte_send_done         ),
        .i2c_slave_rdfifo_data  (i2c_slave_rdfifo_data  ),
        .i2c_slave_rdfifo_empty (i2c_slave_rdfifo_empty ),
        .i2c_slave_rdfifo_req   (i2c_slave_rdfifo_req   ),
        .i2c_slave_wrfifo_data  (i2c_slave_wrfifo_data  ),
        .i2c_slave_wrfifo_pulse (i2c_slave_wrfifo_pulse ),
        .i2c_slave_receive_cpl  (i2c_slave_receive_cpl  ),
        .i2c_slave_data_length  (i2c_slave_data_length  )
    );






/*---------------------------------------spi_slave-----------------------------------------*/
    spi_slave u_spi_slave(
        .Clk               (clk               ),
        .Rst_n             (reset_n             ),
        .Send_Data_Valid   (spi_slave_Send_Data_Valid   ),
        .Send_Data         (spi_slave_Send_Data         ),
        .Recive_Data_Valid (spi_slave_Recive_Data_Valid ),
        .Recive_Data       (spi_slave_Recive_Data       ),
        .Trans_Cnt         (spi_slave_Trans_Cnt         ),
        .Trans_Done        (        ),
        .SPI_CS            (spi_cs_slave            ),
        .SPI_SCK           (spi_clk_slave           ),
        .SPI_MOSI          (spi_mosi_slave          ),
        .SPI_MISO          (spi_miso_slave          ),
        .Trans_Start       (spi_slave_Trans_Start       ),
        .Trans_End         (spi_slave_Trans_End         ),
        .spi_send_over_slave   (spi_send_over_slave),
        .spi_read_flag_slave   (spi_read_flag_slave)
    );
    
    spi_slave_ctrl u_spi_slave_ctrl(
        .clk                    (clk                    ),
        .rst_n                  (reset_n                  ),
        .Send_Data_Valid        (spi_slave_Send_Data_Valid        ),
        .Send_Data              (spi_slave_Send_Data              ),
        .Recive_Data_Valid      (spi_slave_Recive_Data_Valid      ),
        .Recive_Data            (spi_slave_Recive_Data            ),
        .Trans_Cnt              (spi_slave_Trans_Cnt              ),
        .Trans_Start            (spi_slave_Trans_Start            ),
        .Trans_End              (spi_slave_Trans_End              ),
        .spi_send_over_slave    (spi_send_over_slave   ),
        .spi_read_flag_slave    (spi_read_flag_slave   ),
        .spi_slave_rdfifo_data  (spi_slave_rdfifo_data  ),
        .spi_slave_rdfifo_empty (spi_slave_rdfifo_empty ),
        .spi_slave_rdfifo_req   (spi_slave_rdfifo_req   ),
        .spi_slave_wrfifo_data  (spi_slave_wrfifo_data  ),
        .spi_slave_wrfifo_pulse (spi_slave_wrfifo_pulse ),
        .spi_slave_receive_cpl  (spi_slave_receive_cpl  ),
        .spi_slave_data_length  (spi_slave_data_length  )
    );
    





/*---------------------------------------usb_ethernet-----------------------------------------*/
    usb_ethernet_ctrl usb2ethernet_ctrl(
        .clk                (clk                ),
        .rst_n              (reset_n              ),
        
        .rdfifo_data        (usb2ethernet_fifowr_data        ),
        .rdfifo_empty       (usb2ethernet_fifowr_empty       ),
        .rdfifo_req         (usb2ethernet_fifowr_req         ),

        .wrfifo_data        (usb2ethernet_wrfifo_data        ),
        .wrfifo_pulse       (usb2ethernet_wrfifo_pulse       ),
        .wrfifo_over        (usb2ethernet_wrfifo_over        ),
        .wrfifo_data_length (usb2ethernet_wrfifo_length )
    );

    usb_ethernet_ctrl ethernet2usb_ctrl(
        .clk                (clk                ),
        .rst_n              (reset_n              ),

        .rdfifo_data        (ethernet2usb_fifowr_data        ),
        .rdfifo_empty       (ethernet2usb_fifowr_empty       ),
        .rdfifo_req         (ethernet2usb_fifowr_req         ),

        .wrfifo_data        (ethernet2usb_wrfifo_data        ),
        .wrfifo_pulse       (ethernet2usb_wrfifo_pulse       ),
        .wrfifo_over        (ethernet2usb_wrfifo_over        ),
        .wrfifo_data_length (ethernet2usb_wrfifo_length )
    );









/*---------------------------------------ADDA-----------------------------------------*/
    adda_dsp u_adda_dsp(
        .clk        (clk        ),
        .rst_n      (reset_n      ),
        .data_adc   (data_adc   ),
        .uart_rx    (uart_rx_computer    ),
        .uart_tx    (uart_tx_adda    ),
        .clk_35M    (clk_35M    ),
        .clk_125M_n (clk_125M_n ),
        .data_dac   (data_dac   )
    );




/*---------------------------------------digital_signal-----------------------------------------*/
    freq_uart_top u_freq_uart_top(
        .clk      (clk      ),
        .rst_n    (reset_n    ),
        .uart_rx  (uart_rx_computer  ),
        .digit_in (digit_in ),
        .uart_tx  (uart_tx_freq  )
    );





    

/*---------------------------------------logical_analyzer-----------------------------------------*/
    logic_analyzer_top u_logic_analyzer_top(
        .clk          (clk          ),
        .rst_n        (trigger_rst_n        ),
        .trigger      (trigger      ),
        .trigger_ch   (trigger_ch   ),
        .edge_type    (edge_type    ),
        .en0          (en0          ),
        .en1          (en1          ),
        .en2          (en2          ),
        .en3          (en3          ),
        .div_cnt      (logic_div_cnt),
        .sample_depth (sample_depth ),
        .data_in      (data_in      ),
        .uart_tx_done (uart_tx_done_computer ),
        .uart_send_en (uart_send_en_computer ),
        .uart_tx_data (uart_tx_data_computer  )
    );

    uart_tx2computer u_uart_tx2computer(
        .clk        (clk        ),
        .reset_n    (reset_n    ),
        .data_byte  (uart_tx_data_computer  ),
        .send_en    (uart_send_en_computer    ),
        .baud_set   (3'd4   ),
        .uart_tx    (uart_tx_logic    ),
        .tx_done    (uart_tx_done_computer    ),
        .uart_state ( )
    );
    
    
/*-----------------------------------------HDMI----------------------------------------------*/
    rom_char_tft_hdmi u_rom_char_tft_hdmi(
        .clk50M          (clk            ),
        .reset_n         (reset_n         ),
        .fifo_empty      (hdmi_fifo_empty      ),
        .fifo_data       (hdmi_fifo_data       ),
        .rd_en           (hdmi_fifo_rd_en           ),
        .TFT_rgb         (         ),
        .TFT_hs          (          ),
        .TFT_vs          (          ),
        .TFT_clk         (         ),
        .TFT_de          (          ),
        .TFT_pwm         (         ),
        .I_vtc2_offset_x (12'd25 ),
        .I_vtc2_offset_y (12'd172 ),
        .I_wave1_clk     (clk_35M     ),
        .I_wave1_data    (~data_adc    ),
        .I_wave1_data_de (!stream_en ),
        .I_wave2_clk     (1'b0     ),
        .I_wave2_data    (8'd255    ),
        .I_wave2_data_de (1'b0 ),
        .single          (single          ),
        .trigger_edge    (hdmi_trigger_edge    ),
        .trigger_button  (hdmi_trigger_button  ),
        .hdmi1_clk_p     (hdmi1_clk_p     ),
        .hdmi1_clk_n     (hdmi1_clk_n     ),
        .hdmi1_dat_p     (hdmi1_dat_p     ),
        .hdmi1_dat_n     (hdmi1_dat_n     ),
        .hdmi1_oe        (hdmi1_oe        ),
        .hdmi2_clk_p     (hdmi2_clk_p     ),
        .hdmi2_clk_n     (hdmi2_clk_n     ),
        .hdmi2_dat_p     (hdmi2_dat_p     ),
        .hdmi2_dat_n     (hdmi2_dat_n     ),
        .hdmi2_oe        (hdmi2_oe        )
    );



    fifo_mtos_ethernet ethernet_HDMI (
        .Data(rx_payload_dat),  //input [7:0] Data
        .Reset(switch | !ctrl_signal[4]),
        .WrClk(clk125m_o),  //input WrClk
        .RdClk(clk),  //input RdClk
        .WrEn(rx_payload_valid),  //input WrEn
        .RdEn(hdmi_fifo_rd_en_ethernet),  //input RdEn
        .Q(hdmi_fifo_data_ethernet),  //output [7:0] Q
        .Empty(hdmi_fifo_empty_ethernet),  //output Empty
        .Full()  //output Full
    );

    hdmi_ctrl u_hdmi_ctrl(
        .ctrl                     (ctrl_signal[4]           ),
        .hdmi_fifo_empty          (hdmi_fifo_empty          ),
        .hdmi_fifo_data           (hdmi_fifo_data           ),
        .hdmi_fifo_rd_en          (hdmi_fifo_rd_en          ),
        .hdmi_fifo_empty_usb      (hdmi_fifo_empty_usb      ),
        .hdmi_fifo_data_usb       (hdmi_fifo_data_usb       ),
        .hdmi_fifo_rd_en_usb      (hdmi_fifo_rd_en_usb      ),
        .hdmi_fifo_empty_ethernet (hdmi_fifo_empty_ethernet ),
        .hdmi_fifo_data_ethernet  (hdmi_fifo_data_ethernet  ),
        .hdmi_fifo_rd_en_ethernet (hdmi_fifo_rd_en_ethernet )
    );
    


/*-----------------------------------------CAN----------------------------------------------*/
    can_top u_can_top(
        .reset_n       (reset_n       ),
        .clk           (clk           ),
        .can_rx        (can_rx        ),
        .can_tx        (can_tx        ),
        .tx_valid      (can_rdfifo_req      ),
        .tx_data       (can_rdfifo_data       ),
        .tx_fifo_empty (can_rdfifo_empty ),
        .rx_valid      (can_wrfifo_pulse      ),
        .rx_last       (can_receive_cpl       ),
        .rx_data       (can_wrfifo_data       ),
        .rx_data_lenth (can_data_length )
    );
    







/*-----------------------------------------connection----------------------------------------------*/
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_spwm_ch1 <= 1'b0;
            pwm_spwm_ch2 <= 1'b0;
            pwm_spwm_ch3 <= 1'b0;
        end
        else begin
            if (ctrl_signal[3:0] == 4'b0100) begin
                pwm_spwm_ch1 <= pwm_out1;
                pwm_spwm_ch2 <= pwm_out2;
                pwm_spwm_ch3 <= pwm_out3;
            end
            else if (ctrl_signal[3:0] == 4'b1000) begin
                pwm_spwm_ch1 <= spwm_out1;
                pwm_spwm_ch2 <= spwm_out2;
                pwm_spwm_ch3 <= spwm_out3;
            end
            else begin
                pwm_spwm_ch1 <= 1'b0;
                pwm_spwm_ch2 <= 1'b0;
                pwm_spwm_ch3 <= 1'b0;
            end
        end
    end

    uart_data_rx 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)        
    )
    u1_uart_data_rx(
        .Clk(clk),
        .Rst_n(reset_n),
        .uart_rx(uart_rx_computer),
        
        .data(rx_data_computer),
        .Rx_Done(rx_done_computer),
        .timeout_flag(),
        
        .Baud_Set(3'd4)
    );


    computer_ctrl u_computer_ctrl(
        .clk               (clk               ),
        .reset_n           (reset_n           ),
        .rx_done_computer  (rx_done_computer  ),
        .rx_data_computer  (rx_data_computer  ),
        .uart_tx_adda      (uart_tx_adda      ),
        .uart_tx_freq      (uart_tx_freq      ),
        .uart_tx_logic     (uart_tx_logic     ),
        .trigger           (trigger           ),
        .trigger_rst_n_add (trigger_rst_n_add ),
        .trigger_ch        (trigger_ch        ),
        .edge_type         (edge_type         ),
        .en0               (en0               ),
        .en1               (en1               ),
        .en2               (en2               ),
        .en3               (en3               ),
        .spi_div           (spi_div           ),
        .ctrl_signal       (ctrl_signal       ),
        .baud_set          (baud_set          ),
        .sample_depth      (sample_depth      ),
        .logic_div_cnt     (logic_div_cnt     ),
        .uart_tx_computer  (uart_tx_computer  ),
        .dst_mac           (dst_mac           ),
        .dst_ip            (dst_ip            ),
        .dst_port          (dst_port          )
    );
    
    



    mtos_connection u_mtos_connection(
        .ctrl_signal           (ctrl_signal           ),

        .usb_fifowr_data       (usb_fifowr_data       ),
        .usb_fifowr_empty      (usb_fifowr_empty      ),
        .usb_fifowr_req        (usb_fifowr_req       ),

        .ethernet_fifowr_data  (ethernet_fifowr_data  ),
        .ethernet_fifowr_empty (ethernet_fifowr_empty ),
        .ethernet_fifowr_req   (ethernet_fifowr_req   ),

        .uart_rdfifo_data      (uart_rdfifo_data      ),
        .uart_rdfifo_empty     (uart_rdfifo_empty     ),
        .uart_rdfifo_req       (uart_rdfifo_req       ),

        .i2c_rdfifo_data       (i2c_rdfifo_data       ),
        .i2c_rdfifo_empty      (i2c_rdfifo_empty       ),
        .i2c_rdfifo_req        (i2c_rdfifo_req       ),

        .spi_rdfifo_data       (spi_rdfifo_data       ),
        .spi_rdfifo_empty      (spi_rdfifo_empty      ),
        .spi_rdfifo_req        (spi_rdfifo_req        ),

        .can_rdfifo_data       (can_rdfifo_data       ),
        .can_rdfifo_empty      (can_rdfifo_empty      ),
        .can_rdfifo_req        (can_rdfifo_req        ),

        .pwm_rdfifo_data       (pwm_rdfifo_data       ),
        .pwm_rdfifo_empty      (pwm_rdfifo_empty      ),
        .pwm_rdfifo_req        (pwm_rdfifo_req        ),

        .sequence_rdfifo_data  (sequence_rdfifo_data  ),
        .sequence_rdfifo_empty (sequence_rdfifo_empty ),
        .sequence_rdfifo_req   (sequence_rdfifo_req   ),

        .bluetooth_rdfifo_data (bluetooth_rdfifo_data ),
        .bluetooth_rdfifo_empty(bluetooth_rdfifo_empty),
        .bluetooth_rdfifo_req  (bluetooth_rdfifo_req  ),

        .spwm_rdfifo_data       (spwm_rdfifo_data       ),
        .spwm_rdfifo_empty      (spwm_rdfifo_empty      ),
        .spwm_rdfifo_req        (spwm_rdfifo_req        ),

        .i2c_slave_rdfifo_data       (i2c_slave_rdfifo_data       ),
        .i2c_slave_rdfifo_empty      (i2c_slave_rdfifo_empty      ),
        .i2c_slave_rdfifo_req        (i2c_slave_rdfifo_req        ),

        .spi_slave_rdfifo_data       (spi_slave_rdfifo_data       ),
        .spi_slave_rdfifo_empty      (spi_slave_rdfifo_empty      ),
        .spi_slave_rdfifo_req        (spi_slave_rdfifo_req        ),

        .usb2ethernet_fifowr_data       (usb2ethernet_fifowr_data       ),
        .usb2ethernet_fifowr_empty      (usb2ethernet_fifowr_empty      ),
        .usb2ethernet_fifowr_req        (usb2ethernet_fifowr_req        ),

        .ethernet2usb_fifowr_data       (ethernet2usb_fifowr_data       ),
        .ethernet2usb_fifowr_empty      (ethernet2usb_fifowr_empty      ),
        .ethernet2usb_fifowr_req        (ethernet2usb_fifowr_req        )
    );

    stom_connection u_stom_connection(
        .clk                    (clk                    ),
        .rst_n                  (reset_n                ),
        .ctrl_signal            (ctrl_signal            ),

        .usb_wrfifo_data        (usb_wrfifo_data        ),
        .usb_wrfifo_pulse       (usb_wrfifo_pulse       ),
        .usb_tx_en              (usb_tx_en              ),
        .usb_tx_datalength      (usb_tx_datalength      ),

        .ethernet_wrfifo_data   (ethernet_wrfifo_data   ),
        .ethernet_wrfifo_pulse  (ethernet_wrfifo_pulse  ),
        .ethernet_tx_en         (ethernet_tx_en     ),
        .ethernet_tx_datalength (ethernet_tx_data_length ),

        .uart_wrfifo_data       (uart_wrfifo_data    ),
        .uart_wrfifo_pulse      (uart_wrfifo_pulse    ),
        .uart_receive_cpl       (uart_receive_cpl       ),
        .uart_data_length       (uart_data_length       ),

        .i2c_wrfifo_data        (i2c_wrfifo_data       ),
        .i2c_wrfifo_pulse       (i2c_wrfifo_pulse       ),
        .i2c_receive_cpl        (i2c_wrfifo_over       ),
        .i2c_data_length        (i2c_wrfifo_length       ),

        .spi_wrfifo_data        (spi_wrfifo_data        ),
        .spi_wrfifo_pulse       (spi_wrfifo_pulse       ),
        .spi_receive_cpl        (spi_receive_cpl       ),
        .spi_data_length        (spi_data_length       ),

        .can_wrfifo_data        (can_wrfifo_data        ),
        .can_wrfifo_pulse       (can_wrfifo_pulse       ),
        .can_receive_cpl        (can_receive_cpl        ),
        .can_data_length        (can_data_length        ),

        .bluetooth_wrfifo_data  (bluetooth_wrfifo_data  ),
        .bluetooth_wrfifo_pulse (bluetooth_wrfifo_pulse ),
        .bluetooth_receive_cpl  (bluetooth_receive_cpl  ),
        .bluetooth_data_length  (bluetooth_data_length  ),

        .ir_wrfifo_data         (ir_wrfifo_data         ),
        .ir_wrfifo_pulse        (ir_wrfifo_pulse        ),
        .ir_receive_cpl         (ir_receive_cpl         ),
        .ir_data_length         (ir_data_length         ),

        .i2c_slave_wrfifo_data       (i2c_slave_wrfifo_data       ),
        .i2c_slave_wrfifo_pulse      (i2c_slave_wrfifo_pulse      ),
        .i2c_slave_receive_cpl       (i2c_slave_receive_cpl       ),
        .i2c_slave_data_length       (i2c_slave_data_length       ),

        .spi_slave_wrfifo_data       (spi_slave_wrfifo_data       ),
        .spi_slave_wrfifo_pulse      (spi_slave_wrfifo_pulse      ),
        .spi_slave_receive_cpl       (spi_slave_receive_cpl       ),
        .spi_slave_data_length       (spi_slave_data_length       ),

        .usb2ethernet_wrfifo_data       (usb2ethernet_wrfifo_data       ),
        .usb2ethernet_wrfifo_pulse      (usb2ethernet_wrfifo_pulse      ),
        .usb2ethernet_wrfifo_over        (usb2ethernet_wrfifo_over        ),
        .usb2ethernet_wrfifo_length       (usb2ethernet_wrfifo_length       ),

        .ethernet2usb_wrfifo_data       (ethernet2usb_wrfifo_data       ),
        .ethernet2usb_wrfifo_pulse      (ethernet2usb_wrfifo_pulse      ),
        .ethernet2usb_wrfifo_over        (ethernet2usb_wrfifo_over        ),
        .ethernet2usb_wrfifo_length       (ethernet2usb_wrfifo_length       )
    );



endmodule