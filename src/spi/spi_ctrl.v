module spi_ctrl (
    input clk,
    input rst,

    output reg spi_rx_en,
    output reg spi_tx_en,
    output reg [7:0] spi_data_in,
    input [7:0] spi_data_out,
    input spi_tx_done,
    input spi_rx_done,
    output reg O_spi_cs,    // SPI片选信号

    input spi_tx_flag,
    input spi_rx_flag,

    input spi_finish_flag,

    input [7:0] spi_rdfifo_data,
    input spi_rdfifo_empty,
    output reg spi_rdfifo_req,

    output reg [7:0] spi_wrfifo_data,
    output reg spi_wrfifo_pulse,
    output reg spi_receive_cpl,
    output reg [15:0] spi_data_length
);

    reg [18:0] current_state;
    reg [18:0] next_state;
    reg [1:0] message_cnt;
    reg [1:0] rw_message_cnt;
    reg [15:0] wr_cnt;
    reg [15:0] rd_cnt;
    reg w_r_flag;
    reg r_w_flag;

    localparam 
    IDLE = 19'b0000000000000000001, 
    MESSAGE = 19'b0000000000000000010, 
    WRITE = 19'b0000000000000000100,
    WRITE_BUFFER = 19'b0000000000000001000, 
    WRITE_WAIT_DONE = 19'b0000000000000010000, 
    READ = 19'b0000000000000100000,
    READ_BUFFER = 19'b0000000000001000000,
    READ_DONE = 19'b0000000000010000000,
    READ_DONE_PULSE = 19'b0000000000100000000,
    READ_CPL = 19'b0000000001000000000,
    READ_CPL_FIFO_PULSE = 19'b0000000010000000000,
    READ_CPL_PULSE = 19'b0000000100000000000,
    FIFO_EXAUST = 19'b0000001000000000000,
    W_R_MESSAGE = 19'b0000010000000000000,
    R_W_MESSAGE = 19'b0000100000000000000,
    W_R_WAIT = 19'b0001000000000000000,
    R_W_WAIT = 19'b0010000000000000000,
    W_WAIT = 19'b0100000000000000000,
    R_WAIT = 19'b1000000000000000000;






    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (!spi_rdfifo_empty) begin
                    next_state = MESSAGE;
                end else begin
                    next_state = IDLE;
                end
            end

            MESSAGE: begin
                if (message_cnt == 2'd3) begin
                    case (spi_rdfifo_data[1:0])
                        2'b00: next_state = WRITE;
                        2'b01: next_state = READ;
                        2'b10: next_state = W_R_MESSAGE;
                        2'b11: next_state = R_W_MESSAGE;
                        default:; 
                    endcase
                end else begin
                    next_state = MESSAGE;
                end
            end

            WRITE: begin
                next_state = WRITE_BUFFER;
            end

            WRITE_BUFFER: begin
                next_state = WRITE_WAIT_DONE;
            end

            WRITE_WAIT_DONE: begin
                if (spi_tx_done) begin
                    if (wr_cnt == 0) begin
                        if (w_r_flag) begin
                            next_state = W_R_WAIT;
                        end
                        else begin
                            next_state = FIFO_EXAUST;
                        end
                    end else begin
                        next_state = W_WAIT;
                    end
                end else begin
                    next_state = WRITE_WAIT_DONE;
                end
            end

            READ:begin
                next_state = READ_BUFFER;
            end

            READ_BUFFER:begin
                if (spi_rx_done) begin
                    next_state = R_WAIT;
                end else begin
                    next_state = READ_BUFFER;
                end
            end

            READ_DONE:begin
                next_state = READ_DONE_PULSE;
            end

            READ_DONE_PULSE:begin
                next_state = READ_BUFFER;
            end

            READ_CPL:begin
                next_state = READ_CPL_FIFO_PULSE;
            end

            READ_CPL_FIFO_PULSE:begin
                next_state = READ_CPL_PULSE;
            end

            READ_CPL_PULSE:begin
                if(r_w_flag) begin
                    next_state = R_W_WAIT;
                end else begin
                    next_state = FIFO_EXAUST;
                end
            end

            FIFO_EXAUST: begin
                if (spi_rdfifo_empty) begin
                    next_state = IDLE;
                end else begin
                    next_state = FIFO_EXAUST;
                end
            end

            W_R_MESSAGE: begin
                if (rw_message_cnt == 2'd2) begin
                    next_state = WRITE;
                end else begin
                    next_state = W_R_MESSAGE;
                end
            end

            R_W_MESSAGE: begin
                if (rw_message_cnt == 2'd2) begin
                    next_state = READ;
                end else begin
                    next_state = R_W_MESSAGE;
                end
            end

            W_R_WAIT: begin
                if (!spi_tx_flag) begin
                    next_state = READ;
                end
                else begin
                    next_state = W_R_WAIT;
                end
            end

            R_W_WAIT: begin
                if (!spi_rx_flag) begin
                    next_state = WRITE;
                end
                else begin
                    next_state = R_W_WAIT;
                end
            end

            W_WAIT: begin
                if(!spi_tx_flag)begin
                    next_state = WRITE_BUFFER;
                end
                else begin
                    next_state = W_WAIT;
                end
            end

            R_WAIT: begin
                if(!spi_rx_flag)begin
                    if(rd_cnt == 0) begin
                        next_state = READ_CPL;
                    end else begin
                        next_state = READ_DONE;
                    end
                end
                else begin
                    next_state = R_WAIT;
                end
            end


            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            O_spi_cs        <= 1'b1;
            spi_tx_en      <= 1'b0;
            spi_rx_en      <= 1'b0;
            spi_data_in    <= 8'd0;
            wr_cnt         <= 16'd0;
            rd_cnt         <= 16'd0;
            message_cnt    <= 2'd0;
            rw_message_cnt <= 2'd0;
            r_w_flag       <= 1'b0;
            w_r_flag       <= 1'b0;

            spi_rdfifo_req   <= 1'b0;

            spi_wrfifo_data  <= 8'd0;
            spi_wrfifo_pulse <= 1'b0;
            spi_receive_cpl  <= 1'b0;
            spi_data_length  <= 16'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    if(spi_finish_flag) begin
                        O_spi_cs        <= 1'b1;
                    end
                    spi_rdfifo_req   <= 1'b0;
                    spi_wrfifo_pulse <= 1'b0;
                    spi_receive_cpl  <= 1'b0;
                    r_w_flag       <= 1'b0;
                    w_r_flag       <= 1'b0;
                end
                MESSAGE: begin
                    O_spi_cs        <= 1'b0;
                    case (message_cnt)
                        2'd0: begin
                            spi_rdfifo_req <= 1'b1;
                            message_cnt <= 2'd1;
                        end
                        2'd1: begin
                            spi_data_length[15:8] <= spi_rdfifo_data;
                            message_cnt <= 2'd2;
                        end
                        2'd2: begin
                            spi_data_length[7:0] <= spi_rdfifo_data;
                            message_cnt <= 2'd3;
                        end
                        2'd3: begin
                            wr_cnt <= spi_data_length;
                            rd_cnt <= spi_data_length;
                            spi_rdfifo_req <= 1'b0;
                            message_cnt <= 2'd0;
                        end
                        default: begin
                            spi_rdfifo_req <= 1'b0;
                            message_cnt <= 2'd0;
                        end
                    endcase
                end

                WRITE: begin
                    spi_rdfifo_req <= 1'b1;
                    wr_cnt         <= wr_cnt - 1'b1;
                    spi_data_in    <= spi_rdfifo_data;
                end

                WRITE_BUFFER: begin
                    spi_rdfifo_req <= 1'b0;
                    spi_tx_en <= 1'b1;
                end

                WRITE_WAIT_DONE: begin
                    if (spi_tx_done) begin
                        spi_tx_en <= 1'b0;
                        if (wr_cnt != 0) begin
                            spi_rdfifo_req <= 1'b1;
                            spi_data_in <= spi_rdfifo_data;
                            wr_cnt <= wr_cnt - 1'b1;
                        end
                    end else begin
                        spi_tx_en <= 1'b1;
                    end
                end
                
                READ:begin
                    spi_rx_en <= 1'b1;
                    rd_cnt <= rd_cnt - 1'b1;
                end

                READ_BUFFER:begin
                    spi_wrfifo_pulse<= 1'b0;
                    if (spi_rx_done) begin
                            spi_rx_en <= 1'b0;
                        end
                    else begin
                        spi_rx_en <= 1'b1;
                    end
                end

                READ_DONE:begin
                    spi_wrfifo_data  <= spi_data_out;
                    rd_cnt <= rd_cnt - 1'b1;
                end

                READ_DONE_PULSE:begin
                    spi_wrfifo_pulse <= 1'b1;
                end

                READ_CPL:begin
                    spi_wrfifo_data  <= spi_data_out;
                end

                READ_CPL_FIFO_PULSE:begin
                    spi_wrfifo_pulse <= 1'b1;
                end

                READ_CPL_PULSE:begin
                    spi_wrfifo_pulse <= 1'b0;
                    spi_receive_cpl  <= 1'b1;
                end

                FIFO_EXAUST: begin
                    spi_receive_cpl  <= 1'b0;
                    if (spi_rdfifo_empty) begin
                        spi_rdfifo_req   <= 1'b0;
                    end
                    else begin
                        spi_rdfifo_req   <= 1'b1;
                    end
                end

                W_R_MESSAGE: begin
                    case (rw_message_cnt)
                        2'd0: begin
                            spi_rdfifo_req <= 1'b1;
                            rw_message_cnt <= 2'd1;
                        end
                        2'd1: begin
                            spi_data_length[15:8] <= spi_rdfifo_data;
                            rd_cnt[15:8] <= spi_rdfifo_data;
                            rw_message_cnt <= 2'd2;
                        end
                        2'd2: begin
                            spi_data_length[7:0] <= spi_rdfifo_data;
                            rd_cnt[7:0] <= spi_rdfifo_data;
                            spi_rdfifo_req <= 1'b0;
                            rw_message_cnt <= 2'd0;
                            w_r_flag <= 1'b1;
                        end
                        default: begin
                            spi_rdfifo_req <= 1'b0;
                            rw_message_cnt <= 2'd0;
                        end
                    endcase
                end

                R_W_MESSAGE: begin
                    case (rw_message_cnt)
                        2'd0: begin
                            spi_rdfifo_req <= 1'b1;
                            rw_message_cnt <= 2'd1;
                        end
                        2'd1: begin
                            wr_cnt[15:8] <= spi_rdfifo_data;
                            rw_message_cnt <= 2'd2;
                        end
                        2'd2: begin
                            wr_cnt[7:0] <= spi_rdfifo_data;
                            spi_rdfifo_req <= 1'b0;
                            rw_message_cnt <= 2'd0;
                            r_w_flag <= 1'b1;
                        end
                        default: begin
                            spi_rdfifo_req <= 1'b0;
                            rw_message_cnt <= 2'd0;
                        end
                    endcase
                end

                W_R_WAIT: ;

                R_W_WAIT: begin
                    spi_receive_cpl <= 1'b0;
                end

                W_WAIT: begin
                    spi_rdfifo_req <= 1'b0;
                end
                
                R_WAIT: ;

                default: begin
                    spi_rdfifo_req   <= 1'b0;
                    spi_wrfifo_pulse <= 1'b0;
                    spi_receive_cpl  <= 1'b0;
                end
            endcase
        end
    end


endmodule
