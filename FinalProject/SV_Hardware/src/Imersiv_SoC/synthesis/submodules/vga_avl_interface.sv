/***********************************************************************/
//		Custom VGA Graphics Controller for Drawing Binary Characters w/ NN
//
//		Description: Integrates a USB mouse interface into UI for an external VGA monitor.
//						 Controls sprite drawing and character recognition UI for Imersiv NN. 
//						 
//		Date: 4/18/2023
//		Revision: v1.0
//		Authors: Max Ma & Dhruv Kulgod
//
// 	Memory Map:
//
// 	Word Addresses  | Byte Addressses | Purpose
// 	------------------------------------------------------------
// 	0x0000 - 0x257F | 0x0000 - 0x95FF | B&W VRAM
// 	0x3000 - 0x3004 | 0xC000 - 0xC013 | x5 NN Codes
// 	0x3005          | 0xC014 - 0xC017 | Status Register (Read-Only)
//
//		How Memory Works: 
//		1.) VRAM contains B&W data for every pixel [640x480]
//		2.) NN Codes are stored in [15:0] of their word addresss
//		3.) Status Register: blank @ [0]
//
/***********************************************************************/

`define NUM_REGS 9600
`define NUM_NN_CODES_REGS 5
	
module ram_32x20x480 (
	output logic [31:0] DATA_OUT,
	input logic [31:0] DATA_IN,
	input logic [3:0] AVL_BYTE_EN,
	input logic [13:0] WRITE_ADDRESS, READ_ADDRESS,
	input logic WE, CLK
);
	// Infer Dual-Port RAM
	logic [3:0][7:0] VRAM [`NUM_REGS];
	
	always_ff @ (posedge CLK) begin
		if (WE) begin
			// Inferring Byte Enable
			if (AVL_BYTE_EN[0])
				VRAM[WRITE_ADDRESS][0] <= DATA_IN[7:0];
			if (AVL_BYTE_EN[1])
				VRAM[WRITE_ADDRESS][1] <= DATA_IN[15:8];
			if (AVL_BYTE_EN[2])
				VRAM[WRITE_ADDRESS][2] <= DATA_IN[23:16];
			if (AVL_BYTE_EN[3])
				VRAM[WRITE_ADDRESS][3] <= DATA_IN[31:24];
		end
		DATA_OUT <= VRAM[READ_ADDRESS];
	end
	
endmodule

module vga_avl_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,						// Avalon-MM Read
	input  logic AVL_WRITE,						// Avalon-MM Write
	input  logic AVL_CS,							// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [13:0] AVL_ADDR,				// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit Output
	output logic [3:0]  RED, GREEN, BLUE,	// VGA Color Channels
	output logic HS, VS,							// VGA HS / VS
	
	// Exported Conduit Input
	input logic [9:0] MOUSE_X, MOUSE_Y,
	input logic	[1:0] MOUSE_STATUS
);
//////////////////////////////////
///// NN CODES REGISTER FILE /////
//////////////////////////////////
logic [31:0] NN_CODE_REGS [`NUM_NN_CODES_REGS];

///////////////////////
///// VRAM MODULE /////
///////////////////////
logic WE;
logic [13:0] WRITE_ADDRESS, READ_ADDRESS;
logic [31:0] DATA_IN, DATA_OUT;
ram_32x20x480 VRAM_(.*);

/////////////////////////////////
///// VGA Controller MODULE /////
/////////////////////////////////
logic pixel_clk, blank, sync;
logic [9:0] DrawX, DrawY;
vga_controller VGA_(.Clk(CLK), .Reset(RESET), .*);

///////////////////////////
///// STATUS REGISTER /////
///////////////////////////
logic [31:0] STATUS_REG;
assign STATUS_REG[0] = blank;

////////////////////////////////
///// Read and Write Logic /////
////////////////////////////////
logic OE, NN_CODE_OE, STATUS_OE;
always_ff @(posedge CLK) begin
	// Default Values
	OE <= 1'b0;
	NN_CODE_OE <= 1'b0;
	STATUS_OE <= 1'b0;
	WE <= 1'b0;
	
	// When CS is HIGH (Active High): I/O with AVALON BUS
 	if(AVL_CS) begin
		// Read Operation
		if(AVL_READ) begin
			// Address Decode
			if (READ_ADDRESS[13:12] == 2'b11) begin
				if (READ_ADDRESS[2:0] == 3'b101) begin
					STATUS_OE <= 1'b1;
				end else begin
					NN_CODE_OE <= 1'b1;
				end
			end else begin
				OE <= 1'b1;
			end
		end 
		// Write Operation
		else if(AVL_WRITE) begin
			// Address Decode
			if(WRITE_ADDRESS[13:12] == 2'b11) begin
				// NN CODES REGISTER Byte Enable
				NN_CODE_REGS[WRITE_ADDRESS[2:0]] <= AVL_WRITEDATA;
			end else begin
				WE <= 1'b1;
			end
		end
	end
end

always_comb begin
	// ASSIGN READ_ADDRESS
 	if(AVL_READ) begin
		READ_ADDRESS = AVL_ADDR;
	end else begin
		READ_ADDRESS = (DrawX >> 5) + 20 * DrawY;
	end
	
	// ASSIGN WRITE_ADDRESS
	WRITE_ADDRESS = AVL_ADDR;
	
	
	// ASSIGN DATA_IN
	DATA_IN = AVL_WRITEDATA;
end

// 2 Cycle Latency: Read Operation from AVALON BUS  
always_ff @(posedge CLK) begin
	if(OE) begin
		AVL_READDATA <= DATA_OUT;
	end else if(NN_CODE_OE) begin
		AVL_READDATA <= NN_CODE_REGS[READ_ADDRESS[2:0]];
	end else if (STATUS_OE) begin
		AVL_READDATA <= STATUS_REG;
	end
end

///////////////////
///// DISPLAY /////
///////////////////
display_controller display_(.*);

endmodule
