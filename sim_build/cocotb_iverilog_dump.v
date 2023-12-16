module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/convo_2d.fst");
    $dumpvars(0, convo_2d);
end
endmodule
