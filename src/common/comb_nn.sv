module comb_nn #(
    parameter int InputWidth = 49,
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumInputLayer = 37,
    parameter int NumHiddenLayer = 1,
    parameter int NeuronsPerHiddenLayer = 4,
    parameter int NumOutputLayer = 4,
    parameter int EnableHiddenLayer = 0
) (
    input logic clk_i,
    input logic reset_i,

    input logic [(DataWidth*InputWidth)-1:0] actv_i,
    output logic [(DataWidth*NumOutputLayer)-1:0] actv_o,
    input logic [(NumInputLayer*InputWidth)-1:0] req_i,
    output logic [(NumInputLayer*InputWidth)-1:0] ack_o,
    output logic [NumOutputLayer-1:0] req_o,
    input logic [NumOutputLayer-1:0] ack_i,
    //shift in
    input logic shift_i,
    input logic [DataWidth-1:0] weights_i,
    // input logic [DataWidth-1:0] bias_i,
    //shift out
    output logic [DataWidth-1:0] weights_o,
    // output logic [DataWidth-1:0] bias_o,
    output logic [(DataWidth*NumOutputLayer)-1:0] output_o,

    input logic [DataWidth-1:0] data_in

);

  localparam int TotalNumNeurons = (NumInputLayer) +
    (NeuronsPerHiddenLayer*NumHiddenLayer *EnableHiddenLayer) + (NumOutputLayer);
  localparam int OutputLayerInputs = EnableHiddenLayer ? NeuronsPerHiddenLayer : NumInputLayer;
  localparam  int InputLayerWeights = (NumInputLayer * (InputWidth+1));
  localparam int HiddenLayerWeights =  (NumInputLayer*(NeuronsPerHiddenLayer+1)
  *NumHiddenLayer*EnableHiddenLayer);
  localparam int OutputLayerWeights = (NumOutputLayer * (OutputLayerInputs+1));
  localparam int TotalWeights = InputLayerWeights + HiddenLayerWeights
  + OutputLayerWeights;
  //input layer signals
  logic [(NumInputLayer)-1:0] input_layer_reqs;
  logic [NeuronsPerHiddenLayer-1:0] [NumInputLayer-1:0] input_layer_acks;
  logic [(NumInputLayer)-1:0][DataWidth-1:0] in_layer_actv;

  //hidden layer sigbdv bdbvbvzfbvfals
  logic [NumHiddenLayer-1:0][NeuronsPerHiddenLayer-1:0][0:0] hidden_layer_reqs;
  logic [NumHiddenLayer-1:0] [NeuronsPerHiddenLayer-1:0][NeuronsPerHiddenLayer-1:0]  hidden_layer_acks;
  logic [NumHiddenLayer-1:0][NeuronsPerHiddenLayer-1:0][DataWidth-1:0] hidden_layer_actv;
  logic [(TotalNumNeurons):0][WeigthsWidth-1:0] weights;

  assign weights[0] = weights_i;
  assign weights_o  = weights[TotalNumNeurons];


  for (genvar i = 0; i < NumInputLayer; i++) begin : gen_input_layer
    logic [NeuronsPerHiddenLayer-1:0] temp_ack;
    logic [DataWidth-1:0] temp_actv[NumInputLayer];
    for (genvar k = 0; k < NeuronsPerHiddenLayer; k++) begin
      assign temp_ack[k] = input_layer_acks[k][i];
    end
    neuron_comb #(
        .NumInputs(InputWidth),
        .NumOutputs(NeuronsPerHiddenLayer),
        .DataWidth(DataWidth),
        .WeigthsWidth(WeigthsWidth),
        .Layer(1)
    ) neuron_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .shift_i(shift_i),
        .scan_di(weights[i]),
        .scan_do(weights[i+1]),
        .actv_o(in_layer_actv[i]),
        .actv_i(actv_i)
    );
  end

  if (EnableHiddenLayer) begin : gen_enable_hidden_layer
    for (genvar i = 0; i < NumHiddenLayer; i++) begin : gen_hidden_layer
      if (i == 0) begin : gen_first_hidden_layer
        //generate neurons
        for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_neurons
          localparam int Count = NumInputLayer + j;
          localparam int NumOutputs = (i == (NumHiddenLayer - 1)) ? NumOutputLayer : NeuronsPerHiddenLayer;
          logic [NeuronsPerHiddenLayer-1:0] temp_ack_in;
          //unpack acks in from upstream layer
          for (genvar k = 0; k < NumOutputs; k++) begin
            assign temp_ack_in[k] = hidden_layer_acks[i][j][k];
          end
          neuron_comb #(
              .NumInputs(NumInputLayer),
              .DataWidth(DataWidth),
              .WeigthsWidth(WeigthsWidth),
              .NumOutputs(NumOutputs),
              .Layer(1)
          ) neuron_inst (
              .clk_i(clk_i),
              .reset_i(reset_i),
              .shift_i(shift_i),
              .scan_di(weights[Count]),
              .scan_do(weights[Count+1]),
              .actv_o(hidden_layer_actv[i][j]),
              .actv_i(in_layer_actv)
          );
        end
      end else begin : gen_middle_hidden_layer
        for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_neurons
          localparam int NumOutputs = (i == NumHiddenLayer - 1) ? NumOutputLayer : NeuronsPerHiddenLayer;
          localparam int Count = NumInputLayer + (i * NeuronsPerHiddenLayer + j);
          logic [NeuronsPerHiddenLayer-1:0] temp_ack_in;
          //unpack acks in from upstream layer
          for (genvar k = 0; k < NeuronsPerHiddenLayer; k++) begin
            assign temp_ack_in[k] = hidden_layer_acks[i][k][j];
          end
          neuron_comb #(
              .NumInputs(NeuronsPerHiddenLayer),
              .DataWidth(DataWidth),
              .WeigthsWidth(WeigthsWidth),
              .NumOutputs(NumOutputs),
              .Layer(1)
          ) neuron_inst (
              .clk_i(clk_i),
              .reset_i(reset_i),
              .shift_i(shift_i),
              .scan_di(weights[Count]),
              .scan_do(weights[Count+1]),
              .actv_o(hidden_layer_actv[i][j]),
              .actv_i(hidden_layer_actv[(i-i)])
          );
        end
      end
    end

    for (genvar i = 0; i < NumOutputLayer; i++) begin : gen_output_layer
      localparam int Count = (NumInputLayer) + (NeuronsPerHiddenLayer * NumHiddenLayer) + i;
      neuron_comb #(
          .NumInputs(OutputLayerInputs),
          .DataWidth(DataWidth),
          .WeigthsWidth(WeigthsWidth),
          .NumOutputs(1),
          .Layer(2)
      ) neuron_inst (
          .clk_i(clk_i),
          .reset_i(reset_i),
          .shift_i(shift_i),
          .scan_di(weights[Count]),
          .scan_do(weights[Count+1]),
          .actv_o(actv_o[((DataWidth*i))+:DataWidth]),
          .actv_i(hidden_layer_actv[(NumHiddenLayer-1)])
      );
    end
  end
  else begin: gen_bypass_hidden_ouput
    for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_neurons
      localparam int Count = NumInputLayer + j;
      localparam int NumOutputs = (j == (NumHiddenLayer - 1)) ? NumOutputLayer : NeuronsPerHiddenLayer;
      logic [NeuronsPerHiddenLayer-1:0] temp_ack_in;
      neuron_comb #(
          .NumInputs(NumInputLayer),
          .DataWidth(DataWidth),
          .WeigthsWidth(WeigthsWidth),
          .NumOutputs(1),
          .Layer(2)
      ) neuron_inst (
          .clk_i(clk_i),
          .reset_i(reset_i),
          .shift_i(shift_i),
          .scan_di(weights[Count]),
          .scan_do(weights[Count+1]),
          .actv_o(actv_o[((DataWidth*j))+:DataWidth]),
          .actv_i(in_layer_actv)
      );
    end
  end

endmodule
