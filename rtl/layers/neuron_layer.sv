module neuron_layer #(
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
    output logic [$clog2(DataWidth)-1:0] dn_ram_addr_o,
    output logic dn_ram_we_o,
    input logic [DataWidth-1 : 0] dn_ram_din_i,
    output logic [DataWidth-1 : 0] dn_ram_dout_o,
    //weights ram signals
    output logic [$clog2(DataWidth)-1:0] w_ram_addr_o,
    output logic w_ram_we_o,
    input logic [DataWidth-1 : 0] w_ram_din_i,
    output logic [DataWidth-1 : 0] w_ram_dout_o,
    //uptream ram signals
    output logic [$clog2(DataWidth)-1:0] up_ram_addr_o,
    output logic up_ram_we_o,
    input logic [DataWidth-1 : 0] up_ram_din_i,
    output logic [DataWidth-1 : 0] up_ram_dout_o,
    //downstream mutex signals
    output logic dn_req_o,
    output logic dn_rel_o,
    input logic dn_grant_i,
    //upstream mutex signals
    output logic up_req_o,
    output logic up_rel_o,
    input logic up_grant_i,
    //forward propagation
    input logic [(DataWidth*NumInputs)-1:0] actv_i,
    output logic [DataWidth-1 : 0] actv_o,
    input logic start_i,
    output logic done_o
);

  localparam int StartAddress = (NumInputs + 2) * NeuronInstance;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_GET_INPUTS,
    ST_GET_BIAS,
    ST_GET_MULT,
    ST_GET_ACTV,
    ST_GET_SIGMOID,
    ST_OUTPUT
  } st_nueron_e;

  st_nueron_e                                state;

  //internal signals
  logic signed [            DataWidth-1 : 0] sum;
  logic        [                        7:0] afterActivation;
  logic        [      $clog2(NumInputs)-1:0] actv_cnt;
  logic        [$clog2(NeuronsPerLayer)-1:0] neuron_cnt;


  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= ST_IDLE;
      dn_ram_we_o <= '0;
      up_ram_we_o <= '0;
      w_ram_we_o <= '0;
      dn_req_o <= '0;
      dn_rel_o <= '0;
      up_req_o <= '0;
      neuron_cnt <= '0;
      up_rel_o <= '0;
      done_o <= '0;
      //ram signals
    end else begin
      case (state)
        //idle state
        ST_IDLE: begin
          dn_rel_o <= '0;
          up_rel_o <= '0;
          if (start_i) begin
            dn_req_o <= '1;
            w_ram_addr_o <= '0;
            dn_ram_addr_o <= 32'h1;
            actv_cnt <= 1'b1;
            state <= ST_GET_INPUTS;
          end
        end
        ST_GET_BIAS: begin
          actv_cnt <= actv_cnt + 1;
          dn_ram_addr_o <= dn_ram_addr_o + 1;
          w_ram_addr_o <= w_ram_addr_o + 1;
          //get bias
          sum <= dn_ram_din_i;
          state <= ST_GET_MULT;
        end
        ST_GET_INPUTS: begin
          dn_req_o <= '0;
          dn_ram_addr_o <= '0;
          w_ram_addr_o <= '0;
          actv_cnt <= actv_cnt + 1;
          state <= ST_GET_MULT;
        end
        //get multiplier mutex key
        ST_GET_MULT: begin
          dn_ram_addr_o <= dn_ram_addr_o + 1;
          w_ram_addr_o <= w_ram_addr_o + 1;
          sum <= w_ram_din_i * dn_ram_din_i;
          if (w_ram_addr_o >= NumInputs - 1) begin
            state <= ST_GET_ACTV;
            dn_rel_o <= '1;
            up_req_o <= '1;
            up_ram_addr_o <= NeuronInstance;
          end
        end
        //req to upstream.. wait till acked
        ST_OUTPUT: begin
          dn_ram_we_o <= '0;
          up_ram_we_o <= '0;
          if (up_grant_i) begin
            up_req_o <= '0;
            if (neuron_cnt >= NeuronsPerLayer) begin
              dn_ram_addr_o <= '0;
              w_ram_addr_o <= '0;
              state <= ST_IDLE;
            end else begin
              neuron_cnt <= neuron_cnt + 1;
              //reset input activation ram address
              dn_ram_addr_o <= '0;
              //weights and bias address should already be at the right address
              state <= ST_GET_BIAS;
            end
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
  assign output_o = afterActivation;

endmodule
