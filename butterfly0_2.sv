`timescale 1ns/1ps

module butterfly02 (
    input logic               clk,
    input logic               rstn,
    input logic               valid_in,
    input logic signed [12:0] input_real_a[0:15],  // 입력 A의 실수부
    input logic signed [12:0] input_imag_a[0:15],  // 입력 A의 허수부
    input logic signed [12:0] input_real_b[0:15],  // 입력 B의 실수부
    input logic signed [12:0] input_imag_b[0:15],  // 입력 B의 허수부

    output logic valid_out,  // 출력 유효 신호
    output logic signed [22:0] output_real_add  [0:15], // (A + B) × Twiddle 결과 (실수부)
    output logic signed [22:0] output_imag_add  [0:15], // (A + B) × Twiddle 결과 (허수부)
    output logic signed [22:0] output_real_diff [0:15], // (A - B) × Twiddle 결과 (실수부)
    output logic signed [22:0] output_imag_diff [0:15]  // (A - B) × Twiddle 결과 (허수부)
);




    // 중간 연산용 신호 선언
    logic signed [13:0] sum_real[0:15], sum_imag[0:15];
    logic signed [13:0] diff_real[0:15], diff_imag[0:15];

    logic signed [22:0] mult_add0[0:15];
    logic signed [22:0] mult_add1[0:15];
    logic signed [22:0] mult_diff0[0:15];
    logic signed [22:0] mult_diff1[0:15];


    logic [4:0] clk_cnt;
    logic [8:0] twf_re[0:15], twf_im[0:15];






    twiddle_mul MULT1 (
        .data_re_in (sum_real),
        .data_im_in (sum_imag),
        .twf_re_in  (twf_re),
        .twf_im_in  (twf_im),
        .data_re_out(mult_add0),
        .data_im_out(mult_add1)
    );

    twiddle_mul MULT2 (
        .data_re_in (diff_real),
        .data_im_in (diff_imag),
        .twf_re_in  (twf_re),
        .twf_im_in  (twf_im),
        .data_re_out(mult_diff0),
        .data_im_out(mult_diff1)
    );



    twf_0_rom ROM (
        .clk(clk),
        .rstn(rstn),
        .address(clk_cnt * 16),
        .twf_re(twf_re),
        .twf_im(twf_im)
    );


    logic valid_in_dly;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) valid_in_dly <= 0;
        else valid_in_dly <= valid_in;
    end


    // valid_in 기준으로 clk_cnt 증가
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            clk_cnt <= 0;
        end else if (valid_in) begin
            clk_cnt <= clk_cnt + 1;
        end
    end


    // 조합 논리: 버터플라이 + Twiddle 곱셈
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            // (A + B), (A - B)
            sum_real[i]  = input_real_a[i] + input_real_b[i];
            sum_imag[i]  = input_imag_a[i] + input_imag_b[i];
            diff_real[i] = input_real_a[i] - input_real_b[i];
            diff_imag[i] = input_imag_a[i] - input_imag_b[i];

        end
    end

    // 순차 논리: 출력 레지스터 및 tw_cnt 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= 0;
                output_imag_add[i]  <= 0;
                output_real_diff[i] <= 0;
                output_imag_diff[i] <= 0;
            end
        end else begin
            // valid_in 유효할 때 결과 출력
            if (valid_in_dly) begin
                for (int i = 0; i < 16; i++) begin
                    output_real_add[i]  <= mult_add0[i];
                    output_imag_add[i]  <= mult_add1[i];
                    output_real_diff[i] <= mult_diff0[i];
                    output_imag_diff[i] <= mult_diff1[i];
                end
            end
            valid_out <= valid_in_dly;
        end
    end






endmodule
