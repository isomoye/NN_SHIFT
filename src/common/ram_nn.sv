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

  localparam int NumLayers = (NumHiddenLayer * EnableHiddenLayer) + 2;


  //   logic [  (AddrWidth)-1:0]                    wgt_update_ram_addr;
  //   logic                                        wgt_update_ram_we;
  //   logic [(DataWidth)-1 : 0]                    wgt_update_ram_din;
  //   logic [(DataWidth)-1 : 0]                    wgt_update_ram_dout;


  logic [NumLayers-1:0][  (AddrWidth)-1:0] wgt_update_ram_addr;
  logic [NumLayers-1:0]                    wgt_update_ram_we;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] wgt_update_ram_din;
  logic [NumLayers-1:0][(DataWidth)-1 : 0] wgt_update_ram_dout;

  logic [  NumLayers:0][  (AddrWidth)-1:0] top_actv_in_ram_addr;
  logic [  NumLayers:0]                    top_actv_in_ram_we;
  logic [  NumLayers:0][(DataWidth)-1 : 0] top_actv_in_ram_din;
  logic [  NumLayers:0][(DataWidth)-1 : 0] top_actv_in_ram_dout;


  logic [  NumLayers:0][  (AddrWidth)-1:0] top_actv_out_ram_addr;
  logic [  NumLayers:0]                    top_actv_out_ram_we;
  logic [  NumLayers:0][(DataWidth)-1 : 0] top_actv_out_ram_din;
  logic [  NumLayers:0][(DataWidth)-1 : 0] top_actv_out_ram_dout;

  logic [  NumLayers:0]                    request;
  logic [  NumLayers:0]                    ack;

  assign request[0] = req_i;
  assign ack_o   = ack[NumLayers];
  assign top_actv_in_ram_addr[0]  =    actv_in_ram_addr;
  assign top_actv_in_ram_we[0]    =    actv_in_ram_we;
  assign actv_in_ram_dout          =    top_actv_in_ram_din[0];
  assign top_actv_in_ram_dout[0]   =    actv_in_ram_din;



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
      ram_nn_layer #(
          .NumInputLayer    (InputWidth),
          .DataWidth        (DataWidth),
          .WeigthsWidth     (WeigthsWidth),
          .AddrWidth        (AddrWidth),
          .NumNeuronsLayer  (NumInputLayer),
          .InputWgtWidth    (InputWgtWidth),
          .InputWgtAddrWidth(InputWgtAddrWidth),
          .FpWidth          (FpWidth)
      ) ram_nn_layer_inst (
          .clk_i            (clk_i),
          .reset_i          (reset_i),
          .req_i            (request[i]),
          .ack_o            (ack[i]),
          .req_o            (request[i+1]),
          .ack_i            (ack[i+1]),
          .actv_in_ram_we   (top_actv_in_ram_we[i]),
          .actv_in_ram_addr (top_actv_in_ram_addr[i]),
          .actv_in_ram_din  (top_actv_in_ram_dout[i]),
          .actv_in_ram_dout (top_actv_in_ram_din[i]),
          .wgt_in_ram_addr  (wgt_update_ram_addr[i]),
          .wgt_in_ram_we    (wgt_update_ram_we[i]),
          .wgt_in_ram_din   (wgt_update_ram_dout[i]),
          .wgt_in_ram_dout  (wgt_update_ram_din[i]),
          .actv_out_ram_addr(top_actv_in_ram_addr[i+1]),
          .actv_out_ram_we  (top_actv_in_ram_we[i+1]),
          .actv_out_ram_din (top_actv_in_ram_din[i+1]),
          .actv_out_ram_dout(top_actv_in_ram_dout[i+1])
      );
    end
    else begin
        ram_nn_layer #(
          .NumInputLayer    (NumInputLayer),
          .DataWidth        (DataWidth),
          .WeigthsWidth     (WeigthsWidth),
          .AddrWidth        (AddrWidth),
          .NumNeuronsLayer  (NeuronsPerHiddenLayer),
          .FpWidth          (FpWidth)
      ) ram_nn_layer_inst (
          .clk_i            (clk_i),
          .reset_i          (reset_i),
          .req_i            (request[i]),
          .ack_o            (ack[i]),
          .req_o            (request[i+1]),
          .ack_i            (ack[i+1]),
          .actv_in_ram_we   (top_actv_in_ram_we[i]),
          .actv_in_ram_addr (top_actv_in_ram_addr[i]),
          .actv_in_ram_din  (top_actv_in_ram_dout[i]),
          .actv_in_ram_dout (top_actv_in_ram_din[i]),
          .wgt_in_ram_addr  (wgt_update_ram_addr[i]),
          .wgt_in_ram_we    (wgt_update_ram_we[i]),
          .wgt_in_ram_din   (wgt_update_ram_dout[i]),
          .wgt_in_ram_dout  (wgt_update_ram_din[i]),
          .actv_out_ram_addr(top_actv_in_ram_addr[i+1]),
          .actv_out_ram_we  (top_actv_in_ram_we[i+1]),
          .actv_out_ram_din (top_actv_in_ram_din[i+1]),
          .actv_out_ram_dout(top_actv_in_ram_dout[i+1])
      );
    end
  end

endmodule
