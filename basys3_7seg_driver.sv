// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3_7seg_driver (
    input              clk_1k_i,
    input              rst_ni,

    input  logic       digit0_en_i,
    input  logic [3:0] digit0_i,
    input  logic       digit1_en_i,
    input  logic [3:0] digit1_i,
    input  logic       digit2_en_i,
    input  logic [3:0] digit2_i,
    input  logic       digit3_en_i,
    input  logic [3:0] digit3_i,

    output logic [3:0] anode_o,
    output logic [6:0] segments_o
);

//4-bit ring counter
logic [3:0] ring_counter;
always_ff @(posedge clk_1k_i) begin
    if(!rst_ni) begin
        ring_counter <= 4'b1110;
    end
    else begin
        ring_counter <= {ring_counter[2:0], ring_counter[3]};
    end
end

logic [3:0] digit;
logic [3:0] anode_temp;
always_comb begin
    anode_temp = ring_counter;
    if(!digit0_en_i) begin
        anode_temp[0] = 1;
    end
    if(!digit1_en_i) begin
        anode_temp[1] = 1;
    end
    if(!digit2_en_i) begin
        anode_temp[2] = 1;
    end
    if(!digit3_en_i) begin
        anode_temp[3] = 1;
    end
    anode_o = anode_temp;
    case (ring_counter)
        4'b1110: digit = digit0_i;
        4'b1101: digit = digit1_i;
        4'b1011: digit = digit2_i;
        4'b0111: digit = digit3_i;
        default: digit = 4'b0000;
    endcase
end

logic [6:0] seg_temp;
hex7seg hex7seg (
    .d3(digit[3]),
    .d2(digit[2]),
    .d1(digit[1]),
    .d0(digit[0]),

    .A(seg_temp[0]),
    .B(seg_temp[1]),
    .C(seg_temp[2]),
    .D(seg_temp[3]),
    .E(seg_temp[4]),
    .F(seg_temp[5]),
    .G(seg_temp[6])
);

always_comb begin
    if(anode_o == 4'b1111) begin
        segments_o = 8'hFF;
    end
    else begin
        segments_o = ~seg_temp;
    end
end

endmodule
