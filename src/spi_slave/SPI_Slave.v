`timescale 1ns / 1ps

module spi_slave # 
(
    parameter integer CPOL = 1'b0,         //����ʱSCK��ƽ��1Ϊ�ߣ�0Ϊ��
    parameter integer CPHA = 1'b0,         //���ݲ�����أ�0Ϊ��һ�����أ�1Ϊ��2������
    parameter integer BITS_ORDER = 1'b1    //���ݴ���λ��1Ϊ��λ��ǰ��0Ϊ��λ��ǰ
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
    output Trans_End,

    output reg spi_send_over_slave,
    input  spi_read_flag_slave
);

wire SPI_Reset;
reg MISO;
reg [7:0]Recive;
reg [7:0]Recive_r;
reg [15:0]Trans_Cnt_pp;
reg [15:0]Trans_Cnt_p;
wire SCK_Sel;
reg [7:0] Out_Cnt;
reg [7:0] In_Cnt;
reg [7:0]Send_Data_R;

assign SPI_MISO = SPI_CS ? 1'b0 : ((Out_Cnt | CPHA) ? MISO : Send_Data_R[7]);

reg Done_R1,Done_R2;
//��Trans_Done�źŴ��ģ�ȡ������
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n) begin
        Done_R1 <= 1'b0;
        Done_R2 <= 1'b0;
    end
    else begin
        Done_R1 <= Trans_Done;
        Done_R2 <= Done_R1;
    end
end


wire Done_POS;
assign Done_POS = (~Done_R2) & Done_R1;
reg CS_R1,CS_R2;
//��CS�źŴ��ģ�ȡ�½���
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n) begin
        CS_R1 <= 1'b1;
        CS_R2 <= 1'b1;
    end
    else begin
        CS_R1 <= SPI_CS;
        CS_R2 <= CS_R1;
    end
end

assign Trans_Start = (~CS_R1) & CS_R2;
assign Trans_End = (~CS_R2) & CS_R1;

//������Ч��־�ź�
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n)
        Recive_Data_Valid <= 1'b0;
    else if(Done_POS)
        Recive_Data_Valid <= 1'b1;
    else
        Recive_Data_Valid <= 1'b0;
end


//�Ĵ淢�͵����ݣ���ֹ����;�б��޸�
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

always @(posedge Clk or negedge Rst_n) begin
    if (!Rst_n) begin
        Recive_r <= 8'h00;
    end
    else begin
        Recive_r <= Recive;
    end
end

//��������
always@(posedge Clk or negedge Rst_n)
begin
    if(!Rst_n)
        Recive_Data <= 8'h00;
    else if(Done_POS) begin
        if(BITS_ORDER == 1'b1)
            Recive_Data <= Recive_r;
        else
            Recive_Data <= {Recive_r[0],Recive_r[1],Recive_r[2],Recive_r[3],Recive_r[4],Recive_r[5],Recive_r[6],Recive_r[7]};
    end
    else
        Recive_Data <= Recive_Data;
end

always @(posedge Clk or negedge Rst_n) begin
    if (!Rst_n) begin
        Trans_Cnt_p <= 16'h0000;
    end
    else begin
        Trans_Cnt_p <= Trans_Cnt_pp;
    end
end

always @(posedge Clk or negedge Rst_n) begin
    if (!Rst_n) begin
        Trans_Cnt <= 16'h0000;
    end
    else if (Done_POS) begin
        Trans_Cnt <= Trans_Cnt_p;
    end
    else begin
        Trans_Cnt <= Trans_Cnt;
    end
end

always@(posedge Clk or negedge Rst_n) begin
    if (!Rst_n) begin
        spi_send_over_slave <= 1'b1;
    end
    else if(Trans_Start) begin
        spi_send_over_slave <= 1'b0;
    end
    else if(Out_Cnt == 8'd1 & spi_read_flag_slave) begin
        spi_send_over_slave <= 1'b1;
    end
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
//״̬�����������л�����MISO
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
            8'd7: begin Out_Cnt <= 8'd0; MISO <= Send_Data_R[0];end
            default: Out_Cnt <= 8'd0;
        endcase
    end
end

//״̬�����������л��ɼ�MOSI
always@(negedge SCK_Sel or posedge SPI_Reset)
begin
    if(SPI_Reset) begin
        In_Cnt <= 8'd0;
        Recive <= 8'h00;
        Trans_Done <= 1'b0;
        Trans_Cnt_pp <= 8'h00;
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
            8'd7: begin In_Cnt <= 8'd0;  Recive[0] <= SPI_MOSI; Trans_Done <= 1'b1; Trans_Cnt_pp <= Trans_Cnt_pp + 1'b1; end
            default: In_Cnt <= 8'd0;
        endcase
    end
end


endmodule
