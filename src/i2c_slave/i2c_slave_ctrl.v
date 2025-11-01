module i2c_slave_ctrl (
    input        clk,
    input        rst_n,

    input        sram_cs,
    input        sram_rw,
    input [7:0]  sram_addr,
    output reg [7:0]  sram_odata,
    input [7:0] sram_idata,
    input        byte_send_done,

    input [7:0] i2c_slave_rdfifo_data,
    input i2c_slave_rdfifo_empty,
    output reg i2c_slave_rdfifo_req,

    output reg [7:0] i2c_slave_wrfifo_data,
    output reg i2c_slave_wrfifo_pulse,
    output reg i2c_slave_receive_cpl,
    output reg [15:0] i2c_slave_data_length      
);

    localparam 
    IDLE = 7'b000_0001,
    READ_WAIT = 7'b000_0010,
    READ = 7'b000_0100,
    WRITE = 7'b000_1000,
    WRITE_ADDR = 7'b001_0000,
    WRITE_DATA = 7'b010_0000,
    WRITE_CPL = 7'b100_0000;

    reg [6:0] current_state;
    reg [6:0] next_state;

    reg [7:0] address;
    reg [7:0] data_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i2c_slave_data_length <= 16'd0;
        end
        else begin
            i2c_slave_data_length <= 16'd2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always@(*) begin
        case (current_state)
            IDLE: begin
                if (!sram_cs) begin
                    if (!sram_rw) begin
                        next_state = WRITE;
                    end else begin
                        next_state = READ_WAIT;
                    end
                end else begin
                    next_state = IDLE;
                end
            end

            READ_WAIT: begin
                if (byte_send_done) begin
                    next_state = READ;
                end else begin
                    next_state = READ_WAIT;
                end
            end

            READ: begin
                next_state = IDLE;
            end

            WRITE: begin
                next_state = WRITE_ADDR;
            end

            WRITE_ADDR: begin
                next_state = WRITE_DATA;
            end

            WRITE_DATA: begin
                next_state = WRITE_CPL;
            end

            WRITE_CPL: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            address <= 8'd0;
            data_in <= 8'd0;
            sram_odata <= 8'd0;
            i2c_slave_rdfifo_req <= 1'b0;
            i2c_slave_wrfifo_data <= 8'd0;
            i2c_slave_wrfifo_pulse <= 1'b0;
            i2c_slave_receive_cpl <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    i2c_slave_rdfifo_req <= 1'b0;
                    i2c_slave_wrfifo_pulse <= 1'b0;
                    i2c_slave_receive_cpl <= 1'b0;
                    sram_odata <= i2c_slave_rdfifo_data;
                end

                READ_WAIT:;

                READ: begin
                    i2c_slave_rdfifo_req <= 1'b1;
                end

                WRITE: begin
                    address <= sram_addr;
                    data_in <= sram_idata;
                end

                WRITE_ADDR: begin
                    i2c_slave_wrfifo_data <= address;
                    i2c_slave_wrfifo_pulse <= 1'b1;
                end

                WRITE_DATA: begin
                    i2c_slave_wrfifo_data <= data_in;
                end

                WRITE_CPL: begin
                    i2c_slave_wrfifo_pulse <= 1'b0;
                    i2c_slave_receive_cpl <= 1'b1;
                end

                default: ;
            endcase
        end
    end
    
endmodule