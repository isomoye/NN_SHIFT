module simple_nn #(
    parameter int NumInputLayer = 2,
    parameter int NumHiddenLayer = 1,
    parameter int NeuronsPerHiddenLayer = 3,
    parameter int NumOutputLayer = 2
) (
    input logic clk_i,
    input logic reset_i,

    input logic [(32*NumInputLayer)-1:0] actv_i,
    output logic [(32*NumOutputLayer)-1:0] actv_o,
    input logic [NumInputLayer-1:0] req_i,
    output logic [NumInputLayer-1:0] ack_o,
    output logic [NumOutputLayer-1:0] req_o,
    input logic [NumOutputLayer-1:0] ack_i,
    //shift in
    input logic shift_i,
    input logic [31:0] weights_i,
    // input logic [31:0] bias_i,
    //shift out
    output logic [31:0] weights_o,
    // output logic [31:0] bias_o,
    output logic [(32*NumOutputLayer)-1:0] output_o,

    input logic [31:0] data_in

);

  //   localparam int NumInputLayer = 2;
  //   localparam int NumHiddenLayer = 1;
  //   localparam int NeuronsPerHiddenLayer = 3;
  //   localparam int NumOutputLayer = 2;

  localparam int GenOuputLayer = 1;
  localparam int GenHiddenLayer = 1;
  localparam int NumLayers = 3;
  //localparam int NumWeights = 3;
  localparam int NeuronPerLayer = 3;
  localparam int WeigthsWidth = 32 * NeuronPerLayer;
  localparam int TotalNumNeurons = (NumInputLayer) +(NeuronsPerHiddenLayer*NumHiddenLayer) +
  (NumOutputLayer);
  localparam int FanOuts = (NumInputLayer);
  localparam int TotalFanOuts = (NumInputLayer*NeuronsPerHiddenLayer)
  +(NeuronsPerHiddenLayer*NumHiddenLayer) + (NeuronsPerHiddenLayer*NumOutputLayer);

  //(NumInputLayer) + (NumHiddenLayer * NeuronsPerHiddenLayer)
  //shift in
  //logic shift_i;
  //logic [(32*NumWeights)-1:0] weights_i;
  //logic [31:0] bias_i;
  //shift out
  //   logic [(32*NumWeights)-1:0] weights_o;
  //   logic [31:0] bias_o;
  //   logic [31:0] output_o;

  logic [31:0] weights[TotalNumNeurons+1];

  logic [(32 * TotalNumNeurons)-1:0] actv;

  logic [(TotalFanOuts)-1:0] req_in;
  logic [(TotalFanOuts)-1:0] ack_out;
  logic [(TotalFanOuts)-1:0] req_out;
  logic [(TotalFanOuts)-1:0] ack_in;


  //input layer signals
  logic [(NumInputLayer)-1:0] [NeuronsPerHiddenLayer-1:0] input_layer_reqs;
  logic [NeuronsPerHiddenLayer-1:0] [NumInputLayer-1:0] input_layer_acks;
  logic [(NumInputLayer)-1:0] [31:0] in_layer_actv;

  //hidden layer signals
  logic [NumHiddenLayer-1:0] [NeuronsPerHiddenLayer-1:0][NeuronsPerHiddenLayer-1:0] hidden_layer_reqs;
  logic [NumHiddenLayer-1:0] [NeuronsPerHiddenLayer-1:0][NeuronsPerHiddenLayer-1:0]  hidden_layer_acks;
  logic [NumHiddenLayer-1:0] [NeuronsPerHiddenLayer-1:0][31:0] hidden_layer_actv;


  assign weights[0] = weights_i;
  assign weights_o  = weights[TotalNumNeurons];


  for (genvar i = 0; i < NumInputLayer; i++) begin : gen_input_layer
    logic [NeuronsPerHiddenLayer-1:0] temp_ack;
    logic [31:0] temp_actv[NumInputLayer];
    for (genvar k = 0; k < NeuronsPerHiddenLayer; k++) begin
      assign temp_ack[k] = input_layer_acks[k][i];
    end
    neuron #(
        .NUM_INPUTS(1),
        .NUM_OUTPUTS(NeuronsPerHiddenLayer),
        .LAYER(0)
    ) neuron_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .shift_i(shift_i),
        .scan_di(weights[i]),
        .scan_do(weights[i+1]),
        .output_o(in_layer_actv[i]),
        .actv_i(actv_i[((32*i))+:32]),
        .req_i(req_i[i]),
        .ack_o(ack_o[i]),
        .req_o(input_layer_reqs[i]),
        .ack_i(temp_ack),
        .out_i(),
        .back_prop_i('0),
        .en_i('0),
        .result_i('0),
        .result_o()
    );
  end


  for (genvar i = 0; i < NumHiddenLayer; i++) begin : gen_hidden_layer
    if (i == 0) begin : gen_first_hidden_layer
      //generate neurons
      for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_neurons
        parameter int count = NumInputLayer + j;
        parameter int NumOutputs = (i == (NumHiddenLayer - 1)) ? NumOutputLayer : NeuronsPerHiddenLayer;
        logic [NumInputLayer-1:0] temp_req;
        logic [NeuronsPerHiddenLayer-1:0] temp_ack_in;
        logic [NeuronsPerHiddenLayer-1:0] temp_ack_out;
        logic [NeuronsPerHiddenLayer-1:0] temp_req_out;
        logic [(32*NumInputLayer)-1:0] temp_actv;
        logic [31:0] temp_out;

        for (genvar k = 0; k < NumOutputs; k++) begin
         assign temp_ack_in[k] = hidden_layer_acks[i][j][k];
        end
        for (genvar k = 0; k < NumInputLayer; k++) begin
         assign temp_req[k] = input_layer_reqs[k][j];
         assign temp_actv[(32*k)+:32] = in_layer_actv[k];
        end
        //unpack reqs in from
        always_comb begin : unpack_req
          // for (int k = 0; k < NumInputLayer; k++) begin
          //   //temp_req[k] = input_layer_reqs[(NumInputLayer*k)+j];
          //   //input_layer_acks[NumInputLayer*j+k] = temp_ack_out[k];
          //   //input_layer_acks[(i * NumInputLayer + j)] = temp_ack[k];
          //   // temp_ack[k] = hidden_layer_acks[i][j][k];
          //   temp_actv[(32*k)+:32] = in_layer_actv[k];
          // end
          // for (int k = 0; k < NeuronsPerHiddenLayer; k++) begin
          //   // hidden_layer_reqs[(i * NeuronsPerHiddenLayer + j) * NeuronsPerHiddenLayer + k] = 
          //   // temp_req_out[k];
          //   // temp_ack[k] = hidden_layer_acks[(i*NeuronsPerHiddenLayer+j)*NeuronsPerHiddenLayer+k];
          //   // hidden_layer_acks[((i-1)*NeuronsPerHiddenLayer+j)*NeuronsPerHiddenLayer+k] = 
          //   // temp_ack_out[k];
          // end
          // for (int k = 0; k < NumOutputs; k++) begin
          //   // temp_ack_in[k] = hidden_layer_acks[((i)*NeuronsPerHiddenLayer+k)*NeuronsPerHiddenLayer+j];
          //   // hidden_layer_reqs[(i*NeuronsPerHiddenLayer + j) * NeuronsPerHiddenLayer + k] = 
          //   // temp_req_out[k];
          // end
          // for (int k = 0; k < 32; k++) begin
          //  // hidden_layer_actv[(i*NeuronsPerHiddenLayer+j)*32+k] = temp_out[k];
          // end
        end
        neuron #(
            .NUM_INPUTS(NumInputLayer),
            .NUM_OUTPUTS(NumOutputs),
            .LAYER(0)
        ) neuron_inst (
            .clk_i(clk_i),
            .reset_i(reset_i),
            .shift_i(shift_i),
            .scan_di(weights[count]),
            .scan_do(weights[count+1]),
            .output_o(hidden_layer_actv[i][j]),
            .actv_i(temp_actv),  //actv[(32*NumInputLayer)-1:0]),
            .req_i(temp_req),
            .ack_o(input_layer_acks[j]),
            .req_o(hidden_layer_reqs[i][j]),
            .ack_i(temp_ack_in),
            .out_i(),
            .back_prop_i('0),
            .en_i('0),
            .result_i('0),
            .result_o()
        );
      end
    end else begin : gen_middle_hidden_layer
      for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_neurons
        parameter int NumOutputs = (i == NumHiddenLayer - 1) ? NumOutputLayer : NeuronsPerHiddenLayer;
        logic [NeuronsPerHiddenLayer-1:0] temp_ack_in;
        logic [NeuronsPerHiddenLayer-1:0] temp_ack_out;
        logic [NeuronsPerHiddenLayer-1:0] temp_req_in;
        logic [NumOutputs-1:0] temp_req_out;
        logic [(32*NeuronsPerHiddenLayer)-1:0] temp_actv;
        logic [31:0] temp_out;
        localparam count = NumInputLayer + (i * NeuronsPerHiddenLayer + j);
        //unpack reqs in from
        for(genvar k =0; k < NeuronsPerHiddenLayer; k++) begin
          assign temp_ack_in[k] = hidden_layer_acks[i][k][j];
          assign temp_req_in[k] = hidden_layer_reqs[i-1][k][j];
          assign temp_actv[(k * 32) +: 32]  = hidden_layer_actv[(i-i)][k];
        end
        neuron #(
            .NUM_INPUTS(NeuronsPerHiddenLayer),
            .NUM_OUTPUTS(NumOutputs),
            .LAYER(0)
        ) neuron_inst (
            .clk_i(clk_i),
            .reset_i(reset_i),
            .shift_i(shift_i),
            .scan_di(weights[count]),
            .scan_do(weights[count+1]),
            .output_o(hidden_layer_actv[i][j]),
            .actv_i(temp_actv),
            .req_i(temp_req_in),
            .ack_o(hidden_layer_acks[i-1][j]),
            .req_o(hidden_layer_reqs[i][j]),
            .ack_i(temp_ack_in),
            .out_i(),
            .back_prop_i('0),
            .en_i('0),
            .result_i('0),
            .result_o()
        );
      end
    end
  end

  for (genvar i = 0; i < NumOutputLayer; i++) begin : gen_output_layer
    logic [NeuronsPerHiddenLayer-1:0] temp_ack;
    logic [NeuronsPerHiddenLayer-1:0] temp_req_in;
    logic [(32*NeuronsPerHiddenLayer)-1:0] temp_actv;
    localparam count = (NumInputLayer) + (NeuronsPerHiddenLayer * NumHiddenLayer) + i;
    //unpack reqs in from
    for (genvar k = 0; k < NeuronsPerHiddenLayer; k++) begin
      assign temp_req_in[k] = hidden_layer_reqs[(NumHiddenLayer-1)][k][i];
      assign temp_actv[(k * 32) +: 32]  = hidden_layer_actv[(NumHiddenLayer-1)][k];
    end
    neuron #(
        .NUM_INPUTS(NeuronsPerHiddenLayer),
        .NUM_OUTPUTS(1),
        .LAYER(0)
    ) neuron_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .shift_i(shift_i),
        .scan_di(weights[count]),
        .scan_do(weights[count+1]),
        .output_o(actv_o[((32*i))+:32]),
        .actv_i(temp_actv),
        .req_i(temp_req_in),
        .ack_o(hidden_layer_acks[NumHiddenLayer-1][i]),
        .req_o(req_o[i]),
        .ack_i(ack_i[i]),
        .out_i(),
        .back_prop_i('0),
        .en_i('0),
        .result_i('0),
        .result_o()
    );
  end

endmodule