/***********************************************************************/
//
// Single Neuron w/ Own Weight Memory, Bias, and Sigmoid Memories
//
/***********************************************************************/
//`define DEBUG
`include "include.v"

module neuron #(parameter numWeight=784, dataWidth=16, sigmoidSize=10, weightIntWidth=4, biasFile="", weightFile="")(
    input                   CLK,
    input                   RESET,
    input [dataWidth-1:0]   myinput,
    input                   myinputValid,
    output[dataWidth-1:0]   out,
    output reg              outvalid   
);
    
    parameter addressWidth = $clog2(numWeight);
  
    reg [addressWidth:0] r_addr; //read address has to reach until numWeight hence width is 1 bit more
    wire [dataWidth-1:0] w_out;
    reg [2*dataWidth-1:0] mul; 
    reg [2*dataWidth-1:0] sum;
    reg [2*dataWidth-1:0] bias;
    reg [31:0] biasReg[0:0];
    reg weight_valid;
    reg mult_valid;
    wire mux_valid;
    reg sigValid; 
    wire [2*dataWidth:0] comboAdd;
    wire [2*dataWidth:0] BiasAdd;
    reg  [dataWidth-1:0] myinputd;
    reg muxValid_d;
    reg muxValid_f;
    reg addr=0;
	
    assign mux_valid = mult_valid;
    assign comboAdd = mul + sum;
    assign BiasAdd = bias + sum;
    
    // Instantiate Bias Register
    initial $readmemb(biasFile, biasReg);
    always @(posedge CLK) begin
        bias <= {biasReg[addr][dataWidth-1:0],{dataWidth{1'b0}}};
    end
    
    // Grab Next Weight
    always @(posedge CLK) begin
        if(RESET|outvalid)
            r_addr <= 0;
        else if(myinputValid)
            r_addr <= r_addr + 1;
    end
    
    // Weight * Input
    always @(posedge CLK) begin
        mul  <= $signed(myinputd) * $signed(w_out);
    end
    
    // Checking Overflow Conditions during Accumulate
    always @(posedge CLK) begin
        if(RESET|outvalid) begin
            sum <= 0;
        end else if((r_addr > numWeight) & muxValid_f)
        begin
            if(!bias[2*dataWidth-1] &!sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) //If bias and sum are positive and after adding bias to sum, if sign bit becomes 1, saturate
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(bias[2*dataWidth-1] & sum[2*dataWidth-1] &  !BiasAdd[2*dataWidth-1]) //If bias and sum are negative and after addition if sign bit is 0, saturate
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= BiasAdd; 
        end
        else if(mux_valid)
        begin
            if(!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= comboAdd; 
        end
    end
    
    // Control Signals
    always @(posedge CLK) begin
        myinputd <= myinput;
        weight_valid <= myinputValid;
        mult_valid <= weight_valid;
        sigValid <= ((r_addr >= numWeight) & muxValid_f) ? 1'b1 : 1'b0;  // Changed from == to >=
        outvalid <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end
    
    // Instantiation of Memory for Weights
    weight_memory #(.numWeight(numWeight), .addressWidth(addressWidth), .dataWidth(dataWidth), .weightFile(weightFile)) WM_(
        .CLK(CLK),
        .radd(r_addr),
        .wout(w_out)
    );
    
    // Instantiation of ROM for Sigmoid
    sigmoid_rom #(.inWidth(sigmoidSize),.dataWidth(dataWidth)) SR_(
        .CLK(CLK),
        .x(sum[2*dataWidth-1-:sigmoidSize]),
        .SIG_DATA(out)
    );
    
endmodule