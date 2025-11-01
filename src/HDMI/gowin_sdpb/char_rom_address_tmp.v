//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5AT-LV138PG484AC1/I0
//Device: GW5AT-138
//Device Version: B
//Created Time: Mon Oct 13 23:22:28 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    char_rom_address your_instance_name(
        .dout(dout), //output [6:0] dout
        .clka(clka), //input clka
        .cea(cea), //input cea
        .clkb(clkb), //input clkb
        .ceb(ceb), //input ceb
        .oce(oce), //input oce
        .reset(reset), //input reset
        .ada(ada), //input [7:0] ada
        .din(din), //input [6:0] din
        .adb(adb) //input [7:0] adb
    );

//--------Copy end-------------------
