module stom_connection (
    input clk,
    input rst_n,
    input [4:0] ctrl_signal,

    output reg [7:0] usb_wrfifo_data,
    output reg usb_wrfifo_pulse,
    output reg usb_tx_en,
    output reg [15:0] usb_tx_datalength,

    output reg [7:0] ethernet_wrfifo_data,
    output reg ethernet_wrfifo_pulse,
    output reg ethernet_tx_en,
    output reg [15:0] ethernet_tx_datalength,

    input [7:0] uart_wrfifo_data,
    input uart_wrfifo_pulse,
    input uart_receive_cpl,
    input [15:0] uart_data_length,

    input [7:0] i2c_wrfifo_data,
    input i2c_wrfifo_pulse,
    input i2c_receive_cpl,
    input [15:0] i2c_data_length,

    input [7:0] spi_wrfifo_data,
    input spi_wrfifo_pulse,
    input spi_receive_cpl,
    input [15:0] spi_data_length,

    input [7:0] can_wrfifo_data,
    input can_wrfifo_pulse,
    input can_receive_cpl,
    input [15:0] can_data_length,

    input [7:0] bluetooth_wrfifo_data,
    input bluetooth_wrfifo_pulse,
    input bluetooth_receive_cpl,
    input [15:0] bluetooth_data_length,

    input [7:0] ir_wrfifo_data,
    input ir_wrfifo_pulse,
    input ir_receive_cpl,
    input [15:0] ir_data_length,

    input [7:0] i2c_slave_wrfifo_data,
    input i2c_slave_wrfifo_pulse,
    input i2c_slave_receive_cpl,
    input [15:0] i2c_slave_data_length,

    input [7:0] spi_slave_wrfifo_data,
    input spi_slave_wrfifo_pulse,
    input spi_slave_receive_cpl,
    input [15:0] spi_slave_data_length,

    input [7:0] usb2ethernet_wrfifo_data,
    input usb2ethernet_wrfifo_pulse,
    input usb2ethernet_wrfifo_over,
    input [15:0] usb2ethernet_wrfifo_length,

    input [7:0] ethernet2usb_wrfifo_data,
    input ethernet2usb_wrfifo_pulse,
    input ethernet2usb_wrfifo_over,
    input [15:0] ethernet2usb_wrfifo_length
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            usb_wrfifo_data <= 8'b0;
            usb_wrfifo_pulse <= 1'b0;
            usb_tx_en <= 1'b0;
            usb_tx_datalength <= 16'b0;

            ethernet_wrfifo_data <= 8'b0;
            ethernet_wrfifo_pulse <= 1'b0;
            ethernet_tx_en <= 1'b0;
            ethernet_tx_datalength <= 16'b0;
        end else begin
            case (ctrl_signal)
                5'b00000: begin
                    //USB to UART
                    usb_wrfifo_data <= uart_wrfifo_data;
                    usb_wrfifo_pulse <= uart_wrfifo_pulse;
                    usb_tx_en <= uart_receive_cpl;
                    usb_tx_datalength <= uart_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b00001: begin
                    //USB to I2C
                    usb_wrfifo_data <= i2c_wrfifo_data;
                    usb_wrfifo_pulse <= i2c_wrfifo_pulse;
                    usb_tx_en <= i2c_receive_cpl;
                    usb_tx_datalength <= i2c_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b00010: begin
                    //USB to SPI
                    usb_wrfifo_data <= spi_wrfifo_data;
                    usb_wrfifo_pulse <= spi_wrfifo_pulse;
                    usb_tx_en <= spi_receive_cpl;
                    usb_tx_datalength <= spi_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b00011: begin
                    //USB to CAN
                    usb_wrfifo_data <= can_wrfifo_data;
                    usb_wrfifo_pulse <= can_wrfifo_pulse;
                    usb_tx_en <= can_receive_cpl;
                    usb_tx_datalength <= can_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b00110: begin
                    //USB to Bluetooth
                    usb_wrfifo_data <= bluetooth_wrfifo_data;
                    usb_wrfifo_pulse <= bluetooth_wrfifo_pulse;
                    usb_tx_en <= bluetooth_receive_cpl;
                    usb_tx_datalength <= bluetooth_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b00111: begin
                    //USB to Infrared
                    usb_wrfifo_data <= ir_wrfifo_data;
                    usb_wrfifo_pulse <= ir_wrfifo_pulse;
                    usb_tx_en <= ir_receive_cpl;
                    usb_tx_datalength <= ir_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b01001: begin
                    //I2C Slave to USB
                    usb_wrfifo_data <= i2c_slave_wrfifo_data;
                    usb_wrfifo_pulse <= i2c_slave_wrfifo_pulse;
                    usb_tx_en <= i2c_slave_receive_cpl;
                    usb_tx_datalength <= i2c_slave_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
                5'b01010: begin
                    //SPI Slave to USB
                    usb_wrfifo_data <= spi_slave_wrfifo_data;
                    usb_wrfifo_pulse <= spi_slave_wrfifo_pulse;
                    usb_tx_en <= spi_slave_receive_cpl;
                    usb_tx_datalength <= spi_slave_data_length;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end

                5'b10000: begin
                    //Ethernet to UART
                    ethernet_wrfifo_data <= uart_wrfifo_data;
                    ethernet_wrfifo_pulse <= uart_wrfifo_pulse;
                    ethernet_tx_en <= uart_receive_cpl;
                    ethernet_tx_datalength <= uart_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b10001: begin
                    //Ethernet to I2C
                    ethernet_wrfifo_data <= i2c_wrfifo_data;
                    ethernet_wrfifo_pulse <= i2c_wrfifo_pulse;
                    ethernet_tx_en <= i2c_receive_cpl;
                    ethernet_tx_datalength <= i2c_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b10010: begin
                    //Ethernet to SPI
                    ethernet_wrfifo_data <= spi_wrfifo_data;
                    ethernet_wrfifo_pulse <= spi_wrfifo_pulse;
                    ethernet_tx_en <= spi_receive_cpl;
                    ethernet_tx_datalength <= spi_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b10011: begin
                    //Ethernet to CAN
                    ethernet_wrfifo_data <= can_wrfifo_data;
                    ethernet_wrfifo_pulse <= can_wrfifo_pulse;
                    ethernet_tx_en <= can_receive_cpl;
                    ethernet_tx_datalength <= can_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b10110: begin
                    //Ethernet to Bluetooth
                    ethernet_wrfifo_data <= bluetooth_wrfifo_data;
                    ethernet_wrfifo_pulse <= bluetooth_wrfifo_pulse;
                    ethernet_tx_en <= bluetooth_receive_cpl;
                    ethernet_tx_datalength <= bluetooth_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b10111: begin
                    //Ethernet to Infrared
                    ethernet_wrfifo_data <= ir_wrfifo_data;
                    ethernet_wrfifo_pulse <= ir_wrfifo_pulse;
                    ethernet_tx_en <= ir_receive_cpl;
                    ethernet_tx_datalength <= ir_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b11001: begin
                    //I2C Slave to Ethernet
                    ethernet_wrfifo_data <= i2c_slave_wrfifo_data;
                    ethernet_wrfifo_pulse <= i2c_slave_wrfifo_pulse;
                    ethernet_tx_en <= i2c_slave_receive_cpl;
                    ethernet_tx_datalength <= i2c_slave_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end
                5'b11010: begin
                    //SPI Slave to Ethernet
                    ethernet_wrfifo_data <= spi_slave_wrfifo_data;
                    ethernet_wrfifo_pulse <= spi_slave_wrfifo_pulse;
                    ethernet_tx_en <= spi_slave_receive_cpl;
                    ethernet_tx_datalength <= spi_slave_data_length;

                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;
                end

                5'b01111: begin
                    //USB_ETHERNET
                    usb_wrfifo_data <= ethernet2usb_wrfifo_data;
                    usb_wrfifo_pulse <= ethernet2usb_wrfifo_pulse;
                    usb_tx_en <= ethernet2usb_wrfifo_over;
                    usb_tx_datalength <= ethernet2usb_wrfifo_length;

                    ethernet_wrfifo_data <= usb2ethernet_wrfifo_data;
                    ethernet_wrfifo_pulse <= usb2ethernet_wrfifo_pulse;
                    ethernet_tx_en <= usb2ethernet_wrfifo_over;
                    ethernet_tx_datalength <= usb2ethernet_wrfifo_length;
                end
                default: begin
                    usb_wrfifo_data <= 8'b0;
                    usb_wrfifo_pulse <= 1'b0;
                    usb_tx_en <= 1'b0;
                    usb_tx_datalength <= 16'b0;

                    ethernet_wrfifo_data <= 8'b0;
                    ethernet_wrfifo_pulse <= 1'b0;
                    ethernet_tx_en <= 1'b0;
                    ethernet_tx_datalength <= 16'b0;
                end
            endcase
        end
    end

endmodule
