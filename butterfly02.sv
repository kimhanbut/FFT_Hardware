
`timescale 1ns / 1ps

module butterfly02 (
    input logic               clk,
    input logic               rstn,
    input logic               valid_in,
    input logic signed [12:0] input_real_a[0:15],
    input logic signed [12:0] input_imag_a[0:15],
    input logic signed [12:0] input_real_b[0:15],
    input logic signed [12:0] input_imag_b[0:15],

    output logic               valid_out,
    output logic signed [22:0] output_real_add [0:15],
    output logic signed [22:0] output_imag_add [0:15],
    output logic signed [22:0] output_real_diff[0:15],
    output logic signed [22:0] output_imag_diff[0:15]
);

    // Internal signals
    logic signed [13:0] sum_real[0:15], sum_imag[0:15];
    logic signed [13:0] diff_real[0:15], diff_imag[0:15];

    logic signed [13:0] sum_real_reg[0:15], sum_imag_reg[0:15];
    logic signed [13:0] diff_real_reg[0:15], diff_imag_reg[0:15];

    logic signed [13:0] sum_real_reg1[0:15], sum_imag_reg1[0:15];
    logic signed [13:0] diff_real_reg1[0:15], diff_imag_reg1[0:15];


    logic signed [22:0] mult_add0 [0:15];
    logic signed [22:0] mult_add1 [0:15];
    logic signed [22:0] mult_diff0[0:15];
    logic signed [22:0] mult_diff1[0:15];

    logic [4:0] clk_cnt, clk_cnt_delay;
    logic valid_in_dly, valid_in_dly2;




    // Twiddle outputs (from ROM) and 1clk-delayed versions
    logic [8:0] twf_add_re[0:15], twf_add_im[0:15];
    logic [8:0] twf_sub_re[0:15], twf_sub_im[0:15];

    logic [8:0] rom1_addr, rom2_addr;


    // Twiddle ROM instance
    twf_0_rom ROM_1 (
        .clk(clk),
        .rstn(rstn),
        .address(rom1_addr),
        .twf_re(twf_add_re),
        .twf_im(twf_add_im)
    );

    // Twiddle ROM instance
    twf_0_rom ROM_2 (
        .clk(clk),
        .rstn(rstn),
        .address(rom2_addr),
        .twf_re(twf_sub_re),
        .twf_im(twf_sub_im)
    );


    twiddle_address_generator ROM_ADDR (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in_dly),
        .rom1_addr(rom1_addr),
        .rom2_addr(rom2_addr)
    );


    // Twiddle multiplication units
    twiddle_mul MULT1 (
        .data_re_in (sum_real_reg1),
        .data_im_in (sum_imag_reg1),
        .twf_re_in  (twf_add_re),
        .twf_im_in  (twf_add_im),
        .data_re_out(mult_add0),
        .data_im_out(mult_add1)
    );

    twiddle_mul MULT2 (
        .data_re_in (diff_real_reg1),
        .data_im_in (diff_imag_reg1),
        .twf_re_in  (twf_sub_re),
        .twf_im_in  (twf_sub_im),
        .data_re_out(mult_diff0),
        .data_im_out(mult_diff1)
    );



    always_ff @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                valid_in_dly  <= 0;
                valid_in_dly2 <= 0;
            end else begin
                valid_in_dly  <= valid_in;
                valid_in_dly2 <= valid_in_dly;
            end
    end



    // Combinational butterfly add/sub
    always_comb begin
        if (valid_in) begin
            for (int i = 0; i < 16; i++) begin
                sum_real[i]  = input_real_a[i] + input_real_b[i];
                sum_imag[i]  = input_imag_a[i] + input_imag_b[i];
                diff_real[i] = input_real_a[i] - input_real_b[i];
                diff_imag[i] = input_imag_a[i] - input_imag_b[i];
            end
        end
    end


    // Register butterfly results (1clk)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]  <= 0;
                sum_imag_reg[i]  <= 0;
                diff_real_reg[i] <= 0;
                diff_imag_reg[i] <= 0;
                sum_real_reg1[i]  <= 0;
                sum_imag_reg1[i]  <= 0;
                diff_real_reg1[i] <= 0;
                diff_imag_reg1[i] <= 0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]  <= sum_real[i];
                sum_imag_reg[i]  <= sum_imag[i];
                diff_real_reg[i] <= diff_real[i];
                diff_imag_reg[i] <= diff_imag[i];
                sum_real_reg1[i]  <= sum_real_reg[i];
                sum_imag_reg1[i]  <= sum_imag_reg[i];
                diff_real_reg1[i] <= diff_real_reg[i];
                diff_imag_reg1[i] <= diff_imag_reg[i];

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




module twiddle_address_generator (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    output logic [8:0] rom1_addr,
    output logic [8:0] rom2_addr
);

    logic [8:0] rom1_add, rom2_add;

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
            rom2_add <= 64;
        end else if (valid_in) begin
            rom1_add <= rom1_add + 16;
            rom2_add <= rom2_add + 16;
        end else if ((valid_prev & !valid_in) & (valid_in == 0)) begin
            rom1_add <= rom1_add + 64;
            rom2_add <= rom2_add + 64;
        end
    end

    assign rom1_addr = rom1_add;
    assign rom2_addr = rom2_add;


endmodule
