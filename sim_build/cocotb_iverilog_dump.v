module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/convo_2d_wrapper.fst");
    $dumpvars(0, convo_2d_wrapper);
end
endmodule
