module Layer_1 #(parameter NN = 30, numWeight=784, dataWidth=16, sigmoidSize=1, weightIntWidth=4) (
    input                       CLK,
    input                       RESET,
    input                       x_valid,
    input [dataWidth-1:0]       x_in,
    output [NN-1:0]             o_valid,
    output [NN*dataWidth-1:0]   x_out
);
    
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_0.mif"), .biasFile("w_b/b_1_0.mif"))n_0(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[0*dataWidth+:dataWidth]),
        .outvalid(o_valid[0])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_1.mif"), .biasFile("w_b/b_1_1.mif"))n_1(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[1*dataWidth+:dataWidth]),
        .outvalid(o_valid[1])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_2.mif"), .biasFile("w_b/b_1_2.mif"))n_2(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[2*dataWidth+:dataWidth]),
        .outvalid(o_valid[2])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_3.mif"), .biasFile("w_b/b_1_3.mif"))n_3(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[3*dataWidth+:dataWidth]),
        .outvalid(o_valid[3])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_4.mif"), .biasFile("w_b/b_1_4.mif"))n_4(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[4*dataWidth+:dataWidth]),
        .outvalid(o_valid[4])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_5.mif"), .biasFile("w_b/b_1_5.mif"))n_5(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[5*dataWidth+:dataWidth]),
        .outvalid(o_valid[5])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_6.mif"), .biasFile("w_b/b_1_6.mif"))n_6(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[6*dataWidth+:dataWidth]),
        .outvalid(o_valid[6])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_7.mif"), .biasFile("w_b/b_1_7.mif"))n_7(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[7*dataWidth+:dataWidth]),
        .outvalid(o_valid[7])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_8.mif"), .biasFile("w_b/b_1_8.mif"))n_8(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[8*dataWidth+:dataWidth]),
        .outvalid(o_valid[8])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_9.mif"), .biasFile("w_b/b_1_9.mif"))n_9(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[9*dataWidth+:dataWidth]),
        .outvalid(o_valid[9])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_10.mif"), .biasFile("w_b/b_1_10.mif"))n_10(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[10*dataWidth+:dataWidth]),
        .outvalid(o_valid[10])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_11.mif"), .biasFile("w_b/b_1_11.mif"))n_11(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[11*dataWidth+:dataWidth]),
        .outvalid(o_valid[11])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_12.mif"), .biasFile("w_b/b_1_12.mif"))n_12(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[12*dataWidth+:dataWidth]),
        .outvalid(o_valid[12])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_13.mif"), .biasFile("w_b/b_1_13.mif"))n_13(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[13*dataWidth+:dataWidth]),
        .outvalid(o_valid[13])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_14.mif"), .biasFile("w_b/b_1_14.mif"))n_14(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[14*dataWidth+:dataWidth]),
        .outvalid(o_valid[14])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_15.mif"), .biasFile("w_b/b_1_15.mif"))n_15(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[15*dataWidth+:dataWidth]),
        .outvalid(o_valid[15])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_16.mif"), .biasFile("w_b/b_1_16.mif"))n_16(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[16*dataWidth+:dataWidth]),
        .outvalid(o_valid[16])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_17.mif"), .biasFile("w_b/b_1_17.mif"))n_17(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[17*dataWidth+:dataWidth]),
        .outvalid(o_valid[17])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_18.mif"), .biasFile("w_b/b_1_18.mif"))n_18(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[18*dataWidth+:dataWidth]),
        .outvalid(o_valid[18])
);
neuron #(.numWeight(numWeight), .dataWidth(dataWidth), .sigmoidSize(sigmoidSize), .weightIntWidth(weightIntWidth), .weightFile("w_b/w_1_19.mif"), .biasFile("w_b/b_1_19.mif"))n_19(
        .CLK(CLK),
        .RESET(RESET),
        .myinput(x_in),
        .myinputValid(x_valid),
        .out(x_out[19*dataWidth+:dataWidth]),
        .outvalid(o_valid[19])
);

endmodule