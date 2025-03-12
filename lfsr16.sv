// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module lfsr16 (
    input  logic       clk_i,
    input  logic       rst_ni,

    input  logic       next_i,
    output logic [15:0] rand_o
);

logic [15:0] rand_temp;
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        rand_temp <= 16'd1;
    end else if (next_i) begin
        rand_temp[15] <= rand_temp[14];
        rand_temp[14] <= rand_temp[13];
        rand_temp[13] <= rand_temp[12];
        rand_temp[12] <= rand_temp[11];
        rand_temp[11] <= rand_temp[10];
        rand_temp[10] <= rand_temp[9];
        rand_temp[9] <= rand_temp[8];
        rand_temp[8] <= rand_temp[7];
        rand_temp[7] <= rand_temp[6];
        rand_temp[6] <= rand_temp[5];
        rand_temp[5] <= rand_temp[4];
        rand_temp[4] <= rand_temp[3];
        rand_temp[3] <= rand_temp[2];
        rand_temp[2] <= rand_temp[1];
        rand_temp[1] <= rand_temp[0];
        rand_temp[0] <= rand_temp[3]^rand_temp[12]^rand_temp[14]^rand_temp[15];
    end
end

assign rand_o = rand_temp[15:0];

endmodule
