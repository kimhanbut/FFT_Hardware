`timescale 1ns / 1ps

module butterfly12 (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    input logic signed [14:0] input_real_a[0:15], //add
    input logic signed [14:0] input_imag_a[0:15],
    input logic signed [14:0] input_real_b[0:15], //sub
    input logic signed [14:0] input_imag_b[0:15],

    output logic valid_out,
    output logic signed [24:0] output_real_add [0:15],
    output logic signed [24:0] output_imag_add [0:15],
    output logic signed [24:0] output_real_diff[0:15],
    output logic signed [24:0] output_imag_diff[0:15]
);

    logic signed [15:0] sum_r0 [0:7], sum_i0 [0:7];
    logic signed [15:0] diff_r0[0:7], diff_i0[0:7];

    logic signed [15:0] sum_r1 [0:7], sum_i1 [0:7];
    logic signed [15:0] diff_r1[0:7], diff_i1[0:7];

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            // 첫 번째 8-point butterfly
            sum_r0[i]  = input_real_a[i] + input_real_b[i];
            sum_i0[i]  = input_imag_a[i] + input_imag_b[i];
            diff_r0[i] = input_real_a[i] - input_real_b[i];
            diff_i0[i] = input_imag_a[i] - input_imag_b[i];

            // 두 번째 8-point butterfly
            sum_r1[i]  = input_real_a[i+8] + input_real_b[i+8];
            sum_i1[i]  = input_imag_a[i+8] + input_imag_b[i+8];
            diff_r1[i] = input_real_a[i+8] - input_real_b[i+8];
            diff_i1[i] = input_imag_a[i+8] - input_imag_b[i+8];
        end
    end

    logic signed [8:0] twf_re[0:7];
    logic signed [8:0] twf_im[0:7];

    logic [5:0] rom1_addr, rom2_addr;

    logic [5:0] twf_add_re[0:15], twf_add_im[0:15];
    logic [5:0] twf_sub_re[0:15], twf_sub_im[0:15];

    twf_1_rom twf_1_rom (
        .clk(clk),
        .rstn(rstn),
        .address(rom1_addr),
        .twf_re(twf_add_re),
        .twf_im(twf_add_im)
    ); 

    twf_1_rom twf_2_rom (
        .clk(clk),
        .rstn(rstn),
        .address(rom2_addr),
        .twf_re(twf_sub_re),
        .twf_im(twf_sub_im)
    ); 

    twiddle_address_generator ROM_ADDR(
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .rom1_addr(rom1_addr),
        .rom2_addr(rom2_addr)
    );
    
endmodule













module twiddle_address_generator (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    output logic [5:0] rom1_addr,
    output logic [5:0] rom2_addr
);

    logic [5:0] rom1_add, rom2_add;

    logic [1:0] clk_cnt;  // 0, 1, 2, 3 클럭 카운터
    logic       valid_prev;  // 이전 valid_in


    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            valid_prev <= 0;
        end else begin
            valid_prev <= valid_in;
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            rom1_add <= 0;
            rom2_add <= 8;
        end else if (valid_in) begin
            rom1_add <= rom1_add + 2;
            rom2_add <= rom2_add + 2;
        end else if ((valid_prev & !valid_in) & (valid_in == 0))begin
            rom1_add <= rom1_add + 8;
            rom2_add <= rom2_add + 8;    
        end
    end

assign rom1_addr = rom1_add;
assign rom2_addr = rom2_add;


endmodule