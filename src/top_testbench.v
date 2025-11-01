`timescale 1ns / 1ps
`define CLK_PERIOD 20

module top_testbench ();

    GSR GSR (.GSRI(1'b1));

    reg        clk;
    reg        rst_n;
    reg [31:0] computer_data;
    reg        computer_send_en;
    wire       Tx_Done_computer;
    wire       uart_rx;
    wire       uart_rx_computer;
    reg [7:0]  data_input;
    reg        send_en_input;
    wire       tx_done_input;
    


    initial clk = 1;
	always#(`CLK_PERIOD/2)clk = ~clk;

    initial begin
        rst_n = 0;
        computer_data = 32'd0;
        computer_send_en = 1'b0;
        data_input = 8'd0;
        send_en_input = 1'b0;
        #(`CLK_PERIOD*10);
        rst_n = 1;
        #(`CLK_PERIOD*50);

        // Send data from computer
        computer_data = 32'hFFFFFF10;
        computer_send_en = 1'b1;
        #(`CLK_PERIOD);
        computer_send_en = 1'b0;
        @(posedge Tx_Done_computer);
        #(`CLK_PERIOD*10);

        computer_data = 32'h00000001;
        computer_send_en = 1'b1;
        #(`CLK_PERIOD);
        computer_send_en = 1'b0;
        @(posedge Tx_Done_computer);
        #(`CLK_PERIOD*50);

        // Send data from uart_byte_tx
        data_input = 8'h11;
        send_en_input = 1'b1;
        #(`CLK_PERIOD);
        send_en_input = 1'b0;
        @(posedge tx_done_input);
        #(`CLK_PERIOD);
        data_input = 8'h22;
        send_en_input = 1'b1;
        #(`CLK_PERIOD);
        send_en_input = 1'b0;
        @(posedge tx_done_input);
        #(`CLK_PERIOD);
        data_input = 8'h33;
        send_en_input = 1'b1;
        #(`CLK_PERIOD);
        send_en_input = 1'b0;
        @(posedge tx_done_input);
        #(`CLK_PERIOD);
        data_input = 8'h44;
        send_en_input = 1'b1;
        #(`CLK_PERIOD);
        send_en_input = 1'b0;
        @(posedge tx_done_input);
        #(`CLK_PERIOD);
        data_input = 8'h55;
        send_en_input = 1'b1;
        #(`CLK_PERIOD);
        send_en_input = 1'b0;
        @(posedge tx_done_input);
        #(`CLK_PERIOD*5000000);

        $stop;
    end



    top u_top(
        .clk              (clk ),
        .reset_n          (rst_n ),
        .uart_rx_computer (uart_rx_computer ),
        .uart_tx_computer ( ),
        .rgmii_rx_clk_i   ( ),
        .rgmii_rxd        ( ),
        .rgmii_rxdv       ( ),
        .eth_rst_n        ( ),
        .rgmii_tx_clk     ( ),
        .rgmii_txd        ( ),
        .rgmii_txen       ( ),
        .fx2_ifclk        ( ),
        .fx2_flagc        ( ),
        .fx2_flagb        ( ),
        .fx2_fdata        ( ),
        .fx2_pkt_end      ( ),
        .fx2_slcs         ( ),
        .fx2_faddr        ( ),
        .fx2_slrd         ( ),
        .fx2_slwr         ( ),
        .fx2_sloe         ( ),
        .FX2_SPI_MISO     ( ),
        .FX2_SPI_CS       ( ),
        .FX2_SPI_SCLK     ( ),
        .FX2_SPI_MOSI     ( ),
        .uart_tx          ( ),
        .uart_rx          (uart_rx ),
        .i2c_sdat         ( ),
        .i2c_sclk         ( ),
        .i2c_sdat_slave   ( ),
        .i2c_sclk_slave   ( ),
        .I_spi_miso       ( ),
        .O_spi_sck        ( ),
        .O_spi_cs         ( ),
        .O_spi_mosi       ( ),
        .spi_miso_slave   ( ),
        .spi_clk_slave    ( ),
        .spi_cs_slave     ( ),
        .spi_mosi_slave   ( ),
        .pwm_spwm_ch1     ( ),
        .pwm_spwm_ch2     ( ),
        .pwm_spwm_ch3     ( ),
        .seq0             ( ),
        .seq1             ( ),
        .seq2             ( ),
        .seq3             ( ),
        .error            ( ),
        .bluetooth_tx     ( ),
        .bluetooth_rx     ( ),
        .iIR              ( ),
        .data_adc         ( ),
        .data_dac         ( ),
        .clk_35M          ( ),
        .clk_125M_n       ( ),
        .digit_in         ( ),
        .data_in          ( )
    );

    uart_data_tx 
    #(
	.DATA_WIDTH(32),
	.MSB_FIRST(1)
    )computer_uart_data_tx(
        .Clk        (clk        ),
        .Rst_n      (rst_n      ),
        .data       (computer_data       ),
        .send_en    (computer_send_en    ),
        .Baud_Set   (3'd4   ),
        .uart_tx    (uart_rx_computer    ),
        .Tx_Done    (Tx_Done_computer    ),
        .uart_state ( )
    );

    uart_byte_tx u_uart_byte_tx(
        .clk        (clk        ),
        .reset_n    (rst_n    ),
        .data_byte  (data_input  ),
        .send_en    (send_en_input    ),
        .baud_set   (3'd0   ),
        .uart_tx    (uart_rx    ),
        .tx_done    (tx_done_input    ),
        .uart_state ( )
    );
    
    
    
    


endmodule
