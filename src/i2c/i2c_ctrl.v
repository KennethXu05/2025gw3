module i2c_ctrl (
    input clk,
    input reset,

    output reg [7:0] id,
    output reg addr_mode,
    output reg [15:0] addr,

    output reg i2c_wrreg_req,
    output reg i2c_rdreg_req,
    output reg [7:0] i2c_wrdata,
    input [7:0] i2c_rddata,
    input i2c_rw_done,

    input [7:0] fifowr_data,
    input fifowr_empty,
    output reg fifowr_req,

    output reg [7:0] wrfifo_data,
    output reg wrfifo_pulse,
    output reg wrfifo_over,
    output reg [15:0] wrfifo_length
);

    localparam 
    IDLE = 12'b000000000001, 
    MESSAGE = 12'b000000000010, 
    WRITE = 12'b000000000100, 
    WAIT_WRITE = 12'b000000001000, 
    WRITE_DONE = 12'b000000010000,
    WRITE_IMPOSED = 12'b000000100000,
    READ = 12'b000001000000,
    WAIT_READ = 12'b000010000000,
    READ_WRFIFO = 12'b000100000000,
    READ_WRFIFO_PULSE = 12'b001000000000,
    READ_DONE = 12'b010000000000,
    FIFO_EXAUST = 12'b100000000000;

    reg [11:0] state;
    reg [11:0] next_state;
    reg [2:0] message_cnt;
    reg [15:0] rw_cnt;

    always @(posedge clk or posedge reset)
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end

    always @(*) begin
        case (state)
            IDLE: begin
                if (!fifowr_empty) begin
                    next_state = MESSAGE;
                end else begin
                    next_state = IDLE;
                end
            end

            MESSAGE: begin
                if (message_cnt == 3'd7) begin
                    if (fifowr_data[0]) begin
                        next_state = READ;
                    end else begin
                        next_state = WRITE;
                    end
                end else begin
                    next_state = MESSAGE;
                end
            end

            WRITE: begin
                next_state = WAIT_WRITE;
            end

            WAIT_WRITE: begin
                next_state = WRITE_DONE;
            end

            WRITE_DONE: begin
                if (i2c_rw_done) begin
                    if (rw_cnt == 16'd0) next_state = FIFO_EXAUST;
                    else next_state = WRITE_IMPOSED;
                end else next_state = WRITE_DONE;
            end

            WRITE_IMPOSED: begin
                next_state = WRITE;
            end


            READ: begin
                next_state = WAIT_READ;
            end

            WAIT_READ: begin
                if (i2c_rw_done) next_state = READ_WRFIFO;
                else next_state = WAIT_READ;
            end

            READ_WRFIFO: begin
                next_state = READ_WRFIFO_PULSE;
            end

            READ_WRFIFO_PULSE: begin
                next_state = READ_DONE;
            end

            READ_DONE: begin
                if (rw_cnt == 16'd0) next_state = FIFO_EXAUST;
                else next_state = READ;
            end

            FIFO_EXAUST: begin
                if(fifowr_empty) next_state = IDLE;
                else next_state = FIFO_EXAUST;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset)
        if (reset) begin
            i2c_wrreg_req <= 1'b0;
            i2c_rdreg_req <= 1'b0;
            i2c_wrdata <= 8'd0;
            fifowr_req <= 1'b0;
            wrfifo_data <= 8'd0;
            wrfifo_pulse <= 1'b0;
            wrfifo_over <= 1'b0;
            wrfifo_length <= 16'd0;
            id <= 8'd0;
            addr_mode <= 1'b0;
            addr <= 16'd0;
            message_cnt <= 3'd0;
            rw_cnt <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    fifowr_req   <= 1'b0;

                    wrfifo_pulse <= 1'b0;
                    wrfifo_over  <= 1'b0;
                end

                MESSAGE: begin
                    case (message_cnt)
                        3'd0: begin
                            fifowr_req <= 1'b1;
                            message_cnt <= 3'd1;
                        end
                        3'd1: begin
                            id <= fifowr_data;
                            message_cnt <= 3'd2;
                        end
                        3'd2: begin
                            addr_mode   <= fifowr_data[0];
                            message_cnt <= 3'd3;
                        end
                        3'd3: begin
                            addr[15:8]  <= fifowr_data;
                            message_cnt <= 3'd4;
                        end
                        3'd4: begin
                            addr[7:0]   <= fifowr_data;
                            message_cnt <= 3'd5;
                        end
                        3'd5: begin
                            wrfifo_length[15:8] <= fifowr_data;
                            message_cnt <= 3'd6;
                        end
                        3'd6: begin
                            wrfifo_length[7:0] <= fifowr_data;
                            message_cnt <= 3'd7;
                        end
                        3'd7: begin
                            rw_cnt <= wrfifo_length;
                            message_cnt <= 3'd0;
                            fifowr_req <= 1'b0;
                        end
                    endcase
                end

                WRITE: begin
                    fifowr_req <= 1'b1;
                end

                WAIT_WRITE: begin
                    fifowr_req <= 1'b0;
                    i2c_wrdata <= fifowr_data;
                    i2c_wrreg_req <= 1'b1;
                    rw_cnt <= rw_cnt - 16'd1;
                end

                WRITE_DONE: begin
                    i2c_wrreg_req <= 1'b0;
                end

                WRITE_IMPOSED: begin
                    addr <= addr + 16'd1;
                end

                READ: begin
                    i2c_rdreg_req <= 1'b1;
                    rw_cnt <= rw_cnt - 16'd1;
                end

                WAIT_READ: begin
                    i2c_rdreg_req <= 1'b0;
                end

                READ_WRFIFO: begin
                    wrfifo_data <= i2c_rddata;
                end

                READ_WRFIFO_PULSE: begin
                    wrfifo_pulse <= 1'b1;
                end

                READ_DONE: begin
                    wrfifo_pulse <= 1'b0;
                    if (rw_cnt == 16'd0) begin
                        wrfifo_over <= 1'b1;
                    end
                    else begin
                        addr <= addr + 16'd1;
                    end
                end

                FIFO_EXAUST: begin
                    wrfifo_over <= 1'b0;
                    if(fifowr_empty) begin
                        fifowr_req <= 1'b0;
                    end
                    else begin
                        fifowr_req <= 1'b1;
                    end
                end

                default: ;
            endcase
        end

endmodule
