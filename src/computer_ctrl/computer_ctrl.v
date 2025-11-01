module computer_ctrl (
    input clk,
    input reset_n,

    input rx_done_computer,
    input [31:0] rx_data_computer,
    input uart_tx_adda,
    input uart_tx_freq,
    input uart_tx_logic,

    output reg trigger,
    output reg trigger_rst_n_add,
    output reg [1:0] trigger_ch,
    output reg edge_type,
    output reg en0,
    output reg en1,
    output reg en2,
    output reg en3,
    output reg [7:0] spi_div,
    output reg [4:0] ctrl_signal,
    output reg [2:0] baud_set,
    output reg [11:0] sample_depth,
    output reg [15:0] logic_div_cnt,
    output reg uart_tx_computer,
    output reg [47:0] dst_mac,
    output reg [31:0] dst_ip,
    output reg [15:0] dst_port
);
    localparam 
    IDLE = 12'b000000000001,
    PROTOCOL = 12'b000000000010,
    UART = 12'b000000000100,
    TRIGGER_RST = 12'b000000001000,
    TRIGGER_RST_WAIT = 12'b000000010000,
    TRIGGER_MESSAGE = 12'b000000100000,
    TRIGGER_CHMESSAGE = 12'b000001000000,
    TRIGGER = 12'b000010000000,
    DISPLAY = 12'b000100000000,
    SPI = 12'b001000000000,
    ETHERNET = 12'b010000000000,
    ETHERNET_MESSAGE = 12'b100000000000;

    reg [11:0] state;
    reg [1:0] tx_flag;
    reg [1:0] ethernet_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx_flag <= 2'd0;
        end
        else begin
            if (rx_done_computer) begin
                case ({rx_data_computer[23:16],rx_data_computer[7:0]})
                    16'hFFA5: tx_flag <= 2'd1;
                    16'hBBBB: tx_flag <= 2'd2;
                    16'hFFA0: tx_flag <= 2'd3;
                    default:; 
                endcase
            end
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            uart_tx_computer <= 1'b1;
        end
        else begin
            case (tx_flag)
                2'd0: uart_tx_computer <= 1'b1;
                2'd1: uart_tx_computer <= uart_tx_freq;
                2'd2: uart_tx_computer <= uart_tx_adda;
                2'd3: uart_tx_computer <= uart_tx_logic;
                default: uart_tx_computer <= 1'b1;
            endcase
        end
    end

    always@(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            trigger <= 1'b0;
            en0 <= 1'b0;
            en1 <= 1'b0;
            en2 <= 1'b0;
            en3 <= 1'b0;
            ctrl_signal <= 5'b11111;
            baud_set <= 3'd1;
            sample_depth <= 12'd0;
            trigger_rst_n_add <= 1'b1;
            trigger_ch <= 2'b00;
            edge_type <= 1'b1;
            spi_div <= 8'd5;
            logic_div_cnt <= 16'd1;
            dst_mac <= 48'h08_8F_C3_FF_3C_82;
            dst_ip <= 32'hc0_a8_00_03;
            dst_port <= 16'd6102;
            ethernet_cnt <= 2'd0;
        end
        else begin
            case (state)
                IDLE: begin
                    trigger <= 1'b0;
                    en0 <= 1'b0;
                    en1 <= 1'b0;
                    en2 <= 1'b0;
                    en3 <= 1'b0;
                    if (rx_done_computer) begin
                        if(rx_data_computer[31:8] == 24'hFFFFFF && rx_data_computer[7:5] == 3'b000) begin
                            state <= PROTOCOL;
                        end
                        else if (rx_data_computer == 32'hFFFFFFA0) begin
                            state <= TRIGGER_RST;
                        end
                        else if(rx_data_computer[31:4] == 28'hFFFFFF2) begin
                            state <= DISPLAY;
                        end
                        else if(rx_data_computer[31:24] == 8'hDD) begin
                            state <= ETHERNET;
                        end
                    end
                    else state <= IDLE;
                end

                PROTOCOL: begin
                    ctrl_signal <= rx_data_computer[4:0];
                    if (rx_data_computer[3:0] == 4'd0) begin
                        state <= UART;
                    end
                    else if(rx_data_computer[3:0] == 4'd2) begin
                        state <= SPI;
                    end
                    else state <= IDLE;
                end

                UART: begin
                    if (rx_done_computer) begin
                        baud_set <= rx_data_computer[2:0];
                        state <= IDLE;
                    end
                    else state <= UART;
                end

                SPI: begin
                    if (rx_done_computer) begin
                        spi_div <= rx_data_computer[7:0];
                        state <= IDLE;
                    end
                    else state <= SPI;
                end

                TRIGGER_RST: begin
                    trigger_rst_n_add <= 1'b0;
                    state <= TRIGGER_RST_WAIT;
                end

                TRIGGER_RST_WAIT: begin
                    trigger_rst_n_add <= 1'b1;
                    state <= TRIGGER_MESSAGE;
                end

                TRIGGER_MESSAGE: begin
                    if (rx_done_computer) begin
                        logic_div_cnt <= rx_data_computer[15:0];
                        sample_depth <= rx_data_computer[27:16];
                        state <= TRIGGER_CHMESSAGE;
                    end
                    else begin
                        state <= TRIGGER_MESSAGE;
                    end
                end

                TRIGGER_CHMESSAGE: begin
                    if (rx_done_computer) begin
                        trigger_ch <= rx_data_computer[1:0];
                        edge_type <= rx_data_computer[8];
                        state <= TRIGGER;
                    end
                    else begin
                        state <= TRIGGER_CHMESSAGE;
                    end
                end

                TRIGGER: begin
                    trigger <= 1'b1;
                    state <= IDLE;
                end

                DISPLAY: begin
                    case (rx_data_computer[1:0])
                        2'b00: en0 <=1'b1;
                        2'b01: en1 <=1'b1;
                        2'b10: en2 <=1'b1;
                        2'b11: en3 <=1'b1;
                        default: ;
                    endcase
                    state <= IDLE;
                end

                ETHERNET: begin
                    dst_mac[47:24] <= rx_data_computer[23:0];
                    state <= ETHERNET_MESSAGE;
                end

                ETHERNET_MESSAGE: begin
                    if(rx_done_computer) begin
                        case (ethernet_cnt)
                            2'd0: begin
                                dst_mac[23:0] <= rx_data_computer[23:0];
                                ethernet_cnt <= ethernet_cnt + 1'b1;
                            end
                            2'd1: begin
                                dst_ip[31:16] <= rx_data_computer[15:0];
                                ethernet_cnt <= ethernet_cnt + 1'b1;
                            end
                            2'd2: begin
                                dst_ip[15:0] <= rx_data_computer[15:0];
                                ethernet_cnt <= ethernet_cnt + 1'b1;
                            end
                            2'd3: begin
                                dst_port <= rx_data_computer[15:0];
                                ethernet_cnt <= 2'd0;
                                state <= IDLE;
                            end
                            default: begin
                                ethernet_cnt <= 2'd0;
                                state <= IDLE;
                            end
                        endcase
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    



    
endmodule