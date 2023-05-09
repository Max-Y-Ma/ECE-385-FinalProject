/***********************************************************************/
//
//		Neural Network Source Code for Imersiv Net
//		Description: 784 Input Nodes, 1 Hidden Layer, 10 Output Nodes
//
//      784 Input Nodes -> 20 Hidden Nodes (Layer_1) -> 10 Output Nodes (Layer_2)
//						 
//		Date: 4/21/2023
//		Revision: v1.0
//		Authors: Max Ma & Dhruv Kulgod
//
/***********************************************************************/
`include "include.v"
`define NUM_IMAGE_REGS 28

module imersiv_net (
   input logic CLK,
   input logic RESET,
	input logic [31:0] IMAGE_OUT[`NUM_IMAGE_REGS],
	output logic [31:0] CHARACTER_REG
    // Add Start Signal
    // ADD Character RDY Signal or Interrupt
);

logic out_valid;

localparam IDLE = 'd0, SEND = 'd1;

// State Machine for Image Buffer Transfer to Layer 1
logic [`dataWidth-1:0] image_buffer_data;
logic image_buffer_valid;
logic buffer_state;
integer buffer_row;
integer buffer_column;
logic start;
assign start = 1'b1;
always @(posedge CLK) begin
	if(RESET) begin
		buffer_state <= IDLE;
		buffer_row <= 0;
		buffer_column <= 0;
		image_buffer_valid <=0;
		image_buffer_data <= 0;
	end else begin
		case (buffer_state)
			IDLE : begin
                buffer_row <= 0;
		        buffer_column <= 0;
                image_buffer_valid <= 0;
		image_buffer_data <= 0;
				if (start)
                    buffer_state <= SEND;
            end
			SEND : begin
			    if (buffer_column < `NUM_IMAGE_REGS - 1) begin
		            buffer_column <= buffer_column + 1;
	            end else begin
		            buffer_column <= 0;
		            buffer_row <= buffer_row + 1;
                end

                image_buffer_valid <= 1;
                image_buffer_data <= {{`weightIntWidth - 1{1'b0}}, IMAGE_OUT[buffer_row][27 - buffer_column], {`dataWidth - `weightIntWidth{1'b0}}};

                if (buffer_row >= `NUM_IMAGE_REGS) begin
                    buffer_state <= IDLE;
                    image_buffer_valid <= 0;
                end
            end
        endcase
	end
end

logic [`numNeuronLayer1-1:0] o1_valid;
logic [`numNeuronLayer1*`dataWidth-1:0] x1_out;
logic [`numNeuronLayer1*`dataWidth-1:0] holdData_1;
logic [`dataWidth-1:0] out_data_1;
logic data_out_valid_1;

Layer_1 #(.NN(`numNeuronLayer1), .numWeight(`numWeightLayer1), .dataWidth(`dataWidth), .sigmoidSize(`sigmoidSize), .weightIntWidth(`weightIntWidth)) Layer_1_ (
	.CLK(CLK),
	.RESET(RESET),
	.x_valid(image_buffer_valid),
	.x_in(image_buffer_data),
	.o_valid(o1_valid),
	.x_out(x1_out)
);

// State machine for Data Pipelining
logic       state_1;
integer   count_1;
always @(posedge CLK)
begin
    if(RESET)
    begin
        state_1 <= IDLE;
        count_1 <= 0;
        data_out_valid_1 <=0;
    end
    else
    begin
        case(state_1)
            IDLE: begin
                count_1 <= 0;
                data_out_valid_1 <=0;
                if (o1_valid[0] == 1'b1)
                begin
                    holdData_1 <= x1_out;
                    state_1 <= SEND;
                end
            end
            SEND: begin
                out_data_1 <= holdData_1[`dataWidth-1:0];
                holdData_1 <= holdData_1>>`dataWidth;
                count_1 <= count_1 + 1;
                data_out_valid_1 <= 1;
                if (count_1 == `numNeuronLayer1)
                begin
                    state_1 <= IDLE;
                    data_out_valid_1 <= 0;
                end
            end
        endcase
    end
end

logic [`numNeuronLayer2-1:0] o2_valid;
logic [`numNeuronLayer2*`dataWidth-1:0] x2_out;

Layer_2 #(.NN(`numNeuronLayer2), .numWeight(`numWeightLayer2), .dataWidth(`dataWidth), .sigmoidSize(`sigmoidSize), .weightIntWidth(`weightIntWidth)) Layer_2_ (
	.CLK(CLK),
	.RESET(RESET),
	.x_valid(data_out_valid_1),
	.x_in(out_data_1),
	.o_valid(o2_valid),
	.x_out(x2_out)
);

// Module to Determine Final Character Output
maxFinder #(.numInput(`numNeuronLayer2), .inputWidth(`dataWidth)) MF_ (
    .CLK(CLK),
    .i_data(x2_out),
    .i_valid(o2_valid[0]),
    .o_data(CHARACTER_REG),
    .o_data_valid(out_valid)
);

endmodule
