/***********************************************************************/
//
// Reference utils/genSigmoid.py for updating the sigmoid.hex data
//
/***********************************************************************/
module sigmoid_rom #(parameter inWidth=10, dataWidth=16) (
    input logic CLK,
    input logic [inWidth-1:0] x,
    output logic [dataWidth-1:0] SIG_DATA
);
    
    logic [dataWidth-1:0] sig_rom [2**inWidth-1:0];
    logic [inWidth-1:0] y;
	
	 initial $readmemb("sigmoid.mif", sig_rom);

    always_ff @(posedge CLK) begin
        if($signed(x) >= 0)
            y <= x + (2**(inWidth - 1));
        else 
            y <= x - (2**(inWidth - 1));      
    end
    
    assign SIG_DATA = sig_rom[y];
    
endmodule
