/***********************************************************************/
//
//		Custom Neural Network IP for Imersiv Net
//
//		Description: Mathematical numerical character and operator recognition neural network.
//                 Trained on a binary 28x28 pixel image dataset containing the following characters:
//                 0123456789[]+-*/
//						 
//		Date: 4/18/2023
//		Revision: v1.0
//		Authors: Max Ma & Dhruv Kulgod
//
// 	Memory Map:
//
// 	Word Addresses  | Byte Addressses | Purpose
// 	------------------------------------------------------------
// 	0x0000 - 0x001B | 0x0000 - 0x006F | 28 x 28 Image File
// 	0x001C			 |	0x0070 - 0x0073 | Character Register (Read-Only)
// 	
// 	How Memory Works:
//		1.) Each register contains pixel data for each row
//			a.) [32:28] : Blank (Wasted space but makes code simple)
//			b.) [27:0] : Left -> Right pixel data of each row
//		2.) Output register contains the predicted character for given pixel data
//
//
//		IO Interface:
//		1.) Writing to the last image buffer register asserts the start signal for the neural network
//		2.) Upon complete, the neural network IP will assert a positive edge (0 -> 1) IRQ : Specified in Platform Designer
//			a.) The IRQ is cleared upon reading the PIO
//
/***********************************************************************/
`define NUM_IMAGE_REGS 28

module image_buffer_28x28 (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon-MM Slave Signals
	input logic AVL_READ,						// Avalon-MM Read
	input logic AVL_WRITE,						// Avalon-MM Write
	input logic AVL_CS,							// Avalon-MM Chip Select
	input logic [4:0] AVL_ADDR,				// Avalon-MM Address
	input logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] IMAGE_OUT[`NUM_IMAGE_REGS],
	output logic IMG_OE,
	
	// Neural Network Start Signal
	output logic START
);
	/////////////////////////////////////
	///// 28x28 IMAGE REGISTER FILE /////
	/////////////////////////////////////
	logic [31:0] IMAGE_REGS[`NUM_IMAGE_REGS];
	assign IMAGE_OUT = IMAGE_REGS;
	
	////////////////////////////////
	///// Read and Write Logic /////
	////////////////////////////////
	always_ff @(posedge CLK) begin
		// Default Values
		IMG_OE <= 1'b0;
		START <= 1'b0;
		
		// When CS is HIGH (Active High): I/O with AVALON BUS
		if(AVL_CS) begin
			// Read Operation
			if(AVL_READ) begin
				// Address Decode
				if (AVL_ADDR <= 5'h1B) begin
					IMG_OE <= 1'b1;
				end
			end 
			// Write Operation
			else if(AVL_WRITE) begin
				// Image Register Write
				IMAGE_REGS[AVL_ADDR] <= AVL_WRITEDATA;
				
				// Start Signal Decode
				if (AVL_ADDR == 5'h1B) begin
					START <= 1'b1;
				end
			end
		end
	end
	
endmodule


module imersiv_net_avl_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,						// Avalon-MM Read
	input  logic AVL_WRITE,						// Avalon-MM Write
	input  logic AVL_CS,							// Avalon-MM Chip Select
	input  logic [4:0] AVL_ADDR,				// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	   // Avalon-MM Read Data
	
	// Exported Conduit: Neural Network IRQ Signal
	output logic CHARACTER_IRQ
);
	//////////////////////////////
	///// 28x28 IMAGE Buffer /////
	//////////////////////////////
	logic [31:0] IMAGE_OUT[`NUM_IMAGE_REGS];
	logic IMG_OE, START;
	image_buffer_28x28 image_buffer_(.*);
	
	/////////////////////////////////////
	///// OUTPUT CHARACTER REGISTER /////
	/////////////////////////////////////
	logic [31:0] CHARACTER_REG;
	
	//////////////////////////
	///// Neural Network /////
	//////////////////////////
	imersiv_net NN_(.*);
	
	////////////////////////////////
	///// Read and Write Logic /////
	////////////////////////////////
	logic CHAR_OE;
	always_ff @(posedge CLK) begin
		// Default Values
		CHAR_OE <= 1'b0;
		
		// When CS is HIGH (Active High): I/O with AVALON BUS
		if(AVL_CS) begin
			// Read Operation
			if(AVL_READ) begin
				// Address Decode
				if (AVL_ADDR == 5'h1C) begin
					CHAR_OE <= 1'b1;
				end
			end
		end
	end
	
	// 2 Cycle Latency: Read Operation from AVALON BUS  
	always_ff @(posedge CLK) begin
		if(IMG_OE) begin
			AVL_READDATA <= IMAGE_OUT[AVL_ADDR];
		end else if(CHAR_OE) begin
			AVL_READDATA <= CHARACTER_REG;
		end
	end

endmodule
