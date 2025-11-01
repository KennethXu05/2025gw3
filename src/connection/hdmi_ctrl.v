module hdmi_ctrl (
    input         ctrl,
    
    output  reg   hdmi_fifo_empty,
    output  reg[7:0] hdmi_fifo_data,
    input         hdmi_fifo_rd_en,

    input        hdmi_fifo_empty_usb,
    input  [7:0] hdmi_fifo_data_usb,
    output reg   hdmi_fifo_rd_en_usb,

    input        hdmi_fifo_empty_ethernet,
    input  [7:0] hdmi_fifo_data_ethernet,
    output reg   hdmi_fifo_rd_en_ethernet
);

    always @(*) begin
        if (ctrl) begin
            hdmi_fifo_data = hdmi_fifo_data_ethernet;
            hdmi_fifo_empty = hdmi_fifo_empty_ethernet;
            hdmi_fifo_rd_en_ethernet = hdmi_fifo_rd_en;
            hdmi_fifo_rd_en_usb = 1'b0;
        end
        else begin
            hdmi_fifo_data = hdmi_fifo_data_usb;
            hdmi_fifo_empty = hdmi_fifo_empty_usb;
            hdmi_fifo_rd_en_usb = hdmi_fifo_rd_en;
            hdmi_fifo_rd_en_ethernet = 1'b0;
        end
    end

    
endmodule