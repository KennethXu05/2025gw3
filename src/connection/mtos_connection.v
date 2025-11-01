module mtos_connection (
    input [4:0] ctrl_signal,

    input [7:0] usb_fifowr_data,
    input usb_fifowr_empty,
    output reg usb_fifowr_req,

    input [7:0] ethernet_fifowr_data,
    input ethernet_fifowr_empty,
    output reg ethernet_fifowr_req,

    output reg [7:0] uart_rdfifo_data,
    output reg uart_rdfifo_empty,
    input uart_rdfifo_req,

    output reg [7:0] i2c_rdfifo_data,
    output reg i2c_rdfifo_empty,
    input i2c_rdfifo_req,

    output reg [7:0] spi_rdfifo_data,
    output reg spi_rdfifo_empty,
    input spi_rdfifo_req,

    output reg [7:0] can_rdfifo_data,
    output reg can_rdfifo_empty,
    input can_rdfifo_req,

    output reg [7:0] pwm_rdfifo_data,
    output reg pwm_rdfifo_empty,
    input pwm_rdfifo_req,

    output reg [7:0] sequence_rdfifo_data,
    output reg sequence_rdfifo_empty,
    input sequence_rdfifo_req,

    output reg [7:0] bluetooth_rdfifo_data,
    output reg bluetooth_rdfifo_empty,
    input bluetooth_rdfifo_req,

    output reg [7:0] spwm_rdfifo_data,
    output reg spwm_rdfifo_empty,
    input spwm_rdfifo_req,

    output reg [7:0] i2c_slave_rdfifo_data,
    output reg i2c_slave_rdfifo_empty,
    input i2c_slave_rdfifo_req,

    output reg [7:0] spi_slave_rdfifo_data,
    output reg spi_slave_rdfifo_empty,
    input spi_slave_rdfifo_req,

    output reg [7:0] usb2ethernet_fifowr_data,
    output reg usb2ethernet_fifowr_empty,
    input usb2ethernet_fifowr_req,

    output reg [7:0] ethernet2usb_fifowr_data,
    output reg ethernet2usb_fifowr_empty,
    input ethernet2usb_fifowr_req

);

    always@(*)
    begin
        case(ctrl_signal)
            5'b00000: begin
                // USB to UART
                usb_fifowr_req = uart_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = usb_fifowr_data;
                uart_rdfifo_empty = usb_fifowr_empty;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00001: begin
                // USB to I2C
                usb_fifowr_req = i2c_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = usb_fifowr_data;
                i2c_rdfifo_empty = usb_fifowr_empty;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00010: begin
                // USB to SPI
                usb_fifowr_req = spi_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = usb_fifowr_data;
                spi_rdfifo_empty = usb_fifowr_empty;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00011: begin
                // USB to CAN
                usb_fifowr_req = can_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = usb_fifowr_data;
                can_rdfifo_empty = usb_fifowr_empty;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00100: begin
                // USB to PWM
                usb_fifowr_req = pwm_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = usb_fifowr_data;
                pwm_rdfifo_empty = usb_fifowr_empty;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00101: begin
                // USB to SEQUENCE
                usb_fifowr_req = sequence_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = usb_fifowr_data;
                sequence_rdfifo_empty = usb_fifowr_empty;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b00110: begin
                // USB to BLUETOOTH
                usb_fifowr_req = bluetooth_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = usb_fifowr_data;
                bluetooth_rdfifo_empty = usb_fifowr_empty;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b01000: begin
                // USB to SPWM
                usb_fifowr_req = spwm_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = usb_fifowr_data;
                spwm_rdfifo_empty = usb_fifowr_empty;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b01001: begin
                // USB to I2C_SLAVE
                usb_fifowr_req = i2c_slave_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = usb_fifowr_data;
                i2c_slave_rdfifo_empty = usb_fifowr_empty;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b01010: begin
                // USB to SPI_SLAVE
                usb_fifowr_req = spi_slave_rdfifo_req;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = usb_fifowr_data;
                spi_slave_rdfifo_empty = usb_fifowr_empty;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end



            5'b10000: begin
                // ETHERNET to UART
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = uart_rdfifo_req;

                uart_rdfifo_data = ethernet_fifowr_data;
                uart_rdfifo_empty = ethernet_fifowr_empty;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10001: begin
                // ETHERNET to I2C
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = i2c_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = ethernet_fifowr_data;
                i2c_rdfifo_empty = ethernet_fifowr_empty;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10010: begin
                // ETHERNET to SPI
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = spi_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = ethernet_fifowr_data;
                spi_rdfifo_empty = ethernet_fifowr_empty;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10011: begin
                // ETHERNET to CAN
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = can_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = ethernet_fifowr_data;
                can_rdfifo_empty = ethernet_fifowr_empty;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10100: begin
                // ETHERNET to PWM
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = pwm_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = ethernet_fifowr_data;
                pwm_rdfifo_empty = ethernet_fifowr_empty;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10101: begin
                // ETHERNET to SEQUENCE
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = sequence_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = ethernet_fifowr_data;
                sequence_rdfifo_empty = ethernet_fifowr_empty;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b10110: begin
                // ETHERNET to BLUETOOTH
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = bluetooth_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = ethernet_fifowr_data;
                bluetooth_rdfifo_empty = ethernet_fifowr_empty;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b11000: begin
                // ETHERNET to SPWM
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = spwm_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = ethernet_fifowr_data;
                spwm_rdfifo_empty = ethernet_fifowr_empty;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b11001: begin
                // ETHERNET to I2C_SLAVE
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = i2c_slave_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = ethernet_fifowr_data;
                i2c_slave_rdfifo_empty = ethernet_fifowr_empty;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
            5'b11010: begin
                // ETHERNET to SPI_SLAVE
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = spi_slave_rdfifo_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = ethernet_fifowr_data;
                spi_slave_rdfifo_empty = ethernet_fifowr_empty;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end



            5'b01111: begin
                // USB_ETHERNET
                usb_fifowr_req = usb2ethernet_fifowr_req;
                ethernet_fifowr_req = ethernet2usb_fifowr_req;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = usb_fifowr_data;
                usb2ethernet_fifowr_empty = usb_fifowr_empty;

                ethernet2usb_fifowr_data = ethernet_fifowr_data;
                ethernet2usb_fifowr_empty = ethernet_fifowr_empty;
            end

            default: begin
                usb_fifowr_req = 1'b0;
                ethernet_fifowr_req = 1'b0;

                uart_rdfifo_data = 8'b0;
                uart_rdfifo_empty = 1'b1;

                i2c_rdfifo_data = 8'b0;
                i2c_rdfifo_empty = 1'b1;

                spi_rdfifo_data = 8'b0;
                spi_rdfifo_empty = 1'b1;

                can_rdfifo_data = 8'b0;
                can_rdfifo_empty = 1'b1;

                pwm_rdfifo_data = 8'b0;
                pwm_rdfifo_empty = 1'b1;

                sequence_rdfifo_data = 8'b0;
                sequence_rdfifo_empty = 1'b1;

                bluetooth_rdfifo_data = 8'b0;
                bluetooth_rdfifo_empty = 1'b1;

                spwm_rdfifo_data = 8'b0;
                spwm_rdfifo_empty = 1'b1;

                i2c_slave_rdfifo_data = 8'b0;
                i2c_slave_rdfifo_empty = 1'b1;

                spi_slave_rdfifo_data = 8'b0;
                spi_slave_rdfifo_empty = 1'b1;

                usb2ethernet_fifowr_data = 8'b0;
                usb2ethernet_fifowr_empty = 1'b1;

                ethernet2usb_fifowr_data = 8'b0;
                ethernet2usb_fifowr_empty = 1'b1;
            end
        endcase
    end


endmodule
