module neuron #(
    parameter int NUM_INPUTS = 4,
    parameter int NUM_OUTPUTS = NUM_INPUTS,
    parameter int LAYER = 0
    // parameter int w1   = 1,
    // parameter int w2   = 1,
    // parameter int w3   = 1,
    // parameter int bias = 1
) (
    input logic clk_i,
    input logic reset_i,
    //shift in
    input logic shift_i,
    input logic [31:0] scan_di,
    // input logic [31:0] bias_i,weights
    //shift out
    output logic [31:0] scan_do,
    //output logic [31:0] bias_o,
    output logic [31:0] output_o,
    //forward-propagation upstream signals
    input logic [(32*NUM_INPUTS)-1:0] actv_i,
    input logic [NUM_INPUTS-1:0] req_i,
    output logic [NUM_INPUTS-1:0] ack_o,
    //forward-propagation downstream signals
    output logic [NUM_OUTPUTS-1:0] req_o,
    input logic [NUM_OUTPUTS-1:0] ack_i,
    output logic [31:0] out_i,
    //shared multiplier handshake
    // output logic mult_req_o,
    // input logic mult_ack_i,
    // output logic [31:0] mult_actv_o,
    // output logic [(32*NUM_INPUTS)-1:0] mult_weights_o,
    // output logic [31:0] mult_bias_o,
    // input logic [31:0] mult_actv_i,
    // input logic mult_done_i,
    // output logic mult_ack_i,
    // //back-propagation signals
    input logic back_prop_i,
    input logic en_i,
    input logic [31:0] result_i,
    output logic [31:0] result_o
);


  typedef enum logic [2:0] {
    ST_IDLE,
    ST_GET_MULT,
    ST_GET_ACTV,
    ST_GET_SIGMOID,
    ST_OUTPUT
  } st_nueron_e;

  st_nueron_e curr_state;

  //internal signals
  logic [(32*NUM_INPUTS)-1:0] actv;
  logic signed [31:0] sum;
  logic [15:0] sumAddress;
  logic [7:0] afterActivation;
  logic [(32*NUM_INPUTS)-1:0] weights;
  logic [31:0] bias;

  logic [31:0] dactv;
  logic [(32*NUM_INPUTS)-1:0] dweights;
  logic [31:0] dbias;
  logic [31:0] dz;

  logic [31:0] result;
  logic [31:0] hold_result;
  logic delay_en;


  logic [NUM_INPUTS-1:0] req;
  logic [NUM_OUTPUTS-1:0] acks;

  //multiplier signals
  logic mult_start;
  logic mult_done;
  logic mult_ack_out;
  logic mult_ack_in;
  logic [7:0] counter;

  assign mult_actv_o = actv;
  assign mult_weights_o = weights;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      curr_state <= ST_IDLE;
      ack_o <= '0;
      req_o <= '0;
      req <= '0;
      mult_ack_out <= '0;
      mult_start <= '0;
      counter <= '0;
      acks <= '0;
      actv <= '0;
    end  //shift in data
    else if (shift_i) begin
      //soft reset
      curr_state <= ST_IDLE;
      ack_o <= '0;
      req_o <= '0;
      req <= '0;
      mult_ack_out <= '0;
      counter <= '0;
      acks <= '0;
      //shift in
      {bias,weights} <= {weights, scan_di};
      //bias <= bias_i;
      //shift out
      scan_do <= bias;
      //bias_o <= bias;
    end else begin
      case (curr_state)
        //idle state
        ST_IDLE: begin
          ack_o <= '0;
          for(int i =0; i < NUM_INPUTS; i++) begin
            if (req_i[i]) begin
              req[i] <= '1;
              ack_o[i] <= '1;
              actv[32*i +: 32] <= actv_i[32*i +: 32];
            end
          end
          if(req[NUM_INPUTS-1:0] == '1 || req_i[NUM_INPUTS-1:0] == '1) begin
            req <= '0;
            mult_start <= '1;
            curr_state <= ST_GET_MULT;
          end
          // if (req_i) begin
          //   counter <= counter + 1;
          //   ack_o <= '1;
          //   actv <= actv_i;
          //   mult_start <= '1;
          //   if (counter >= NUM_INPUTS) begin
          //     counter <= '0;
          //     curr_state <= ST_GET_MULT;
          //   end
          // end
        end
        //get multiplier mutex key
        ST_GET_MULT: begin
          ack_o <= '0;
          if (mult_ack_in) begin
            mult_start <= '0;
            curr_state <= ST_GET_ACTV;
          end
        end
        //wait for multipler done
        ST_GET_ACTV: begin
          if (mult_done) begin
            //ack multipler output
            mult_ack_out <= '1;
            req_o <= '1;
            curr_state <= ST_OUTPUT;
          end
        end
        //req to upstream.. wait till acked
        ST_OUTPUT: begin
          mult_ack_out <= '0;
          for(int i = 0; i < NUM_OUTPUTS; i++) begin
            if(ack_i[i]) begin
              req_o[i] <= '0;
              acks[i] <= '1;
            end
          end
          if ((ack_i[NUM_OUTPUTS-1:0] == '1) || (acks[NUM_OUTPUTS-1:0] == '1)) begin
            req_o <= '0;
            acks <= '0;
            //goto idle
            curr_state <= ST_IDLE;
          end
        end
        default: begin
        end
      endcase
    end
  end


  multiplier #(
      .NUM_INPUTS(NUM_INPUTS),
      .LAYER(LAYER)
  ) multiplier_inst (
      .clk_i(clk_i),
      .reset_i(reset_i),
      .start_i(mult_start),
      .ack_o(mult_ack_in),
      .actv_i(actv),
      .weights_i(weights),
      .bias_i(bias),
      .actv_o(output_o),
      .done_o(mult_done),
      .ack_i(mult_ack_out)
  );


endmodule
