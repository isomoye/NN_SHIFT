module conv_2d_top #(
    parameter int ConvoWidth    = 3,
    parameter int ConvoHeight   = 3,
    parameter int NumConvoCores = 1,
    parameter int DataSizeW     = 28,
    parameter int DataSizeH     = 28,
    parameter int NumInputs     = 4,
    parameter int DataWidth     = 8,
    parameter int WeigthsWidth  = DataWidth,
    parameter int AddrWidth     = $clog2(DataSizeW * DataSizeH),
    parameter int FpWidth       = 4,
    parameter int NumWeights        = NumConvoCores * ConvoWidth * ConvoHeight,
    parameter int InputWgtAddrWidth = $clog2(NumWeights)
) ();


  // Parameters

  //Ports
  logic system_clk;
  logic system_rst;
  //   logic req_i;
  //   logic ack_o;
  //   logic req_o;
  //   logic ack_i;
  //   logic ready_i;
  //   logic ready_o;

  logic hw_rst;
  logic sw_rst;

  assign sw_rst = gpio_ins[0];
  assign system_rst = sw_rst | hw_rst;


  logic                           actv_in_ram_we;
  logic [        (AddrWidth)-1:0] actv_in_ram_addr;
  logic [      (DataWidth)-1 : 0] actv_in_ram_din;
  logic [      (DataWidth)-1 : 0] actv_in_ram_dout;
  logic                           actv_in_ram_clk;

  logic [(InputWgtAddrWidth)-1:0] wgt_in_ram_addr;
  logic                           wgt_in_ram_we;
  logic [   (WeigthsWidth)-1 : 0] wgt_in_ram_din;
  logic [   (WeigthsWidth)-1 : 0] wgt_in_ram_dout;
  logic                           wgt_in_ram_clk;


  logic [        (AddrWidth)-1:0] actv_out_ram_addr;
  logic                           actv_out_ram_we;
  logic [      (DataWidth)-1 : 0] actv_out_ram_din;
  logic [      (DataWidth)-1 : 0] actv_out_ram_dout;
  logic                           actv_out_ram_clk;


  logic [        (AddrWidth)-1:0] actv_ps_ram_addr;
  logic                           actv_ps_ram_we;
  logic [      (DataWidth)-1 : 0] actv_ps_ram_din;
  logic [      (DataWidth)-1 : 0] actv_ps_ram_dout;

  logic [                   31:0] gpio_ins;
  logic [                   31:0] gpio_outs;


  convo_2d_wrapper #(
      .ConvoWidth       (ConvoWidth),
      .ConvoHeight      (ConvoHeight),
      .DataSizeW        (DataSizeW),
      .DataSizeH        (DataSizeH),
      .NumConvoCores    (NumConvoCores),
      .DataWidth        (DataWidth),
      .WeigthsWidth     (WeigthsWidth)
  ) convo_2d_wrapper_inst (
      .clk_i(system_clk),
      .reset_i(system_rst),
      .req_i(gpio_ins[1]),
      .ack_o(gpio_outs[0]),
      .req_o(gpio_outs[1]),
      .ack_i(gpio_ins[2]),
      .ready_i(gpio_ins[3]),
      .ready_o(gpio_outs[2]),
      .actv_in_ram_we(actv_in_ram_we),
      .actv_in_ram_addr(actv_in_ram_addr),
      .actv_in_ram_din(actv_in_ram_din),
      .actv_in_ram_dout(actv_in_ram_dout),
      .actv_in_ram_clk(actv_in_ram_clk),
      .wgt_in_ram_addr(wgt_in_ram_addr),
      .wgt_in_ram_we(wgt_in_ram_we),
      .wgt_in_ram_din(wgt_in_ram_din),
      .wgt_in_ram_dout(wgt_in_ram_dout),
      .wgt_in_ram_clk(wgt_in_ram_clk),
      .actv_out_ram_addr(actv_out_ram_addr),
      .actv_out_ram_we(actv_out_ram_we),
      .actv_out_ram_din(actv_out_ram_din),
      .actv_out_ram_dout(actv_out_ram_dout)
  );

  bram_dp #(
      .RAM_DATA_WIDTH(DataWidth),
      .RAM_ADDR_WIDTH(AddrWidth)
  ) actv_out_bram_dp_inst (
      .rst       (reset_i),
      .a_clk     (system_clk),
      .a_wr      (actv_ps_ram_we),
      .a_addr    (actv_ps_ram_addr),
      .a_data_in (actv_ps_ram_din),
      .a_data_out(actv_ps_ram_dout),
      .b_clk     (actv_out_ram_clk),
      .b_wr      (actv_out_ram_we),
      .b_addr    (actv_out_ram_addr),
      .b_data_in (actv_out_ram_din),
      .b_data_out(actv_out_ram_dout)
  );


  system_wrapper_wrapper system_wrapper_inst (
      .convo_clock(system_clk),
      .system_rst(hw_rst),
      .actv_i_addr(actv_in_ram_addr),
      .actv_i_clk(actv_in_ram_clk),
      .actv_i_din(actv_in_ram_dout),
      .actv_i_dout(actv_in_ram_din),
      .actv_i_en('1),
      .actv_i_rst('0),
      .actv_i_we(actv_in_ram_we),
      .actv_o_addr(actv_ps_ram_addr),
      .actv_o_clk(actv_out_ram_clk),
      .actv_o_din(actv_ps_ram_din),
      .actv_o_dout(actv_ps_ram_dout),
      .actv_o_en('1),
      .actv_o_rst('0),
      .actv_o_we(actv_ps_ram_we),
      .gpio_ins_tri_i(gpio_outs),
      .gpio_outs_tri_o(gpio_ins),
      .wgt_addr(wgt_in_ram_addr),
      .wgt_clk(wgt_in_ram_clk),
      .wgt_din(wgt_in_ram_dout),
      .wgt_dout(wgt_in_ram_din),
      .wgt_en('1),
      .wgt_rst('0),
      .wgt_we(wgt_in_ram_we)
  );


endmodule
