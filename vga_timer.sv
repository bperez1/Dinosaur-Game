// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

// https://vesa.org/vesa-standards/
// http://tinyvga.com/vga-timing
module vga_timer (
    // TODO
    // possible ports list:
    input  logic       clk_i,
    input  logic       rst_ni,
    output logic       hsync_o,
    output logic       vsync_o,
    output logic       visible_o,
    output logic [9:0] position_x_o,
    output logic [9:0] position_y_o
);

localparam int h_display = 639;
localparam int h_frontP = 656-639; // 17
localparam int h_syncP = 751-656; // 95
localparam int h_backP = 799-751; // 48
// lower bound of where h should be low (656)
localparam int h_low1 = h_display + h_frontP;
// upper bound of where h should be low (751)
localparam int h_low2 = h_display + h_frontP + h_syncP;
localparam int h_total = h_display + h_frontP
+ h_syncP + h_backP; // (799)
// range of horizontal count: 0 to 799 = 800

localparam int v_display = 479;
localparam int v_frontP = 490-479; // 11
localparam int v_syncP = 491-490; // 1
localparam int v_backP = 524-491; // 33
// lower bound of where v should be low (490)
localparam int v_low1 = v_display + v_frontP;
// upper bound of where v should be low (491)
localparam int v_low2 = v_display + v_frontP + v_syncP;
localparam int v_total = v_display + v_frontP
+ v_syncP + v_backP; // (524)
// range of vertical count: 0 to 524 = 525


// TODO
logic [9:0] h_counter = 0;
logic [9:0] v_counter = 0;

// h_counter, counts up to total then reset
always_ff @(posedge clk_i) begin
    // if reset signal is low, reset h_count
    if(!rst_ni)
        h_counter <= 0;
    // if h_count = 799
    else if(h_counter == h_total)
    // reset h_count if end of line (799)
        h_counter <= 0;
    else
    // if not at end of line, increment
        h_counter <= h_counter + 1;
end

// v_counter, counts up to total then reset
always_ff @(posedge clk_i) begin
    // if reset signal is low, reset v_count
    if(!rst_ni)
        v_counter <= 0;
    // if h_count = 799
    else if(h_counter == h_total) begin
    // reset v_count if end of frame (524)
        if(v_counter == v_total)
            v_counter <= 0;
        else
        // if not at end of frame, increment
            v_counter <= v_counter + 1;
    end
end

// h_sync and v_sync signals
// sets h_sync to low when in sync pulse
// h_count < 656 or h_count > 751 (not inclusive)
// set high if not inbetween the sync pulse range
assign hsync_o = (h_counter < h_low1) || (h_counter > h_low2);
// sets v_sync to low when in sync pulse
// h_count < 490 or h_count > 491 (not inclusive)
// set high if not inbetween the sync pulse range
assign vsync_o = (v_counter < v_low1) || (v_counter > v_low2);

// visible signal when both counters are in display area
// h_count < 639 (inclusive)
// v_count < 479 (inclusive)
assign visible_o = (h_counter <= h_display)
&& (v_counter <= v_display);

// current pixel position
assign position_x_o = h_counter; // convert to 9 bits
assign position_y_o = v_counter; // convert to 8 bits

endmodule
