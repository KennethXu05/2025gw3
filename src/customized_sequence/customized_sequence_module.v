module customized_sequence_module (
    input  clk,
    input  rst_n,

    input [7:0] length,
    input [7:0] cycle,
    input [255:0] data,
    input refresh,

    output reg seq
);

    reg [7:0] cnt;
    reg [7:0] cycle_cnt;
    reg [255:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd0;
            cycle_cnt <= 8'd0;
            data_reg <= 256'd0;
            seq <= 1'b0;
        end else if (refresh) begin
            cnt <= 8'd0;
            cycle_cnt <= 8'd0;
            data_reg <= data;
            seq <= data[0];
        end else if (cycle_cnt == cycle - 1) begin
            cycle_cnt <= 8'd0;
            if (cnt < length - 1) begin
                cnt <= cnt + 1;
                seq <= data_reg[cnt + 1];
            end else begin
                cnt <= 8'd0;
                seq <= data_reg[0];
            end
        end else begin
            cycle_cnt <= cycle_cnt + 1;
        end
    end
    
endmodule