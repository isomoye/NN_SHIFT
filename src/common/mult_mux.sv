module mult_mux #(
    parameter  int NUM_PORTS = 6,
    parameter int SEL_WIDTH = ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1),
    parameter  int DataWidth = 8,
    parameter int AddrWidth = $clog2(DataWidth)

) (
    //grant in
    input logic [SEL_WIDTH-1:0] select_i,
    input logic                 active_i,
    input logic [NUM_PORTS-1:0] start_i,
    //ram inputs
    input logic [(DataWidth*NUM_PORTS)-1:0] mult_a_i,
    input logic [(DataWidth*NUM_PORTS)-1:0] mult_b_i,
    output logic [(DataWidth*2)-1:0] result_o,

    output logic [DataWidth-1:0] mult_a_o,
    output logic [DataWidth-1:0] mult_b_o,
    input logic [DataWidth-1:0] value_i,
    input logic overflow_i,
    output logic start_o,
    input logic done_i,
    input logic valid_i
);


  always_comb begin : ram_mux
    mult_a_o = '0;
    mult_b_o = '0;
    start_o  = '0;
    if (active_i) begin
          mult_a_o = mult_a_i[AddrWidth*select_i+:AddrWidth];
          mult_b_o = mult_b_i[DataWidth*select_i+:DataWidth];
          start_o  = start_i[select_i];
    end
    result_o = {overflow_i, value_i[DataWidth-1:0]};
  end



endmodule
