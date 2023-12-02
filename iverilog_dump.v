module iverilog_dump();
initial begin
    $dumpfile("simple_nn_tb.fst");
    $dumpvars(0, simple_nn_tb);
end
endmodule
