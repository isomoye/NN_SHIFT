//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Sun Dec 17 15:46:56 2023
//Host        : idris-HP-EliteBook-840-G3 running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target system_wrapper_wrapper.bd
//Design      : system_wrapper_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper_wrapper
   (actv_i_addr,
    actv_i_clk,
    actv_i_din,
    actv_i_dout,
    actv_i_en,
    actv_i_rst,
    actv_i_we,
    actv_o_addr,
    actv_o_clk,
    actv_o_din,
    actv_o_dout,
    actv_o_en,
    actv_o_rst,
    actv_o_we,
    convo_clock,
    gpio_ins_tri_i,
    gpio_outs_tri_o,
    locked_0,
    system_rst,
    wgt_addr,
    wgt_clk,
    wgt_din,
    wgt_dout,
    wgt_en,
    wgt_rst,
    wgt_we);
  output [12:0]actv_i_addr;
  output actv_i_clk;
  output [31:0]actv_i_din;
  input [31:0]actv_i_dout;
  output actv_i_en;
  output actv_i_rst;
  output [3:0]actv_i_we;
  output [12:0]actv_o_addr;
  output actv_o_clk;
  output [31:0]actv_o_din;
  input [31:0]actv_o_dout;
  output actv_o_en;
  output actv_o_rst;
  output [3:0]actv_o_we;
  output convo_clock;
  input [31:0]gpio_ins_tri_i;
  output [31:0]gpio_outs_tri_o;
  output locked_0;
  output system_rst;
  output [12:0]wgt_addr;
  output wgt_clk;
  output [31:0]wgt_din;
  input [31:0]wgt_dout;
  output wgt_en;
  output wgt_rst;
  output [3:0]wgt_we;

  wire [12:0]actv_i_addr;
  wire actv_i_clk;
  wire [31:0]actv_i_din;
  wire [31:0]actv_i_dout;
  wire actv_i_en;
  wire actv_i_rst;
  wire [3:0]actv_i_we;
  wire [12:0]actv_o_addr;
  wire actv_o_clk;
  wire [31:0]actv_o_din;
  wire [31:0]actv_o_dout;
  wire actv_o_en;
  wire actv_o_rst;
  wire [3:0]actv_o_we;
  wire convo_clock;
  wire [31:0]gpio_ins_tri_i;
  wire [31:0]gpio_outs_tri_o;
  wire locked_0;
  wire system_rst;
  wire [12:0]wgt_addr;
  wire wgt_clk;
  wire [31:0]wgt_din;
  wire [31:0]wgt_dout;
  wire wgt_en;
  wire wgt_rst;
  wire [3:0]wgt_we;

  system_wrapper system_wrapper_i
       (.actv_i_addr(actv_i_addr),
        .actv_i_clk(actv_i_clk),
        .actv_i_din(actv_i_din),
        .actv_i_dout(actv_i_dout),
        .actv_i_en(actv_i_en),
        .actv_i_rst(actv_i_rst),
        .actv_i_we(actv_i_we),
        .actv_o_addr(actv_o_addr),
        .actv_o_clk(actv_o_clk),
        .actv_o_din(actv_o_din),
        .actv_o_dout(actv_o_dout),
        .actv_o_en(actv_o_en),
        .actv_o_rst(actv_o_rst),
        .actv_o_we(actv_o_we),
        .convo_clock(convo_clock),
        .gpio_ins_tri_i(gpio_ins_tri_i),
        .gpio_outs_tri_o(gpio_outs_tri_o),
        .locked_0(locked_0),
        .system_rst(system_rst),
        .wgt_addr(wgt_addr),
        .wgt_clk(wgt_clk),
        .wgt_din(wgt_din),
        .wgt_dout(wgt_dout),
        .wgt_en(wgt_en),
        .wgt_rst(wgt_rst),
        .wgt_we(wgt_we));
endmodule
