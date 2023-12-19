module convo_2d_wrapper #(
    parameter int ConvoWidth        = 3,
    parameter int ConvoHeight       = 3,
    parameter int NumConvoCores     = 1,
    parameter int DataSizeW         = 28,
    parameter int DataSizeH         = 28,
    parameter int NumInputs         = 4,
    parameter int DataWidth         = 8,
    parameter int WeigthsWidth      = DataWidth,
    parameter int FpWidth           = 4,
    parameter int NumActv           = DataSizeW * DataSizeH,
    parameter int AddrWidth         = $clog2(NumActv),
    parameter int NumWeights        = NumConvoCores * ConvoWidth * ConvoHeight,
    parameter int InputWgtAddrWidth = $clog2(NumWeights)
) (
    input  logic                           clk_i,
    input  logic                           reset_i,
    //upstream handshake
    input  logic                           req_i,
    output logic                           ack_o,
    //downstream handshake
    output logic                           req_o,
    input  logic                           ack_i,
    input  logic                           ready_i,
    output logic                           ready_o,
    //actv inputs
    input  logic                           actv_in_ram_we,
    input  logic [        (AddrWidth)-1:0] actv_in_ram_addr,
    input  logic [      (DataWidth)-1 : 0] actv_in_ram_din,
    output logic [      (DataWidth)-1 : 0] actv_in_ram_dout,
    input  logic                           actv_in_ram_clk,
    //ram inputs
    input  logic [(InputWgtAddrWidth)-1:0] wgt_in_ram_addr,
    input  logic                           wgt_in_ram_we,
    input  logic [   (WeigthsWidth)-1 : 0] wgt_in_ram_din,
    output logic [   (WeigthsWidth)-1 : 0] wgt_in_ram_dout,
    input logic                            wgt_in_ram_clk,
    //ram outputs
    output logic [        (AddrWidth)-1:0] actv_out_ram_addr,
    output logic                           actv_out_ram_we,
    input  logic [      (DataWidth)-1 : 0] actv_out_ram_din,
    output logic [      (DataWidth)-1 : 0] actv_out_ram_dout
);


  //mult handshake signals
  logic [        NumConvoCores-1:0]                    mult_req;
  logic [        NumConvoCores-1:0]                    mult_grant;
  logic [        NumConvoCores-1:0]                    mult_start_array;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] mult_a_array;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] mult_b_array;
  logic [        (DataWidth)-1 : 0]                    mult_a;
  logic [        (DataWidth)-1 : 0]                    mult_b;
  logic [        (DataWidth)-1 : 0]                    mult_result;
  logic                                                mult_ovfl;
  logic                                                mult_start;
  logic                                                mult_done;
  logic                                                mult_busy;
  logic                                                mult_valid;
  logic [$clog2(NumConvoCores)-1:0]                    mult_select;
  logic                                                mult_active;
  logic [          (DataWidth) : 0]                    mult_output;

  //downstream mutex signals
  logic                                                in_actv_req_o;
  logic                                                in_actv_grant_i;
  //weight mutex signals
  logic                                                wgt_req_o;
  logic                                                wgt_grant_i;
  //upstream mutex signals
  logic                                                out_actv_req_o;
  logic                                                out_actv_grant_i;
  //multiply algor signals
  logic [          (DataWidth)-1:0]                    mult_a_o;
  logic [          (DataWidth)-1:0]                    mult_b_o;
  logic [        (DataWidth*2)-1:0]                    mult_result_i;

  logic [        NumConvoCores-1:0]                    array_actv_in_ram_we;
  logic [        NumConvoCores-1:0][  (AddrWidth)-1:0] array_actv_in_ram_addr;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_actv_in_ram_din;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_actv_in_ram_dout;
  logic [        NumConvoCores-1:0]                    array_actv_in_req;
  logic [        NumConvoCores-1:0]                    array_actv_in_grant;




  logic                                                single_actv_in_ram_we;
  logic [          (AddrWidth)-1:0]                    single_actv_in_ram_addr;
  logic [        (DataWidth)-1 : 0]                    single_actv_in_ram_din;
  logic [        (DataWidth)-1 : 0]                    single_actv_in_ram_dout;
  logic [$clog2(NumConvoCores)-1:0]                    actv_i_select;
  logic                                                actv_i_active;


  logic [        NumConvoCores-1:0]                    array_actv_out_ram_we;
  logic [        NumConvoCores-1:0][  (AddrWidth)-1:0] array_actv_out_ram_addr;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_actv_out_ram_din;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_actv_out_ram_dout;
  logic [        NumConvoCores-1:0]                    array_actv_out_req;
  logic [        NumConvoCores-1:0]                    array_actv_out_grant;

  logic                                                single_actv_out_ram_we;
  logic [          (AddrWidth)-1:0]                    single_actv_out_ram_addr;
  logic [        (DataWidth)-1 : 0]                    single_actv_out_ram_din;
  logic [        (DataWidth)-1 : 0]                    single_actv_out_ram_dout;
  logic [$clog2(NumConvoCores)-1:0]                    actv_o_select;
  logic                                                actv_o_active;




  //weights array
  logic [        NumConvoCores-1:0][  (AddrWidth)-1:0] array_wgt_ram_addr;
  logic [        NumConvoCores-1:0]                    array_wgt_ram_we;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_wgt_ram_din;
  logic [        NumConvoCores-1:0][(DataWidth)-1 : 0] array_wgt_ram_dout;
  logic [        NumConvoCores-1:0]                    wgt_request;
  logic [        NumConvoCores-1:0]                    wgt_grant;
  //demuxes selected weigth ram signals
  logic [  (InputWgtAddrWidth)-1:0]                    single_wgt_ram_addr;
  logic                                                single_wgt_ram_we;
  logic [     (WeigthsWidth)-1 : 0]                    single_wgt_ram_din;
  logic [     (WeigthsWidth)-1 : 0]                    single_wgt_ram_dout;



  logic [        NumConvoCores-1:0]                    array_req;
  logic [        NumConvoCores-1:0]                    array_ack;
  logic [        NumConvoCores-1:0]                    array_ready;


  assign req_o   = &array_req;
  assign ack_o   = &array_ack;
  assign ready_o = &array_ready;





  //input ram index
  //   ram_mux_input #(
  //       .NUM_PORTS(NumConvoCores),
  //       .DataWidth(WeigthsWidth),
  //       .AddrWidth(InputWgtAddrWidth)
  //   ) ram_mux_input_inst (
  //       .select_i  (wgt_index_i),
  //       .ram_addr_i(wgt_in_ram_addr),
  //       .ram_we_i  (wgt_in_ram_we),
  //       .ram_din_o (wgt_in_ram_dout),
  //       .ram_dout_i(wgt_in_ram_din),
  //       .ram_addr_o(array_wgt_ram_addr),
  //       .ram_we_o  (array_wgt_ram_we),
  //       .ram_din_i (array_wgt_ram_din),
  //       .ram_dout_o(array_wgt_ram_dout)
  //   );

  ram_switch #(
      .NumPorts (NumConvoCores),
      .DataWidth(WeigthsWidth),
      .AddrWidth(InputWgtAddrWidth)
  ) wgt_ram_switch (
      .clk_i(clk_i),
      .reset_i(reset_i),
      .requests(wgt_request),
      .grants(wgt_grant),
      .input_ram_addr(array_wgt_ram_addr),
      .input_ram_we  (array_wgt_ram_we),
      .input_ram_din( array_wgt_ram_din),
      .input_ram_dout(array_wgt_ram_dout),
      .output_ram_addr( single_wgt_ram_addr),
      .output_ram_we(   single_wgt_ram_we),
      .output_ram_din(  single_wgt_ram_din),
      .output_ram_dout( single_wgt_ram_dout)
  );


  bram_dp #(
      .RAM_DATA_WIDTH(DataWidth),
      .RAM_ADDR_WIDTH(InputWgtAddrWidth)
  ) wgt_bram_dp_inst (
      .rst       (reset_i),
      .a_clk     (clk_i),
      .a_wr      (single_wgt_ram_we),
      .a_addr    (single_wgt_ram_addr),
      .a_data_in (single_wgt_ram_dout),
      .a_data_out(single_wgt_ram_din),
      .b_clk     (wgt_in_ram_clk),
      .b_wr      (wgt_in_ram_we),
      .b_addr    (wgt_in_ram_addr),
      .b_data_in (wgt_in_ram_din),
      .b_data_out(wgt_in_ram_dout)
  );


  ram_switch #(
      .NumPorts (NumConvoCores),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) actv_i_ram_switch (
      .clk_i(clk_i),
      .reset_i(reset_i),
      .requests(array_actv_in_req),
      .grants(array_actv_in_grant),
      .input_ram_addr(  array_actv_in_ram_addr),
      .input_ram_we  (  array_actv_in_ram_we),
      .input_ram_din(   array_actv_in_ram_din),
      .input_ram_dout(  array_actv_in_ram_dout),
      .output_ram_addr( single_actv_in_ram_addr),
      .output_ram_we(   single_actv_in_ram_we),
      .output_ram_din(  single_actv_in_ram_din),
      .output_ram_dout( single_actv_in_ram_dout)
  );


  //   arbiter #(
  //       .NUM_PORTS(NumConvoCores),
  //       .SEL_WIDTH()
  //   ) actv_i_arbiter_inst (
  //       .clk(clk_i),
  //       .rst(reset_i),
  //       .request(array_actv_in_req),
  //       .grant(array_actv_in_grant),
  //       .select(actv_i_select),
  //       .active(actv_i_active)
  //   );

  //   ram_mux #(
  //       .NUM_PORTS(NumConvoCores),
  //       .DataWidth(DataWidth),
  //       .AddrWidth(AddrWidth)
  //   ) actv_i_ram_mux_inst (
  //       .select_i  (actv_i_select),
  //       .active_i  (actv_i_active),
  //       .ram_addr_i(array_actv_in_ram_addr),
  //       .ram_we_i  (array_actv_in_ram_we),
  //       .ram_din_o (array_actv_in_ram_din),
  //       .ram_dout_i(array_actv_in_ram_dout),
  //       .ram_addr_o(single_actv_in_ram_addr),
  //       .ram_we_o  (single_actv_in_ram_we),
  //       .ram_din_i (single_actv_in_ram_din),
  //       .ram_dout_o(single_actv_in_ram_dout)
  //   );

  bram_dp #(
      .RAM_DATA_WIDTH(DataWidth),
      .RAM_ADDR_WIDTH(AddrWidth)
  ) actv_i_bram_dp_inst (
      .rst       (reset_i),
      .a_clk     (clk_i),
      .a_wr      (single_actv_in_ram_we),
      .a_addr    (single_actv_in_ram_addr),
      .a_data_in (single_actv_in_ram_dout),
      .a_data_out(single_actv_in_ram_din),
      .b_clk     (actv_in_ram_clk),
      .b_wr      (actv_in_ram_we),
      .b_addr    (actv_in_ram_addr),
      .b_data_in (actv_in_ram_din),
      .b_data_out(actv_in_ram_dout)
  );



  ram_switch #(
      .NumPorts (NumConvoCores),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) actv_o_ram_switch (
      .clk_i          (clk_i),
      .reset_i        (reset_i),
      .requests       (array_actv_out_req),
      .grants         (array_actv_out_grant),
      .input_ram_addr (array_actv_out_ram_addr),
      .input_ram_we   (array_actv_out_ram_we),
      .input_ram_din  (array_actv_out_ram_din),
      .input_ram_dout (array_actv_out_ram_dout),
      .output_ram_addr(actv_out_ram_addr),
      .output_ram_we  (actv_out_ram_we),
      .output_ram_din (actv_out_ram_din),
      .output_ram_dout(actv_out_ram_dout)
  );



  //   arbiter #(
  //   .NUM_PORTS(NumConvoCores),
  //   .SEL_WIDTH()
  //   ) actv_o_arbiter_inst (
  //   .clk(clk_i),
  //   .rst(reset_i),
  //   .request(layer_array_actv_out_req),
  //   .grant(single_array_actv_out_grant),
  //   .select(actv_o_select),
  //   .active(actv_o_active)
  //   );


  //   ram_mux #(
  //   .NUM_PORTS(NumConvoCores),
  //   .DataWidth(DataWidth),
  //   .AddrWidth(AddrWidth)
  //   ) actv_o_ram_mux_inst (
  //   .select_i  (actv_o_select),
  //   .active_i  (actv_o_active),
  //   .ram_addr_i(array_actv_out_ram_addr),
  //   .ram_we_i  (array_actv_out_ram_we),
  //   .ram_din_o (array_actv_out_ram_din),
  //   .ram_dout_i(array_actv_out_ram_dout),
  //   .ram_addr_o(single_actv_out_ram_addr),
  //   .ram_we_o  (single_actv_out_ram_we),
  //   .ram_din_i (single_actv_out_ram_din),
  //   .ram_dout_o(single_actv_out_ram_dout)
  //   );


  arbiter #(
      .NUM_PORTS(NumConvoCores),
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
      .NUM_PORTS(NumConvoCores),
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

  for (genvar i = 0; i < NumConvoCores; i++) begin : gen_convo_network
    convo_2d #(
        .ConvoWidth       (ConvoWidth),
        .ConvoHeight      (ConvoHeight),
        .DataSizeW        (DataSizeW),
        .DataSizeH        (DataSizeH),
        .NumInputs        (NumInputs),
        .DataWidth        (DataWidth),
        .Instance         (i),
        .AddrWidth        (AddrWidth),
        .InputWgtAddrWidth(InputWgtAddrWidth),
        .WeigthsWidth     (WeigthsWidth)
    ) convo_2d_inst (
        .clk_i            (clk_i),
        .reset_i          (reset_i),
        .req_i            (req_i),
        .ack_o            (array_ack[i]),
        .req_o            (array_req[i]),
        .ack_i            (ack_i),
        .ready_i          (ready_i),
        .ready_o          (array_ready[i]),
        .actv_in_ram_we   (array_actv_in_ram_we[i]),
        .actv_in_ram_addr (array_actv_in_ram_addr[i]),
        .actv_in_ram_din  (array_actv_in_ram_din[i]),
        .actv_in_ram_dout (array_actv_in_ram_dout[i]),
        .wgt_in_ram_addr  (array_wgt_ram_addr[i]),
        .wgt_in_ram_we    (array_wgt_ram_we[i]),
        .wgt_in_ram_din   (array_wgt_ram_din[i]),
        .wgt_in_ram_dout  (array_wgt_ram_dout[i]),
        .actv_out_ram_addr(array_actv_out_ram_addr[i]),
        .actv_out_ram_we  (array_actv_out_ram_we[i]),
        .actv_out_ram_din (array_actv_out_ram_din[i]),
        .actv_out_ram_dout(array_actv_out_ram_dout[i]),
        .mult_done_i      (mult_done),
        .mult_busy_i      (mult_busy),
        .mult_start_o     (mult_start_array[i]),
        .mult_grant_i     (mult_grant[i]),
        .mult_req_o       (mult_req[i]),
        .in_actv_req_o    (array_actv_in_req[i]),
        .in_actv_grant_i  (array_actv_in_grant[i]),
        .wgt_req_o        (wgt_request[i]),
        .wgt_grant_i      (wgt_grant[i]),
        .out_actv_req_o   (array_actv_out_req[i]),
        .out_actv_grant_i (array_actv_out_grant[i]),
        .mult_a_o         (mult_a_array[i]),
        .mult_b_o         (mult_b_array[i]),
        .mult_result_i    (mult_result)
    );

  end


endmodule
