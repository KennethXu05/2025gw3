module spwm_module (
    input clk,
    input rst_n,
    input refresh,

    input [15:0] cycle,
    input [9:0] phase_sin,
    input [5:0] phase_tri,

    output reg spwm_out
);

    reg [15:0] cycle_reg;

    reg [15:0] cnt;
    reg [ 9:0] addr_sin;
    reg [ 5:0] addr_tri;

    wire [9:0] data_sin;
    wire [9:0] data_tri;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_reg <= 16'd0;
        end else if (refresh) begin
            cycle_reg <= cycle;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 16'd0;
        end else if (cnt >= cycle_reg - 1) begin
            cnt <= 16'd0;
        end else begin
            cnt <= cnt + 16'd1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_sin <= 10'd0;
        end else if (refresh) begin
            addr_sin <= phase_sin;
        end else if (cnt == cycle_reg - 1) begin
            addr_sin <= addr_sin + 10'd1;
        end else if (addr_sin == 10'd999) begin
            addr_sin <= 10'd0;
        end else begin
            addr_sin <= addr_sin;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_tri <= 6'd0;
        end else if (refresh) begin
            addr_tri <= phase_tri;
        end else if (cnt == cycle_reg - 1) begin
            addr_tri <= addr_tri + 6'd1;
        end else if (addr_tri == 6'd49) begin
            addr_tri <= 6'd0;
        end else begin
            addr_tri <= addr_tri;
        end
    end
    
    Gowin_pROM_spwm_sin spwm_sin(
        .dout(data_sin), //output [9:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(!rst_n), //input reset
        .ad(addr_sin) //input [9:0] ad
    );

    Gowin_pROM_spwm_tri spwm_tri(
        .dout(data_tri), //output [9:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(!rst_n), //input reset
        .ad(addr_tri) //input [5:0] ad
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spwm_out <= 1'b0;
        end else if (data_tri < data_sin) begin
            spwm_out <= 1'b1;
        end else begin
            spwm_out <= 1'b0;
        end
    end


endmodule