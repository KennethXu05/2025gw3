module spwm_ctrl (
    input clk,     // 时钟信号
    input reset_n, // 异步复位，低电平有效

    input [7:0] spwm_rdfifo_data,
    input spwm_rdfifo_empty,
    output reg spwm_rdfifo_req,

    output reg spwm_out1,
    output reg spwm_out2,
    output reg spwm_out3
);

    reg [15:0] cycle1;
    reg [ 9:0] phase_sin1;
    reg [ 9:0] phase_tri1;
    reg [15:0] cycle2;
    reg [ 9:0] phase_sin2;
    reg [ 9:0] phase_tri2;
    reg [15:0] cycle3;
    reg [ 9:0] phase_sin3;
    reg [ 9:0] phase_tri3;

    reg refresh;

    wire spwm_out1_pre;
    wire spwm_out2_pre;
    wire spwm_out3_pre;


    reg [4:0]state;

    reg [3:0] message_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            spwm_out1 <= 0;
            spwm_out2 <= 0;
            spwm_out3 <= 0;
        end
        else begin
            spwm_out1 <= spwm_out1_pre;
            spwm_out2 <= spwm_out2_pre;
            spwm_out3 <= spwm_out3_pre;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            refresh <= 1'b0;
            cycle1 <= 16'd0;
            phase_sin1 <= 10'd0;
            phase_tri1 <= 10'd0;
            cycle2 <= 16'd0;
            phase_sin2 <= 10'd0;
            phase_tri2 <= 10'd0;
            cycle3 <= 16'd0;
            phase_sin3 <= 10'd0;
            phase_tri3 <= 10'd0;
            message_cnt <= 4'd0;
            spwm_rdfifo_req <= 1'b0;
            state <= 5'b00001; 
        end
        else begin
            case (state)
                5'b00001: begin
                    if (!spwm_rdfifo_empty) begin
                        spwm_rdfifo_req <= 1'b1;
                        state <= 5'b00010;
                    end
                end

                5'b00010: begin
                    message_cnt <= message_cnt + 1;
                    case (message_cnt)
                        4'd0:cycle1[15:8] <= spwm_rdfifo_data; 
                        4'd1:cycle1[7:0] <= spwm_rdfifo_data;  
                        4'd2:begin
                            phase_sin1[9:8] <= spwm_rdfifo_data[1:0];
                            phase_tri1[9:8] <= spwm_rdfifo_data[1:0];
                        end   
                        4'd3:begin
                            phase_sin1[7:0] <= spwm_rdfifo_data;
                            phase_tri1[7:0] <= spwm_rdfifo_data;    
                        end
                        4'd4:cycle2[15:8] <= spwm_rdfifo_data; 
                        4'd5:cycle2[7:0] <= spwm_rdfifo_data;  
                        4'd6:begin
                            phase_sin2[9:8] <= spwm_rdfifo_data[1:0];
                            phase_tri2[9:8] <= spwm_rdfifo_data[1:0];
                        end   
                        4'd7:begin
                            phase_sin2[7:0] <= spwm_rdfifo_data;
                            phase_tri2[7:0] <= spwm_rdfifo_data;    
                        end    
                        4'd8:cycle3[15:8] <= spwm_rdfifo_data; 
                        4'd9:cycle3[7:0] <= spwm_rdfifo_data;
                        4'd10:begin
                            phase_sin3[9:8] <= spwm_rdfifo_data[1:0];
                            phase_tri3[9:8] <= spwm_rdfifo_data[1:0];
                        end
                        4'd11:begin
                            phase_sin3[7:0] <= spwm_rdfifo_data;
                            phase_tri3[7:0] <= spwm_rdfifo_data;    
                        end
                    endcase
                    if (message_cnt == 4'd11) begin
                        message_cnt <= 4'd0;
                        state <= 5'b00100;
                    end
                end

                5'b00100:begin
                    spwm_rdfifo_req <= 1'b0;
                    if (phase_tri1 >= 10'd50) begin
                        phase_tri1 <= phase_tri1 - 10'd50;
                    end
                    else if (phase_tri2 >= 10'd50) begin
                        phase_tri2 <= phase_tri2 - 10'd50;
                    end
                    else if (phase_tri3 >= 10'd50) begin
                        phase_tri3 <= phase_tri3 - 10'd50;
                    end
                    else begin
                        refresh <= 1'b1;
                        state <= 5'b01000;
                    end
                end

                5'b01000: begin
                    refresh <= 1'b0;
                    state <= 5'b10000;
                end

                5'b10000: begin
                    if (spwm_rdfifo_empty) begin
                        state <= 5'b00001;
                        spwm_rdfifo_req <= 1'b0;
                    end
                    else begin
                        spwm_rdfifo_req <= 1'b1;
                    end
                end
                default:;
            endcase
        end
    end

    spwm_module spwm1 (
        .clk(clk),
        .rst_n(reset_n),
        .cycle(cycle1),
        .phase_sin(phase_sin1),
        .phase_tri(phase_tri1[5:0]),
        .refresh(refresh),
        .spwm_out(spwm_out1_pre)
    );

    spwm_module spwm2 (
        .clk(clk),
        .rst_n(reset_n),
        .cycle(cycle2),
        .phase_sin(phase_sin2),
        .phase_tri(phase_tri2[5:0]),
        .refresh(refresh),
        .spwm_out(spwm_out2_pre)
    );

    spwm_module spwm3 (
        .clk(clk),
        .rst_n(reset_n),
        .cycle(cycle3),
        .phase_sin(phase_sin3),
        .phase_tri(phase_tri3[5:0]),
        .refresh(refresh),
        .spwm_out(spwm_out3_pre)
    );


endmodule