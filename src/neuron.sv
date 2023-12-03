module neuron #(
    parameter int NumInputs = 4,
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumOutputs = NumInputs,
    parameter int Layer = 0
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
    // input logic [DataWidth-1 :0] bias_i,weights
    //shift out
    output logic [WeigthsWidth-1 : 0] scan_do,
    //output logic [DataWidth-1 :0] bias_o,
    output logic [DataWidth-1 : 0] output_o,
    //forward-propagation upstream signals
    input logic [(DataWidth*NumInputs)-1:0] actv_i,
    input logic [NumInputs-1:0] req_i,
    output logic [NumInputs-1:0] ack_o,
    //forward-propagation downstream signals
    output logic req_o,
    input logic [NumOutputs-1:0] ack_i,
    output logic [DataWidth-1 : 0] out_i,
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
    input logic back_prop_i,
    input logic en_i,
    input logic [DataWidth-1 : 0] result_i,
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

  logic [DataWidth-1 : 0] dactv;
  logic [(DataWidth*NumInputs)-1:0] dweights;
  logic [DataWidth-1 : 0] dbias;
  logic [DataWidth-1 : 0] dz;

  logic [DataWidth-1 : 0] result;
  logic [DataWidth-1 : 0] hold_result;
  logic delay_en;


  logic [NumInputs-1:0] req;
  logic [NumOutputs-1:0] acks;

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
      state <= ST_IDLE;
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
      state <= ST_IDLE;
      ack_o <= '0;
      req_o <= '0;
      req <= '0;
      mult_ack_out <= '0;
      counter <= '0;
      acks <= '0;
      //shift in
      {bias, weights} <= {weights, scan_di};
      //bias <= bias_i;
      //shift out
      scan_do <= bias;
      //bias_o <= bias;
    end else begin
      case (state)
        //idle state
        ST_IDLE: begin
          ack_o <= '0;
          if (req_i != '0) begin
            ack_o <= '0;
            sum <= '0;
            counter <= '0;
            state <= ST_GET_INPUTS;
          end
          // if(req_i[counter]) begin
          //   ack_o[counter] <= '1;
          //   req[counter] <= '1;
          //   sum <= actv_i[DataWidth*counter +: DataWidth] 
          //   *  weights[WeigthsWidth*counter +: WeigthsWidth];
          //   if(counter == NumInputs) begin
          //     state <= ST_GET_MULT;
          //     counter <= '0;
          //   end
          //   else begin
          //     state <= ST_GET_INPUTS;
          //     counter <= counter + 1;
          //   end
          // end
        end
        ST_GET_INPUTS: begin
          if (req_i[counter]) begin
            ack_o[counter] <= '1;
            req[counter] <= '1;
            sum <= actv_i[DataWidth*counter +: DataWidth] 
            *  weights[WeigthsWidth*counter +: WeigthsWidth];
            if (counter == NumInputs - 1) begin
              state   <= ST_GET_MULT;
              counter <= '0;
            end else begin
              state   <= ST_GET_INPUTS;
              counter <= counter + 1;
            end
          end
        end
        //get multiplier mutex key
        ST_GET_MULT: begin
          if (req_i == '0) begin
            state <= ST_GET_ACTV;
            ack_o <= '0;
          end
          // ack_o <= '0;
          // if (mult_ack_in) begin
          //   mult_start <= '0;
          //   state <= ST_GET_ACTV;
          // end
        end
        //wait for multipler done
        ST_GET_ACTV: begin
          ack_o <= '0;
          req   <= '0;
          sum   <= sum + bias;
          req_o <= '1;
          state <= ST_OUTPUT;
          // if (mult_done) begin
          //   //ack multipler output
          //   mult_ack_out <= '1;
          //   req_o <= '1;
          //   state <= ST_OUTPUT;
          // end
        end
        //req to upstream.. wait till acked
        ST_OUTPUT: begin
          mult_ack_out <= '0;
          for (int i = 0; i < NumOutputs; i++) begin
            if (ack_i[i]) begin
              //req_o[i] <= '0;
              acks[i] <= '1;
            end
          end
          if ((ack_i[NumOutputs-1:0] == '1)) begin
            req_o <= '0;
            acks  <= '0;
            //goto idle
            state <= ST_IDLE;
          end
        end
        default: begin
        end
      endcase
    end
  end

  if (Layer == 1) begin : gen_relu
    assign afterActivation = (signed'(sum) > 0) ? sum : '0;
  end else begin : gen_sigmoid
    sigmoid sigmoid_inst (
        .x  (sum),
        .out(afterActivation)
    );
  end
  assign output_o = afterActivation;

  // multiplier #(
  //     .NumInputs(NumInputs),
  //     .Layer(Layer)
  // ) multiplier_inst (
  //     .clk_i(clk_i),
  //     .reset_i(reset_i),
  //     .start_i(mult_start),
  //     .ack_o(mult_ack_in),
  //     .actv_i(actv),
  //     .weights_i(weights),
  //     .bias_i(bias),
  //     .actv_o(output_o),
  //     .done_o(mult_done),
  //     .ack_i(mult_ack_out)
  // );


endmodule
