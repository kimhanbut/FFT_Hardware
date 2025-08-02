`timescale 1ns / 1ps

module butterfly21 (
    input logic               clk,
    input logic               rstn,
    input logic               valid_in,
    input logic signed [13:0] input_real[0:15],
    input logic signed [13:0] input_imag[0:15],

    output logic               valid_out,
    output logic signed [15:0] output_real[0:15],
    output logic signed [15:0] output_imag[0:15],
    output logic               SR_valid
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
    logic signed [9:0] fac_real_add[0:3] = '{256, 256, 256, 181};
    logic signed [9:0] fac_real_sub[0:3] = '{0, 0, 0, -181};
    logic signed [9:0] fac_imag_add[0:3] = '{256, 0, 256, -181};
    logic signed [9:0] fac_imag_sub[0:3] = '{0, -256, 0, -181};

    // 내부 레지스터 및 곱셈 결과
    logic signed [14:0]
        sum_r[0:3],
        sum_i[0:3],
        diff_r[0:3],
        diff_i[0:3];

    logic signed [13:0] sat_sum_r[0:15], sat_diff_r[0:15];
    logic signed [13:0] sat_sum_i[0:15], sat_diff_i[0:15];
    logic signed [23:0] mul_add_r[0:15], mul_add_i[0:15];
    logic signed [23:0] mul_sub_r[0:15], mul_sub_i[0:15];

    logic signed [15:0] rd_add_r[0:15], rd_add_i[0:15];
    logic signed [15:0] rd_sub_r[0:15], rd_sub_i[0:15];

    logic [3:0] tw_cnt;  // fac8_1 계수 적용위한 인덱스를 cnt : 0~15
    logic [2:0] tw_idx;  // fac8_1 계수 인덱스 : 0~7



    always_ff @(posedge clk or negedge rstn) begin
       if (!rstn) begin
          for (int i = 0; i < 16; i++) begin
              sum_r[i]      <= 0;
              sum_i[i]      <= 0;
              diff_r[i]     <= 0;
              diff_i[i]     <= 0;
              sat_sum_r[i]  <= 0;
              sat_sum_i[i]  <= 0;
              sat_diff_r[i] <= 0;
              sat_diff_i[i] <= 0;
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


    // 조합 Twiddle 곱
    always_comb begin
        tw_idx = tw_cnt[3:2];  // 64포인트마다 8패턴, 상위 3bit 추출
        for (int i = 0; i < 16; i++) begin
            // (Re + jIm) × (fac_real + j fac_imag)
            mul_add_r[i]  = (sat_sum_r[i]  * fac_real_add[tw_idx])-(sat_sum_i[i]  * fac_imag_add[tw_idx]);			
            mul_add_i[i]  = (sat_sum_i[i]  * fac_real_add[tw_idx])+(sat_sum_r[i]  * fac_imag_add[tw_idx]);
            mul_sub_r[i] = (sat_diff_r[i] * fac_real_sub[tw_idx])-(sat_diff_i[i]  * fac_imag_sub[tw_idx]);
            mul_sub_i[i] = (sat_diff_i[i] * fac_real_sub[tw_idx])+(sat_diff_r[i] * fac_imag_sub[tw_idx]);

            rd_add_r[i] = (mul_add_r[i] + 128) >>> 8;
            rd_add_i[i] = (mul_add_i[i] + 128) >>> 8;
            rd_sub_r[i] = (mul_sub_r[i] + 128) >>> 8;
            rd_sub_i[i] = (mul_sub_i[i] + 128) >>> 8;
        end  // rounding : 8bit shift
    end

    // 출력 레지스터 + valid 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in_d4 <= 0;
            valid_in_d3 <= 0;
            valid_in_d2 <= 0;
            valid_in_d1 <= 0;
            valid_out   <= 0;
            tw_cnt      <= 0;
            clk_cnt     <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real[i] <= 0;
                output_imag[i] <= 0;
            end
        end else begin
            valid_in_d1 <= valid_in;
            valid_in_d2 <= valid_in_d1;
            valid_in_d3 <= valid_in_d2;
            valid_in_d4 <= valid_in_d3;

            if (valid_in_d4) begin
                tw_cnt  <= tw_cnt + 1;
                clk_cnt <= clk_cnt + 1;
                for (int i = 0; i < 16; i++) begin
                    output_real[i] <= rd_add_r[i];
                    output_imag[i] <= rd_add_i[i];
                end
            end else begin
                for (int i = 0; i < 16; i++) begin
                    output_real[i] <= rd_sub_r[i];
                    output_imag[i] <= rd_sub_i[i];
                end
            end
            valid_out <= valid_in_d1;


        end
    end

endmodule