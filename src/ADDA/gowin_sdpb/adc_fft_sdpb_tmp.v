//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5AT-LV138PG484AC1/I0
//Device: GW5AT-138
//Device Version: B
//Created Time: Thu Sep 18 15:13:52 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    adc_fft_SDPB your_instance_name(
        .dout(dout_o), //output [7:0] dout
        .clka(clka_i), //input clka
        .cea(cea_i), //input cea
        .clkb(clkb_i), //input clkb
        .ceb(ceb_i), //input ceb
        .oce(oce_i), //input oce
        .reset(reset_i), //input reset
        .ada(ada_i), //input [11:0] ada
        .din(din_i), //input [7:0] din
        .adb(adb_i) //input [11:0] adb
    );

//--------Copy end-------------------
