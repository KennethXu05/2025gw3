module usb_ethernet_ctrl (
    input clk,
    input rst_n,
    
    input [7:0]rdfifo_data,
    input rdfifo_empty,
    output reg rdfifo_req,

    output reg [7:0]wrfifo_data,
    output reg wrfifo_pulse,
    output reg wrfifo_over,
    output reg [15:0]wrfifo_data_length
);

    localparam 
    IDLE = 5'b00001,
    READ = 5'b00010,
    WRITE_WAIT = 5'b00100,
    WRITE= 5'b01000,
    OVER = 5'b10000;

    reg [4:0]current_state;
    reg [4:0]next_state;

    reg [15:0]data_length_cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE: begin
                if(!rdfifo_empty)
                    next_state = READ;
                else
                    next_state = IDLE;
            end
            READ: begin
                next_state = WRITE_WAIT;
            end
            WRITE_WAIT: begin
                next_state = WRITE;
            end
            WRITE: begin
                if (rdfifo_empty) begin
                    next_state = OVER;
                end
                else begin
                    next_state = READ;
                end
            end
            OVER: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdfifo_req <= 1'b0;
            wrfifo_data <= 8'b0;
            wrfifo_pulse <= 1'b0;
            wrfifo_over <= 1'b0;
            wrfifo_data_length <= 16'b0;
            data_length_cnt <= 16'b0;
        end
        else begin
            case(current_state)
                IDLE: begin
                    rdfifo_req <= 1'b0;
                    wrfifo_data <= 8'b0;
                    wrfifo_pulse <= 1'b0;
                    wrfifo_over <= 1'b0;
                    data_length_cnt <= 16'b0;
                end
                READ: begin
                    rdfifo_req <= 1'b1;
                    wrfifo_pulse <= 1'b0;
                end
                WRITE_WAIT: begin
                    rdfifo_req <= 1'b0;
                    wrfifo_data <= rdfifo_data;
                end
                WRITE: begin
                    wrfifo_pulse <= 1'b1;
                    data_length_cnt <= data_length_cnt + 1'b1;
                end
                OVER: begin
                    wrfifo_pulse <= 1'b0;
                    wrfifo_over <= 1'b1;
                    wrfifo_data_length <= data_length_cnt;
                end
                default: begin
                    rdfifo_req <= 1'b0;
                    wrfifo_data <= 8'b0;
                    wrfifo_pulse <= 1'b0;
                    wrfifo_over <= 1'b0;
                    wrfifo_data_length <= 16'b0;
                end
            endcase
        end
    end

endmodule