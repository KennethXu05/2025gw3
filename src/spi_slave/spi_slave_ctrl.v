module spi_slave_ctrl (
    input clk,
    input rst_n,

    output reg Send_Data_Valid,
    output  [7:0]Send_Data,

    input Recive_Data_Valid,
    input [7:0]Recive_Data,
    input [15:0]Trans_Cnt,

    input Trans_Start,
    input Trans_End,

    input spi_send_over_slave,
    output reg spi_read_flag_slave,

    input [7:0] spi_slave_rdfifo_data,
    input spi_slave_rdfifo_empty,
    output reg spi_slave_rdfifo_req,

    output reg [7:0] spi_slave_wrfifo_data,
    output reg spi_slave_wrfifo_pulse,
    output reg spi_slave_receive_cpl,
    output reg [15:0] spi_slave_data_length
);

    localparam 
    IDLE  = 8'b00000001,
    RW    = 8'b00000010,
    WRITE = 8'b00000100,
    WRITE_PULSE = 8'b00001000,
    FAST_WRITE = 8'b00010000,
    FAST_WRITE_CPL = 8'b00100000,
    READ  = 8'b01000000,
    READ_CPL = 8'b10000000;

    reg [7:0] current_state;
    reg [7:0] next_state;

    assign Send_Data = spi_slave_rdfifo_data;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always@(*)begin
        case(current_state)
            IDLE: begin
                if (Trans_Start) begin
                    next_state = RW;
                end
                else begin
                    next_state = IDLE;
                end
            end

            RW:begin
                if (Recive_Data_Valid) begin
                    if (Recive_Data[0]) begin
                        next_state = READ;
                    end
                    else begin
                        next_state = WRITE;
                    end
                end
                else begin
                    next_state = RW;
                end
            end

            WRITE: begin
                if (Recive_Data_Valid & Trans_End) begin
                    next_state = FAST_WRITE;
                end
                else if (Recive_Data_Valid) begin
                    next_state = WRITE_PULSE;
                end
                else if (Trans_End) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WRITE;
                end
            end

            FAST_WRITE: begin
                next_state = FAST_WRITE_CPL;
            end

            FAST_WRITE_CPL: begin
                next_state = IDLE;
            end

            WRITE_PULSE: begin
                if (Trans_End) begin
                    next_state = FAST_WRITE_CPL;
                end
                else begin
                    next_state = WRITE;
                end
            end

            READ:begin
                next_state = READ_CPL;
            end

            READ_CPL: begin
                if (Trans_End & spi_send_over_slave) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = READ_CPL;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            Send_Data_Valid <= 1'b0;
            spi_slave_rdfifo_req <= 1'b0;
            spi_slave_wrfifo_data <= 8'h00;
            spi_slave_wrfifo_pulse <= 1'b0;
            spi_slave_receive_cpl <= 1'b0;
            spi_slave_data_length <= 16'h0000;
            spi_read_flag_slave <= 1'b0;
        end
        else begin
            case(current_state)
                IDLE: begin
                    Send_Data_Valid <= 1'b0;
                    spi_slave_rdfifo_req <= 1'b0;
                    spi_slave_wrfifo_data <= 8'h00;
                    spi_slave_wrfifo_pulse <= 1'b0;
                    spi_slave_receive_cpl <= 1'b0;
                    spi_read_flag_slave <= 1'b0;
                end

                RW:;

                WRITE: begin
                    spi_slave_wrfifo_pulse <= 1'b0;
                    if (Recive_Data_Valid) begin
                        spi_slave_wrfifo_data <= Recive_Data;
                    end
                    else if (Trans_End) begin
                        spi_slave_receive_cpl <= 1'b1;
                        spi_slave_data_length <= Trans_Cnt - 16'h0001; 
                    end
                end

                WRITE_PULSE: begin
                    spi_slave_wrfifo_pulse <= 1'b1;
                end

                FAST_WRITE: begin
                    spi_slave_wrfifo_pulse <= 1'b1;
                end

                FAST_WRITE_CPL: begin
                    spi_slave_wrfifo_pulse <= 1'b0;
                    spi_slave_receive_cpl <= 1'b1;
                    spi_slave_data_length <= Trans_Cnt - 16'h0001;
                end

                READ: begin
                    spi_read_flag_slave <= 1'b1;
                    spi_slave_rdfifo_req <= 1'b1;
                    Send_Data_Valid <= 1'b1;
                end

                READ_CPL: begin
                    spi_slave_rdfifo_req <= 1'b0;
                    Send_Data_Valid <= 1'b0;
                end
            endcase
        end
    end

    
endmodule