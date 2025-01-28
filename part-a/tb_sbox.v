`timescale 1ns/1ns

module tb_sbox;

// testbench signals
reg [3:0] inp; 
wire [3:0] outp;
integer i;

// instantiate the S-box module
sbox sb ( .inp(inp), .outp(outp) );

initial begin
    // display header
    $display("Time\t Input\t Output");
    // monitor changes in inp and outp
    $monitor("%0dns\t %b\t %b", $time, inp, outp);

    // stimulate the inp signal after a certain delay
    // test all possible values for inp signal
    for (i = 0; i < 16; i = i + 1) begin
        inp = i;
        #10; 
    end
    
    // finish simulation
    $finish;
end


initial begin
    $dumpfile("sbox_dump.vcd");
    $dumpvars(1, tb_sbox);    
end

endmodule
