module Layer_2 #(parameter NN = 30, numWeight=784, dataWidth=16, sigmoidSize=1, weightIntWidth=4) (
    input                       CLK,
    input                       RESET,
    input                       x_valid,
    input [dataWidth-1:0]       x_in,
    output [NN-1:0]             o_valid,
    output [NN*dataWidth-1:0]   x_out
);
    
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_0.mif"), .biasFile("w_b/b_2_0.mif"))n_0(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[0*dataWidth+:dataWidth]),
        .outvalid(o_valid[0])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_1.mif"), .biasFile("w_b/b_2_1.mif"))n_1(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[1*dataWidth+:dataWidth]),
        .outvalid(o_valid[1])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_2.mif"), .biasFile("w_b/b_2_2.mif"))n_2(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[2*dataWidth+:dataWidth]),
        .outvalid(o_valid[2])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_3.mif"), .biasFile("w_b/b_2_3.mif"))n_3(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[3*dataWidth+:dataWidth]),
        .outvalid(o_valid[3])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_4.mif"), .biasFile("w_b/b_2_4.mif"))n_4(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[4*dataWidth+:dataWidth]),
        .outvalid(o_valid[4])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_5.mif"), .biasFile("w_b/b_2_5.mif"))n_5(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[5*dataWidth+:dataWidth]),
        .outvalid(o_valid[5])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_6.mif"), .biasFile("w_b/b_2_6.mif"))n_6(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[6*dataWidth+:dataWidth]),
        .outvalid(o_valid[6])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_7.mif"), .biasFile("w_b/b_2_7.mif"))n_7(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[7*dataWidth+:dataWidth]),
        .outvalid(o_valid[7])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_8.mif"), .biasFile("w_b/b_2_8.mif"))n_8(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[8*dataWidth+:dataWidth]),
        .outvalid(o_valid[8])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_2_9.mif"), .biasFile("w_b/b_2_9.mif"))n_9(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[9*dataWidth+:dataWidth]),
        .outvalid(o_valid[9])
);


endmodule