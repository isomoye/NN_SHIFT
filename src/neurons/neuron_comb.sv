module neuron_comb #(
    parameter int NumInputs = 4,
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumOutputs = NumInputs,
    parameter int Layer = 0,
    parameter int EnableBackPropagation = 0
    // parameter int w1   = 1,
    // parameter int w2   = 1,
    // parameter int w3   = 1,
    // parameter int bias = 1
) (
    input logic clk_i,
    input logic reset_i,
    //shift in
    input logic shift_i,
    input logic [WeigthsWidth-1 : 0] scan_di,
    //shift out
    output logic [WeigthsWidth-1 : 0] scan_do,
    //output logic [DataWidth-1 :0] bias_o,
    output logic [DataWidth-1 : 0] actv_o,
    //forward-propagation upstream signals
    input logic [(DataWidth*NumInputs)-1:0] actv_i,
    //forward-propagation downstream signals
    //shared multiplier handshake
    // output logic mult_req_o,
    // input logic mult_ack_i,
    // output logic [DataWidth-1 :0] mult_actv_o,
    // output logic [(DataWidth*NumInputs)-1:0] mult_weights_o,
    // output logic [DataWidth-1 :0] mult_bias_o,
    // input logic [DataWidth-1 :0] mult_actv_i,
    // input logic mult_done_i,
    // output logic mult_ack_i,
    // //back-propagation signals
    input logic back_prop_req_i,
    output logic back_prop_ack_o,
    output logic back_prop_req_o,
    input logic [NumInputs-1 : 0] back_prop_ack_i,
    input logic [(DataWidth * NumOutputs)-1 : 0] result_i,
    output logic [DataWidth-1 : 0] result_o
);


  typedef enum logic [2:0] {
    ST_IDLE,
    ST_GET_INPUTS,
    ST_GET_MULT,
    ST_GET_ACTV,
    ST_GET_SIGMOID,
    ST_OUTPUT
  } st_nueron_e;



  st_nueron_e state;

  //internal signals
  logic [DataWidth-1:0] actv;
  logic signed [DataWidth-1 : 0] sum;
  logic [15:0] sumAddress;
  logic [7:0] afterActivation;
  logic [(WeigthsWidth*NumInputs)-1:0] weights;
  logic [WeigthsWidth-1 : 0] bias;
  //logic [DataWidth-1:0] actv_o;

  logic [DataWidth-1 : 0] dactv;
  logic [(WeigthsWidth)-1:0] dweights;
  logic [WeigthsWidth-1 : 0] dbias;
  logic [DataWidth-1 : 0] dz;



  logic [DataWidth-1:0 ] result [NumInputs] ;
  logic [NumInputs-1:0] overflow;
  logic [DataWidth-1 : 0] hold_result;
  logic delay_en;


  //update weights signals
  logic update_weigths;
  logic [WeigthsWidth-1:0] new_weights;


  logic [NumInputs-1:0] req;
  logic [NumOutputs-1:0] acks;

  //multiplier signals
  logic mult_start;
  logic mult_done;
  logic mult_ack_out;
  logic mult_ack_in;
  logic [$clog2(NumInputs)-1:0] counter;

//   assign mult_actv_o = actv;
//   assign mult_weights_o = weights;


  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= ST_IDLE;
    end  //shift in data
    else
    if (update_weigths) begin

    end else if (shift_i) begin
      //soft reset
      //shift in
      {bias, weights} <= {weights, scan_di};
      //bias <= bias_i;
      //shift out
      scan_do <= bias;
      //bias_o <= bias;
    end else begin
    end
  end

  always_comb begin : comput_neuron_output
    for (int i = 0; i < NumInputs + 1; i++) begin
        logic signed [DataWidth-1 : 0] temp_sum;
        if (i == 0) begin
          sum = bias;
          temp_sum = bias;
        end else begin
          sum = sum + {overflow[i-1],result[i-1]};
          temp_sum = sum + {overflow[i-1],result[i-1]};
        end
      end
  end

  //Output layer
  if (Layer == 2) begin : gen_sigmoid
    sigmoid sigmoid_inst (
        .x  (sum),
        .out(afterActivation)
    );
  end  //Not output layer
  else begin: gen_relu
    assign afterActivation = (signed'(sum) > 0) ? sum : '0;
  end
  assign actv_o = afterActivation;


  if (EnableBackPropagation) begin : gen_back_propagation
  end else begin : gen_no_bp
    assign update_weigths = '0;
  end

  for(genvar i= 0 ; i < NumInputs; i++) begin: gen_multipliers
    qmult #(
        .Q(DataWidth/2),
        .N(DataWidth)
    ) qmult_inst (
        .i_multiplicand( actv_i[DataWidth*i +: DataWidth]),
        .i_multiplier(weights[WeigthsWidth*i +: WeigthsWidth]),
        .o_result(result[i]),
        .ovr(overflow[i])
    );
  end

endmodule
