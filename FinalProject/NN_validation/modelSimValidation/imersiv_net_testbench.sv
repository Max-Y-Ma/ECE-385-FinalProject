`timescale 1ns / 1ps
`include "include.v"
`define MaxTestSamples 50
`define NUM_IMAGE_REGS 28
`define IMAGE_SIZE 784

module imersiv_net_testbench();
    // Logic Variables
    logic RESET;
    logic CLK;
    logic [31:0] IMAGE_OUT [`NUM_IMAGE_REGS];
    logic [31:0] CHARACTER_REG;
    logic [7:0] fileName [3:0];
    logic [31:0] expected;

    integer match;
    integer error;

    // DUT
    imersiv_net DUT(.*);

    // Clock Initialization 
    initial begin
        CLK = 1'b0;
	match = 0;
	error = 0;
    end

    always
        #20 CLK = ~CLK;
   
    function [7:0] to_ascii (input integer a);
        begin
            to_ascii = a + 48;
        end
    endfunction
  
    // Compute Current Test Data
    logic [3:0] mem [`IMAGE_SIZE:0];
    task sendData(input integer t);
    begin        
        $readmemb({"testData/test_data_", fileName[3], fileName[2], fileName[1], fileName[0],".txt"}, mem);
        // Assign Image Buffer
        for (t=0; t < `IMAGE_SIZE; t=t+1) begin
            IMAGE_OUT[t / 28][27 - t % 28] <= mem[t];
        end 
        expected = mem[t];  // Assign Expected Value
    end
    endtask
  
    // Run Test
    integer i, j, t, k;
    integer start;
    integer testCount;
    integer currentTest;
    initial begin
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
            sendData(t);
	    RESET = 0;
            #100
            RESET = 1;
            #100;
            RESET = 0;
            #100
            start = $time;
	    #40000

            // Process Results
            if(CHARACTER_REG == expected) begin
                $display("Match");
                match++;
            end else begin
		$display("Error");
                error++;
            end
            
            $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x", testCount+1, match*100.0 / (testCount+1), CHARACTER_REG, expected);
            $display("Total execution time",,,,$time-start,,"ns");
        end
	$display("Matches: %0d, Error: %0d", match, error);
        $display("Accuracy: %f", match*100.0 / testCount);        
	$stop;
    end

endmodule