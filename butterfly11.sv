module butterfly11 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [11:0] input_real_a [0:15],
    input  logic signed [11:0] input_imag_a [0:15],
    input  logic signed [11:0] input_real_b [0:15],
    input  logic signed [11:0] input_imag_b [0:15],

    output logic         valid_out,
    output logic signed [14:0] output_real_add  [0:15],
    output logic signed [14:0] output_imag_add  [0:15],
    output logic signed [14:0] output_real_diff [0:15],
    output logic signed [14:0] output_imag_diff [0:15],
    output logic SR_valid
);

    // 내부 변수
    logic [5:0] sr_valid_cnt; //0~63, 넉넉히 잡았고 실제 사용은 9까지
    logic valid_in_d1; // valid_in 1clk 딜레이

    // SR_valid 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            sr_valid_cnt <= 0;
        else if (valid_in_d1)
            sr_valid_cnt <= 6'd9;  
        else if (sr_valid_cnt != 0)
            sr_valid_cnt <= sr_valid_cnt - 1;
    end
    assign SR_valid = (sr_valid_cnt != 0);

    // Twiddle 계수 (<2.8> fixed-point)
    logic signed [9:0] fac_real [0:7] = '{256, 256, 256, 0, 256, 181, 256, -181};
    logic signed [9:0] fac_imag [0:7] = '{  0,   0,   0, -256,   0, -181,   0, -181};

    // 내부 레지스터 및 곱셈 결과
    logic signed [12:0] sum_r [0:15], sum_i [0:15], diff_r [0:15], diff_i [0:15];
    logic signed [22:0] mul_add_r [0:15], mul_add_i [0:15];
    logic signed [22:0] mul_sub_r [0:15], mul_sub_i [0:15];

    logic signed [14:0] rd_add_r [0:15], rd_add_i [0:15];
    logic signed [14:0] rd_sub_r [0:15], rd_sub_i [0:15];

    logic [3:0] tw_cnt; // fac8_1 계수 적용위한 인덱스를 cnt : 0~15
    logic [2:0] tw_idx; // fac8_1 계수 인덱스 : 0~7

    // Sum/Diff 파이프라인
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                sum_r[i]  <= 0; 
                sum_i[i]  <= 0;
                diff_r[i] <= 0; 
                diff_i[i] <= 0;           
            end
        end else if (valid_in | valid_in_d1) begin
            for (int i = 0; i < 16; i++) begin
                sum_r[i]  <= input_real_a[i] + input_real_b[i];
                sum_i[i]  <= input_imag_a[i] + input_imag_b[i];
                diff_r[i] <= input_real_a[i] - input_real_b[i];
                diff_i[i] <= input_imag_a[i] - input_imag_b[i];
            end
        end
    end

    // 조합 Twiddle 곱
    always_comb begin
        tw_idx = tw_cnt[3:1]; // 64포인트마다 8패턴, 상위 3bit 추출
        for (int i = 0; i < 16; i++) begin
            // (Re + jIm) × (fac_real + j fac_imag)
            mul_add_r[i]  = (sum_r[i]  * fac_real[tw_idx]) - (sum_i[i]  * fac_imag[tw_idx]);
            mul_add_i[i]  = (sum_i[i]  * fac_real[tw_idx]) + (sum_r[i]  * fac_imag[tw_idx]);
            mul_sub_r[i]  = (diff_r[i] * fac_real[tw_idx]) - (diff_i[i] * fac_imag[tw_idx]);
            mul_sub_i[i]  = (diff_i[i] * fac_real[tw_idx]) + (diff_r[i] * fac_imag[tw_idx]);

            rd_add_r[i] = (mul_add_r[i] + 128) >>> 8;
            rd_add_i[i] = (mul_add_i[i] + 128) >>> 8;
            rd_sub_r[i] = (mul_sub_r[i] + 128) >>> 8;
            rd_sub_i[i] = (mul_sub_i[i] + 128) >>> 8;
        end // rounding : 8bit shift
    end

    // 출력 레지스터 + valid 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in_d1 <= 0;
            valid_out   <= 0;
            tw_cnt      <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= 0;
                output_imag_add[i]  <= 0;
                output_real_diff[i] <= 0;
                output_imag_diff[i] <= 0;
            end
        end else begin
            valid_in_d1 <= valid_in;
            if (valid_in_d1) begin
                tw_cnt <= tw_cnt + 1;
                for (int i = 0; i < 16; i++) begin
                    output_real_add[i]  <= rd_add_r[i];
                    output_imag_add[i]  <= rd_add_i[i];
                    output_real_diff[i] <= rd_sub_r[i];
                    output_imag_diff[i] <= rd_sub_i[i];
                end
            end
            valid_out <= valid_in_d1;
        end
    end

endmodule
