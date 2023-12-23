module ram_mux_input #(
    parameter  int NUM_PORTS = 6,
    parameter  int DataWidth = 8,
    parameter  int SelectWidth =  ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1),
    parameter  int AddrWidth = $clog2(DataWidth)

) (
    //grant in
    input  logic [               SelectWidth-1:0] select_i,
    //ram inputs
    input  logic [             (AddrWidth)-1:0] ram_addr_i,
    input  logic                                ram_we_i,
    output logic [           (DataWidth)-1 : 0] ram_din_o,
    input  logic [           (DataWidth)-1 : 0] ram_dout_i,
    //ram output
    output logic [  (NUM_PORTS *AddrWidth)-1:0] ram_addr_o,
    output logic [             (NUM_PORTS)-1:0] ram_we_o,
    input  logic [(NUM_PORTS *DataWidth)-1 : 0] ram_din_i,
    output logic [(NUM_PORTS *DataWidth)-1 : 0] ram_dout_o

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
    for (int i = 0; i < NUM_PORTS; i++) begin
      // ram_addr_o[i] = '0;
      // ram_dout_o[i] = '0;
      // ram_we_o[i]   = '0;
      if (select_i == i) begin
        ram_addr_o[AddrWidth*i+:AddrWidth] = ram_addr_i;
        ram_dout_o[DataWidth*i+:DataWidth] = ram_dout_i;
        ram_we_o[i]   = ram_we_i;
      end
    end
  end

  assign ram_din_o = ram_din_i[DataWidth*select_i+:DataWidth];

endmodule
