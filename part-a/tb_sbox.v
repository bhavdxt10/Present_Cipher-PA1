`timescale 1ns / 1ps
module tb_sbox;

// testbench signals
reg [3:0] inp;
wire [3:0] outp;

// instantiate the S-box module

initial begin
    // display header
    $display("Time\t Input\t Output");
    // monitor changes in inp and outp
    $monitor("%0dns\t %b\t %b", $time, inp, outp);

    inp = 0;
    // stimulate the inp signal after a certain delay
    // test all possible values for inp signal

    // finish simulation
    $finish;
end

initial begin
    $dumpfile("sbox_dump.vcd");
    $dumpvars(1, tb_sbox);
end

endmodule
