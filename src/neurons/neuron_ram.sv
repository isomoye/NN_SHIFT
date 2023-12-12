module neuron_ram #(
    parameter int NumInputs = 4,
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumOutputs = NumInputs,
    parameter int Layer = 0,
    parameter int NeuronsPerLayer = 5,
    parameter int NeuronInstance = 0,
    parameter int EnableBackPropagation = 0
    // parameter int w1   = 1,
    // parameter int w2   = 1,
    // parameter int w3   = 1,
    // parameter int bias = 1
) (
    input logic clk_i,
    input logic reset_i,
    //downstream ram signals
    output logic [$clog2(NumInputs)-1:0] in_actv_addr_o,
    output logic in_actv_we_o,
    input logic [DataWidth-1 : 0] in_actv_din_i,
    output logic [DataWidth-1 : 0] in_actv_dout_o,
    //weigths ram signals
    output logic [$clog2(DataWidth)-1:0] wgt_addr_o,
    output logic wgt_we_o,
    input logic [DataWidth-1 : 0] wgt_din_i,
    output logic [DataWidth-1 : 0] wgt_dout_o,
    //uptream ram signals
    output logic [$clog2(NeuronsPerLayer)-1:0] out_actv_addr_o,
    output logic out_actv_we_o,
    input logic [DataWidth-1 : 0] out_actv_din_i,
    output logic [DataWidth-1 : 0] out_actv_dout_o,
    //downstream mutex signals
    output logic in_actv_req_o,
    input logic in_actv_grant_i,
    //weight mutex signals
    output logic wgt_req_o,
    input logic wgt_grant_i,
    //upstream mutex signals
    output logic out_actv_req_o,
    input logic out_actv_grant_i,
    //forward propagation
    // input logic [(DataWidth*NumInputs)-1:0] actv_i,
    // output logic [DataWidth-1 : 0] actv_o,
    input logic req_i,
    output logic ack_o,

    output  logic req_o,
    input logic ack_i,

    input  logic mult_done_i,
    input  logic mult_busy_i,
    output logic mult_start_o,
    input  logic mult_grant_i,
    output logic mult_req_o,

    output logic [  (DataWidth)-1:0] mult_a_o,
    output logic [  (DataWidth)-1:0] mult_b_o,
    input  logic [(DataWidth*2)-1:0] mult_result_i

    //shift in
    // input logic shift_i,
    // input logic [WeigthsWidth-1 : 0] scan_di,
    // input logic [DataWidth-1 :0] bias_i,weights
    //shift out
    // output logic [WeigthsWidth-1 : 0] scan_do,
    //output logic [DataWidth-1 :0] bias_o,
    // output logic [DataWidth-1 : 0] out_o,
    //forward-propagation upstream signals
    // input logic [(DataWidth*NumInputs)-1:0] actv_i,
    // input logic [NumInputs-1:0] req_i,
    // output logic [NumInputs-1:0] ack_o,
    //forward-propagation downstream signals
    // output logic in_actv_req_o,
    // input logic [NumOutputs-1:0] ack_i,
    // output logic [DataWidth-1 : 0] out_i,
    //shared multiplier handshake
    // output logic mult_in_actv_req_o,
    // input logic mult_ack_i,
    // output logic [DataWidth-1 :0] mult_actv_o,
    // output logic [(DataWidth*NumInputs)-1:0] mult_weights_o,
    // output logic [DataWidth-1 :0] mult_bias_o,
    // input logic [DataWidth-1 :0] mult_actv_i,
    // input logic mult_done_i,
    // output logic mult_ack_i,
    // //back-propagation signals
    // input logic back_prop_req_i,
    // output logic back_prop_ack_o,
    // output logic back_prop_in_actv_req_o,
    // input logic [NumInputs-1 : 0] back_prop_ack_i,
    // input logic [(DataWidth * NumOutputs)-1 : 0] result_i,
    // output logic [DataWidth-1 : 0] result_o
);

  localparam int StartAddress = (NumInputs + 2) * NeuronInstance;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_GET_KEY,
    ST_GET_INPUTS,
    ST_GET_MULT,
    ST_WAIT_MULT,
    ST_GET_BIAS,
    ST_GET_ACTV,
    ST_GET_SIGMOID,
    ST_OUTPUT
  } st_nueron_e;

  st_nueron_e state;

  //internal signals
  logic signed [(DataWidth*2)-1 : 0] sum;
  logic [7:0] afterActivation;
  logic [$clog2(NumInputs)-1:0] counter;
  logic [$clog2(DataWidth)-1:0] actv_in;
  logic [$clog2(DataWidth)-1:0] actv_out;

  logic mult_start;
  logic mult_done;
  logic mult_busy;


  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= ST_IDLE;
      //we
      in_actv_we_o <= '0;
      out_actv_we_o <= '0;
      wgt_we_o <= '0;
      //req
      in_actv_req_o <= '0;
      out_actv_req_o <= '0;
      wgt_req_o <= '0;
      ack_o <= '0;
      sum <= '0;
      //ram signals
    end else begin
      case (state)
        //idle state
        ST_IDLE: begin
          if (req_i) begin
            in_actv_req_o <= '1;
            ack_o <= '1;
            wgt_req_o <= '1;
            counter <= '0;
            state <= ST_GET_KEY;
          end
        end
        ST_GET_KEY: begin
          ack_o <= '0;
          if (in_actv_grant_i && wgt_grant_i) begin
            state <= ST_GET_INPUTS;
          end
        end
        ST_GET_INPUTS: begin
          mult_a_o <= wgt_din_i;
          mult_b_o <= in_actv_din_i;
          in_actv_req_o <= '0;
          wgt_req_o <= '0;
          mult_req_o <= '1;
          mult_start_o <= '1;
          state <= ST_GET_MULT;
        end
        //get multiplier mutex key
        ST_GET_MULT: begin
          if (mult_grant_i) begin
            mult_start_o <= '1;
            state <= ST_WAIT_MULT;
          end
        end
        ST_WAIT_MULT: begin
          mult_start_o <= '1;
          if (mult_done_i) begin
            sum <= sum + mult_result_i;
            mult_req_o <= '0;
            if (counter >= NumInputs - 1) begin
              state <= ST_GET_BIAS;
              out_actv_req_o <= '1;
              counter <= counter + 1;
            end else begin
              in_actv_req_o <= '1;
              wgt_req_o <= '1;
              counter <= counter + 1;
              state <= ST_GET_KEY;
            end
          end
        end
        ST_GET_BIAS: begin
          //store bias
          counter <= '0;
          sum <= sum + wgt_din_i;
          out_actv_req_o <= '1;
          state <= ST_GET_ACTV;
        end
        //wait for multipler done
        ST_GET_ACTV: begin
          out_actv_dout_o <= afterActivation;
          if (out_actv_grant_i) begin
            out_actv_we_o <= '1;
            //ack_o <= '1;
            req_o <= '1;
            state <= ST_OUTPUT;
          end
        end
        //req to upstream.. wait till acked
        ST_OUTPUT: begin
          in_actv_we_o <= '0;
          out_actv_we_o <= '0;
          out_actv_req_o <= '0;
          ack_o <= '0;
          if (ack_i) begin
            state <= ST_IDLE;
            req_o <= '0;
          end
        end
        default: begin
        end
      endcase
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
  // assign out_o = afterActivation;

  assign in_actv_addr_o = counter;
  assign wgt_addr_o = StartAddress + counter;
  assign out_actv_addr_o = NeuronInstance;

endmodule
