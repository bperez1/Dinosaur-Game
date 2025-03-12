// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module dinorun import dinorun_pkg::*; (
    input  logic       clk_25_175_i,
    input  logic       rst_ni,

    input  logic       start_i,
    input  logic       up_i,
    input  logic       down_i,

    output logic       digit0_en_o,
    output logic [3:0] digit0_o,
    output logic       digit1_en_o,
    output logic [3:0] digit1_o,
    output logic       digit2_en_o,
    output logic [3:0] digit2_o,
    output logic       digit3_en_o,
    output logic [3:0] digit3_o,

    output logic [3:0] vga_red_o,
    output logic [3:0] vga_green_o,
    output logic [3:0] vga_blue_o,
    output logic       vga_hsync_o,
    output logic       vga_vsync_o
);

// for setting the color of the VGA within a flip flop
logic [3:0] vga_r;
logic [3:0] vga_g;
logic [3:0] vga_b;

logic next_frame_toggle;

logic h_sync; // output
logic v_sync; // output
logic visible; // output
logic [9:0] position_x; // output
logic [9:0] position_y; //output
vga_timer timer_inst(
    .hsync_o(h_sync), // output
    .vsync_o(v_sync),.visible_o(visible), // outputs
    .position_x_o(position_x), // output
    .position_y_o(position_y), // output
    .clk_i(clk_25_175_i),.rst_ni // inputs
    );

logic [15:0] lfsr16_rand; // output
lfsr16 lfsr16_inst(
    .clk_i(clk_25_175_i), // input
    .rst_ni(rst_ni), // input
    .next_i(next_frame), // input
    .rand_o(lfsr16_rand) // output
);

logic next_frame; // output
edge_detector edge_inst(
    .clk_i(clk_25_175_i), // input
    .data_i(v_sync), // input
    .edge_o(next_frame) // output
);

logic score_en; // input
logic score_rst_toggle_n; // input
logic [3:0] temp_digit0;
logic [3:0] temp_digit1;
logic [3:0] temp_digit2;
logic [3:0] temp_digit3;
score_counter score_inst(
    .clk_i(clk_25_175_i), // inputs
    .rst_ni(~(~rst_ni || ~score_rst_toggle_n)), .en_i(score_en & next_frame), // inputs
    .digit0_o(temp_digit0), // outputs
    .digit1_o(temp_digit1),
    .digit2_o(temp_digit2),
    .digit3_o(temp_digit3)
);

logic title_pixel; // output
title title_inst(
    .pixel_x_i(position_x), // inputs
    .pixel_y_i(position_y),
    .pixel_o(title_pixel) // output
);

logic dino_pixel; // output
logic dino_up; // input
logic dino_down; // input
dino dino_inst(
    .clk_i(clk_25_175_i), .rst_ni, // inputs
    .next_frame_i(next_frame),
    .up_i(dino_up),
    .down_i(dino_down),
    .hit_i(state_q == COLLISION),
    .pixel_x_i(position_x),
    .pixel_y_i(position_y),
    .pixel_o(dino_pixel) // output
);

logic obstacle_rst_n;

logic cactus_pixel_1; // output
logic cactus_spawn_1; // input
logic [1:0] cactus_rand_1; // input
cactus cactus_inst_1(
    .clk_i(clk_25_175_i), .rst_ni(~(~rst_ni || ~obstacle_rst_n)), // input
    .next_frame_i(next_frame && next_frame_toggle), // input
    .spawn_i(cactus_spawn_1), // input
    .rand_i(cactus_rand_1), // input
    .pixel_x_i(position_x), // input
    .pixel_y_i(position_y), // input
    .pixel_o(cactus_pixel_1) // output
);

logic cactus_pixel_2; // output
logic cactus_spawn_2; // input
logic [1:0] cactus_rand_2; // input
cactus cactus_inst_2(
    .clk_i(clk_25_175_i), .rst_ni(~(~rst_ni || ~obstacle_rst_n)), // input
    .next_frame_i(next_frame && next_frame_toggle), // input
    .spawn_i(cactus_spawn_2), // input
    .rand_i(cactus_rand_2), // input
    .pixel_x_i(position_x), // input
    .pixel_y_i(position_y), // input
    .pixel_o(cactus_pixel_2) // output
);

logic bird_pixel; // output
logic bird_spawn; // input
logic [1:0] bird_rand; // input
bird bird_inst(
    .clk_i(clk_25_175_i), .rst_ni(~(~rst_ni || ~obstacle_rst_n)), // input
    .next_frame_i(next_frame && next_frame_toggle), // input
    .spawn_i(bird_spawn), // input
    .rand_i(bird_rand), // input
    .pixel_x_i(position_x), // input
    .pixel_y_i(position_y), // input
    .pixel_o(bird_pixel) // output
);

logic ground_pixel;
assign ground_pixel = ((position_y < 480) && (position_y > 399));

// State machine
state_t state_d, state_q;
always_ff @(posedge clk_25_175_i) begin
    if (!rst_ni) begin
        state_q <= STARTING;
    end else begin
        state_q <= state_d;
    end
end

logic [3:0] digit0_comb;
logic [3:0] digit1_comb;
logic [3:0] digit2_comb;
logic [3:0] digit3_comb;
always_comb begin
    // defaults
    state_d = state_q;
    digit0_en_o = 1'b1; // default enable all digits
    digit1_en_o = 1'b1;
    digit2_en_o = 1'b1;
    digit3_en_o = 1'b1;

    digit0_comb = temp_digit0;
    digit1_comb = temp_digit1;
    digit2_comb = temp_digit2;
    digit3_comb = temp_digit3;

    score_en = 1'b0; // default not incrementing score

    dino_up = 1'b0; // default not jumping
    dino_down = 1'b0; // default not ducking

    cactus_spawn_1 = 1'b0; // default cactus not spawning
    cactus_spawn_2 = 1'b0; // default cactus not spawning
    bird_spawn = 1'b0; // default bird not spawning

    obstacle_rst_n = 1'b1; // default not reseting obstacles
    score_rst_toggle_n = 1'b1; // default not resetting score

    // Default vga signals to off
    vga_r = 4'h0;
    vga_g = 4'h0;
    vga_b = 4'h0;

    next_frame_toggle = 1'b1;

    cactus_rand_1 = lfsr16_rand[1:0];
    cactus_rand_2 = lfsr16_rand[3:2];
    bird_rand = lfsr16_rand[5:4];

    unique case (state_q)
        STARTING: begin
            score_rst_toggle_n = 1'b0; // reset score
            obstacle_rst_n = 1'b0; // reset obstacles

            digit0_comb = 4'b0000;
            digit1_comb = 4'b0000;
            digit2_comb = 4'b0000;
            digit3_comb = 4'b0000;

            // pixel color logic
            if(visible) begin
                if(title_pixel) begin // title is dark blue
                    vga_r = 4'h3; // 46 / 16
                    vga_g = 4'h2; // 33 / 16
                    vga_b = 4'h5; // 87 / 16
                end
                else if (dino_pixel) begin // dino is cyan
                    vga_r = 4'h0; // 45 / 16
                    vga_g = 4'hE; // 226 / 16
                    vga_b = 4'hE; // 230 / 16
                end
                else if (cactus_pixel_1) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (cactus_pixel_2) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (bird_pixel) begin // bird is lighter purpler
                    vga_r = 4'h9; // 146 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h7; // 117 / 16
                end
                else if (ground_pixel) begin // ground is dark blue
                    vga_r = 4'h0; // 0 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h9; // 139/ 16
                end
                else begin // if not title or object then set to black
                    vga_r = 4'h0;
                    vga_g = 4'h0;
                    vga_b = 4'h0;
                end
            end
            else begin
                vga_r = 4'h0;
                vga_g = 4'h0;
                vga_b = 4'h0;
            end

            if (start_i) begin // if start button is pressed go to RUNNING
                state_d = RUNNING;
            end
        end
        RUNNING: begin
            score_en = 1'b1; // enable score counter

            // pixel color logic
            if(visible) begin
                // title is disabled
                if (dino_pixel) begin // dino is cyan
                    vga_r = 4'h0; // 45 / 16
                    vga_g = 4'hE; // 226 / 16
                    vga_b = 4'hE; // 230 / 16
                end
                else if (cactus_pixel_1) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (cactus_pixel_2) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (bird_pixel) begin // bird is lighter purple
                    vga_r = 4'h9; // 146 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h7; // 117 / 16
                end
                else if (ground_pixel) begin // ground is dark blue
                    vga_r = 4'h0; // 0 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h9; // 139/ 16
                end
                else begin // if not object then set to black
                    vga_r = 4'h0;
                    vga_g = 4'h0;
                    vga_b = 4'h0;
                end
            end
            else begin
                vga_r = 4'h0;
                vga_g = 4'h0;
                vga_b = 4'h0;
            end

            if (up_i) begin
                dino_up = 1'b1; // set jump signal
            end
            else if (down_i) begin
                dino_down = 1'b1; // set duck signal
            end

            // Randomly spawn obstacles based on LFSR output
            if (lfsr16_rand[12:8] == 5'b00000) begin
                cactus_spawn_1 = 1'b1;
            end
            if (lfsr16_rand[12:8] == 5'b00001) begin
                cactus_spawn_2 = 1'b1;
            end
            if (lfsr16_rand[12:7] == 6'b101010) begin
                bird_spawn = 1'b1;
            end

            // if dino is hit then go to COLLISION and set hit signal
            if (dino_pixel && (cactus_pixel_1 || cactus_pixel_2 || bird_pixel)) begin
                state_d = COLLISION;
            end
        end
        COLLISION: begin
            next_frame_toggle = 1'b0;
            // pixel color logic
            if(visible) begin
                // title is disabled
                if (dino_pixel) begin // dino is cyan
                    vga_r = 4'h0; // 45 / 16
                    vga_g = 4'hE; // 226 / 16
                    vga_b = 4'hE; // 230 / 16
                end
                else if (cactus_pixel_1) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (cactus_pixel_2) begin // cactus is dark purple
                    vga_r = 4'h5; // 84 / 16
                    vga_g = 4'h1; // 13 / 16
                    vga_b = 4'hD; // 110 / 16
                end
                else if (bird_pixel) begin // bird is lighter purple
                    vga_r = 4'h9; // 146 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h7; // 117 / 16
                end
                else if (ground_pixel) begin // ground is dark blue
                    vga_r = 4'h0; // 0 / 16
                    vga_g = 4'h0; // 0 / 16
                    vga_b = 4'h9; // 139/ 16
                end
                else begin // if not object then set to black
                    vga_r = 4'h0;
                    vga_g = 4'h0;
                    vga_b = 4'h0;
                end
            end
            else begin
                vga_r = 4'h0;
                vga_g = 4'h0;
                vga_b = 4'h0;
            end

            if(start_i) begin
                state_d = STARTING;
            end
        end
        default: begin
            state_d = STARTING;
        end
    endcase
end

always_comb begin
    digit0_o = digit0_comb;
    digit1_o = digit1_comb;
    digit2_o = digit2_comb;
    digit3_o = digit3_comb;
end

always_ff @(posedge clk_25_175_i) begin
    if (~rst_ni) begin
        vga_hsync_o <= 1'b0;
        vga_vsync_o <= 1'b0;

        vga_red_o <= 4'h0;
        vga_green_o <= 4'h0;
        vga_blue_o <= 4'h0;
    end
    else begin
        vga_hsync_o <= h_sync;
        vga_vsync_o <= v_sync;

        vga_red_o <= vga_r;
        vga_green_o <= vga_g;
        vga_blue_o <= vga_b;
    end
end

endmodule
