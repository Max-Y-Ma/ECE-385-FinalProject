module font_rom ( 
	input logic [7:0] addr,
	output logic [7:0] data
);

	parameter ADDR_WIDTH = 8;
	parameter DATA_WIDTH =  8;
				
	// ROM Initialization			
	logic [DATA_WIDTH-1:0] ROM [2**ADDR_WIDTH-1];
	initial $readmemb("font_rom.mif", ROM);

	assign data = ROM[addr];

endmodule  