`include "include.v"

module weight_memory #(parameter numWeight = 3, addressWidth=10, dataWidth=16, weightFile="w_1_15.mif") ( 
    input logic CLK,
    input logic [addressWidth:0] radd,
    output logic [dataWidth-1:0] wout
);
    logic [dataWidth-1:0] mem [numWeight-1:0];
    
    initial $readmemb(weightFile, mem);
    
    always_ff @(posedge CLK) begin
        wout <= mem[radd];
    end 

endmodule
