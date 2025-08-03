`timescale 1ns / 1ps

module butterfly12 (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    input logic signed [13:0] input_real[0:15],  //add
    input logic signed [13:0] input_imag[0:15],

    output logic valid_out,
    output logic signed [24:0] output_real[0:15],
    output logic signed [24:0] output_imag[0:15]
);

    logic signed [15:0] sum_r[0:7], sum_i[0:7];
    logic signed [15:0] diff_r[0:7], diff_i[0:7];


    logic signed [15:0] sum_r_reg[0:7], sum_i_reg[0:7];
    logic signed [15:0] diff_r_reg[0:7], diff_i_reg[0:7];




    logic signed [24:0] mult_add_r[0:7], mult_sub_r[0:7];
    logic signed [24:0] mult_add_i[0:7], mult_sub_i[0:7];

    logic valid_in_dly1, valid_in_dly;


    assign valid_out = valid_in_dly1;



    always_comb begin
        for (int i = 0; i < 8; i++) begin
            // 첫 번째 8-point butterfly
            sum_r[i]  = input_real[i] + input_real[i+8];
            sum_i[i]  = input_imag[i] + input_imag[i+8];
            diff_r[i] = input_real[i] - input_real[i+8];
            diff_i[i] = input_imag[i] - input_imag[i+8];

        end
    end


    logic signed [8:0] twf_re[0:7];
    logic signed [8:0] twf_im[0:7];

    logic [5:0] rom1_addr, rom2_addr;

    logic [1:0] clk_cnt;

    logic [8:0] twf_add_re[0:7], twf_add_im[0:7];
    logic [8:0] twf_sub_re[0:7], twf_sub_im[0:7];


    assign rom1_addr = clk_cnt * 16;
    assign rom2_addr = clk_cnt * 16 + 8;


    twf_1_rom ROM1 (
        .clk(clk),
        .rstn(rstn),
        .address(rom1_addr),
        .twf_re(twf_add_re),
        .twf_im(twf_add_im)
    );

    twf_1_rom ROM2 (
        .clk(clk),
        .rstn(rstn),
        .address(rom2_addr),
        .twf_re(twf_sub_re),
        .twf_im(twf_sub_im)
    );

    twiddle_mul #(
        .IN_DATA_W (16),
        .OUT_DATA_W(25),
        .DATA_SIZE (8)
    ) MULT1 (
        .data_re_in (sum_r_reg),
        .data_im_in (sum_i_reg),
        .twf_re_in  (twf_add_re),
        .twf_im_in  (twf_add_im),
        .data_re_out(mult_add_r),
        .data_im_out(mult_add_i)
    );


    twiddle_mul #(
        .IN_DATA_W (16),
        .OUT_DATA_W(25),
        .DATA_SIZE (8)
    ) MULT2 (
        .data_re_in (diff_r_reg),
        .data_im_in (diff_i_reg),
        .twf_re_in  (twf_sub_re),
        .twf_im_in  (twf_sub_im),
        .data_re_out(mult_sub_r),
        .data_im_out(mult_sub_i)
    );



    // PIPE Registered butterfly results (1clk)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in_dly  <= 0;
            valid_in_dly1 <= 0;

            for (int i = 0; i < 8; i++) begin
                sum_r_reg[i]  <= 0;
                sum_i_reg[i]  <= 0;
                diff_r_reg[i] <= 0;
                diff_i_reg[i] <= 0;

            end
        end else begin
            valid_in_dly  <= valid_in;
            valid_in_dly1 <= valid_in_dly;
            for (int i = 0; i < 8; i++) begin
                sum_r_reg[i]  <= sum_r[i];
                sum_i_reg[i]  <= sum_i[i];
                diff_r_reg[i] <= diff_r[i];
                diff_i_reg[i] <= diff_i[i];

            end
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            clk_cnt <= 0;
        end else if (valid_in) begin
            if (clk_cnt >= 3) begin
                clk_cnt <= 0;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end



    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                output_real[i] <= 0;
                output_imag[i] <= 0;
            end
        end else begin
            for (int i = 0; i < 8; i++) begin
                output_real[i] <= mult_add_r[i];
                output_imag[i] <= mult_add_i[i];
            end
            for (int i = 0; i < 8; i++) begin
                output_real[i+8] <= mult_sub_r[i];
                output_imag[i+8] <= mult_sub_i[i];
            end

        end
    end



endmodule


