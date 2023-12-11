module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/ram_nn.fst");
    $dumpvars(0, ram_nn);
end
endmodule
