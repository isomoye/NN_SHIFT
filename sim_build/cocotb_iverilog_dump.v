module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/simple_nn_tb.fst");
    $dumpvars(0, simple_nn_tb);
end
endmodule
