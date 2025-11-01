module  ir_control(
    input clk,
    input reset_n,
    input iIR,

    output reg dec_done_r,
    output reg [7:0]data,
    output reg stop,
    output reg [15:0]data_length
);
    reg[79:0]rx_data;
    wire [15:0]ir_data;
    wire dec_done;
    ir_decode ir_decode(
	.clk(clk),
	.reset_n(reset_n),
  
	.iIR(iIR),
  
	.dec_done(dec_done),
	.ir_data(ir_data),
	.ir_addr()
);
    reg [3:0]cnt;
    reg [1:0]state;
    reg [3:0]r_cnt;
    reg [1:0]s_cnt;
    reg end_signal;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            state<=0;
        else if(dec_done)
            state<=1;
        else if(end_signal)
            state<=2;
        else if(stop)
            state<=0;
        else
            state<=state;
    end

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            begin
                r_cnt<=0;
                data<=0;
                dec_done_r<=0;
                end_signal<=0;
                stop<=0;
                s_cnt<=0;
            end
        else if(state==0)
            begin
                r_cnt<=0;
                dec_done_r<=0;
                end_signal<=0;
                stop<=0;
                s_cnt<=0;
                data<=8'hff;
            end
        else if(state==1)
            begin
                if(r_cnt>=cnt)
                    begin
                        r_cnt<=r_cnt;
                        dec_done_r<=0;
                        data<=8'hff;
                        end_signal<=1;
                        stop<=0;
                        s_cnt<=0;
                    end
                else
                    begin
                        end_signal<=0;
                        r_cnt<=r_cnt+1;
                        stop<=0;
                        s_cnt<=0;
                        case (r_cnt)
                            0:begin dec_done_r<=1;data<=rx_data[7:0];end
                            1:begin dec_done_r<=1;data<=rx_data[15:8];end
                            2:begin dec_done_r<=1;data<=rx_data[23:16];end
                            3:begin dec_done_r<=1;data<=rx_data[31:24];end
                            4:begin dec_done_r<=1;data<=rx_data[39:32];end
                            5:begin dec_done_r<=1;data<=rx_data[47:40];end
                            6:begin dec_done_r<=1;data<=rx_data[55:48];end
                            7:begin dec_done_r<=1;data<=rx_data[63:56];end
                            8:begin dec_done_r<=1;data<=rx_data[71:64];end
                            9:begin dec_done_r<=1;data<=rx_data[79:72];end
                            default:begin dec_done_r<=0;data<=8'hff;end
                        endcase
                    end
            end
        else if(state==2)
            begin
                if(s_cnt>=2)
                    begin
                        s_cnt<=s_cnt;
                        stop<=1;
                        dec_done_r<=0;
                        data<=8'hff;
                        end_signal<=0;
                        r_cnt<=0;
                    end
                else 
                begin
                    stop<=0;
                    s_cnt<=s_cnt+1;
                    end_signal<=0;
                    r_cnt<=0;
                    case(s_cnt)
                            0:begin dec_done_r<=1;data<=8'h0D; end
                            1:begin dec_done_r<=1;data<=8'h0A; end
                            default:begin dec_done_r<=0;data<=8'hff;end
                    endcase
                end
            end
        else
            begin
                r_cnt<=0;
                data<=8'hff;
                dec_done_r<=0;
                end_signal<=0;
                stop<=0;
                s_cnt<=0;
            end
    end

    always@(posedge clk or negedge reset_n)
        if(!reset_n)
            begin
                rx_data<=0;
            end
        else 
        begin
            case(ir_data[7:0])
                8'h16:begin rx_data<=80'h30;cnt<=1;end//0
                8'h0C:begin rx_data<=80'h31;cnt<=1;end//1
                8'h18:begin rx_data<=80'h32;cnt<=1;end//2
                8'h5E:begin rx_data<=80'h33;cnt<=1;end//3
                8'h08:begin rx_data<=80'h34;cnt<=1;end//4
                8'h1C:begin rx_data<=80'h35;cnt<=1;end//5
                8'h5A:begin rx_data<=80'h36;cnt<=1;end//6
                8'h42:begin rx_data<=80'h37;cnt<=1;end//7
                8'h52:begin rx_data<=80'h38;cnt<=1;end//8
                8'h4A:begin rx_data<=80'h39;cnt<=1;end//9
                8'h45:begin rx_data<=80'h2D4843;cnt<=3;end//CH-
                8'h46:begin rx_data<=80'h4843;cnt<=2;end//CH
                8'h47:begin rx_data<=80'h2B4843;cnt<=3;end//CH+
                8'h44:begin rx_data<=80'h56455250;cnt<=4;end//PREV
                8'h40:begin rx_data<=80'h5458454E;cnt<=4;end//NEXT
                8'h43:begin rx_data<=80'h45535541502F59414C50;cnt<=10;end//PLAY/PAUSE 
                8'h07:begin rx_data<=80'h2D4C4F56;cnt<=4;end//VOL-
                8'h15:begin rx_data<=80'h2B4C4F56;cnt<=4;end//VOL+
                8'h09:begin rx_data<=80'h5145;cnt<=2;end//EQ
                8'h19:begin rx_data<=80'h2B303031;cnt<=4;end//100+
                8'h0D:begin rx_data<=80'h2B303032;cnt<=4;end//200+
                default:begin rx_data<=80'hFF;cnt<=1;end
            endcase
        end
            
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                data_length <= 0;
            end
            else begin
                data_length <= cnt + 2;
            end
        end
                
endmodule