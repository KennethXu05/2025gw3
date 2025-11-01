`timescale 1ns/1ns

module dvi_encoder_tb;

	reg       pixelclk;       // system clock
	reg       pixelclk5x;     // system clock x5
	reg       rst_n;          // reset
	reg[7:0]  blue_din;       // Blue data in
	reg[7:0]  green_din;      // Green data in
	reg[7:0]  red_din;        // Red data in
	reg       hsync;          // hsync data
	reg       vsync;          // vsync data
	reg       de;             // data enable
	wire      tmds_clk_p;
	wire      tmds_clk_n;
	wire[2:0] tmds_data_p;    //rgb
	wire[2:0] tmds_data_n;     //rgb


	dvi_encoder dvi_encoder(
		pixelclk,       // system clock
		pixelclk5x,     // system clock x5
		rst_n,          // reset
		blue_din,       // Blue data in
		green_din,      // Green data in
		red_din,        // Red data in
		hsync,          // hsync data
		vsync,          // vsync data
		de,             // data enable
		tmds_clk_p,
		tmds_clk_n,
		tmds_data_p,    //rgb
		tmds_data_n     //rgb
	);
	
	initial pixelclk = 1;
	always#20 pixelclk = ~pixelclk;

	initial pixelclk5x = 1;
	always#4 pixelclk5x = ~pixelclk5x;	
	
	
	
	
	initial begin
		rst_n = 0;
		#201;
		rst_n = 1;
		
	
	
	end

endmodule
