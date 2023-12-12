module ram_nn #(
    parameter int InputWidth = 49,
    parameter int DataWidth = 8,
    parameter int FpWidth = 4,
    parameter int WeigthsWidth = DataWidth,
    parameter int NumInputLayer = 37,
    parameter int NumHiddenLayer = 1,
    parameter int NeuronsPerHiddenLayer = 4,
    parameter int NumOutputLayer = 4,
    parameter int EnableHiddenLayer = 1,
    parameter int AddrWidth = $clog2(InputWidth),
    localparam int InputWgtWidth = (InputWidth + 1) * NumInputLayer,
    localparam int InputWgtAddrWidth = $clog2(InputWgtWidth)
) (
    input logic clk_i,
    input logic reset_i,

    input  logic                           req_i,
    output logic                           ack_o,
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
    input  logic [  $clog2(NumLayers)-1:0] ram_index_i,
    //ram outputs
    input  logic [        (AddrWidth)-1:0] ram_addr_o,
    input  logic                           ram_we_o,
    output logic [      (DataWidth)-1 : 0] ram_din_i,
    input  logic [      (DataWidth)-1 : 0] ram_dout_o
);

  localparam int NumLayers = NumHiddenLayer + 2;


  //   logic [  (AddrWidth)-1:0]                    wgt_update_ram_addr;
  //   logic                                        wgt_update_ram_we;
  //   logic [(DataWidth)-1 : 0]                    wgt_update_ram_din;
  //   logic [(DataWidth)-1 : 0]                    wgt_update_ram_dout;


  logic [NumLayers-1:0][  (AddrWidth)-1:0] wgt_update_ram_addr;
  logic [NumLayers-1:0]                    wgt_update_ram_we;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] wgt_update_ram_din;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] wgt_update_ram_dout;

  logic [NumLayers-1:0][  (AddrWidth)-1:0] top_actv_ram_addr;
  logic [NumLayers-1:0]                    top_actv_ram_we;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] top_actv_ram_din;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] top_actv_ram_dout;

  logic [NumLayers-1:0]                    request;
  logic [NumLayers-1:0]                    ack;


  //input ram index
  ram_mux_input #(
      .NUM_PORTS(NumLayers),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) ram_mux_input_inst (
      .select_i  (ram_index_i),
      .ram_addr_i(wgt_in_ram_addr),
      .ram_we_i  (wgt_in_ram_we),
      .ram_din_o (wgt_in_ram_dout),
      .ram_dout_i(wgt_in_ram_din),
      .ram_addr_o(wgt_update_ram_addr),
      .ram_we_o  (wgt_update_ram_we),
      .ram_din_i (wgt_update_ram_din),
      .ram_dout_o(wgt_update_ram_dout)
  );


  for (genvar i = 0; i < NumLayers; i++) begin : gen_neural_network
    if (i == 0) begin : gen_input_layer
      logic [        NumInputLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_in_ram_addr;
      logic [        NumInputLayer-1:0]                    layer_array_actv_in_ram_we;
      logic [        (DataWidth)-1 : 0]                    layer_array_actv_in_ram_din;
      logic [        NumInputLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_in_ram_dout;
      logic [        NumInputLayer-1:0]                    layer_array_actv_in_req;
      logic [        NumInputLayer-1:0]                    layer_array_actv_in_grant;
      logic [$clog2(NumInputLayer)-1:0]                    actv_i_select;
      logic                                                actv_i_active;

      logic [          (AddrWidth)-1:0]                    layer_actv_in_ram_addr;
      logic                                                layer_actv_in_ram_we;
      logic [        (DataWidth)-1 : 0]                    layer_actv_in_ram_din;
      logic [        (DataWidth)-1 : 0]                    layer_actv_in_ram_dout;


      logic [        NumInputLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_out_ram_addr;
      logic [        NumInputLayer-1:0]                    layer_array_actv_out_ram_we;
      logic [        (DataWidth)-1 : 0]                    layer_array_actv_out_ram_din;
      logic [        NumInputLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_out_ram_dout;
      logic [        NumInputLayer-1:0]                    layer_array_actv_out_req;
      logic [        NumInputLayer-1:0]                    layer_array_actv_out_grant;
      logic [$clog2(NumInputLayer)-1:0]                    actv_o_select;
      logic                                                actv_o_active;

      logic [          (AddrWidth)-1:0]                    layer_actv_out_ram_addr;
      logic                                                layer_actv_out_ram_we;
      logic [        (DataWidth)-1 : 0]                    layer_actv_out_ram_din;
      logic [        (DataWidth)-1 : 0]                    layer_actv_out_ram_dout;


      logic [        NumInputLayer-1:0][(AddrWidth)-1 : 0] layer_array_wgt_ram_addr;
      logic [        NumInputLayer-1:0]                    layer_array_wgt_ram_we;
      logic [        (DataWidth)-1 : 0]                    layer_array_wgt_ram_din;
      logic [        NumInputLayer-1:0][(DataWidth)-1 : 0] layer_array_wgt_ram_dout;
      logic [        NumInputLayer-1:0]                    layer_array_wgt_req;
      logic [        NumInputLayer-1:0]                    layer_array_wgt_grant;

      logic [$clog2(NumInputLayer)-1:0]                    wgt_select;
      logic                                                wgt_active;
      logic [        NumInputLayer-1:0]                    layer_done;
      logic [        NumInputLayer-1:0]                    layer_req;


      logic [        (AddrWidth)-1 : 0]                    wgt_ram_addr;
      logic                                                wgt_ram_we;
      logic [        (DataWidth)-1 : 0]                    wgt_ram_din;
      logic [        (DataWidth)-1 : 0]                    wgt_ram_dout;


      logic [        NumInputLayer-1:0]                    mult_req;
      logic [        NumInputLayer-1:0]                    mult_grant;
      logic [        NumInputLayer-1:0]                    mult_start_array;

      logic [        NumInputLayer-1:0][(DataWidth)-1 : 0] mult_a_array;
      logic [        NumInputLayer-1:0][(DataWidth)-1 : 0] mult_b_array;
      logic [        (DataWidth)-1 : 0]                    mult_a;
      logic [        (DataWidth)-1 : 0]                    mult_b;
      //   logic [        (DataWidth)-1 : 0]                    mult_out;
      logic [        (DataWidth)-1 : 0]                    mult_result;
      logic                                                mult_ovfl;
      logic                                                mult_start;
      logic                                                mult_done;
      logic                                                mult_busy;
      logic                                                mult_valid;
      logic [$clog2(NumInputLayer)-1:0]                    mult_select;
      logic                                                mult_active;

      logic [          (DataWidth) : 0]                    mult_output;


      assign request[i] = &layer_req;
      assign ack_o = &layer_done;

      arbiter #(
          .NUM_PORTS(NumInputLayer),
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
          .NUM_PORTS(NumInputLayer),
          .DataWidth(DataWidth),
          .AddrWidth(AddrWidth)
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
          .b_wr      (wgt_update_ram_we[i]),
          .b_addr    (wgt_update_ram_addr[i]),
          .b_data_in (wgt_update_ram_dout[i]),
          .b_data_out(wgt_update_ram_din[i])
      );



      arbiter #(
          .NUM_PORTS(NumInputLayer),
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
          .NUM_PORTS(NumInputLayer),
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
          .NUM_PORTS(NumInputLayer),
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
          .NUM_PORTS(NumInputLayer),
          .DataWidth(DataWidth),
          .AddrWidth(AddrWidth)
      ) actv_o_ram_mux_inst (
          .select_i  (actv_o_select),
          .active_i  (actv_o_active),
          .ram_addr_i(layer_array_actv_out_ram_addr),
          .ram_we_i  (layer_array_actv_out_ram_we),
          .ram_din_o (layer_array_actv_out_ram_din),
          .ram_dout_i(layer_array_actv_out_ram_dout),
          .ram_addr_o(layer_actv_out_ram_addr),
          .ram_we_o  (layer_actv_out_ram_we),
          .ram_din_i (layer_actv_out_ram_din),
          .ram_dout_o(layer_actv_out_ram_dout)
      );

      bram_dp #(
          .RAM_DATA_WIDTH(DataWidth),
          .RAM_ADDR_WIDTH(AddrWidth)
      ) actv_o_bram_dp_inst (
          .rst       (reset_i),
          .a_clk     (clk_i),
          .a_wr      (layer_actv_out_ram_we),
          .a_addr    (layer_actv_out_ram_addr),
          .a_data_in (layer_actv_out_ram_dout),
          .a_data_out(layer_actv_out_ram_din),
          .b_clk     (clk_i),
          .b_wr      (top_actv_ram_we[i]),
          .b_addr    (top_actv_ram_addr[i]),
          .b_data_in (top_actv_ram_dout[i]),
          .b_data_out(top_actv_ram_din[i])
      );



      arbiter #(
          .NUM_PORTS(NumInputLayer),
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
          .NUM_PORTS(NumInputLayer),
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
      for (genvar j = 0; j < NumInputLayer; j++) begin : gen_input_layer_neurons
        neuron_ram #(
            .NumInputs(InputWidth),
            .DataWidth(DataWidth),
            .WeigthsWidth(WeigthsWidth),
            .Layer(1),
            .NeuronsPerLayer(NumInputLayer),
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
            .ack_i           (ack[i]),
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
    end else if (EnableHiddenLayer) begin : gen_hidden_and_output_layer
      if (i != NumHiddenLayer + 1) begin : gen_hidden_layer
        localparam int NumInputsToLayer = (i == 1) ? NumInputLayer : NeuronsPerHiddenLayer;
        localparam int NumOutputsFromLayer = (i == NumHiddenLayer) ?
        NumOutputLayer : NeuronsPerHiddenLayer;

        logic [        NumInputsToLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_in_ram_addr;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_in_ram_we;
        logic [           (DataWidth)-1 : 0]                    layer_array_actv_in_ram_din;
        logic [        NumInputsToLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_in_ram_dout;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_in_req;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_in_grant;
        logic [$clog2(NumInputsToLayer)-1:0]                    actv_i_select;
        logic                                                   actv_i_active;

        logic [             (AddrWidth)-1:0]                    layer_actv_in_ram_addr;
        logic                                                   layer_actv_in_ram_we;
        logic [           (DataWidth)-1 : 0]                    layer_actv_in_ram_din;
        logic [           (DataWidth)-1 : 0]                    layer_actv_in_ram_dout;


        logic [        NumInputsToLayer-1:0][(AddrWidth)-1 : 0] layer_array_actv_out_ram_addr;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_out_ram_we;
        logic [           (DataWidth)-1 : 0]                    layer_array_actv_out_ram_din;
        logic [        NumInputsToLayer-1:0][(DataWidth)-1 : 0] layer_array_actv_out_ram_dout;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_out_req;
        logic [        NumInputsToLayer-1:0]                    layer_array_actv_out_grant;
        logic [$clog2(NumInputsToLayer)-1:0]                    actv_o_select;
        logic                                                   actv_o_active;

        logic [             (AddrWidth)-1:0]                    layer_actv_out_ram_addr;
        logic                                                   layer_actv_out_ram_we;
        logic [           (DataWidth)-1 : 0]                    layer_actv_out_ram_din;
        logic [           (DataWidth)-1 : 0]                    layer_actv_out_ram_dout;


        logic [        NumInputsToLayer-1:0][(AddrWidth)-1 : 0] layer_array_wgt_ram_addr;
        logic [        NumInputsToLayer-1:0]                    layer_array_wgt_ram_we;
        logic [           (DataWidth)-1 : 0]                    layer_array_wgt_ram_din;
        logic [        NumInputsToLayer-1:0][(DataWidth)-1 : 0] layer_array_wgt_ram_dout;
        logic [        NumInputsToLayer-1:0]                    layer_array_wgt_req;
        logic [        NumInputsToLayer-1:0]                    layer_array_wgt_grant;

        logic [$clog2(NumInputsToLayer)-1:0]                    wgt_select;
        logic                                                   wgt_active;
        logic [        NumInputsToLayer-1:0]                    layer_done;
        logic [        NumInputsToLayer-1:0]                    layer_req;


        logic [           (AddrWidth)-1 : 0]                    wgt_ram_addr;
        logic                                                   wgt_ram_we;
        logic [           (DataWidth)-1 : 0]                    wgt_ram_din;
        logic [           (DataWidth)-1 : 0]                    wgt_ram_dout;


        logic [        NumInputsToLayer-1:0]                    mult_req;
        logic [        NumInputsToLayer-1:0]                    mult_grant;
        logic [        NumInputsToLayer-1:0]                    mult_start_array;

        logic [        NumInputsToLayer-1:0][(DataWidth)-1 : 0] mult_a_array;
        logic [        NumInputsToLayer-1:0][(DataWidth)-1 : 0] mult_b_array;
        logic [           (DataWidth)-1 : 0]                    mult_a;
        logic [           (DataWidth)-1 : 0]                    mult_b;
        //   logic [        (DataWidth)-1 : 0]                    mult_out;
        logic [           (DataWidth)-1 : 0]                    mult_result;
        logic                                                   mult_ovfl;
        logic                                                   mult_start;
        logic                                                   mult_done;
        logic                                                   mult_busy;
        logic                                                   mult_valid;
        logic [$clog2(NumInputsToLayer)-1:0]                    mult_select;
        logic                                                   mult_active;

        logic [             (DataWidth) : 0]                    mult_output;


        assign request[i] = &layer_req;
        assign ack[i-1] = &layer_done;
        //assign mult_output = {mult_ovfl,mult_result};

        // always_ff @(posedge clk_i) begin : request_seq
        //   if (reset_i) begin
        //     request[i] <= '0;
        //   end else begin
        //     if (ack[i]) begin
        //       request[i] <= '0;
        //     end else if (&layer_done) begin
        //       request[i] <= '1;
        //     end
        //   end
        // end

        arbiter #(
            .NUM_PORTS(NumInputLayer),
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
            .NUM_PORTS(NumInputLayer),
            .DataWidth(DataWidth),
            .AddrWidth(AddrWidth)
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
            .b_wr      (wgt_update_ram_we[i]),
            .b_addr    (wgt_update_ram_addr[i]),
            .b_data_in (wgt_update_ram_dout[i]),
            .b_data_out(wgt_update_ram_din[i])
        );



        arbiter #(
            .NUM_PORTS(NumInputLayer),
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
            .NUM_PORTS(NumInputLayer),
            .DataWidth(DataWidth),
            .AddrWidth(AddrWidth)
        ) actv_i_ram_mux_inst (
            .select_i  (actv_i_select),
            .active_i  (actv_i_active),
            .ram_addr_i(layer_array_actv_in_ram_addr),
            .ram_we_i  (layer_array_actv_in_ram_we),
            .ram_din_o (layer_array_actv_in_ram_din),
            .ram_dout_i(layer_array_actv_in_ram_dout),
            .ram_addr_o(top_actv_ram_addr[i-1]),
            .ram_we_o  (top_actv_ram_we[i-1]),
            .ram_din_i (top_actv_ram_din[i-1]),
            .ram_dout_o(top_actv_ram_dout[i-1])
        );

        // //   actv_i_select
        // bram_dp #(
        //     .RAM_DATA_WIDTH(DataWidth),
        //     .RAM_ADDR_WIDTH(AddrWidth)
        // ) actv_i_bram_dp_inst (
        //     .rst       (reset_i),
        //     .a_clk     (clk_i),
        //     .a_wr      (layer_actv_in_ram_we),
        //     .a_addr    (layer_actv_in_ram_addr),
        //     .a_data_in (layer_actv_in_ram_dout),
        //     .a_data_out(layer_actv_in_ram_din),
        //     .b_clk     (clk_i),
        //     .b_wr      (top_actv_ram_we[i]),
        //     .b_addr    (top_actv_ram_addr[i]),
        //     .b_data_in (top_actv_ram_din[i]),
        //     .b_data_out(top_actv_ram_dout[i])
        // );

        arbiter #(
            .NUM_PORTS(NumInputLayer),
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
            .NUM_PORTS(NumInputLayer),
            .DataWidth(DataWidth),
            .AddrWidth(AddrWidth)
        ) actv_o_ram_mux_inst (
            .select_i  (actv_o_select),
            .active_i  (actv_o_active),
            .ram_addr_i(layer_array_actv_out_ram_addr),
            .ram_we_i  (layer_array_actv_out_ram_we),
            .ram_din_o (layer_array_actv_out_ram_din),
            .ram_dout_i(layer_array_actv_out_ram_dout),
            .ram_addr_o(layer_actv_out_ram_addr),
            .ram_we_o  (layer_actv_out_ram_we),
            .ram_din_i (layer_actv_out_ram_din),
            .ram_dout_o(layer_actv_out_ram_dout)
        );

        bram_dp #(
            .RAM_DATA_WIDTH(DataWidth),
            .RAM_ADDR_WIDTH(AddrWidth)
        ) actv_o_bram_dp_inst (
            .rst       (reset_i),
            .a_clk     (clk_i),
            .a_wr      (layer_actv_out_ram_we),
            .a_addr    (layer_actv_out_ram_addr),
            .a_data_in (layer_actv_out_ram_dout),
            .a_data_out(layer_actv_out_ram_din),
            .b_clk     (clk_i),
            .b_wr      (top_actv_ram_we[i]),
            .b_addr    (top_actv_ram_addr[i]),
            .b_data_in (top_actv_ram_dout[i]),
            .b_data_out(top_actv_ram_din[i])
        );



        arbiter #(
            .NUM_PORTS(NumInputsToLayer),
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
            .NUM_PORTS(NumInputsToLayer),
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
        for (genvar j = 0; j < NeuronsPerHiddenLayer; j++) begin : gen_hidden_layer_neurons
          neuron_ram #(
              .NumInputs(NumInputsToLayer),
              .DataWidth(DataWidth),
              .WeigthsWidth(WeigthsWidth),
              .Layer(1),
              .NeuronsPerLayer(NeuronsPerHiddenLayer),
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
              .req_i           (request[i-1]),
              .ack_o           (layer_done[j]),
              .req_o           (layer_req[j]),
              .ack_i           (ack[i]),
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
      end

    end


  end

endmodule
