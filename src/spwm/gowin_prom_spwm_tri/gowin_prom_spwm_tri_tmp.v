//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5AT-LV138PG484AC1/I0
//Device: GW5AT-138
//Device Version: B
//Created Time: Fri Oct  3 12:08:51 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_pROM_spwm_tri your_instance_name(
        .dout(dout), //output [9:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(reset), //input reset
        .ad(ad) //input [5:0] ad
    );

//--------Copy end-------------------
