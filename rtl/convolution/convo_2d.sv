module convo_2d #(
    parameter int ConvoWidth        = 4,
    parameter int ConvoHeight       = 4,
    parameter int DataSizeW         = 16,
    parameter int DataSizeH         = 16,
    parameter int NumInputs         = 4,
    parameter int DataWidth         = 8,
    parameter int Instance          = 0,
    parameter int AddrWidth         = $clog2(DataSizeW * DataSizeH),
    parameter int InputWgtAddrWidth = $clog2(ConvoWidth * ConvoHeight),
    parameter int WeigthsWidth      = DataWidth
) (
    input  logic clk_i,
    input  logic reset_i,
    //upstream handshake
    input  logic req_i,
    output logic ack_o,
    //downstream handshake
    output logic req_o,
    input  logic ack_i,

    input  logic ready_i,
    output logic ready_o,

    //actv inputs
    output logic                     actv_in_ram_we,
    output logic [  (AddrWidth)-1:0] actv_in_ram_addr,
    input  logic [(DataWidth)-1 : 0] actv_in_ram_din,
    output logic [(DataWidth)-1 : 0] actv_in_ram_dout,

    //ram inputs
    output logic [(InputWgtAddrWidth)-1:0] wgt_in_ram_addr,
    output logic                           wgt_in_ram_we,
    input  logic [      (DataWidth)-1 : 0] wgt_in_ram_din,
    output logic [      (DataWidth)-1 : 0] wgt_in_ram_dout,

    //ram outputs
    output logic [  (AddrWidth)-1:0] actv_out_ram_addr,
    output logic                     actv_out_ram_we,
    input  logic [(DataWidth)-1 : 0] actv_out_ram_din,
    output logic [(DataWidth)-1 : 0] actv_out_ram_dout,
    //mult handshake signals
    input  logic                     mult_done_i,
    input  logic                     mult_busy_i,
    output logic                     mult_start_o,
    input  logic                     mult_grant_i,
    output logic                     mult_req_o,
    //downstream mutex signals
    output logic                     in_actv_req_o,
    input  logic                     in_actv_grant_i,
    //weight mutex signals
    output logic                     wgt_req_o,
    input  logic                     wgt_grant_i,
    //upstream mutex signals
    output logic                     out_actv_req_o,
    input  logic                     out_actv_grant_i,
    //multiply algor signals
    output logic [  (DataWidth)-1:0] mult_a_o,
    output logic [  (DataWidth)-1:0] mult_b_o,
    input  logic [(DataWidth*2)-1:0] mult_result_i
);

  localparam int NumWindowsWidth = DataSizeW / ConvoWidth;
  localparam int NumWindowsHeight = DataSizeH / ConvoWidth;

  localparam int KCenterX = ConvoWidth / 2;
  localparam int KCenterY = ConvoHeight / 2;

  localparam int StartWeightAddr = InputWgtAddrWidth * Instance;
  // int kCenterX = MASK_WIDTH2 / 2;
  // int kCenterY = MASK_WIDTH1 / 2;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_WAIT_REQ,
    ST_GET_KEY,
    ST_GET_MULT,
    ST_WAIT_MULT,
    ST_GET_VALUES,
    ST_CHECK_INDEX,
    ST_CHECK_IMG_INDEX,
    ST_WAIT_READY,
    ST_ADDRESS,
    ST_OUTPUT,
    ST_CHECK,
    ST_STORE
  } st_convo_e;

  st_convo_e state;


  logic [$clog2(NumInputs)-1:0] counter;
  logic signed [(DataWidth*2)-1 : 0] sum;


  logic [31:0] cnt_x;
  logic [31:0] cnt_y;
  logic [31:0] start_x;
  logic [31:0] start_y;

  logic [31:0] cnt_x_center;
  logic [31:0] cnt_y_center;
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= ST_IDLE;
      //we
      actv_in_ram_we <= '0;
      actv_out_ram_we <= '0;
      wgt_in_ram_we <= '0;
      //req
      req_o <= '0;
      ack_o <= '0;
      sum <= '0;
      ready_o <= '1;

      mult_start_o <= '0;
      mult_req_o <= '0;

      counter <= '0;
      start_x <= '0;
      start_y <= '0;
      cnt_x <= '0;
      cnt_y <= '0;
      //ram signals
    end else begin
      case (state)
        //idle state
        ST_IDLE: begin
          if (req_i) begin
            in_actv_req_o <= '1;
            ack_o <= '1;
            wgt_req_o <= '1;
            counter <= '0;
            start_x <= '0;
            start_y <= '0;
            sum <= '0;
            ready_o <= '0;
            //addresses
            actv_in_ram_addr <= '0;
            wgt_in_ram_addr <= StartWeightAddr;
            actv_out_ram_addr <= '0;

            state <= ST_WAIT_REQ;
          end
        end
        ST_WAIT_REQ: begin
          if (!req_i) begin
            ack_o <= '0;
            if (in_actv_grant_i && wgt_grant_i) begin
              cnt_x_center <= cnt_x + KCenterX;
              cnt_y_center <= cnt_y + KCenterY;
              state <= ST_GET_VALUES;
            end else begin
              state <= ST_GET_KEY;
            end
          end
        end
        ST_GET_KEY: begin
          ack_o <= '0;
          if (in_actv_grant_i && wgt_grant_i) begin
            cnt_x_center <= start_x + KCenterX;
            cnt_y_center <= start_y + KCenterY;
            state <= ST_GET_VALUES;
          end
        end
        ST_GET_VALUES: begin
          if(((start_x < KCenterX) && (cnt_x < KCenterX)) ||
          ((cnt_x_center >= DataSizeW-1) && (cnt_x > KCenterX)) ||
          ((start_y < KCenterY) && (cnt_y < KCenterY)) ||
          ( (cnt_y_center >= DataSizeH-1) && (cnt_y > KCenterY))) begin
            //skip
            state <= ST_CHECK_INDEX;
          end else begin
            mult_a_o <= wgt_in_ram_din;
            mult_b_o <= actv_in_ram_din;
            in_actv_req_o <= '0;
            wgt_req_o <= '0;
            mult_req_o <= '1;
            mult_start_o <= '1;
            if (mult_grant_i) begin
              mult_start_o <= '0;
              state <= ST_WAIT_MULT;
            end else begin
              state <= ST_GET_MULT;
            end
          end
        end
        //get multiplier mutex key
        ST_GET_MULT: begin
          if (mult_grant_i) begin
            mult_start_o <= '0;
            if (mult_done_i) begin
              sum <= sum + mult_result_i;
              mult_req_o <= '0;
              state <= ST_CHECK_INDEX;
            end else begin
              state <= ST_WAIT_MULT;
            end
          end
        end
        ST_WAIT_MULT: begin
          mult_start_o <= '0;
          if (mult_done_i) begin
            sum <= sum + mult_result_i;
            mult_req_o <= '0;
            state <= ST_CHECK_INDEX;
          end
        end
        ST_CHECK_INDEX: begin
          if ((cnt_x == ConvoWidth - 1) && (cnt_y == ConvoHeight - 1)) begin
            cnt_x <= '0;
            cnt_y <= '0;
            //start_x <= start_x + 1;
            out_actv_req_o <= '1;
            state <= ST_CHECK_IMG_INDEX;
          end else if (cnt_x == (ConvoWidth - 1)) begin
            cnt_x <= '0;
            cnt_y <= cnt_y + 1;
            in_actv_req_o <= '1;
            state <= ST_ADDRESS;
          end else begin
            cnt_x <= cnt_x + 1;
            in_actv_req_o <= '1;
            state <= ST_ADDRESS;
          end
        end
        ST_ADDRESS: begin
          //x * SIZE_Y + y
          actv_out_ram_we <= '0;
          wgt_in_ram_addr <= StartWeightAddr + ((cnt_y * ConvoWidth) + cnt_x);
          actv_in_ram_addr <= (((cnt_y + (start_y-KCenterY)) * DataSizeW)) + 
          (cnt_x + (start_x-KCenterX));
          in_actv_req_o <= '1;
          wgt_req_o <= '1;
          state <= ST_GET_KEY;
        end
        ST_CHECK_IMG_INDEX: begin
          if ((start_x >= DataSizeW - 1) && (start_y >= DataSizeH - 1)) begin
            ready_o <= '1;
            state   <= ST_OUTPUT;
            req_o   <= '1;
          end else if (start_x == DataSizeW - 1) begin
            start_x <= '0;
            start_y <= start_y + 1;
            state   <= ST_WAIT_READY;
          end else begin
            start_x <= start_x + 1;
            state   <= ST_WAIT_READY;
          end
        end
        ST_WAIT_READY: begin
          if (ready_i && out_actv_grant_i) begin
            state <= ST_ADDRESS;
            actv_out_ram_addr <= (start_y * DataSizeW) + start_x;
            actv_out_ram_we <= '1;
            actv_out_ram_dout <= sum;
            sum <= '0;
            out_actv_req_o <= '0;
          end
        end
        //req to upstream.. wait till acked
        ST_OUTPUT: begin
          actv_in_ram_we <= '0;
          actv_out_ram_we <= '0;
          out_actv_req_o <= '0;
          cnt_x <= '0;
          cnt_y <= '0;
          start_x <= '0;
          start_y <= '0;
          if (ack_i) begin
            state <= ST_IDLE;
            req_o <= '0;
          end
        end
        default: begin
        end
      endcase
    end
  end


  // assign in_actv_addr_o = counter;
  // assign wgt_addr_o = StartAddress + counter;
  // assign out_actv_addr_o = NeuronInstance;
endmodule



// // find center position of kernel (half of kernel size)
// int kCenterX = MASK_WIDTH2 / 2;
// int kCenterY = MASK_WIDTH1 / 2;

// for (int i = 0; i < WIDTH1; ++i)              // rows
// {
//     for (int j = 0; j < WIDTH2; ++j)          // columns
//     {
//         for (int m = 0; m < MASK_WIDTH1; ++m)     // kernel rows
//         {
//             int mm = MASK_WIDTH1 - 1 - m;      // row index

//             for (int n = 0; n < MASK_WIDTH2; ++n) // kernel columns
//             {
//                 int nn = MASK_WIDTH2 - 1 - n;  // column index

//                 // index of input signal, used for checking boundary
//                 int ii = i + (m - kCenterY);
//                 int jj = j + (n - kCenterX);

//                 // ignore input samples which are out of bound
//                 if (ii >= 0 && ii < WIDTH1 && jj >= 0 && jj < WIDTH2)
//                     P[i][j] += N[ii][jj] * M[mm][nn];
//             }
//         }
//     }
// }
