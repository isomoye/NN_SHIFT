module ram_nn_layer #(
    parameter int NumInputLayer     = 10,
    parameter int DataWidth         = 8,
    parameter int WeigthsWidth      = DataWidth,
    parameter int AddrWidth         = $clog2(NumInputLayer),
    parameter int NumNeuronsLayer   = 15,
    parameter int InputWgtWidth     = (NumInputLayer + 1) * NumNeuronsLayer,
    parameter int InputWgtAddrWidth = $clog2(InputWgtWidth),
    parameter int FpWidth           = 4

) (
    input  logic                           clk_i,
    input  logic                           reset_i,
    //upstream handshake
    input  logic                           req_i,
    output logic                           ack_o,
    //downstream handshake
    output logic                           req_o,
    input  logic                           ack_i,
    //actv inputs
    input  logic                           actv_in_ram_we,
    input  logic [        (AddrWidth)-1:0] actv_in_ram_addr,
    input  logic [      (DataWidth)-1 : 0] actv_in_ram_din,
    output logic [      (DataWidth)-1 : 0] actv_in_ram_dout,
    //ram inputs
    input  logic [(InputWgtAddrWidth)-1:0] wgt_in_ram_addr,
    input  logic                           wgt_in_ram_we,
    input  logic [      (DataWidth)-1 : 0] wgt_in_ram_din,
    output logic [      (DataWidth)-1 : 0] wgt_in_ram_dout,
    //ram outputs
    output  logic [        (AddrWidth)-1:0] actv_out_ram_addr,
    output  logic                           actv_out_ram_we,
    input   logic [      (DataWidth)-1 : 0] actv_out_ram_din,
    output  logic [      (DataWidth)-1 : 0] actv_out_ram_dout
);

  logic [NumNeuronsLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_in_ram_addr;
  logic [NumNeuronsLayer-1:0] layer_array_actv_in_ram_we;
  logic [(DataWidth)-1 : 0] layer_array_actv_in_ram_din;
  logic [NumNeuronsLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_in_ram_dout;
  logic [NumNeuronsLayer-1:0] layer_array_actv_in_req;
  logic [NumNeuronsLayer-1:0] layer_array_actv_in_grant;
  logic [$clog2(NumNeuronsLayer)-1:0] actv_i_select;
  logic actv_i_active;

  logic [(AddrWidth)-1:0] layer_actv_in_ram_addr;
  logic layer_actv_in_ram_we;
  logic [(DataWidth)-1 : 0] layer_actv_in_ram_din;
  logic [(DataWidth)-1 : 0] layer_actv_in_ram_dout;


  logic [NumNeuronsLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_out_ram_addr ;
  logic [NumNeuronsLayer-1:0] layer_array_actv_out_ram_we;
  logic [(DataWidth)-1 : 0] layer_array_actv_out_ram_din;
  logic [NumNeuronsLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_out_ram_dout ;
  logic [NumNeuronsLayer-1:0] layer_array_actv_out_req;
  logic [NumNeuronsLayer-1:0] layer_array_actv_out_grant;
  logic [$clog2(NumNeuronsLayer)-1:0] actv_o_select;
  logic actv_o_active;

  logic [(AddrWidth)-1:0] layer_actv_out_ram_addr;
  logic layer_actv_out_ram_we;
  logic [(DataWidth)-1 : 0] layer_actv_out_ram_din;
  logic [(DataWidth)-1 : 0] layer_actv_out_ram_dout;


  logic [NumNeuronsLayer-1:0][(InputWgtAddrWidth)-1 : 0] layer_array_wgt_ram_addr ;
  logic [NumNeuronsLayer-1:0] layer_array_wgt_ram_we;
  logic [(DataWidth)-1 : 0] layer_array_wgt_ram_din;
  logic[NumNeuronsLayer-1:0] [(DataWidth)-1 : 0] layer_array_wgt_ram_dout ;
  logic [NumNeuronsLayer-1:0] layer_array_wgt_req;
  logic [NumNeuronsLayer-1:0] layer_array_wgt_grant;

  logic [$clog2(NumNeuronsLayer)-1:0] wgt_select;
  logic wgt_active;
  logic [NumNeuronsLayer-1:0] layer_done;
  logic [NumNeuronsLayer-1:0] layer_req;


  logic [(AddrWidth)-1 : 0] wgt_ram_addr;
  logic wgt_ram_we;
  logic [(DataWidth)-1 : 0] wgt_ram_din;
  logic [(DataWidth)-1 : 0] wgt_ram_dout;


  logic [NumNeuronsLayer-1:0] mult_req;
  logic [NumNeuronsLayer-1:0] mult_grant;
  logic [NumNeuronsLayer-1:0] mult_start_array;

  logic [NumNeuronsLayer-1:0][(DataWidth)-1 : 0] mult_a_array ;
  logic [NumNeuronsLayer-1:0][(DataWidth)-1 : 0] mult_b_array ;
  logic [(DataWidth)-1 : 0] mult_a;
  logic [(DataWidth)-1 : 0] mult_b;
  //   logic [        (DataWidth)-1 : 0]                    mult_out;
  logic [(DataWidth)-1 : 0] mult_result;
  logic mult_ovfl;
  logic mult_start;
  logic mult_done;
  logic mult_busy;
  logic mult_valid;
  logic [$clog2(NumNeuronsLayer)-1:0] mult_select;
  logic mult_active;

  logic [(DataWidth) : 0] mult_output;


  assign req_o = &layer_req;
  assign ack_o = &layer_done;

  arbiter #(
      .NUM_PORTS(NumNeuronsLayer),
      .SEL_WIDTH()
  ) wgt_arbiter_inst (
      .clk(clk_i),
      .rst(reset_i),
      .request(layer_array_wgt_req),
      .grant(layer_array_wgt_grant),
      .select(wgt_select),
      .active(wgt_active)
  );


  ram_mux #(
      .NUM_PORTS(NumNeuronsLayer),
      .DataWidth(DataWidth),
      .AddrWidth(InputWgtAddrWidth)
  ) wgt_ram_mux_inst (
      .active_i  (wgt_active),
      .select_i  (wgt_select),
      .ram_addr_i(layer_array_wgt_ram_addr),
      .ram_we_i  (layer_array_wgt_ram_we),
      .ram_din_o (layer_array_wgt_ram_din),
      .ram_dout_i(layer_array_wgt_ram_dout),
      .ram_addr_o(wgt_ram_addr),
      .ram_we_o  (wgt_ram_we),
      .ram_din_i (wgt_ram_din),
      .ram_dout_o(wgt_ram_dout)
  );

  bram_dp #(
      .RAM_DATA_WIDTH(DataWidth),
      .RAM_ADDR_WIDTH(InputWgtAddrWidth)
  ) wgt_bram_dp_inst (
      .rst       (reset_i),
      .a_clk     (clk_i),
      .a_wr      (wgt_ram_we),
      .a_addr    (wgt_ram_addr),
      .a_data_in (wgt_ram_dout),
      .a_data_out(wgt_ram_din),
      .b_clk     (clk_i),
      .b_wr      (wgt_in_ram_we),
      .b_addr    (wgt_in_ram_addr),
      .b_data_in (wgt_in_ram_din),
      .b_data_out(wgt_in_ram_dout)
  );



  arbiter #(
      .NUM_PORTS(NumNeuronsLayer),
      .SEL_WIDTH()
  ) actv_i_arbiter_inst (
      .clk(clk_i),
      .rst(reset_i),
      .request(layer_array_actv_in_req),
      .grant(layer_array_actv_in_grant),
      .select(actv_i_select),
      .active(actv_i_active)
  );

  ram_mux #(
      .NUM_PORTS(NumNeuronsLayer),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) actv_i_ram_mux_inst (
      .select_i  (actv_i_select),
      .active_i  (actv_i_active),
      .ram_addr_i(layer_array_actv_in_ram_addr),
      .ram_we_i  (layer_array_actv_in_ram_we),
      .ram_din_o (layer_array_actv_in_ram_din),
      .ram_dout_i(layer_array_actv_in_ram_dout),
      .ram_addr_o(layer_actv_in_ram_addr),
      .ram_we_o  (layer_actv_in_ram_we),
      .ram_din_i (layer_actv_in_ram_din),
      .ram_dout_o(layer_actv_in_ram_dout)
  );

  //   actv_i_select
  bram_dp #(
      .RAM_DATA_WIDTH(DataWidth),
      .RAM_ADDR_WIDTH(AddrWidth)
  ) actv_i_bram_dp_inst (
      .rst       (reset_i),
      .a_clk     (clk_i),
      .a_wr      (layer_actv_in_ram_we),
      .a_addr    (layer_actv_in_ram_addr),
      .a_data_in (layer_actv_in_ram_dout),
      .a_data_out(layer_actv_in_ram_din),
      .b_clk     (clk_i),
      .b_wr      (actv_in_ram_we),
      .b_addr    (actv_in_ram_addr),
      .b_data_in (actv_in_ram_din),
      .b_data_out(actv_in_ram_dout)
  );

  arbiter #(
      .NUM_PORTS(NumNeuronsLayer),
      .SEL_WIDTH()
  ) actv_o_arbiter_inst (
      .clk(clk_i),
      .rst(reset_i),
      .request(layer_array_actv_out_req),
      .grant(layer_array_actv_out_grant),
      .select(actv_o_select),
      .active(actv_o_active)
  );


  ram_mux #(
      .NUM_PORTS(NumNeuronsLayer),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) actv_o_ram_mux_inst (
      .select_i  (actv_o_select),
      .active_i  (actv_o_active),
      .ram_addr_i(layer_array_actv_out_ram_addr),
      .ram_we_i  (layer_array_actv_out_ram_we),
      .ram_din_o (layer_array_actv_out_ram_din),
      .ram_dout_i(layer_array_actv_out_ram_dout),
      .ram_addr_o(actv_out_ram_addr),
      .ram_we_o  (actv_out_ram_we),
      .ram_din_i (actv_out_ram_din),
      .ram_dout_o(actv_out_ram_dout)
  );

//   bram_dp #(
//       .RAM_DATA_WIDTH(DataWidth),
//       .RAM_ADDR_WIDTH(AddrWidth)
//   ) actv_o_bram_dp_inst (
//       .rst       (reset_i),
//       .a_clk     (clk_i),
//       .a_wr      (layer_actv_out_ram_we),
//       .a_addr    (layer_actv_out_ram_addr),
//       .a_data_in (layer_actv_out_ram_dout),
//       .a_data_out(layer_actv_out_ram_din),
//       .b_clk     (clk_i),
//       .b_wr      (actv_out_ram_addr),
//       .b_addr    (actv_out_ram_we),
//       .b_data_in (actv_out_ram_dout),
//       .b_data_out(actv_out_ram_din)
//   );



  arbiter #(
      .NUM_PORTS(NumNeuronsLayer),
      .SEL_WIDTH()
  ) mult_arbiter_inst (
      .clk(clk_i),
      .rst(reset_i),
      .request(mult_req),
      .grant(mult_grant),
      .select(mult_select),
      .active(mult_active)
  );

  mult_mux #(
      .NUM_PORTS(NumNeuronsLayer),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) mult_mux_inst (
      .select_i(mult_select),
      .active_i(mult_active),
      .start_i(mult_start_array),
      .mult_a_i(mult_a_array),
      .mult_b_i(mult_b_array),
      .result_o(mult_result),
      .mult_a_o(mult_a),
      .mult_b_o(mult_b),
      .value_i(mult_output),
      .overflow_i(mult_ovfl),
      .start_o(mult_start),
      .done_i(mult_done),
      .valid_i(mult_valid)
  );

  mul #(
      .WIDTH(DataWidth),
      .FBITS(FpWidth)
  ) mul_inst (
      .clk(clk_i),
      .rst(reset_i),
      .start(mult_start),
      .busy(mult_busy),
      .done(mult_done),
      .valid(mult_valid),
      .ovf(mult_ovfl),
      .a(mult_a),
      .b(mult_b),
      .val(mult_output)
  );

  //input layer neurons
  for (genvar j = 0; j < NumNeuronsLayer; j++) begin : gen_layer_neurons
    neuron_ram #(
        .NumInputs(NumInputLayer),
        .DataWidth(DataWidth),
        .WeigthsWidth(WeigthsWidth),
        .Layer(1),
        .NeuronsPerLayer(NumNeuronsLayer),
        .NeuronInstance(j),
        .EnableBackPropagation(0)
    ) neuron_ram_inst (
        .clk_i           (clk_i),
        .reset_i         (reset_i),
        .in_actv_addr_o  (layer_array_actv_in_ram_addr[j]),
        .in_actv_we_o    (layer_array_actv_in_ram_we[j]),
        .in_actv_din_i   (layer_array_actv_in_ram_din),
        .in_actv_dout_o  (layer_array_actv_in_ram_dout[j]),
        .wgt_addr_o      (layer_array_wgt_ram_addr[j]),
        .wgt_we_o        (layer_array_wgt_ram_we[j]),
        .wgt_din_i       (layer_array_wgt_ram_din),
        .wgt_dout_o      (layer_array_wgt_ram_dout[j]),
        .out_actv_addr_o (layer_array_actv_out_ram_addr[j]),
        .out_actv_we_o   (layer_array_actv_out_ram_we[j]),
        .out_actv_din_i  (layer_array_actv_out_ram_din),
        .out_actv_dout_o (layer_array_actv_out_ram_dout[j]),
        .in_actv_req_o   (layer_array_actv_in_req[j]),
        .in_actv_grant_i (layer_array_actv_in_grant[j]),
        .wgt_req_o       (layer_array_wgt_req[j]),
        .wgt_grant_i     (layer_array_wgt_grant[j]),
        .out_actv_req_o  (layer_array_actv_out_req[j]),
        .out_actv_grant_i(layer_array_actv_out_grant[j]),
        .req_i           (req_i),
        .ack_o           (layer_done[j]),
        .req_o           (layer_req[j]),
        .ack_i           (ack_i),
        .mult_done_i     (mult_done),
        .mult_busy_i     (),
        .mult_start_o    (mult_start_array[j]),
        .mult_grant_i    (mult_grant[j]),
        .mult_req_o      (mult_req[j]),
        .mult_a_o        (mult_a_array[j]),
        .mult_b_o        (mult_b_array[j]),
        .mult_result_i   (mult_output)
    );
  end

endmodule
