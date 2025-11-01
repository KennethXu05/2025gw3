//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5A-EV25UG324SC2/I1
//Device: GW5A-25
//Device Version: A
//Created Time: Wed Oct  1 16:50:09 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	fifo_can_mtos your_instance_name(
		.Data(Data), //input [7:0] Data
		.Reset(Reset), //input Reset
		.WrClk(WrClk), //input WrClk
		.RdClk(RdClk), //input RdClk
		.WrEn(WrEn), //input WrEn
		.RdEn(RdEn), //input RdEn
		.Q(Q), //output [31:0] Q
		.Empty(Empty), //output Empty
		.Full(Full) //output Full
	);

//--------Copy end-------------------
