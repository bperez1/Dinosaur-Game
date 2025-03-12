// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module hex7seg(
    input  logic d3,d2,d1,d0,
    output logic A,B,C,D,E,F,G
);

wire [0:0] zero_w;
wire [0:0] one_w;
wire [0:0] two_w;
wire [0:0] three_w;
wire [0:0] four_w;
wire [0:0] five_w;
wire [0:0] six_w;
wire [0:0] seven_w;
wire [0:0] eight_w;
wire [0:0] nine_w;
wire [0:0] a_w;
wire [0:0] b_w;
wire [0:0] c_w;
wire [0:0] d_w;
wire [0:0] e_w;
wire [0:0] f_w;


assign zero_w = (~d3 & ~d2 & ~d1 & ~d0)/*0*/;
assign one_w = (~d3 & ~d2 & ~d1 & d0)/*1*/;
assign two_w = (~d3 & ~d2 & d1 & ~d0)/*2*/;
assign three_w = (~d3 & ~d2 & d1 & d0)/*3*/;
assign four_w = (~d3 & d2 & ~d1 & ~d0)/*4*/;
assign five_w = (~d3 & d2 & ~d1 & d0)/*5*/;
assign six_w = (~d3 & d2 & d1 & ~d0)/*6*/;
assign seven_w = (~d3 & d2 & d1 & d0)/*7*/;
assign eight_w = (d3 & ~d2 & ~d1 & ~d0)/*8*/;
assign nine_w = (d3 & ~d2 & ~d1 & d0)/*9*/;
assign a_w = (d3 & ~d2 & d1 & ~d0)/*A*/;
assign b_w = (d3 & ~d2 & d1 & d0)/*B*/;
assign c_w = (d3 & d2 & ~d1 & ~d0)/*C*/;
assign d_w = (d3 & d2 & ~d1 & d0)/*D*/;
assign e_w = (d3 & d2 & d1 & ~d0)/*E*/;
assign f_w = (d3 & d2 & d1 & d0)/*F*/;

assign A = zero_w | two_w | three_w | five_w | six_w |
    seven_w | eight_w | nine_w | a_w | c_w | e_w | f_w;
assign B = zero_w | one_w | two_w | three_w | four_w |
    seven_w | eight_w | nine_w | a_w | d_w;
assign C = zero_w | one_w | three_w | four_w | five_w |
    six_w | seven_w | eight_w | nine_w | a_w | b_w | d_w;
assign D = zero_w | two_w | three_w | five_w | six_w |
    eight_w | nine_w | b_w | c_w | d_w | e_w;
assign E = zero_w | two_w | six_w | eight_w | a_w | b_w |
    c_w | d_w | e_w | f_w;
assign F = zero_w | four_w | five_w | six_w | eight_w |
    nine_w | a_w | b_w | c_w | e_w | f_w;
assign G = two_w | three_w | four_w | five_w | six_w |
    eight_w | nine_w | a_w | b_w | d_w | e_w |f_w;

endmodule
