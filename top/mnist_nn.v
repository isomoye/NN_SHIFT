module mnist_nn #(
    parameter int InputWidth = 28*28,
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumInputLayer = 100,
    parameter int NumHiddenLayer = 1,
    parameter int NeuronsPerHiddenLayer = 50,
    parameter int NumOutputLayer = 10,
    parameter int EnableHiddenLayer = 1
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

simple_nn # (
    .InputWidth(InputWidth),
    .DataWidth(DataWidth),
    .WeigthsWidth(WeigthsWidth),
    .NumInputLayer(NumInputLayer),
    .NumHiddenLayer(NumHiddenLayer),
    .NeuronsPerHiddenLayer(NeuronsPerHiddenLayer),
    .NumOutputLayer(NumOutputLayer),
    .EnableHiddenLayer(EnableHiddenLayer)
  )
  mnist_nn_inst (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .actv_i(actv_i),
    .actv_o(actv_o),
    .req_i(req_i),
    .ack_o(ack_o),
    .req_o(req_o),
    .ack_i(ack_i),
    .shift_i(shift_i),
    .weights_i(weights_i),
    .weights_o(weights_o),
    .output_o(output_o),
    .data_in(data_in)
  );
endmodule
