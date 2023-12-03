
module simple_nn_tb;

  // Parameters
  localparam int NumInputLayer = 37;
  localparam int NumHiddenLayer = 1;
  localparam int InputWidth = 49;
  localparam int NeuronsPerHiddenLayer = 4;
  localparam int NumOutputLayer = 4;
  localparam int DataWidth = 8;
  localparam int WeigthsWidth = DataWidth;
  localparam int EnableHiddenLayer = 0;

  //Ports
  reg clk_i;
  reg reset_i;
  reg [(DataWidth*InputWidth)-1:0] actv_i;
  reg [(DataWidth*NumOutputLayer)-1:0] actv_o;
  reg [(NumInputLayer*InputWidth) - 1:0] req_i;
  wire [(NumInputLayer*InputWidth) - 1:0] ack_o;
  wire [NumOutputLayer-1:0] req_o;
  reg [NumOutputLayer-1:0] ack_i;
  reg shift_i;
  reg [31:0] weights_i;
  wire [31:0] weights_o;
  wire [(DataWidth*NumOutputLayer)-1:0] output_o;
  reg [31:0] data_in;

  simple_nn #(
      .NumInputLayer(NumInputLayer),
      .NumHiddenLayer(NumHiddenLayer),
      .InputWidth(InputWidth),
      .DataWidth(DataWidth),
      .WeigthsWidth(WeigthsWidth),
      .NeuronsPerHiddenLayer(NeuronsPerHiddenLayer),
      .NumOutputLayer(NumOutputLayer),
      .EnableHiddenLayer(EnableHiddenLayer)
  ) simple_nn_inst (
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

  //always #5  clk = ! clk ;

endmodule
