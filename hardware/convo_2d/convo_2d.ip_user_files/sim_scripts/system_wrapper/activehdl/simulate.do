transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+system_wrapper  -L xilinx_vip -L xpm -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_15 -L processing_system7_vip_v1_0_17 -L xil_defaultlib -L axi_jtag_v1_0_1 -L bsip_v1_1_0 -L axi_lite_ipif_v3_0_4 -L lib_cdc_v1_0_2 -L interrupt_control_v3_1_5 -L axi_gpio_v2_0_31 -L xlconstant_v1_1_8 -L proc_sys_reset_v5_0_14 -L smartconnect_v1_0 -L axi_register_slice_v2_1_29 -L axi_bram_ctrl_v4_1_9 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.system_wrapper xil_defaultlib.glbl

do {system_wrapper.udo}

run

endsim

quit -force
