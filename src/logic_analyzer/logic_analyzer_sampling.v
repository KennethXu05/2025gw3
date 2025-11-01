module logic_analyzer_sampling (
    input clk,
    input rst_n,

    input trigger,
    input [1:0] trigger_ch,
    input edge_type, // 0: falling, 1: rising
    input [15:0] div_cnt,
    input [11:0] sample_depth,

    input [3:0] data_in,

    output reg wrfifo_pulse,
    output reg [7:0] wrfifo_data0,
    output reg [7:0] wrfifo_data1,
    output reg [7:0] wrfifo_data2,
    output reg [7:0] wrfifo_data3
);

    localparam 
    IDLE = 6'b000001,
    TRIGGER = 6'b000010,
    SAMPLING = 6'b000100,
    SAMPLING_PULSE = 6'b001000,
    SAMPLING_NONEDIV = 6'b010000,
    DONE = 6'b100000;

    reg [ 5:0] current_state;
    reg [ 5:0] next_state;

    reg [15:0] cnt;
    reg [11:0] sample_addr;

    reg [ 3:0] data_in_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_reg <= 4'd0;
        end else begin
            data_in_reg <= data_in;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 16'd0;
        end else if (current_state == SAMPLING || current_state == SAMPLING_PULSE) begin
            if (cnt < div_cnt - 16'd1) begin
                cnt <= cnt + 16'd1;
            end else cnt <= 16'd0;
        end else begin
            cnt <= 16'd0;
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (trigger) begin
                    next_state = TRIGGER;
                end else begin
                    next_state = IDLE;
                end
            end

            TRIGGER: begin
                if ((edge_type & !data_in_reg[trigger_ch] & data_in[trigger_ch]) | (!edge_type & data_in_reg[trigger_ch] & !data_in[trigger_ch])) begin
                    if (div_cnt <= 1) begin
                        next_state = SAMPLING_NONEDIV;
                    end else begin
                        next_state = SAMPLING;
                    end
                end else begin
                    next_state = TRIGGER;
                end
            end

            SAMPLING: begin
                if (cnt == div_cnt - 16'd2) begin
                    next_state = SAMPLING_PULSE;
                end else begin
                    next_state = SAMPLING;
                end
            end

            SAMPLING_PULSE: begin
                if (sample_addr >= sample_depth) begin
                    next_state = DONE;
                end else begin
                    next_state = SAMPLING;
                end
            end

            SAMPLING_NONEDIV: begin
                if (sample_addr >= sample_depth - 12'd1) begin
                    next_state = DONE;
                end else begin
                    next_state = SAMPLING_NONEDIV;
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wrfifo_pulse <= 1'b0;
            wrfifo_data0 <= 8'd0;
            wrfifo_data1 <= 8'd0;
            wrfifo_data2 <= 8'd0;
            wrfifo_data3 <= 8'd0;
            sample_addr  <= 12'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    wrfifo_pulse <= 1'b0;
                    wrfifo_data0 <= 8'd0;
                    wrfifo_data1 <= 8'd0;
                    wrfifo_data2 <= 8'd0;
                    wrfifo_data3 <= 8'd0;
                    sample_addr  <= 12'd0;
                end

                TRIGGER: begin
                    if ((edge_type & !data_in_reg[trigger_ch] & data_in[trigger_ch]) | (!edge_type & data_in_reg[trigger_ch] & !data_in[trigger_ch])) begin
                        sample_addr  <= sample_addr + 12'd1;
                        wrfifo_pulse <= 1'b1;
                        if (data_in[0]) begin
                            wrfifo_data0 <= 8'b11111111;
                        end else begin
                            wrfifo_data0 <= 8'b00000000;
                        end
                        if (data_in[1]) begin
                            wrfifo_data1 <= 8'b11111111;
                        end else begin
                            wrfifo_data1 <= 8'b00000000;
                        end
                        if (data_in[2]) begin
                            wrfifo_data2 <= 8'b11111111;
                        end else begin
                            wrfifo_data2 <= 8'b00000000;
                        end
                        if (data_in[3]) begin
                            wrfifo_data3 <= 8'b11111111;
                        end else begin
                            wrfifo_data3 <= 8'b00000000;
                        end
                    end
                end

                SAMPLING: begin
                    wrfifo_pulse <= 1'b0;
                    if (cnt == div_cnt - 16'd2) begin
                        sample_addr <= sample_addr + 12'd1;
                        if (data_in[0]) begin
                            wrfifo_data0 <= 8'b11111111;
                        end else begin
                            wrfifo_data0 <= 8'b00000000;
                        end
                        if (data_in[1]) begin
                            wrfifo_data1 <= 8'b11111111;
                        end else begin
                            wrfifo_data1 <= 8'b00000000;
                        end
                        if (data_in[2]) begin
                            wrfifo_data2 <= 8'b11111111;
                        end else begin
                            wrfifo_data2 <= 8'b00000000;
                        end
                        if (data_in[3]) begin
                            wrfifo_data3 <= 8'b11111111;
                        end else begin
                            wrfifo_data3 <= 8'b00000000;
                        end
                    end
                end

                SAMPLING_PULSE: begin
                    wrfifo_pulse <= 1'b1;
                end

                SAMPLING_NONEDIV: begin
                    sample_addr  <= sample_addr + 12'd1;
                    wrfifo_pulse <= 1'b1;
                    if (data_in[0]) begin
                        wrfifo_data0 <= 8'b11111111;
                    end else begin
                        wrfifo_data0 <= 8'b00000000;
                    end
                    if (data_in[1]) begin
                        wrfifo_data1 <= 8'b11111111;
                    end else begin
                        wrfifo_data1 <= 8'b00000000;
                    end
                    if (data_in[2]) begin
                        wrfifo_data2 <= 8'b11111111;
                    end else begin
                        wrfifo_data2 <= 8'b00000000;
                    end
                    if (data_in[3]) begin
                        wrfifo_data3 <= 8'b11111111;
                    end else begin
                        wrfifo_data3 <= 8'b00000000;
                    end
                end

                DONE: begin
                    wrfifo_pulse <= 1'b0;
                end
            endcase
        end
    end






endmodule
