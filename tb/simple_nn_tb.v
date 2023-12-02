
module simple_nn_tb;

  // Parameters
  localparam int NumInputLayer = 2;
  localparam int NumHiddenLayer = 2;
  localparam int NeuronsPerHiddenLayer = 3;
  localparam int NumOutputLayer = 2;

  //Ports
  reg  clk_i;
  reg  reset_i;
  reg [(32*NumInputLayer)-1:0] actv_i;
  reg [(32*NumOutputLayer)-1:0] actv_o;
  reg [NumInputLayer-1:0] req_i;
  wire [NumInputLayer-1:0] ack_o;
  wire [NumOutputLayer-1:0] req_o;
  reg [NumOutputLayer-1:0] ack_i;
  reg  shift_i;
  reg [31:0] weights_i;
  wire [31:0] weights_o;
  wire [(32*NumOutputLayer)-1:0] output_o;
  reg [31:0] data_in;

  simple_nn # (
    .NumInputLayer(NumInputLayer),
    .NumHiddenLayer(NumHiddenLayer),
    .NeuronsPerHiddenLayer(NeuronsPerHiddenLayer),
    .NumOutputLayer(NumOutputLayer)
  )
  simple_nn_inst (
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