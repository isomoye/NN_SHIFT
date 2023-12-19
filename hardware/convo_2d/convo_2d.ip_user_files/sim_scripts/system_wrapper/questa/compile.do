vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_15
vlib questa_lib/msim/processing_system7_vip_v1_0_17
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/axi_jtag_v1_0_1
vlib questa_lib/msim/bsip_v1_1_0
vlib questa_lib/msim/axi_lite_ipif_v3_0_4
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/interrupt_control_v3_1_5
vlib questa_lib/msim/axi_gpio_v2_0_31
vlib questa_lib/msim/xlconstant_v1_1_8
vlib questa_lib/msim/proc_sys_reset_v5_0_14
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_register_slice_v2_1_29
vlib questa_lib/msim/axi_bram_ctrl_v4_1_9

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_15 questa_lib/msim/axi_vip_v1_1_15
vmap processing_system7_vip_v1_0_17 questa_lib/msim/processing_system7_vip_v1_0_17
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap axi_jtag_v1_0_1 questa_lib/msim/axi_jtag_v1_0_1
vmap bsip_v1_1_0 questa_lib/msim/bsip_v1_1_0
vmap axi_lite_ipif_v3_0_4 questa_lib/msim/axi_lite_ipif_v3_0_4
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap interrupt_control_v3_1_5 questa_lib/msim/interrupt_control_v3_1_5
vmap axi_gpio_v2_0_31 questa_lib/msim/axi_gpio_v2_0_31
vmap xlconstant_v1_1_8 questa_lib/msim/xlconstant_v1_1_8
vmap proc_sys_reset_v5_0_14 questa_lib/msim/proc_sys_reset_v5_0_14
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_register_slice_v2_1_29 questa_lib/msim/axi_register_slice_v2_1_29
vmap axi_bram_ctrl_v4_1_9 questa_lib/msim/axi_bram_ctrl_v4_1_9

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/home/idris/opt/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_15 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/5753/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_17 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_processing_system7_0_0/sim/system_wrapper_processing_system7_0_0.v" \

vlog -work axi_jtag_v1_0_1 -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/e7c0/hdl/axi_jtag_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_debug_bridge_0_0/bd_0/ip/ip_0/sim/bd_07e0_axi_jtag_0.v" \

vlog -work bsip_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/275b/hdl/bsip_v1_1_rfs.v" \

vcom -work bsip_v1_1_0 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/275b/hdl/bsip_v1_1_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/system_wrapper/ip/system_wrapper_debug_bridge_0_0/bd_0/ip/ip_1/sim/bd_07e0_bsip_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_debug_bridge_0_0/bd_0/sim/bd_07e0.v" \
"../../../bd/system_wrapper/ip/system_wrapper_debug_bridge_0_0/sim/system_wrapper_debug_bridge_0_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work interrupt_control_v3_1_5 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/d8cc/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_31 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6fbe/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/system_wrapper/ip/system_wrapper_axi_gpio_0_0/sim/system_wrapper_axi_gpio_0_0.vhd" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_gpio_0_1/sim/system_wrapper_axi_gpio_0_1.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/sim/bd_7662.v" \

vlog -work xlconstant_v1_1_8 -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/d390/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_0/sim/bd_7662_one_0.v" \

vcom -work proc_sys_reset_v5_0_14 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/408c/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_1/sim/bd_7662_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/bd53/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_2/sim/bd_7662_arinsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_3/sim/bd_7662_rinsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_4/sim/bd_7662_awinsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_5/sim/bd_7662_winsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_6/sim/bd_7662_binsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_7/sim/bd_7662_aroutsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_8/sim/bd_7662_routsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_9/sim/bd_7662_awoutsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_10/sim/bd_7662_woutsw_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_11/sim/bd_7662_boutsw_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_12/sim/bd_7662_arni_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_13/sim/bd_7662_rni_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_14/sim/bd_7662_awni_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_15/sim/bd_7662_wni_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_16/sim/bd_7662_bni_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c6b2/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_17/sim/bd_7662_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/abb8/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_18/sim/bd_7662_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/7827/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_19/sim/bd_7662_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/79ce/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_20/sim/bd_7662_s00a2s_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_21/sim/bd_7662_sarn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_22/sim/bd_7662_srn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_23/sim/bd_7662_sawn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_24/sim/bd_7662_swn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_25/sim/bd_7662_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ebf7/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_26/sim/bd_7662_m00s2a_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_27/sim/bd_7662_m00arn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_28/sim/bd_7662_m00rn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_29/sim/bd_7662_m00awn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_30/sim/bd_7662_m00wn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_31/sim/bd_7662_m00bn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6eea/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_15 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_17 -L xilinx_vip "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_32/sim/bd_7662_m00e_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_33/sim/bd_7662_m01s2a_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_34/sim/bd_7662_m01arn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_35/sim/bd_7662_m01rn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_36/sim/bd_7662_m01awn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_37/sim/bd_7662_m01wn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_38/sim/bd_7662_m01bn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_39/sim/bd_7662_m01e_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_40/sim/bd_7662_m02s2a_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_41/sim/bd_7662_m02arn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_42/sim/bd_7662_m02rn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_43/sim/bd_7662_m02awn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_44/sim/bd_7662_m02wn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_45/sim/bd_7662_m02bn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_46/sim/bd_7662_m02e_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_47/sim/bd_7662_m03s2a_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_48/sim/bd_7662_m03arn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_49/sim/bd_7662_m03rn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_50/sim/bd_7662_m03awn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_51/sim/bd_7662_m03wn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_52/sim/bd_7662_m03bn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_53/sim/bd_7662_m03e_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_54/sim/bd_7662_m04s2a_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_55/sim/bd_7662_m04arn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_56/sim/bd_7662_m04rn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_57/sim/bd_7662_m04awn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_58/sim/bd_7662_m04wn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_59/sim/bd_7662_m04bn_0.sv" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/bd_0/ip/ip_60/sim/bd_7662_m04e_0.sv" \

vlog -work axi_register_slice_v2_1_29 -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ff9f/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_smc_0/sim/system_wrapper_axi_smc_0.v" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/system_wrapper/ip/system_wrapper_rst_ps7_0_50M_0/sim/system_wrapper_rst_ps7_0_50M_0.vhd" \

vcom -work axi_bram_ctrl_v4_1_9 -64 -93  \
"../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/5ed7/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/system_wrapper/ip/system_wrapper_axi_bram_ctrl_0_1/sim/system_wrapper_axi_bram_ctrl_0_1.vhd" \
"../../../bd/system_wrapper/ip/system_wrapper_axi_bram_ctrl_1_0/sim/system_wrapper_axi_bram_ctrl_1_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/ec67/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/6b2b/hdl" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/f0b6/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/35de/hdl/verilog" "+incdir+../../../../convo_2d.gen/sources_1/bd/system_wrapper/ipshared/c2c6" "+incdir+/home/idris/opt/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../bd/system_wrapper/ip/system_wrapper_clk_wiz_0_0/system_wrapper_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/system_wrapper/ip/system_wrapper_clk_wiz_0_0/system_wrapper_clk_wiz_0_0.v" \
"../../../bd/system_wrapper/sim/system_wrapper.v" \

vlog -work xil_defaultlib \
"glbl.v"

