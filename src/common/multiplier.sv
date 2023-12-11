module multiplier #(
    parameter int DataWidth = 8,
    parameter int WeigthsWidth = DataWidth,
    parameter int Layer = 0
) (
    input logic clk_i,
    input logic reset_i,

    //shared multiplier handshake
    input logic start_i,
    output logic ack_o,
    input logic [(DataWidth)-1:0] actv_i,
    input logic [(WeigthsWidth)-1:0] weights_i,
    input logic [31:0] bias_i,
    output logic [31:0] actv_o,
    output logic done_o,
    input logic ack_i
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_GIVE_KEY,
    ST_MULTIPLY,
    ST_GET_ACTV,
    ST_GIVE_OUTPUT
  } st_mult_e;

  st_mult_e state;

  logic mutex_flag;
  logic mutex_index;

  logic signed [31:0] sum;
  logic [15:0] sumAddress;
  logic [31:0] afterActivation;
  logic [31:0] counter;


  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= ST_IDLE;
      ack_o <= '0;
      done_o <= '0;
      counter <= '0;
    end else begin
      case (state)
        ST_IDLE: begin
          //retry mutex block
          if (start_i) begin
            ack_o <= '1;
            sum <= '0;
            state <= ST_GIVE_KEY;
            counter <= '0;
          end
        end
        ST_GIVE_KEY: begin
          ack_o <= '0;

          counter <= counter + 1;
          // sum of input with factors and bias
          sum <=  sum + (signed'(weights_i[((counter))+:32]) *
          signed'(actv_i[((counter))+:32]));
          if(counter >= DataWidth) begin
            sum <= sum + bias_i;
            state <= ST_MULTIPLY;
            counter <= '0;
          end
        //   for (int i = 0; i < DataWidth; i++) begin
        //     if (i == 0) begin
        //       sum <= (weights_i[31:0] * actv_i[31:0]);
        //     end else begin
        //       sum <= sum + (signed'(weights_i[((i)-1)+:32]) * signed'(actv_i[((i)-1)+:32]));
        //     end
        //   end
        //  state <= ST_MULTIPLY;
        end
        ST_MULTIPLY: begin
          // if (signed'(sum) < -32768) begin
          //   sumAddress <= '0;
          // end else if (signed'(sum) > 32767) begin
          //   sumAddress <= '1;
          // end else begin
          //   sumAddress <= unsigned'(sum + 32768);
          // end
          sumAddress <= signed'(sum) ;
          state <= ST_GET_ACTV;
        end
        ST_GET_ACTV: begin
          done_o <= '1;
          state <= ST_GIVE_OUTPUT;
        end
        ST_GIVE_OUTPUT: begin
          if (ack_i) begin
            done_o <= '0;
            state <= ST_IDLE;
          end
        end
        default: begin
        end
      endcase
    end
  end

  if (Layer == 1) begin : gen_relu
    assign afterActivation = (signed'(sumAddress) > 0) ? sumAddress : '0;
  end else begin : gen_sigmoid
    sigmoid sigmoid_inst (
        .x  (sumAddress),
        .out(afterActivation)
    );
  end

  assign  actv_o = afterActivation;
  // assign out = unsigned'(afterActivation);

endmodule
