module pwm_module (
    input wire clk,          // 时钟信号
    input wire reset_n,      // 异步复位，低电平有效
    input wire [15:0] period,  // 周期控制，决定PWM频率
    input wire [15:0] duty,    // 占空比控制
    output reg pwm_out       // PWM输出
);

    reg [15:0] counter;  // 16位计数器
    
    // 计数器逻辑
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
        end else begin
            if (counter >= period - 1)  // 计数到周期值后归零
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

    // PWM输出逻辑
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_out <= 0;
        end else begin
            if (duty == 0)  // 占空比为0时，始终输出低电平
                pwm_out <= 0;
            else if (duty >= period)  // 占空比大于等于周期时，始终输出高电平
                pwm_out <= 1;
            else
                pwm_out <= (counter < duty);
        end
    end

endmodule
