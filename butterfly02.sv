
`timescale 1ns/1ps

module butterfly02 (
    input logic               clk,
    input logic               rstn,
    input logic               valid_in,
    input logic signed [12:0] input_real_a[0:15],
    input logic signed [12:0] input_imag_a[0:15],
    input logic signed [12:0] input_real_b[0:15],
    input logic signed [12:0] input_imag_b[0:15],

    output logic              valid_out,
    output logic signed [22:0] output_real_add  [0:15],
    output logic signed [22:0] output_imag_add  [0:15],
    output logic signed [22:0] output_real_diff [0:15],
    output logic signed [22:0] output_imag_diff [0:15]
);

    // Internal signals
    logic signed [13:0] sum_real    [0:15], sum_imag    [0:15];
    logic signed [13:0] diff_real   [0:15], diff_imag   [0:15];

    logic signed [13:0] sum_real_reg[0:15], sum_imag_reg[0:15];
    logic signed [13:0] diff_real_reg[0:15], diff_imag_reg[0:15];

    logic signed [22:0] mult_add0 [0:15];
    logic signed [22:0] mult_add1 [0:15];
    logic signed [22:0] mult_diff0[0:15];
    logic signed [22:0] mult_diff1[0:15];

    logic [4:0] clk_cnt;

    // Twiddle outputs (from ROM) and 1clk-delayed versions
    logic [8:0] twf_re[0:15], twf_im[0:15];
    logic [8:0] twf_re_dly[0:15], twf_im_dly[0:15];

    // Twiddle ROM instance
    twf_0_rom ROM (
        .clk(clk),
        .rstn(rstn),
        .address(clk_cnt * 16),
        .twf_re(twf_re),
        .twf_im(twf_im)
    );

    // Delay Twiddle ROM outputs by 1 clk
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                twf_re_dly[i] <= 0;
                twf_im_dly[i] <= 0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                twf_re_dly[i] <= twf_re[i];
                twf_im_dly[i] <= twf_im[i];
            end
        end
    end

    // Twiddle multiplication units
    twiddle_mul MULT1 (
        .data_re_in (sum_real_reg),
        .data_im_in (sum_imag_reg),
        .twf_re_in  (twf_re_dly),
        .twf_im_in  (twf_im_dly),
        .data_re_out(mult_add0),
        .data_im_out(mult_add1)
    );

    twiddle_mul MULT2 (
        .data_re_in (diff_real_reg),
        .data_im_in (diff_imag_reg),
        .twf_re_in  (twf_re_dly),
        .twf_im_in  (twf_im_dly),
        .data_re_out(mult_diff0),
        .data_im_out(mult_diff1)
    );

    // Valid signal delay pipeline
    logic valid_in_dly, valid_in_dly2;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in_dly  <= 0;
            valid_in_dly2 <= 0;
        end else begin
            valid_in_dly  <= valid_in;
            valid_in_dly2 <= valid_in_dly;
        end
    end

    // clk_cnt for ROM address
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 0;
        else if (valid_in)
            clk_cnt <= clk_cnt + 1;
    end

    // Combinational butterfly add/sub
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            sum_real[i]  = input_real_a[i] + input_real_b[i];
            sum_imag[i]  = input_imag_a[i] + input_imag_b[i];
            diff_real[i] = input_real_a[i] - input_real_b[i];
            diff_imag[i] = input_imag_a[i] - input_imag_b[i];
        end
    end

    // Register butterfly results (1clk)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]   <= 0;
                sum_imag_reg[i]   <= 0;
                diff_real_reg[i]  <= 0;
                diff_imag_reg[i]  <= 0;
            end
        end else if (valid_in_dly) begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]   <= sum_real[i];
                sum_imag_reg[i]   <= sum_imag[i];
                diff_real_reg[i]  <= diff_real[i];
                diff_imag_reg[i]  <= diff_imag[i];
            end
        end
    end

    // Output stage: register multiplier outputs
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= 0;
                output_imag_add[i]  <= 0;
                output_real_diff[i] <= 0;
                output_imag_diff[i] <= 0;
            end
        end else if (valid_in_dly2) begin
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= mult_add0[i];
                output_imag_add[i]  <= mult_add1[i];
                output_real_diff[i] <= mult_diff0[i];
                output_imag_diff[i] <= mult_diff1[i];
            end
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

endmodule

