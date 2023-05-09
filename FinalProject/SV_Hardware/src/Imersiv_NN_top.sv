//-------------------------------------------------------------------------
//      ECE 385 - Final Project Imersiv NET Top Module                   --                                                              --
//                                                                       --
//      Data: 4/18/2023                                                  --
//      Contact: Max Ma @ maxma2@illinois.edu || Dhruv Kulgod            --
//			                                                                --
//-------------------------------------------------------------------------


module Imersiv_NN_top (
      ///////// Clocks /////////
      input    MAX10_CLK1_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,
		
		///////// SW /////////
      input    [ 9: 0]   SW,
		
		///////// LEDR /////////
      output   [ 9: 0]   LEDR,
		
		///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,
		
		///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N
);
	////////////////
	///// MISC /////
	////////////////
	logic Reset_h;
	assign {Reset_h} = ~(KEY[0]); 
	
	////////////////////////////////////
	///// USB SIGNALS + ASSIGNMENT /////
	////////////////////////////////////
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [9:0] mouse_x_wire, mouse_y_wire;
	logic character_irq_wire;
	
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST; // USB Reset 
	assign ARDUINO_IO[8] = 1'bZ; // This is GPX (set to input)
	assign USB_GPX = 1'b0; //GPX is not Needed for Standard USB Host - Set to 0 to Prevent Interrupt
	
	// Assign uSD CS to '1' to Prevent uSD card from Interfering with USB Host
	assign ARDUINO_IO[6] = 1'b1;
	
	///////////////////////
	///// HEX DRIVERS /////
	///////////////////////
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0;
	logic [1:0] signs;
	logic [1:0] hundreds;
	
	hex_driver hex_driver4_ (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	hex_driver hex_driver3_ (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	hex_driver hex_driver1_ (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	hex_driver hex_driver0_ (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	// Fill in the Hundreds Digit & Negative Sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	// SOC Instantiation
	Imersiv_NN Imersiv_SOC_ (
		// CLOCKS
		.clk_clk(MAX10_CLK1_50),    						// Clk
		.reset_reset_n(1'b1),             				// Reset KEY[0]
		.altpll_0_locked_conduit_export(),    			// PLL
		.altpll_0_phasedone_conduit_export(), 			// PLL
		.altpll_0_areset_conduit_export(),     		// PLL
		
		// PIO
		.key_external_connection_export(KEY),    		   						// Btn Output
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),	// Hex Output
		.switches_export(SW),															// Switches Input
		.leds_export({hundreds, signs, LEDR}),										// LEDs Output
		.mouse_x_export(mouse_x_wire),												// Keycode Output
		.mouse_y_export(mouse_y_wire),												// Keycode Output
		.character_irq_export(character_irq_wire),
		
		// Mouse Ports for VGA Interface
		.mouse_x_port_mouse_x(mouse_x_wire),						// Input
		.mouse_y_port_mouse_y(mouse_y_wire),						// Input
		
		// Character IRQ Port for NN Interface
		.character_irq_port_character_irq(character_irq_wire),
		
		// SDRAM
		.sdram_clk_clk(DRAM_CLK),            				   // clk_sdram.clk
	   .sdram_wire_addr(DRAM_ADDR),               			// sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                			   // .ba
		.sdram_wire_cas_n(DRAM_CAS_N),              		   // .cas_n
		.sdram_wire_cke(DRAM_CKE),                 			// .cke
		.sdram_wire_cs_n(DRAM_CS_N),                		   // .cs_n
		.sdram_wire_dq(DRAM_DQ),                  			// .dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),            // .dqm
		.sdram_wire_ras_n(DRAM_RAS_N),              		   // .ras_n
		.sdram_wire_we_n(DRAM_WE_N),                		   // .we_n
		
		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		// VGA
		.vga_port_red(VGA_R),
		.vga_port_green(VGA_G),
		.vga_port_blue(VGA_B),
		.vga_port_hs(VGA_HS),
		.vga_port_vs(VGA_VS)
	 );

endmodule
