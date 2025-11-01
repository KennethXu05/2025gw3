`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 15:56:12
// Design Name: 
// Module Name: byte_tx_control
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


module byte_tx_control(
    input clk,
    input rst_n,
    input tx_fifo_empty,
    input byte_tx_done,
    output reg tx_fifo_pop,
    output reg byte_send_en
);

  //状态机控制，当tx_fifo非空时，读取其内容，写入发送模块，直到发送完成，继续发送下一个数据
  reg [2:0] SM_TX_State;
  localparam S_TX_IDLE = 3'b001;
  localparam S_TX_SEND = 3'b010;
  localparam S_TX_WAIT = 3'b100;


  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      SM_TX_State  <= S_TX_IDLE;
      tx_fifo_pop  <= 1'b0;
      byte_send_en <= 1'b0;
    end else begin
      case (SM_TX_State)
        S_TX_IDLE: begin
          if (~tx_fifo_empty) begin
            SM_TX_State <= S_TX_SEND;
          end else begin
            SM_TX_State <= S_TX_IDLE;
          end
        end
        S_TX_SEND: begin
          if (~tx_fifo_empty) begin
            tx_fifo_pop  <= 1'b1;
            byte_send_en <= 1'b1;
            SM_TX_State  <= S_TX_WAIT;
          end else begin
            SM_TX_State <= S_TX_IDLE;
          end
        end
        S_TX_WAIT: begin
          tx_fifo_pop  <= 1'b0;
          byte_send_en <= 1'b0;
          if (byte_tx_done) begin
            SM_TX_State <= S_TX_SEND;
          end else begin
            SM_TX_State <= S_TX_WAIT;
          end
        end
        default: SM_TX_State <= S_TX_IDLE;
      endcase
    end
  end



endmodule
