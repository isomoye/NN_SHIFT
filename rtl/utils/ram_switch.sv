module ram_switch #(
    parameter int NumPorts  = 3,
    parameter int DataWidth = 8,
    parameter int AddrWidth = $clog2(DataWidth)

) (
    input logic clk_i,
    input logic reset_i,

    input  logic requests,
    output logic grants,

    input  logic [NumPorts-1:0][  (AddrWidth)-1:0] input_ram_addr,
    input  logic [NumPorts-1:0]                    input_ram_we,
    output logic [NumPorts-1:0][(DataWidth)-1 : 0] input_ram_din,
    input  logic [NumPorts-1:0][(DataWidth)-1 : 0] input_ram_dout,

    output logic [  (AddrWidth)-1:0] output_ram_addr,
    output logic                     output_ram_we,
    input  logic [(DataWidth)-1 : 0] output_ram_din,
    output logic [(DataWidth)-1 : 0] output_ram_dout

);


  logic [$clog2(NumPorts)-1:0] select;
  logic                        active;

  arbiter #(
      .NUM_PORTS(NumPorts),
      .SEL_WIDTH()
  ) actv_o_arbiter_inst (
      .clk(clk_i),
      .rst(reset_i),
      .request(requests),
      .grant(grants),
      .select(select),
      .active(active)
  );
  ram_mux #(
      .NUM_PORTS(NumPorts),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) actv_o_ram_mux_inst (
      .select_i  (select),
      .active_i  (active),
      .ram_addr_i(input_ram_addr),
      .ram_we_i  (input_ram_we),
      .ram_din_o (input_ram_din),
      .ram_dout_i(input_ram_dout),
      .ram_addr_o(output_ram_addr),
      .ram_we_o  (output_ram_we),
      .ram_din_i (output_ram_din),
      .ram_dout_o(output_ram_dout)
  );


endmodule
