module customized_sequence_ctrl (
    input clk,
    input rst_n,

    input [7:0] sequence_rdfifo_data,
    input sequence_rdfifo_empty,
    output reg sequence_rdfifo_req,

    output reg error,
    output seq0,
    output seq1,
    output seq2,
    output seq3
);

    localparam 
    IDLE = 7'b0000001, 
    MESSAGE = 7'b0000010, 
    READ_DATA = 7'b0000100,
    READ_CPL = 7'b0001000,
    SEQ_REFRESH = 7'b0010000,
    ERROR_HANDLE = 7'b0100000,
    FIFO_EXAUST = 7'b1000000;

    reg [6:0] current_state;
    reg [6:0] next_state;

    reg [1:0] message_cnt;
    reg [7:0] data_cnt;

    reg [7:0] number;
    reg [7:0] length[0:3];
    reg [7:0] cycle[0:3];
    reg [255:0] data[0:3];
    reg refresh;

    reg [7:0]length_reg;
    reg [7:0]cycle_reg;
    reg [255:0] data_reg;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end


    always @(*) begin
        case (current_state)
            IDLE: begin
                if (!sequence_rdfifo_empty) next_state = MESSAGE;
                else next_state = IDLE;
            end

            MESSAGE: begin
                if (message_cnt == 2'd3) next_state = READ_DATA;
                else next_state = MESSAGE;
            end

            READ_DATA: begin
                if(error) next_state = ERROR_HANDLE;
                else if (data_cnt == length_reg - 1) next_state = READ_CPL;
                else next_state = READ_DATA;
            end

            READ_CPL: begin
                next_state = SEQ_REFRESH;
            end

            SEQ_REFRESH: begin
                next_state = FIFO_EXAUST;
            end

            FIFO_EXAUST: begin
                if(sequence_rdfifo_empty) next_state = IDLE;
                else next_state = FIFO_EXAUST;
            end

            ERROR_HANDLE: begin
                if(sequence_rdfifo_empty) next_state = IDLE;
                else next_state = ERROR_HANDLE;
            end

            default: next_state = IDLE;
        endcase
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sequence_rdfifo_req <= 1'b0;
            message_cnt <= 2'd0;
            data_cnt <= 8'd0;
            error <= 1'b0;

            number <= 8'd0;
            length_reg <= 8'd0;
            cycle_reg <= 8'd0;
            data_reg <= 256'd0;

            length[0] <= 8'd1;
            length[1] <= 8'd1;
            length[2] <= 8'd1;
            length[3] <= 8'd1;
            cycle[0] <= 8'd1;
            cycle[1] <= 8'd1;
            cycle[2] <= 8'd1;
            cycle[3] <= 8'd1;
            data[0] <= 256'd0;
            data[1] <= 256'd0;
            data[2] <= 256'd0;
            data[3] <= 256'd0;
            refresh <= 1'b0;

        end else begin
            case (current_state)
                IDLE: begin
                    sequence_rdfifo_req <= 1'b0;
                    message_cnt <= 2'd0;
                    data_cnt <= 8'd0;

                    number <= 8'd0;
                    length_reg <= 8'd1;
                    cycle_reg <= 8'd1;
                    data_reg <= 256'd0;
                    refresh <= 1'b0;
                end

                MESSAGE: begin
                    case (message_cnt)
                        2'd0: begin
                            sequence_rdfifo_req <= 1'b1;
                            message_cnt <= 2'd1;
                        end
                        2'd1: begin
                            if(sequence_rdfifo_data > 3) error <= 1'b1;
                            else error <= 1'b0;
                            number <= sequence_rdfifo_data;
                            message_cnt <= 2'd2;
                        end
                        2'd2: begin
                            if(sequence_rdfifo_data == 0) error <= 1'b1;
                            length_reg <= sequence_rdfifo_data;
                            message_cnt <= 2'd3;
                        end
                        2'd3: begin
                            if(sequence_rdfifo_data == 0) error <= 1'b1;
                            cycle_reg <= sequence_rdfifo_data;
                            message_cnt <= 2'd0;
                        end
                        default: ;
                    endcase
                end

                READ_DATA: begin
                    data_reg <= {sequence_rdfifo_data[0], data_reg[255:1]};
                    if (data_cnt == length_reg - 1) begin
                        sequence_rdfifo_req <= 1'b0;
                        data_cnt <= 8'd0;
                    end else begin
                        data_cnt <= data_cnt + 1;
                        sequence_rdfifo_req <= 1'b1;
                    end
                end

                READ_CPL: begin
                        length[number] <= length_reg;
                        cycle[number] <= cycle_reg;
                        data[number] <= (data_reg >> (256 - length_reg));
                end

                SEQ_REFRESH: begin
                    refresh <= 1'b1;
                end

                ERROR_HANDLE: begin
                    if(sequence_rdfifo_empty) sequence_rdfifo_req <= 1'b0;
                    else sequence_rdfifo_req <= 1'b1;
                end

                FIFO_EXAUST: begin
                    refresh <= 1'b0;
                    if(sequence_rdfifo_empty) sequence_rdfifo_req <= 1'b0;
                    else sequence_rdfifo_req <= 1'b1;
                end

                default: ;
            endcase
        end
    end

    customized_sequence_module seq_mod0 (
        .clk(clk),
        .rst_n(rst_n),
        .length(length[0]),
        .cycle(cycle[0]),
        .data(data[0]),
        .refresh(refresh),
        .seq(seq0)
    );

    customized_sequence_module seq_mod1 (
        .clk(clk),
        .rst_n(rst_n),
        .length(length[1]),
        .cycle(cycle[1]),
        .data(data[1]),
        .refresh(refresh),
        .seq(seq1)
    );
    
    customized_sequence_module seq_mod2 (
        .clk(clk),
        .rst_n(rst_n),
        .length(length[2]),
        .cycle(cycle[2]),
        .data(data[2]),
        .refresh(refresh),
        .seq(seq2)
    );

    customized_sequence_module seq_mod3 (
        .clk(clk),
        .rst_n(rst_n),
        .length(length[3]),
        .cycle(cycle[3]),
        .data(data[3]),
        .refresh(refresh),
        .seq(seq3)
    );

endmodule
