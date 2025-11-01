//////////////////////////////////////////////////////////////////////////////////
// Company: �人о·��Ƽ����޹�˾
// Engineer: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: HT6221
// Module Name: ir_decode
// Project Name: HT6221
// Target Devices: XC7A35T-2FGG484I
// Tool Versions: Vivado 2018.3
// Description: ����ң�ؽ���ģ��
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ir_decode(
	clk,
	reset_n,
  
	iIR,
  
	dec_done,
	ir_data,
	ir_addr
);

	input clk;   //ϵͳʱ�����룬50M
	input reset_n;  //��λ�ź����룬����Ч

	input iIR;      //�����ź�����
	
	output dec_done; //һ�κ��������ɱ�־
	output [15:0]ir_data;  //�����������
	output [15:0]ir_addr;  //������ĵ�ַ
	
	reg dec_done; //һ�κ��������ɱ�־
	reg [3:0] state;       //״̬��״̬
	reg time_cnt_en; //ʱ�������ʹ��
	reg [18:0]time_cnt;    //ʱ�������

	reg T9ms_ok;
	reg T4_5ms_ok;
	reg T_56ms_ok;
	reg T1_69ms_ok;
	reg timeout;

	reg [5:0]data_cnt;	
	reg [31:0]data_tmp;
	wire reset=~reset_n;
	
	assign ir_addr = data_tmp[15:0];
	assign ir_data = data_tmp[31:16];
	
	localparam 
		IDLE        = 4'b0001,
		LEADER_T9   = 4'b0010,
		LEADER_T4_5 = 4'b0100,
		DATE_GET    = 4'b1000;
		
	reg iIR_sync1;
	reg iIR_sync2;
	reg iIR_sync_reg1;
	reg iIR_sync_reg2;
	wire iIR_pedge;
	wire iIR_nedge;
	
  //�ⲿ��������ź�ͬ��
	always@(posedge clk or posedge reset)
	if(reset)begin
		iIR_sync1 <= 1'b0;
		iIR_sync2 <= 1'b0;
	end
	else begin
		iIR_sync1 <= iIR;
		iIR_sync2 <= iIR_sync1;
	end

	//�ⲿ��������ź�ͬ����Ĵ�
	always@(posedge clk or posedge reset)
	if(reset)begin
		iIR_sync_reg1 <= 1'b0;
		iIR_sync_reg2 <= 1'b0;
	end
	else begin
		iIR_sync_reg1 <= iIR_sync2;
		iIR_sync_reg2 <= iIR_sync_reg1;
	end

	//�ⲿ��������źű��ؼ��
	assign iIR_pedge = !iIR_sync_reg2 && iIR_sync_reg1;
	assign iIR_nedge = iIR_sync_reg2  && !iIR_sync_reg1;

	always@(posedge clk or posedge reset)
	if(reset)	
		time_cnt <= 19'd0;
	else if(time_cnt_en == 1'b1)
		time_cnt <= time_cnt + 1'b1;
	else
		time_cnt <= 19'd0;

	always@(posedge clk or posedge reset)
	if(reset)
		T9ms_ok <= 1'b0;
	else if(time_cnt > 19'd325000 && time_cnt <19'd495000)
		T9ms_ok <= 1'b1;
	else
		T9ms_ok <= 1'b0;
		
	always@(posedge clk or posedge reset)
	if(reset)
		T4_5ms_ok <= 1'b0;
	else if(time_cnt > 19'd152500 && time_cnt <19'd277500)
		T4_5ms_ok <= 1'b1;
	else
		T4_5ms_ok <= 1'b0;
	
	always@(posedge clk or posedge reset)
	if(reset)
		T_56ms_ok <= 1'b0;
	else if(time_cnt > 19'd20000 && time_cnt <19'd35000)
		T_56ms_ok <= 1'b1;
	else
		T_56ms_ok <= 1'b0;
		
	always@(posedge clk or posedge reset)
	if(reset)
		T1_69ms_ok <= 1'b0;
	else if(time_cnt > 19'd75000 && time_cnt <19'd90000)
		T1_69ms_ok <= 1'b1;
	else
		T1_69ms_ok <= 1'b0;
		
	always@(posedge clk or posedge reset)
	if(reset)	
		timeout <= 1'b0;
	else if(time_cnt >= 19'd500000)
		timeout <= 1'b1;
	else 
		timeout <= 1'b0;

	always@(posedge clk or posedge reset)
	if(reset)begin
		state <= IDLE;
		time_cnt_en <= 1'b0;
	end
	else if(!timeout)begin
		case(state)
			IDLE:
				if(iIR_nedge)begin
					time_cnt_en <= 1'b1;
					state <= LEADER_T9;
				end
				else begin
					state <= IDLE;
					time_cnt_en <= 1'b0;
				end
			
			LEADER_T9:
				if(iIR_pedge)begin
					if(T9ms_ok)begin
						time_cnt_en <= 1'b0;
						state <= LEADER_T4_5;
					end
					else begin
						state <= IDLE;	
					end
				end
				else begin
					state <= LEADER_T9;
					time_cnt_en <= 1'b1;
				end
					
			LEADER_T4_5:
				if(iIR_nedge)begin
					if(T4_5ms_ok)begin
						time_cnt_en <= 1'b0;
						state <= DATE_GET;
					end
					else begin
						state <= IDLE;	
					end
				end
				else begin
					state <= LEADER_T4_5;
					time_cnt_en <= 1'b1;
				end
					
			DATE_GET:
				if(iIR_pedge && !T_56ms_ok)
					state <= IDLE;
				else if(iIR_nedge && (!T_56ms_ok && !T1_69ms_ok))
					state <= IDLE;			
				else if(dec_done)
					state <= IDLE;	
				else if(iIR_pedge && T_56ms_ok)begin
					time_cnt_en <= 1'b0;
				end
				else if(iIR_nedge && (T_56ms_ok || T1_69ms_ok))begin
					time_cnt_en <= 1'b0;				
				end
				else
					time_cnt_en <= 1'b1;
			default:;
		endcase
	end
	else begin
		time_cnt_en <= 1'b0;
		state <= IDLE;	
	end

	always@(posedge clk or posedge reset)
	if(reset)	
		dec_done <= 1'b0;
	else if(state == DATE_GET && iIR_pedge && (data_cnt == 6'd32))
		dec_done <= 1'b1;
	else 
		dec_done <= 1'b0;
    
	always@(posedge clk or posedge reset)
	if(reset)begin
		data_cnt <= 6'd0;
		data_tmp <= 32'd0;
	end
	else if(state == DATE_GET)begin
		if(iIR_pedge && (data_cnt == 6'd32))
			data_cnt <= 6'd0;
		else begin
			if(iIR_nedge)
				data_cnt <= data_cnt + 1'b1;
			if(iIR_nedge && T_56ms_ok)
				data_tmp[data_cnt] <= 1'b0;
			else if(iIR_nedge && T1_69ms_ok)
				data_tmp[data_cnt] <= 1'b1;			
		end	
	end

endmodule
