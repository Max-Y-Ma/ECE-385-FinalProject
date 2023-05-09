/***********************************************************************/
//
//		Module to Determine What is Displayed to an External VGA Monitor
//						 
//		Date: 4/21/2023
//		Revision: v1.0
//		Authors: Max Ma
//
//		Mouse Status: 0x1 = Draw | 0x2 = Erase 
//
/***********************************************************************/
`define borderSize 4
`define leftBorder 255
`define rightBorder `leftBorder + 156
`define NUM_NN_CODES_REGS 5
`define topBorder 225
`define bottomBorder 253 
`define pencilSize 16
`define imageSize 28
`define fontWidth 8
`define fontHeight 16
`define characterYTop 208
`define characterYBottom 224

// Asynchronous ROM
module pencil_rom (
	input logic [7:0] PENCIL_ADDR,
	output logic [2:0] PENCIL_DATA
);
	logic [2:0] PENCIL_ROM [`pencilSize * `pencilSize];
	
	assign PENCIL_DATA = PENCIL_ROM[PENCIL_ADDR];

	initial $readmemb("pencil_rom.mif", PENCIL_ROM);
	
endmodule

module display_controller (
	input logic CLK, 
	input logic [31:0] NN_CODE_REGS [`NUM_NN_CODES_REGS],
	input logic blank, pixel_clk,
	input logic [9:0] DrawX, DrawY,
	input logic [9:0] MOUSE_X, MOUSE_Y,
	input logic [31:0] DATA_OUT,
	output logic [3:0] RED, GREEN, BLUE
);
	//////////////////////
	///// PENCIL ROM /////
	//////////////////////
	logic [7:0] PENCIL_ADDR;
	logic [2:0] PENCIL_DATA;
	pencil_rom PENCIL_SPRITE_ (.*);
	assign PENCIL_ADDR = (DrawX - MOUSE_X) + 16 * (DrawY - (MOUSE_Y - 15));
	
	////////////////////
	///// FONT ROM /////
	////////////////////
	logic [2:0] Character;
	logic [31:0] NN_Character;
	logic [7:0] ROM_addr;
	logic [7:0] ROM_data;
	font_rom ROM_(.addr(ROM_addr), .data(ROM_data));
	assign ROM_addr = 16 * NN_Character + DrawY[3:0];

	///////////////////////
	///// VGA DISPLAY /////
	///////////////////////
	logic [3:0] red, green, blue;
	always_ff @ (posedge pixel_clk) begin
		RED <= red;
		GREEN <= green;
		BLUE <= blue;
	end
	
	////////////////////////////
	///// Object Locations /////
	////////////////////////////
	
	logic characterBox;
	assign characterBox = ((((DrawX > `leftBorder - `borderSize) && (DrawX <= `leftBorder)) ||
						((DrawX > `rightBorder) && (DrawX <= `rightBorder + `borderSize)) ||
						((DrawX > `leftBorder + `imageSize) && (DrawX <= `leftBorder + `imageSize + `borderSize)) ||
						((DrawX > `leftBorder + 2 * `imageSize + `borderSize) && (DrawX <= `leftBorder + 2 * `imageSize + 2 * `borderSize)) ||
						((DrawX > `leftBorder + 3 * `imageSize + 2 * `borderSize) && (DrawX <= `leftBorder + 3 * `imageSize + 3 * `borderSize)) ||
						((DrawX > `leftBorder + 4 * `imageSize + 3 * `borderSize) && (DrawX <= `leftBorder + 4 * `imageSize + 4 * `borderSize))) && 
						(DrawY >= `topBorder - `borderSize) && (DrawY < `bottomBorder + `borderSize)) ||
						
					   ((((DrawY >= `topBorder - `borderSize) && (DrawY < `topBorder)) ||
						((DrawY >= `bottomBorder) && (DrawY < `bottomBorder + `borderSize))) &&
						(DrawX >= `leftBorder - `borderSize) && (DrawX < `rightBorder + `borderSize));
	
	// TODO: Nice Mapping
	logic character1;
	assign character1 = ((DrawX > `leftBorder) && (DrawX <= `leftBorder + `fontWidth)) && 
							  ((DrawY >= `characterYTop) && (DrawY < `characterYBottom));
	
	logic character2;
	assign character2 = ((DrawX > `leftBorder + `imageSize + `borderSize) && (DrawX <= `leftBorder + `imageSize + `borderSize + `fontWidth)) && 
							  ((DrawY >= `characterYTop) && (DrawY < `characterYBottom));
	
	logic character3;
	assign character3 = ((DrawX > `leftBorder + 2*`imageSize + 2*`borderSize) && (DrawX <= `leftBorder + 2*`imageSize + 2*`borderSize + `fontWidth)) && 
							  ((DrawY >= `characterYTop) && (DrawY < `characterYBottom));
	
	logic character4;
	assign character4 = ((DrawX > `leftBorder + 3*`imageSize + 3*`borderSize) && (DrawX <= `leftBorder + 3*`imageSize + 3*`borderSize + `fontWidth)) && 
							  ((DrawY >= `characterYTop) && (DrawY < `characterYBottom));
	
	logic character5;
	assign character5 = ((DrawX > `leftBorder + 4*`imageSize + 4*`borderSize) && (DrawX <= `leftBorder + 4*`imageSize + 4*`borderSize + `fontWidth)) && 
							  ((DrawY >= `characterYTop) && (DrawY < `characterYBottom));
							  
	///////////////////////////						
	///// Character Logic /////		
	///////////////////////////
	always_ff @(posedge CLK) begin
		NN_Character <= NN_CODE_REGS[Character];
	end
	
	always_comb begin
		if (character1) begin
			Character = 3'd0;
		end else if (character2) begin
			Character = 3'd1;
		end else if (character3) begin
			Character = 3'd2;
		end else if (character4) begin
			Character = 3'd3;
		end else if (character5) begin
			Character = 3'd4;
		end else begin
			Character = 3'd0;
		end 
	end
	
	///////////////////////////
	///// VGA Color Logic /////
	///////////////////////////
	always_comb begin
		if (blank == 0) begin
			red = 4'h0;
			green = 4'h0;
			blue = 4'h0;
		end else if ((DrawX >= MOUSE_X && DrawX < (MOUSE_X + `pencilSize)) && 
						 (DrawY > (MOUSE_Y - `pencilSize) && DrawY <= MOUSE_Y)) begin
				unique case(PENCIL_DATA)
					3'h0 : begin
						if (characterBox) begin
							red = 4'hF;
							green = 4'h0;
							blue = 4'h0;
						end else if (DATA_OUT[DrawX[4:0]] == 1) begin
							red = 4'hF;
							green = 4'hF;
							blue = 4'hF;
						end else if (character1 || character2 || character3 || character4 || character5) begin
							if (ROM_data[~(DrawX[2:0])] == 1) begin
								red = 4'hF;
								green = 4'hF;
								blue = 4'hF;
							end else begin
								red = 4'h0;
								green = 4'h0;
								blue = 4'h0;
							end
						end else begin
							red = 4'h0;
							green = 4'h0;
							blue = 4'h0;
						end
					end
					3'h1 : begin
						red = 4'h0;
						green = 4'h0;
						blue = 4'h0;
					end
					3'h2 : begin
						red = 4'hF;
						green = 4'hD;
						blue = 4'h0;
					end
					3'h3 : begin
						red = 4'h6;
						green = 4'h6;
						blue = 4'h6;
					end
					3'h4 : begin
						red = 4'hB;
						green = 4'hB;
						blue = 4'hB;
					end
					3'h5 : begin
						red = 4'hF;
						green = 4'hE;
						blue = 4'hC;
					end
					3'h6 : begin
						red = 4'hF;
						green = 4'hA;
						blue = 4'hC;
					end
					3'h7 : begin
						red = 4'h9;
						green = 4'h7;
						blue = 4'h4;
					end
				endcase
		end else if(characterBox) begin
			red = 4'hF;
			green = 4'h0;
			blue = 4'h0;
		end else if (character1 || character2 || character3 || character4 || character5) begin
			if (ROM_data[~(DrawX[2:0])] == 1) begin
				red = 4'hF;
				green = 4'hF;
				blue = 4'hF;
			end else begin
				red = 4'h0;
				green = 4'h0;
				blue = 4'h0;
			end
		end else if (DATA_OUT[DrawX[4:0]] == 1) begin
			red = 4'hF;
			green = 4'hF;
			blue = 4'hF;
		end else begin
			red = 4'h0;
			green = 4'h0;
			blue = 4'h0;
		end
	end
endmodule
