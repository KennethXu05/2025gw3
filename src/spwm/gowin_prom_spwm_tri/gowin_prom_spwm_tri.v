//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5AT-LV138PG484AC1/I0
//Device: GW5AT-138
//Device Version: B
//Created Time: Fri Oct  3 12:08:51 2025

module Gowin_pROM_spwm_tri (dout, clk, oce, ce, reset, ad);

output [9:0] dout;
input clk;
input oce;
input ce;
input reset;
input [5:0] ad;

wire [21:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[21:0],dout[9:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,gw_gnd,ad[5:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 16;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h0266023D021401EB01C2019901700147011E00F600CD00A4007B005200290000;
defparam prom_inst_0.INIT_RAM_01 = 256'h03090332035B038403AD03D603FF03D603AD0384035B0332030902E102B8028F;
defparam prom_inst_0.INIT_RAM_02 = 256'h007B00A400CD00F6011E01470170019901C201EB0214023D0266028F02B802E1;
defparam prom_inst_0.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000000290052;

endmodule //Gowin_pROM_spwm_tri
