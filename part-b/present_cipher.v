
// =========================================================

// PRESENT - a lightweight block cipher design
// NOTE: DO NOT modify the present_cipher module.
//       Make changes only to the present_datapath, present_keyschedule and perm modules.

// =========================================================

module present_cipher (clk, rst, plaintext, key, en, prdy, krdy, start, done, ciphertext);

input clk, rst;
input [63:0] plaintext;         // 64-bit plaintext
input [79:0] key;               // 80-bit encryption key
input en;                       // enable signal for controller
input prdy, krdy;               // plaintext and key ready or available
output start, done;             // control signals
output [63:0] ciphertext;       // 64-bit ciphertext

reg [63:0] ciphertext;
reg start, done;

// controller signals
reg [4:0] round_counter;        // counter for encryption round
reg [63:0] pstate;              // plaintext state reg
reg [79:0] kstate;              // round key state reg

// datapath signals
wire [63:0] pstate_nxt;         // next state for plaintext
wire [79:0] kstate_nxt;         // next state for key update
wire [63:0] nxt_rkey;           // next round key

// detect final round one cycle early
wire final_round = (round_counter == 30);

// instantiating the present_datapath module
present_datapath dpath ( .pstate_in(pstate), .kstate_in(kstate), .round_counter(round_counter), .pstate_out(pstate_nxt), .kstate_out(kstate_nxt), .rkey(nxt_rkey) );

// controller design
always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
        // initialize the signals
        pstate <= 64'h0000000000000000;
        kstate <= 80'h00000000000000000000;
        ciphertext <= 64'h0000000000000000;
        round_counter <= 5'b00000;
        start <= 0;
        done <= 0;
    end
    else if (en) begin
        if (!start) begin
            // proceed only if plaintext and key ready signals are high
            if (krdy && prdy) begin
                kstate <= key;
                pstate <= plaintext;
                done <= 0;
                start <= 1;
            end
        end
        else if (start) begin
            // check for round 30 instead of 31
            if (final_round) begin
                // on the next cycle, round_counter will be 31
                round_counter <= round_counter + 1;
                pstate <= pstate_nxt;
                kstate <= kstate_nxt;
            end
            else if (round_counter == 31) begin
                // this will execute one cycle after final_round == 1
                kstate <= key;
                round_counter <= 5'b00000;  // reset counter for next encryption
                ciphertext <= pstate ^ nxt_rkey;
                start <= 0;
                done <= 1;
            end
            else begin
                // update the round counter and next states for plaintext and key update
                round_counter <= round_counter + 1;
                pstate <= pstate_nxt;
                kstate <= kstate_nxt;
            end
        end
    end
end

endmodule

// =========================================================

// datapath module for PRESENT cipher
// NOTE: DO NOT make any change to the interface signals.
module present_datapath (pstate_in, kstate_in, round_counter, pstate_out, kstate_out, rkey);

input [63:0] pstate_in;         // plaintext state input
input [79:0] kstate_in;         // key update state input
input [4:0] round_counter;      // counter for encryption round
output [63:0] pstate_out;       // next state for plaintext
output [79:0] kstate_out;       // next state for key update
output [63:0] rkey;             // next round key

// ===== DO NOT MODIFY ANYTHING ABOVE THIS =====

// declare any necessary wires/reg
wire [63:0] sbox_inp, sbox_out, perm_out;

// instantiate your present_keyschedule module to change the next state of key update and next round key
present_keyschedule keysched (
    .kstate_in(kstate_in),
    .round_counter(round_counter),
    .kstate_out(kstate_out),
    .rkey(rkey)
);

// add round key to the plaintext state input
assign sbox_inp = pstate_in ^ rkey;

// perform sbox operation, instantiate the sbox module
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin
        sbox sbox_inst (
            .inp(sbox_inp[(i+1)*4-1:i*4]),
            .outp(sbox_out[(i+1)*4-1:i*4])
        );
    end
endgenerate

// perform bit-permutation operation, instantiate the bit-permutation module
perm perm_inst (
    .state_in(sbox_out),
    .state_out(perm_out)
);

assign pstate_out = perm_out;

endmodule

// =========================================================

// datapath module for key schedule
// NOTE: DO NOT make any change to the interface signals.
module present_keyschedule ( kstate_in, round_counter, kstate_out, rkey);

input [79:0] kstate_in;             // key update state input
input [4:0] round_counter;          // counter for encryption round
output [79:0] kstate_out;           // next state for key update
output [63:0] rkey;                 // next round key

// ===== DO NOT MODIFY ANYTHING ABOVE THIS =====

// declare any necessary wires/reg
wire [79:0] kstate_temp;

// generate the next round key from the current key update state
assign rkey = kstate_in[79:16]; //initial round key

// perform the key update operation   
// use the concatenation operator for the 1st step 
//left shift by 61 bits
assign kstate_temp = {kstate_in[18:0], kstate_in[79:19]};
  
// for 2nd step, perform sbox operation on 79 to 76 bits of key state
sbox sbox_inst (.inp(kstate_temp[79:76]), .outp(kstate_out[79:76]));

// NOTE: for the 3rd step in key update, xor the 19 to 15 bits with (round_counter + 1), instead of round_counter     
assign kstate_out[14:0] = kstate_temp[14:0];
assign kstate_out[19:15] = kstate_temp[19:15] ^ (round_counter + 1);
assign kstate_out[75:20] = kstate_temp[75:20]; 

endmodule

// =========================================================

// datapath module for bit-permutation
// NOTE: DO NOT make any change to the interface signals.
module perm (state_in, state_out);

input [63:0] state_in;          // input state
output [63:0] state_out;        // output state

// ===== DO NOT MODIFY ANYTHING ABOVE THIS =====

// declare any necessary wires/reg

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin 
        assign state_out[i] = state_in[((i % 16) * 4) + (i / 16)];
    end
endgenerate


// perform the bit-permutation operation by either using high level constructs for concurrency or continuous assignments


endmodule

// =========================================================
