`timescale 1ns / 1ps

module butterfly21 (
    input logic               clk,
    input logic               rstn,
    input logic               valid_in,
    input logic signed [12:0] input_real[0:15],
    input logic signed [12:0] input_imag[0:15],

    output logic               valid_out,
    output logic signed [14:0] output_real[0:15],
    output logic signed [14:0] output_imag[0:15]
);

    // 내부 변수
    logic [5:0]
        valid_cnt,
        clk_cnt;  //0~63, 넉넉히 잡았고 실제 사용은 9까지
    logic
        valid_in_d1,
        valid_in_d2,
        valid_in_d3,
        valid_in_d4,
        local_valid;  // valid_in 1clk 딜레이, 32clk짜리 valid signal

    // Twiddle 계수 (<2.8> fixed-point)
    logic signed [9:0] fac_real[0:7] = '{256, 256, 256, 0, 256, 181, 256, -181};
    logic signed [9:0] fac_imag[0:7] = '{0, 0, 0, -256, 0, -181, 0, -181};

    // 내부 레지스터 및 곱셈 결과
    logic signed [13:0]
        sum_r[0:15],
        sum_i[0:15],
        diff_r[0:15],
        diff_i[0:15];

    logic signed [13:0] sat_sum_r[0:15], sat_diff_r[0:15];
    logic signed [13:0] sat_sum_i[0:15], sat_diff_i[0:15];
    logic signed [23:0] mul_r[0:15];
    logic signed [23:0] mul_i[0:15];

    logic signed [15:0] rd_r[0:15];
    logic signed [15:0] rd_i[0:15];

    // sum/diff 계산
    always_ff @(posedge clk or negedge rstn) begin
       if (!rstn) begin
          for (int i = 0; i < 16; i++) begin
              sum_r[i]      <= 0;
              sum_i[i]      <= 0;
              diff_r[i]     <= 0;
              diff_i[i]     <= 0;
           end
       end else if (valid_in) begin
          for (int i = 0; i < 2; i++) begin
            // sum & diff 계산
            sum_r[i]      <= input_real[i] + input_real[i+2];
            sum_i[i]      <= input_imag[i] + input_imag[i+2];
            diff_r[i+2]   <= input_real[i] - input_real[i+2];
            diff_i[i+2]   <= input_imag[i] - input_imag[i+2];

            sum_r[i+4]    <= input_real[i+4] + input_real[i+6];
            sum_i[i+4]    <= input_imag[i+4] + input_imag[i+6];
            diff_r[i+6]   <= input_real[i+4] - input_real[i+6];
            diff_i[i+6]   <= input_imag[i+4] - input_imag[i+6];

            sum_r[i+8]    <= input_real[i+8] + input_real[i+10];
            sum_i[i+8]    <= input_imag[i+8] + input_imag[i+10];
            diff_r[i+10]  <= input_real[i+8] - input_real[i+10];
            diff_i[i+10]  <= input_imag[i+8] - input_imag[i+10];

            sum_r[i+12]   <= input_real[i+12] + input_real[i+14];
            sum_i[i+12]   <= input_imag[i+12] + input_imag[i+14];
            diff_r[i+14]  <= input_real[i+12] - input_real[i+14];
            diff_i[i+14]  <= input_imag[i+12] - input_imag[i+14];
          end
       end
    end

    // saturation 처리
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i< 16;i++) begin
               sat_sum_r[i] <=0;
               sat_sum_i[i] <=0;
               sat_diff_r[i] <=0;
               sat_diff_i[i] <=0;
            end
        end else begin
            for (int i =0; i<16; i++) begin
                // saturation 처리 (합)
                sat_sum_r[i]  <= (sum_r[i]  >  8191) ?  8191 :
                                 (sum_r[i]  < -8192) ? -8192 : sum_r[i];
                sat_sum_i[i]  <= (sum_i[i]  >  8191) ?  8191 :
                                 (sum_i[i]  < -8192) ? -8192 : sum_i[i];

                // saturation 처리 (차)
                sat_diff_r[i] <= (diff_r[i] >  8191) ?  8191 :
                                 (diff_r[i] < -8192) ? -8192 : diff_r[i];
                sat_diff_i[i] <= (diff_i[i] >  8191) ?  8191 :
                                 (diff_i[i] < -8192) ? -8192 : diff_i[i];
            end
        end
    end
    int i, idx;
    // 조합 Twiddle 곱
    always_comb begin
        for (i = 0; i < 16; i++) begin
            idx = i % 8;
            if (i % 4 < 2) begin
                // i가 0,1,4,5,8,9,12,13일 때 실행됨
                mul_r[i] = (sat_sum_r[i] * fac_real[idx]) - (sat_sum_i[i] * fac_imag[idx]);
                mul_i[i] = (sat_sum_i[i] * fac_real[idx]) + (sat_sum_r[i] * fac_imag[idx]);

            end else begin
                // 나머지 (2,3,6,7,10,11,14,15)일 때 실행됨
                mul_r[i] = (sat_diff_r[i] * fac_real[idx]) - (sat_diff_i[i] * fac_imag[idx]);
                mul_i[i] = (sat_diff_i[i] * fac_real[idx]) + (sat_diff_r[i] * fac_imag[idx]);
            end

            rd_r[i] = (mul_r[i] + 128) >>> 8; // rounding
            rd_i[i] = (mul_i[i] + 128) >>> 8;
        end
    end

    // 출력 레지스터 + valid 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in_d4 <= 0;
            valid_in_d3 <= 0;
            valid_in_d2 <= 0;
            valid_in_d1 <= 0;
            valid_out   <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real[i] <= 0;
                output_imag[i] <= 0;
            end
        end else begin
            valid_in_d1 <= valid_in;
            valid_in_d2 <= valid_in_d1;
            valid_in_d3 <= valid_in_d2;
            valid_in_d4 <= valid_in_d3;

            if (valid_in_d2) begin
                for (int i = 0; i < 16; i++) begin
                    output_real[i] <= rd_r[i];
                    output_imag[i] <= rd_i[i];
                end
                valid_out <= 1;
            end else begin
      valid_out<=0;
        end
    end
   end
endmodule
