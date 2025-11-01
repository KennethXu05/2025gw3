module can_top(
    reset_n,
    clk,
    can_rx,
    can_tx,
    tx_valid,
    tx_data,
    tx_fifo_empty,
    rx_valid,
    rx_last,
    rx_data,
    rx_data_lenth
);
    input        reset_n;
    input        clk;
    input        can_rx;
    output       can_tx;
    output        tx_valid;
    input  [7:0] tx_data;
    input tx_fifo_empty;
    output       rx_valid;
    output       rx_last;
    output [7:0] rx_data;
    output [15:0]rx_data_lenth;
    wire [31:0] Q;
    wire tx_ready;
    wire Empty;
    wire Full;
    wire [31:0]Q_tx;
    reg can_tx_data_valid;
    assign Q_tx={Q[7:0],Q[15:8],Q[23:16],Q[31:24]};

    reg [1:0]rd_fifo_state;

    reg [3:0]rd_fifo_cnt;
// 状态机：00=空闲，01=计数延时（FIFO非空时计数到255），10=开始读FIFO
always @(posedge clk or negedge reset_n) begin
  if (!reset_n)
    rd_fifo_state <= 2'b00;  // 复位后进入空闲
  else case (rd_fifo_state)
    2'b00: begin
      // 空闲状态：FIFO非空时，进入计数延时状态
      if (!tx_fifo_empty)
        rd_fifo_state <= 2'b01;
      else
        rd_fifo_state <= 2'b00;
    end
    2'b01: begin
      // 计数延时状态：计数到255后，进入读状态；若FIFO变空，回到空闲
      if (rd_fifo_cnt >= 4'hf)  // 计数满15，结束延时
        rd_fifo_state <= 2'b10;
      else if (tx_fifo_empty)  // 计数中途FIFO空，放弃延时
        rd_fifo_state <= 2'b00;
      else
        rd_fifo_state <= 2'b01;  // 继续计数
    end
    2'b10: begin
      // 读状态：FIFO空时结束读，回到空闲；否则持续读
      if (tx_fifo_empty)
        rd_fifo_state <= 2'b00;
      else
        rd_fifo_state <= 2'b10;  // 保持读状态
    end
    default: rd_fifo_state <= 2'b00;
  endcase
end

// 计数逻辑：仅在计数延时状态（01）时递增，其他状态清零
always @(posedge clk or negedge reset_n) begin
  if (!reset_n)
    rd_fifo_cnt <= 4'h0;
  else if (rd_fifo_state == 2'b01) begin  // 计数延时阶段
    if (rd_fifo_cnt >= 4'hf)
      rd_fifo_cnt <= 4'hf;  // 保持最大值，避免溢出
    else
      rd_fifo_cnt <= rd_fifo_cnt + 4'h1;  // 每时钟加1，直到15
  end
  else
    rd_fifo_cnt <= 4'h0;  // 非计数状态时清零
end

// 读使能逻辑：仅在读完延时（进入10状态）且FIFO非空时，才触发读
    assign tx_valid = (rd_fifo_state == 2'b10) & (!tx_fifo_empty&!Full);

    always@(posedge clk or negedge reset_n)
        if(!reset_n)
            can_tx_data_valid<=0;
        else
            can_tx_data_valid<=!Empty&tx_ready;
    can_control#(
    // local ID parameter
    .LOCAL_ID       (11'h456),
    // recieve ID filter parameters
    .RX_ID_SHORT_FILTER (11'h123     ),
    .RX_ID_SHORT_MASK   (11'h7ff     ),
    .RX_ID_LONG_FILTER  (29'h12345678),
    .RX_ID_LONG_MASK    (29'h1fffffff),
    .default_c_PTS      (16'd34      ),
    .default_c_PBS1     (16'd5       ),
    .default_c_PBS2     (16'd10      )
) can_control(
    .rstn(reset_n),      // set to 1 while working
    .clk(clk),       // system clock
    .can_rx(can_rx),
    .can_tx(can_tx),

    .tx_valid(can_tx_data_valid),  // when tx_valid=1 and tx_ready=1, push a data to tx fifo
    .tx_ready(tx_ready),  // whether the tx fifo is available
    .tx_data(Q_tx),   // the data to push to tx fifo

    .rx_valid(rx_valid),  // whether data byte is valid
    .rx_last(rx_last),   // indicate the last data byte of a packet
    .rx_data(rx_data),   // a data byte in the packet
    .rx_id(),     // the ID of a packet
    .rx_ide()     // whether the ID is LONG or SHORT
);

    reg [1:0]tx_data_cnt;
    always@(posedge clk or negedge reset_n)
    begin
        if(!reset_n)begin
            tx_data_cnt<=0;
        end
        else if(tx_valid)begin
            tx_data_cnt<=tx_data_cnt+1;
        end
        else if(tx_data_cnt!=1'b0)begin
            tx_data_cnt<=tx_data_cnt+1;
        end
        else begin
            tx_data_cnt<=tx_data_cnt;
        end
    end
    reg tx_valid_dly;
    always@(posedge clk or negedge reset_n)
    begin
        if(!reset_n)begin
            tx_valid_dly<=0;
        end
        else begin
            tx_valid_dly<=tx_valid;
        end
    end
    wire tx_fifo_valid;
    wire [7:0]tx_fifo_data;
    assign tx_fifo_data=(tx_valid)?tx_data:8'h0;
    assign tx_fifo_valid=(tx_valid)?1:(tx_data_cnt==2'b00)?0:1;
    fifo_can_mtos fifo_can_mtos(
		.Data(tx_fifo_data), //input [7:0] Data
		.Reset(!reset_n), //input Reset
		.WrClk(clk), //input WrClk
		.RdClk(clk), //input RdClk
		.WrEn(tx_fifo_valid), //input WrEn
		.RdEn(!Empty&tx_ready), //input RdEn
		.Q(Q), //output [31:0] Q
		.Empty(Empty), //output Empty
		.Full(Full) //output Full
	);
    assign rx_data_lenth={12'd0,can_control.r_len};
endmodule