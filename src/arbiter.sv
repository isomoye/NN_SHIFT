module arbiter #(
    parameter int NUM_NODES = 10,
    parameter int NUM_MULT  = 10

) (
    input logic clk_i,
    input logic reset_i,

    //shared multiplier handshake
    input  logic [NUM_NODES-1:0] request_i,
    output logic [NUM_NODES-1:0] grant_o,

    //shared multiplier handshake
    input  logic [NUM_MULT -1:0] busy_i,
    output logic [ NUM_MULT-1:0] start_o
);

logic [NUM_NODES-1:0] grant_c, grant_r;
logic [ NUM_MULT-1:0] start_c, start_r;


always_ff @(posedge clk_i) begin
    if(reset_i) begin
        grant_r <= '0;
        start_r <= '0;
    end
    else begin
        grant_r <= grant_c;
        start_r <= start_c;
    end
end



  always_comb begin
    grant_o = '0;

    for (int i = 0; i < NUM_NODES; i++) begin
      logic mutex_flag = 0;
      if (request_i[i]) begin
        for (int j = 1; j < i; j++) begin
          if (request_i[j]) begin
            mutex_flag[i] = 1'b1;
          end
        end
        if (!mutex_flag[i] || i == 0) begin
          ack_o[i] <= '1;
          mutex_index <= i;
        end
      end
      if (request_i[i]) begin
        grant_o[i] = 1;
        break;
      end
    end
  end



endmodule
