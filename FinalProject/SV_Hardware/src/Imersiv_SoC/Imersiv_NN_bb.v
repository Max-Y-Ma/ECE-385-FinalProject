
module Imersiv_NN (
	character_irq_port_character_irq,
	clk_clk,
	hex_digits_export,
	key_external_connection_export,
	leds_export,
	mouse_x_export,
	mouse_x_port_mouse_x,
	mouse_y_export,
	mouse_y_port_mouse_y,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	switches_export,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export,
	vga_port_blue,
	vga_port_vs,
	vga_port_hs,
	vga_port_red,
	vga_port_green,
	character_irq_export);	

	output		character_irq_port_character_irq;
	input		clk_clk;
	output	[15:0]	hex_digits_export;
	input	[1:0]	key_external_connection_export;
	output	[13:0]	leds_export;
	output	[9:0]	mouse_x_export;
	input	[9:0]	mouse_x_port_mouse_x;
	output	[9:0]	mouse_y_export;
	input	[9:0]	mouse_y_port_mouse_y;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input	[9:0]	switches_export;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
	output	[3:0]	vga_port_blue;
	output		vga_port_vs;
	output		vga_port_hs;
	output	[3:0]	vga_port_red;
	output	[3:0]	vga_port_green;
	input		character_irq_export;
endmodule
