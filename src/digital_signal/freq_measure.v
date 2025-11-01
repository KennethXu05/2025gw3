module freq_measure(
    input clk,
    input rst_n,
    input digit_in, 
    output reg [15:0] high_cnt,       //高电平时间（时钟周期数）
    output reg [15:0] low_cnt         //低电平时间（时钟周期数）
);

    reg [15:0] counter;          //16位计数器，用于测量时间
    reg digit_in_prev;           //用于检测边沿的上一状态
    
    //状态定义
    parameter STATE_IDLE = 2'b00;
    parameter STATE_HIGH = 2'b01;
    parameter STATE_LOW  = 2'b10;
    reg [1:0] current_state, next_state;

    //边沿检测
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_in_prev <= 0;
        end 
        else begin
            digit_in_prev <= digit_in;
        end
    end

    wire rising_edge = digit_in && !digit_in_prev;
    wire falling_edge = !digit_in && digit_in_prev;

    //FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
        end 
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            STATE_IDLE: begin
                if (rising_edge)
                    next_state = STATE_HIGH;
                else if (falling_edge)
                    next_state = STATE_LOW;
                else
                    next_state = STATE_IDLE;
            end
            STATE_HIGH: begin
                if (falling_edge)
                    next_state = STATE_LOW;
                else
                    next_state = STATE_HIGH;
            end
            STATE_LOW: begin
                if (rising_edge)
                    next_state = STATE_HIGH;
                else
                    next_state = STATE_LOW;
            end
            default: next_state = STATE_IDLE;
        endcase
    end

    //计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            high_cnt <= 0;
            low_cnt <= 0;
        end 
        else if (counter == 16'hFFFF) begin
            counter <= 0;
            high_cnt <= high_cnt;
            low_cnt <= low_cnt;
        end
        else begin
            case (current_state)
                STATE_HIGH: begin
                    if (falling_edge) begin
                        high_cnt <= counter;
                        counter <= 0;
                    end
                    else
                        counter <= counter + 1'b1;
                end
                STATE_LOW: begin
                    if (rising_edge) begin
                        low_cnt <= counter;
                        counter <= 0;
                    end
                    else
                        counter <= counter + 1'b1;
                end
                STATE_IDLE: begin
                    counter <= 0;
                end
            endcase
        end
    end

endmodule