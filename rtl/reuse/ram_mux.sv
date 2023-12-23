module ram_mux #(
    parameter int NUM_PORTS = 6,
    parameter int SEL_WIDTH = ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1),
    parameter int DataWidth = 8,
    parameter int AddrWidth = $clog2(DataWidth)

) (
    //grant in
    input  logic [               SEL_WIDTH-1:0] select_i,
    input  logic                                active_i,
    //ram inputs
    input  logic [  (NUM_PORTS *AddrWidth)-1:0] ram_addr_i,
    input  logic [             (NUM_PORTS)-1:0] ram_we_i,
    output logic [           (DataWidth)-1 : 0] ram_din_o,
    input  logic [(NUM_PORTS *DataWidth)-1 : 0] ram_dout_i,
    //ram output
    output logic [               AddrWidth-1:0] ram_addr_o,
    output logic                                ram_we_o,
    input  logic [             DataWidth-1 : 0] ram_din_i,
    output logic [             DataWidth-1 : 0] ram_dout_o

);

  //registered mux
  // always_ff @(posedge clk_i) begin
  //     //reset ram signals to be safe
  //     if (reset_i) begin
  //         ram_we_o <= '0;
  //     end
  //     else begin
  //         if(grant_i != 0) begin
  //             for(int i = 0; i < NUM_PORTS; i++) begin
  //                 if(grant_i[i]) begin
  //                     ram_addr_o <= ram_addr_i[AddrWidth*i +: AddrWidth];
  //                     ram_dout_o <= ram_dout_i[DataWidth*i +: DataWidth];
  //                     ram_we_o <= ram_we_i[i];
  //                 end
  //                 ram_din_o[DataWidth*i +: DataWidth] <= ram_din_i;
  //             end
  //         end
  //     end
  // end


  always_comb begin : ram_mux
    ram_we_o   = '0;
    ram_addr_o = '0;
    ram_dout_o = '0;
    if (active_i) begin
      ram_addr_o = ram_addr_i[AddrWidth*select_i+:AddrWidth];
      ram_dout_o = ram_dout_i[DataWidth*select_i+:DataWidth];
      ram_we_o   = ram_we_i[select_i];
    end
    ram_din_o = ram_din_i;

  end



endmodule
