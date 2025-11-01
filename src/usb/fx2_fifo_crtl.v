`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 09:02:04
// Design Name: 
// Module Name: fx2_fifo_crtl
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


module fx2_fifo_crtl (
    input fx2_ifclk,
    input reset_n,
    input fx2_flagb,  // FX2型USB2.0芯片的端点2 OUT空标志，1为非空，0为空
    input fx2_flagc,  // FX2型USB2.0芯片的端点6 IN满标志，1为非满，0为满
    output reg [1:0] fx2_faddr,  // FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    output reg fx2_sloe,  // FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
    output reg fx2_slwr,  // FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    output reg fx2_slrd,  // FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效

    input rx_fifo_empty,
    input rx_fifo_full,
    input tx_fifo_full,

    output reg tx_fifo_push,
    output reg rx_fifo_pop,
    output fx2_pkt_end
);

  /*
    这个状态机，只负责内部fifo和usb fifo接口的数据交互

    内部rx fifo不满且usb的out fifo非空，则读取数据到内部
    否则不做读取

    内部tx fifo非空且usb的in fifo非满，则写数据到usb的in fifo中
    内部tx fifo满则强制切换为写数据状态，将fifo数据写入usb的in fifo中，直到把内部fifo写空或者将in fifo写满
  
  */
  reg [3:0] SM_State;
  localparam S_IDLE = 4'b0001;
  localparam S_READ = 4'b0010;
  localparam S_WRITE_WAIT = 4'b0100;
  localparam S_WRITE = 4'b1000;

  reg [3:0] delay_cnt;

  always @(posedge fx2_ifclk or negedge reset_n) begin
    if (~reset_n) begin
      delay_cnt <= 4'd0;
    end else if (SM_State == S_IDLE) begin
      if (delay_cnt >= 4'd8) begin
        delay_cnt <= 4'd8;
      end else begin
        delay_cnt <= delay_cnt + 4'd1;
      end
    end else begin
      delay_cnt <= 4'd0;
    end
  end

  always @(posedge fx2_ifclk or negedge reset_n) begin
    if (~reset_n) begin
      SM_State <= S_IDLE;
    end else begin
      case (SM_State)
        S_IDLE: begin
          if (delay_cnt < 4'd8) begin
            SM_State <= S_IDLE;
          end else if (~rx_fifo_empty) begin  // 内部rx fifo有数据，写入usb的in fifo中
            SM_State <= S_WRITE_WAIT;
          end else if ((~tx_fifo_full) && (fx2_flagb)) begin // 内部tx fifo没满，且usb的out fifo有数据，准备接收usb的数据
            SM_State <= S_READ;
          end else begin
            SM_State <= S_IDLE;
          end
        end
        S_READ: begin
          if (rx_fifo_full) begin  // 如果内部rx fifo满了则切换到写
            SM_State <= S_WRITE_WAIT;
          end else if((~fx2_flagb) || (tx_fifo_full)) begin // 内部tx fifo满了或者usb的out fifo空了，结束读取
            SM_State <= S_IDLE;
          end else begin
            SM_State <= S_READ;
          end
        end
        S_WRITE_WAIT: begin
          if (fx2_flagc) begin
            SM_State <= S_WRITE;
          end else if(rx_fifo_full) begin // 因为fifo满了所以急切地要将rx fifo数据通过usb的in fifo发送出去，在此期间不再接收usb数据
            SM_State <= S_WRITE_WAIT;
          end else begin  // 内部rx_fifo非满，且usb的in fifo满了，回到idle
            SM_State <= S_IDLE;
          end
        end
        S_WRITE: begin
          if ((~fx2_flagc) || (rx_fifo_empty)) begin  // 内部rx_fifo写空，或者usb的in fifo写满，退出写状态
            SM_State <= S_IDLE;
          end else begin
            SM_State <= S_WRITE;
          end
        end
        default: SM_State <= S_IDLE;
      endcase

    end
  end


  always @(*) begin
    if (((SM_State == S_IDLE) && (delay_cnt >= 4'd3)) || (SM_State == S_READ)) begin
      fx2_faddr = 2'b00;
    end else begin
      fx2_faddr = 2'b10;
    end
  end

  // USB接收的数据，进入tx_fifo，后续uart/spi模块取出tx_fifo内的数据，发送出去
  always @(*) begin
    if (((~tx_fifo_full)) && (fx2_flagb == 1'b1) && (SM_State == S_READ)) begin
      fx2_slrd     = 1'b0;
      fx2_sloe     = 1'b0;
      tx_fifo_push = 1'b1;
    end else begin
      fx2_slrd     = 1'b1;
      fx2_sloe     = 1'b1;
      tx_fifo_push = 1'b0;
    end
  end

  // uart/spi模块接收的数据，进入rx_fifo，后续取出rx_fifo内的数据，写入usb的in fifo发送出去
  always @(*) begin
    if (((~rx_fifo_empty)) && (fx2_flagc == 1'b1) && (SM_State == S_WRITE)) begin
      fx2_slwr    = 1'b0;
      rx_fifo_pop = 1'b1;
    end else begin
      fx2_slwr    = 1'b1;
      rx_fifo_pop = 1'b0;
    end
  end

  assign fx2_pkt_end = ((SM_State == S_IDLE) && (delay_cnt < 4'd3)) ? 1'b0 : 1'b1;




endmodule
