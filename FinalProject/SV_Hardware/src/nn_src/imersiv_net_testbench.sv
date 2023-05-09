`timescale 1ns / 1ps
`include "include.v"
`define MaxTestSamples 100
`define NUM_IMAGE_REGS 28
`define IMAGE_SIZE 784

module imersiv_net_testbench();
	// Logic Variables
	logic RESET;
	logic CLK;
	logic CHARACTER_IRQ;
	 
	// Avalon Address Variables
	logic AVL_READ;						// Avalon-MM Read
	logic AVL_WRITE;						// Avalon-MM Write
	logic AVL_CS;							// Avalon-MM Chip Select
	logic [4:0] AVL_ADDR;				// Avalon-MM Address
	logic [31:0] AVL_WRITEDATA;		// Avalon-MM Write Data
	logic [31:0] AVL_READDATA;	   // Avalon-MM Read Data
	 
	logic [7:0] fileName [3:0];
  	logic [31:0] expected;
	logic [31:0] result;

   	integer match;
   	integer error;
    
	// DUT
  	imersiv_net_avl_interface DUT(.*);

	// Initialization 
	initial begin
		CLK = 1'b1;
		match = 0;
		error = 0;
		RESET = 0;
		AVL_CS = 1'b0;
		AVL_WRITE = 1'b0;
		AVL_READ = 1'b0;
		AVL_ADDR = 1'b0;
		AVL_WRITEDATA = 32'd0;
		AVL_READDATA = 32'd0;
	end
	
	// Clock
	always
		#20 CLK = ~CLK;
	
   	function [7:0] to_ascii (input integer a);
       begin
           to_ascii = a + 48;
       end
   	endfunction
	 
	// Load Image 
	logic [3:0] mem [`IMAGE_SIZE:0];
	integer i, j;
	task loadImage();
		begin
			$readmemb({"testData/test_data_", fileName[3], fileName[2], fileName[1], fileName[0],".txt"}, mem);
			for (i=0; i < `NUM_IMAGE_REGS; i++) begin
				for (j=0; j < `NUM_IMAGE_REGS; j++) begin
					AVL_WRITEDATA[27 - j % 28] <= mem[28 * i + j];
				end
				AVL_WRITEDATA[31:28] = 4'h0;
				AVL_CS = 1'b1;
				AVL_WRITE = 1'b1;
				AVL_ADDR = i;
				@(posedge CLK);
			end
			expected <= mem[784];
			AVL_CS = 1'b0;
			AVL_WRITE = 1'b0;
		end
	endtask
	
	task readCharacter();
		begin
			@(posedge CLK);
			AVL_CS = 1'b1;
			AVL_READ = 1'b1;
			AVL_ADDR = 5'h1C;
			@(posedge CLK);
			@(posedge CLK);	// Two Cycle Read Latency
			@(posedge CLK);	// Two Cycle Read Latency
			result = AVL_READDATA;
			AVL_CS = 1'b0;
			AVL_READ = 1'b0;
		end
	endtask
  
   // Run Test
   integer start;
   integer testCount;
   integer currentTest;
   initial begin
		@(posedge CLK);
     	RESET = 1;
		@(posedge CLK);
		RESET = 0;
		for(testCount = 0; testCount < `MaxTestSamples; testCount++) begin
			// Prepare Data
			currentTest = testCount;
			fileName[0] = "0";
			fileName[1] = "0";
			fileName[2] = "0";
			fileName[3] = "0";
			i=0;
			while(currentTest != 0) begin
				fileName[i] = to_ascii(currentTest % 10);
				currentTest = currentTest / 10;
				i++;
			end
			loadImage();
			start = $time;
				
			#40000
			readCharacter();
			#200

			// Process Results
			if(result == expected) begin
				$display("Match");
				match++;
			end else begin
				$display("Error");
				error++;
			end
            
			$display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x", testCount+1, match*100.0 / (testCount+1), result, expected);
			$display("Total execution time",,,,$time-start,,"ns");
		end
		$display("Matches: %0d, Error: %0d", match, error);
		$display("Accuracy: %f", match*100.0 / testCount);        
		$stop;
	end
	
endmodule
