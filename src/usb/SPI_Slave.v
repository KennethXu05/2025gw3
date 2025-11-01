`timescale 1ns / 1ps

module SPI_Slave # 
(
    parameter integer CPOL = 1'b0,         //空闲时SCK电平：1为高，0为低
    parameter integer CPHA = 1'b1,         //数据捕获边沿：0为第一个边沿，1为第2个边沿
    parameter integer BITS_ORDER = 1'b1    //数据传输位序：1为高位在前，0为低位在前
)
(
    input Clk,
    input Rst_n,
    input Send_Data_Valid,
    input [7:0]Send_Data,
    output reg Recive_Data_Valid,
    output reg [7:0]Recive_Data,
    output reg [15:0]Trans_Cnt,
    output reg Trans_Done,
    input SPI_CS,
    input SPI_SCK, 
    input SPI_MOSI,
    output SPI_MISO,
    output Trans_Start,
    output Trans_End
);

wire SPI_Reset;
reg MISO;
reg [7:0]Recive;
wire SCK_Sel;
reg [7:0] Out_Cnt;
reg [7:0] In_Cnt;
reg [7:0]Send_Data_R;

assign SPI_MISO = SPI_CS ? 1'b0 : ((Out_Cnt | CPHA) ? MISO : Send_Data_R[7]);

reg Done_R1,Done_R2;
//对Trans_Done信号打拍，取上升沿
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n) begin
        Done_R1 <= 8'h00;
        Done_R2 <= 8'h00;
    end
    else begin
        Done_R1 <= Trans_Done;
        Done_R2 <= Done_R1;
    end
end


wire Done_POS;
assign Done_POS = (~Done_R2) & Done_R1;
reg CS_R1,CS_R2;
//对CS信号打拍，取下降沿
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n) begin
        CS_R1 <= 8'h00;
        CS_R2 <= 8'h00;
    end
    else begin
        CS_R1 <= SPI_CS;
        CS_R2 <= CS_R1;
    end
end

assign Trans_Start = (~CS_R1) & CS_R2;
assign Trans_End = (~CS_R2) & CS_R1;

//数据有效标志信号
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n)
        Recive_Data_Valid <= 1'b0;
    else if(Done_POS)
        Recive_Data_Valid <= 1'b1;
    else
        Recive_Data_Valid <= 1'b0;
end


//寄存发送的数据，防止发送途中被修改
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n)
        Send_Data_R <= 8'h00;
    else if(Send_Data_Valid) begin
        if(BITS_ORDER == 1'b1)
            Send_Data_R <= Send_Data;
        else
            Send_Data_R <= {Send_Data[0],Send_Data[1],Send_Data[2],Send_Data[3],Send_Data[4],Send_Data[5],Send_Data[6],Send_Data[7]};
    end
    else
        Send_Data_R <= Send_Data_R;
end

//接收数据
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n)
        Recive_Data <= 8'h00;
    else if(Done_POS) begin
        if(BITS_ORDER == 1'b1)
            Recive_Data <= Recive;
        else
            Recive_Data <= {Recive[0],Recive[1],Recive[2],Recive[3],Recive[4],Recive[5],Recive[6],Recive[7]};
    end
    else
        Recive_Data <= Recive_Data;
end

/*********************************************************************| 
*    | SPI Mode | CPOL | CPHA | Shift Sclk edge   | Capture Sclk edge | 
*    | 0        | 0    | 0    | Falling (negedge) | Rising (posedge)  | 
*    | 1        | 0    | 1    | Rising (posedge)  | Falling (negedge) | 
*    | 2        | 1    | 0    | Rising (posedge)  | Falling (negedge) | 
*    | 3        | 1    | 1    | Falling (negedge) | Rising (posedge)  | 
**********************************************************************/ 
assign SCK_Sel = (CPOL ^ CPHA) ? (SPI_SCK) : (~SPI_SCK);
assign SPI_Reset = (~Rst_n) | SPI_CS;
//状态机加线性序列机控制MISO
always@(posedge SCK_Sel or posedge SPI_Reset)
begin
    if(SPI_Reset) begin
        Out_Cnt <= 8'd0;
    end
    else begin
        case (Out_Cnt)
            8'd0: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[6+CPHA]; end
            8'd1: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[5+CPHA]; end
            8'd2: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[4+CPHA]; end
            8'd3: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[3+CPHA]; end
            8'd4: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[2+CPHA]; end
            8'd5: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[1+CPHA]; end
            8'd6: begin Out_Cnt <= Out_Cnt + 1'b1; MISO <= Send_Data_R[0+CPHA]; end
            8'd7: begin Out_Cnt <= 8'd0; MISO <= Send_Data_R[0]; end
            default: Out_Cnt <= 8'd0;
        endcase
    end
end

//状态机加线性序列机采集MOSI
always@(negedge SCK_Sel or posedge SPI_Reset)
begin
    if(SPI_Reset) begin
        In_Cnt <= 8'd0;
        Recive <= 8'h00;
        Trans_Done <= 1'b0;
        Trans_Cnt <= 8'h00;
    end
    else begin
        case (In_Cnt)
            8'd0: begin In_Cnt <= In_Cnt + 1'b1; Recive[7] <= SPI_MOSI; Trans_Done <= 1'b0; end
            8'd1: begin In_Cnt <= In_Cnt + 1'b1; Recive[6] <= SPI_MOSI; end
            8'd2: begin In_Cnt <= In_Cnt + 1'b1; Recive[5] <= SPI_MOSI; end
            8'd3: begin In_Cnt <= In_Cnt + 1'b1; Recive[4] <= SPI_MOSI; end
            8'd4: begin In_Cnt <= In_Cnt + 1'b1; Recive[3] <= SPI_MOSI; end
            8'd5: begin In_Cnt <= In_Cnt + 1'b1; Recive[2] <= SPI_MOSI; end
            8'd6: begin In_Cnt <= In_Cnt + 1'b1; Recive[1] <= SPI_MOSI; end
            8'd7: begin In_Cnt <= 8'd0;  Recive[0] <= SPI_MOSI; Trans_Done <= 1'b1; Trans_Cnt <= Trans_Cnt + 1'b1; end
            default: In_Cnt <= 8'd0;
        endcase
    end
end


endmodule
