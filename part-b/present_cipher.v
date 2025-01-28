
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
  

// generate the next round key from the current key update state
   assign rkey = kstate_in[79:16]; //initial round key

// perform the key update operation
   assign kstate_out = kstate_in;
   
// use the concatenation operator for the 1st step 
//left shift by 61 bits
  assign kstate_out = {kstate_out[18:0], kstate_out[79:19]};
  
// for 2nd step, perform sbox operation on 79 to 76 bits of key state
  sbox sbox_inst (.inp(kstate_out[79:76]), .outp(kstate_out[79:76]));

// NOTE: for the 3rd step in key update, xor the 19 to 15 bits with (round_counter + 1), instead of round_counter     
   assign kstate_out[19:15] = kstate_out[19:15]^ (round_counter + 1); //xor round constant to first 4 bits
   // assign rkey = kstate_out[79:16];   

endmodule

// =========================================================

// datapath module for bit-permutation
// NOTE: DO NOT make any change to the interface signals.
module perm (state_in, state_out);

input [63:0] state_in;          // input state
output [63:0] state_out;        // output state

// ===== DO NOT MODIFY ANYTHING ABOVE THIS =====

// declare any necessary wires/reg
   assign state_out = {
        state_in[0], state_in[16], state_in[32], state_in[48], state_in[1], state_in[17], state_in[33], state_in[49],
        state_in[2], state_in[18], state_in[34], state_in[50], state_in[3], state_in[19], state_in[35], state_in[51],
        state_in[4], state_in[20], state_in[36], state_in[52], state_in[5], state_in[21], state_in[37], state_in[53],
        state_in[6], state_in[22], state_in[38], state_in[54], state_in[7], state_in[23], state_in[39], state_in[55],
        state_in[8], state_in[24], state_in[40], state_in[56], state_in[9], state_in[25], state_in[41], state_in[57],
        state_in[10], state_in[26], state_in[42], state_in[58], state_in[11], state_in[27], state_in[43], state_in[59],
        state_in[12], state_in[28], state_in[44], state_in[60], state_in[13], state_in[29], state_in[45], state_in[61],
        state_in[14], state_in[30], state_in[46], state_in[62], state_in[15], state_in[31], state_in[47], state_in[63]
    };


// perform the bit-permutation operation by either using high level constructs for concurrency or continuous assignments


endmodule

// =========================================================
