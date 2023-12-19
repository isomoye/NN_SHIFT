// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Sat Dec 16 20:45:01 2023
// Host        : idris-HP-EliteBook-840-G3 running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/idris/projects/FPGA_VISION/NN_SHIFT/hardware/convo_2d/convo_2d.gen/sources_1/bd/system_wrapper/ip/system_wrapper_debug_bridge_0_0/bd_0/ip/ip_1/bd_07e0_bsip_0_stub.v
// Design      : bd_07e0_bsip_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bsip_v1_1_0_bsip,Vivado 2023.2" *)
module bd_07e0_bsip_0(drck, reset, sel, shift, tdi, update, capture, runtest, 
  tck, tms, tap_tdo, tdo, tap_tdi, tap_tms, tap_tck)
/* synthesis syn_black_box black_box_pad_pin="drck,reset,sel,shift,tdi,update,capture,runtest,tms,tap_tdo,tdo,tap_tdi,tap_tms,tap_tck" */
/* synthesis syn_force_seq_prim="tck" */;
  output drck;
  output reset;
  output sel;
  output shift;
  output tdi;
  output update;
  output capture;
  output runtest;
  output tck /* synthesis syn_isclock = 1 */;
  output tms;
  output tap_tdo;
  input tdo;
  input tap_tdi;
  input tap_tms;
  input tap_tck;
endmodule
