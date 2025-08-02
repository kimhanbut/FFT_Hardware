`timescale 1ns / 1ps

module butterfly22 (
    input  logic             clk,
    input  logic             rstn,
    input  logic             valid_in,
    input  logic signed [15:0] input_real[0:15], 
    input  logic signed [15:0] input_imag[0:15],
    input  logic signed [4:0]  index_1_re,
    input  logic signed [4:0]  index_1_im,
    input  logic signed [4:0]  index_2_re,
    input  logic signed [4:0]  index_2_im,

    output logic             valid_out,
    output logic signed [12:0] output_real [0:15],
    output logic signed [12:0] output_imag [0:15]
);

    // 내부 신호 선언 (reg로)
    logic signed [5:0] index_sum_re;
    logic signed [5:0] index_sum_im;

    logic signed [16:0] sum_r [0:7], sum_i [0:7];
    logic signed [16:0] diff_r[0:7], diff_i[0:7];

    // Saturation 함수 (16비트 signed saturation)
    function automatic logic signed [15:0] sat_16(input logic signed [16:0] in);
        if (in > 16'sh7FFF) begin
            sat_16 = 16'sh7FFF;
        end else if (in < -16'sh8000) begin
            sat_16 = -16'sh8000;
        end else begin
            sat_16 = in[15:0];
        end
    endfunction

    // Index 합 계산 (combinational)
    always_comb begin
        index_sum_re = index_1_re + index_2_re;
        index_sum_im = index_1_im + index_2_im;
    end

    // 덧셈/뺄셈 수행 (combinational)
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            int idx = i*2;
            sum_r[i]  = input_real[idx] + input_real[idx+1];
            sum_i[i]  = input_imag[idx] + input_imag[idx+1];
            diff_r[i] = input_real[idx] - input_real[idx+1];
            diff_i[i] = input_imag[idx] - input_imag[idx+1];
        end
    end

    // 레지스터 저장 및 saturation + shift 연산 (clocked, non-blocking)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 1'b0;
            for (int i=0; i<16; i++) begin
                output_real[i] <= 13'sd0;
                output_imag[i] <= 13'sd0;
            end
        end else begin
            valid_out <= valid_in;

            for (int i = 0; i < 8; i++) begin
                logic signed [15:0] sat_sum_r, sat_diff_r;
                logic signed [15:0] sat_sum_i, sat_diff_i;

                // 16bit saturation
                sat_sum_r  = sat_16(sum_r[i]);
                sat_diff_r = sat_16(diff_r[i]);
                sat_sum_i  = sat_16(sum_i[i]);
                sat_diff_i = sat_16(diff_i[i]);

                // Re shift 처리
                if (index_sum_re >= 6'd23) begin
                    output_real[2*i]   <= 13'sd0;
                    output_real[2*i+1] <= 13'sd0;
                end else begin
                    output_real[2*i]   <= $signed({{(13-16){sat_sum_r[15]}}, sat_sum_r}) >>> (6'd9 - index_sum_re);
                    output_real[2*i+1] <= $signed({{(13-16){sat_diff_r[15]}}, sat_diff_r}) >>> (6'd9 - index_sum_re);
                end

                // Im shift 처리
                if (index_sum_im >= 6'd23) begin
                    output_imag[2*i]   <= 13'sd0;
                    output_imag[2*i+1] <= 13'sd0;
                end else begin
                    output_imag[2*i]   <= $signed({{(13-16){sat_sum_i[15]}}, sat_sum_i}) >>> (6'd9 - index_sum_im);
                    output_imag[2*i+1] <= $signed({{(13-16){sat_diff_i[15]}}, sat_diff_i}) >>> (6'd9 - index_sum_im);
                end
            end
        end
    end

endmodule
