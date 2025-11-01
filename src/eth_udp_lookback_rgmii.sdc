//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12 (64-bit) 
//Created Time: 2025-10-02 16:11:30
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}] -add
create_clock -name fx2_ifclk -period 20.833 -waveform {0 10.416} [get_ports {fx2_ifclk}] -add
create_clock -name FX2_SPI_SCLK -period 41.667 -waveform {0 20.834} [get_ports {FX2_SPI_SCLK}] -add
