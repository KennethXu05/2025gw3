module pwm_ctrl (
    input clk,     // 时钟信号
    input reset_n, // 异步复位，低电平有效

    input [7:0] pwm_rdfifo_data,
    input pwm_rdfifo_empty,
    output reg pwm_rdfifo_req,

    output reg pwm_out1,
    output reg pwm_out2,
    output reg pwm_out3
);

    reg [15:0] period1;  // 16位周期寄存器
    reg [15:0] duty1;  // 16位占空比寄存器
    reg [15:0] period2;  // 16位周期寄存器
    reg [15:0] duty2;  // 16位占空比寄
    reg [15:0] period3;  // 16位周期寄存器
    reg [15:0] duty3;  // 16位占空比寄

    wire pwm_out1_pre;
    wire pwm_out2_pre;
    wire pwm_out3_pre;

    pwm_module pwm1 (
        .clk(clk),
        .reset_n(reset_n),
        .period(period1),
        .duty(duty1),
        .pwm_out(pwm_out1_pre)
    );

    pwm_module pwm2 (
        .clk(clk),
        .reset_n(reset_n),
        .period(period2),
        .duty(duty2),
        .pwm_out(pwm_out2_pre)
    );

    pwm_module pwm3 (
        .clk(clk),
        .reset_n(reset_n),
        .period(period3),
        .duty(duty3),
        .pwm_out(pwm_out3_pre)
    );

    reg [2:0]state;

    reg [3:0] message_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_out1 <= 0;
            pwm_out2 <= 0;
            pwm_out3 <= 0;
        end
        else begin
            pwm_out1 <= pwm_out1_pre;
            pwm_out2 <= pwm_out2_pre;
            pwm_out3 <= pwm_out3_pre;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            period1 <= 16'd0;
            duty1 <= 16'd0;  
            period2 <= 16'd0;
            duty2 <= 16'd0;
            period3 <= 16'd0;
            duty3 <= 16'd0;
            message_cnt <= 4'd0;
            pwm_rdfifo_req <= 1'b0;
            state <= 3'b001; 
        end
        else begin
            case (state)
                3'b001: begin
                    if (!pwm_rdfifo_empty) begin
                        pwm_rdfifo_req <= 1'b1;
                        state <= 3'b010;
                    end
                end
                3'b010: begin
                    message_cnt <= message_cnt + 1;
                    case (message_cnt)
                        4'd0:period1[15:8] <= pwm_rdfifo_data; 
                        4'd1:period1[7:0] <= pwm_rdfifo_data;  
                        4'd2:duty1[15:8] <= pwm_rdfifo_data;   
                        4'd3:duty1[7:0] <= pwm_rdfifo_data;    
                        4'd4:period2[15:8] <= pwm_rdfifo_data; 
                        4'd5:period2[7:0] <= pwm_rdfifo_data;  
                        4'd6:duty2[15:8] <= pwm_rdfifo_data;   
                        4'd7:duty2[7:0] <= pwm_rdfifo_data;    
                        4'd8:period3[15:8] <= pwm_rdfifo_data; 
                        4'd9:period3[7:0] <= pwm_rdfifo_data;
                        4'd10:duty3[15:8] <= pwm_rdfifo_data;
                        4'd11:duty3[7:0] <= pwm_rdfifo_data;
                    endcase
                    if (message_cnt == 4'd11) begin
                        message_cnt <= 4'd0;
                        state <= 3'b100;
                    end
                end
                3'b100: begin
                    if (pwm_rdfifo_empty) begin
                        state <= 3'b001;
                        pwm_rdfifo_req <= 1'b0;
                    end
                    else begin
                        pwm_rdfifo_req <= 1'b1;
                    end
                end
                default:;
            endcase
        end
    end


endmodule
