`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/29 10:37:58
// Design Name: 
// Module Name: User_Param
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module User_Param (
    input clk,
    input reset_n,
    input SPI_CS,
    input SPI_SCLK,
    input SPI_MOSI,
    output SPI_MISO,
    output [7:0] Param0,
    output [7:0] Param1,
    output [7:0] Param2,
    output [7:0] Param3,
    output [7:0] Param4,
    output [7:0] Param5,
    output [7:0] Param6
);

  /*
    对于CDC串口：
    Byte 0~3: 波特率（Baud Rate），DWORD，LSB First
    Byte 4: 停止位数量（Stop Bits）:
            0 = 1位，1 = 1.5位，2 = 2位
    Byte 5: 校验（Parity）:
            0 = None，1 = Odd，2 = Even，3 = Mark，4 = Space
    Byte 6: 数据位（Data Bits），通常为 8
  */
  localparam local_data = {8'h08, 8'h00, 8'h00, 8'h00, 8'h01, 8'hC2, 8'h00};

  reg Send_Data_Valid;
  reg [7:0] Send_Data;
  wire Recive_Data_Valid;
  wire [7:0] Recive_Data;
  wire [15:0] Trans_Cnt;
  wire Trans_Done;
  wire Trans_Start;
  wire Trans_End;



  SPI_Slave #(
      .CPOL(1'b0),
      .CPHA(1'b0),
      .BITS_ORDER(1'b1)
  ) SPI_Slave (
      .Clk(clk),
      .Rst_n(reset_n),
      .Send_Data_Valid(Send_Data_Valid),
      .Send_Data(Send_Data),
      .Recive_Data_Valid(Recive_Data_Valid),
      .Recive_Data(Recive_Data),
      .Trans_Cnt(Trans_Cnt),
      .Trans_Done(Trans_Done),
      .SPI_CS(SPI_CS),
      .SPI_SCK(SPI_SCLK),
      .SPI_MOSI(SPI_MOSI),
      .SPI_MISO(SPI_MISO),
      .Trans_Start(Trans_Start),
      .Trans_End(Trans_End)
  );

  /*当出现Trans_Start时，先接收一个字节，判断bit[7]读(0)/写(1)位，并判断bit[6:0]字节长度len
  如果为写，则读取len个字节参数并存储到寄存器[7:0]Param_Reg[63:0]
  如果为读，且长度为len字节，则从Param_Reg连续读取len个字节，通过MISO发送出去
  */

  reg [7:0] Param_Reg[63:0];
  reg [6:0] len;

  localparam S_IDLE = 7'b0000001;  // 空闲
  localparam S_CMD = 7'b0000010;  // 第一个字节完成，解析
  localparam S_READ_WAIT = 7'b0000100;  // 读等待
  localparam S_READ_REG = 7'b0001000;  // 读
  localparam S_WRITE_WAIT = 7'b0010000;  // 写等待
  localparam S_WRITE_REG = 7'b0100000;  // 写
  localparam S_END = 7'b1000000;  // 结束

  reg [6:0] SM_State;

  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
      SM_State <= S_IDLE;
      len <= 7'd0;
      Send_Data_Valid <= 1'b0;
      Send_Data <= 8'h00;
      Param_Reg[0] <= local_data[7:0];
      Param_Reg[1] <= local_data[15:8];
      Param_Reg[2] <= local_data[23:16];
      Param_Reg[3] <= local_data[31:24];
      Param_Reg[4] <= local_data[39:32];
      Param_Reg[5] <= local_data[47:40];
      Param_Reg[6] <= local_data[55:48];
    end else begin
      case (SM_State)
        S_IDLE: begin
          if (Trans_Start) begin
            SM_State <= S_CMD;
          end else begin
            SM_State <= S_IDLE;
          end
        end
        S_CMD: begin
          if (Recive_Data_Valid) begin
            len <= Recive_Data[6:0];
            if (Recive_Data[7]) begin  //写寄存器
              SM_State <= S_READ_REG;
            end else begin
              SM_State <= S_WRITE_REG;
            end
          end else begin
            SM_State <= S_CMD;
          end
        end
        S_READ_WAIT: begin
          if (Recive_Data_Valid) begin
            if (Trans_Cnt >= len + 1'b1) SM_State <= S_END;
            else SM_State <= S_READ_REG;
          end else begin
            Send_Data_Valid <= 1'b0;
            SM_State <= S_READ_WAIT;
          end

        end
        S_READ_REG: begin
          if (~SPI_SCLK) begin
            Send_Data <= Param_Reg[Trans_Cnt-1];  //读取寄存器数据
            Send_Data_Valid <= 1'b1;
            SM_State <= S_READ_WAIT;
          end else begin
            Send_Data <= Param_Reg[Trans_Cnt-1];  //读取寄存器数据
            Send_Data_Valid <= 1'b0;
          end
        end
        S_WRITE_WAIT: begin
          if (Trans_Cnt >= len + 1'b1) SM_State <= S_END;
          else SM_State <= S_WRITE_REG;
        end
        S_WRITE_REG: begin
          if (Recive_Data_Valid) begin
            Param_Reg[Trans_Cnt-2] <= Recive_Data;
            SM_State <= S_WRITE_WAIT;
          end else begin
            SM_State <= S_WRITE_REG;
          end
        end
        S_END: begin
          len <= 7'd0;
          Send_Data_Valid <= 1'b0;
          Send_Data <= 8'h00;
          SM_State <= S_IDLE;
        end
        default: SM_State <= S_IDLE;
      endcase
    end
  end

  assign Param0 = Param_Reg[0];
  assign Param1 = Param_Reg[1];
  assign Param2 = Param_Reg[2];
  assign Param3 = Param_Reg[3];
  assign Param4 = Param_Reg[4];
  assign Param5 = Param_Reg[5];
  assign Param6 = Param_Reg[6];

endmodule
