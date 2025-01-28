module sbox (inp, outp);

input [3:0] inp;
output [3:0] outp;

reg [3:0] outp;

// implement the SBox design based on the truth table / boolean equations provided
// you can either use a high level concurrency construct or you can use continuous assignments

always @(*) begin
    case (inp)
        4'h0: outp = 4'hC; // 1100
        4'h1: outp = 4'h5; // 0101
        4'h2: outp = 4'h6; // 0110
        4'h3: outp = 4'hB; // 1011
        4'h4: outp = 4'h9; // 1001
        4'h5: outp = 4'h0; // 0000
        4'h6: outp = 4'hA; // 1010
        4'h7: outp = 4'hD; // 1101
        4'h8: outp = 4'h3; // 0011
        4'h9: outp = 4'hE; // 1110
        4'hA: outp = 4'hF; // 1111
        4'hB: outp = 4'h8; // 1000
        4'hC: outp = 4'h4; // 0100
        4'hD: outp = 4'h7; // 0111
        4'hE: outp = 4'h1; // 0001
        4'hF: outp = 4'h2; // 0010
        default: outp = 4'h0; 
    endcase
end

endmodule
