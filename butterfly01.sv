module butterfly01 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [9:0] input_real_a [0:15],  // 입력 A 실수부
    input  logic signed [9:0] input_imag_a [0:15],  // 입력 A 허수부
    input  logic signed [9:0] input_real_b [0:15],  // 입력 B 실수부
    input  logic signed [9:0] input_imag_b [0:15],  // 입력 B 허수부

    output logic         valid_out,  // 출력 유효 신호
    output logic signed [12:0] output_real_add  [0:15], // (A + B) × Twiddle 결과 (실수부)
    output logic signed [12:0] output_imag_add  [0:15], // (A + B) × Twiddle 결과 (허수부)
    output logic signed [12:0] output_real_diff [0:15], // (A - B) × Twiddle 결과 (실수부)
    output logic signed [12:0] output_imag_diff [0:15]  // (A - B) × Twiddle 결과 (허수부)
);

    // Twiddle factor ROMs (10-bit <2.8> 고정소수점)
    logic signed [9:0] tw_add_real [0:3] = '{
        256, 256, 256, 181
    };
    logic signed [9:0] tw_add_imag [0:3] = '{
          0,   0,   0, -181
    };
    logic signed [9:0] tw_diff_real [0:3] = '{
        256, 0, 256, -181
    };
    logic signed [9:0] tw_diff_imag [0:3] = '{
          0,   -256,   0, -181
    };

    // 중간 연산용 신호 선언
    logic signed [10:0] sum_real_reg  [0:15], sum_imag_reg  [0:15];
    logic signed [10:0] diff_real_reg [0:15], diff_imag_reg [0:15];

    logic signed [20:0] mult_add0 [0:15];
    logic signed [20:0] mult_add1 [0:15];
    logic signed [20:0] mult_diff0 [0:15];
    logic signed [20:0] mult_diff1 [0:15];

    logic signed [12:0] rd_add_real [0:15], rd_add_imag [0:15];
    logic signed [12:0] rd_diff_real [0:15], rd_diff_imag [0:15];

    logic [3:0] tw_cnt;

    logic [1:0] tw_idx;

    // 덧셈, 뺄셈 결과 pipeline register (1 stage)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]  <= 0;
                sum_imag_reg[i]  <= 0;
                diff_real_reg[i] <= 0;
                diff_imag_reg[i] <= 0;
            end
        end else if (valid_in) begin
            for (int i = 0; i < 16; i++) begin
                sum_real_reg[i]  <= input_real_a[i] + input_real_b[i];
                sum_imag_reg[i]  <= input_imag_a[i] + input_imag_b[i];
                diff_real_reg[i] <= input_real_a[i] - input_real_b[i];
                diff_imag_reg[i] <= input_imag_a[i] - input_imag_b[i];
            end
        end
    end

    // Twiddle 곱 적용 (조합 논리)
    always_comb begin
        tw_idx = tw_cnt[3:2];

        for (int i = 0; i < 16; i++) begin
            mult_add0[i]  = sum_real_reg[i]  * tw_add_real[tw_idx];
            mult_add1[i]  = sum_imag_reg[i]  * tw_add_imag[tw_idx];
            mult_diff0[i] = diff_real_reg[i] * tw_diff_real[tw_idx];
            mult_diff1[i] = diff_imag_reg[i] * tw_diff_imag[tw_idx];

            rd_add_real[i]  = mult_add0[i]  >>> 8;
            rd_add_imag[i]  = mult_add1[i]  >>> 8;
            rd_diff_real[i] = mult_diff0[i] >>> 8;
            rd_diff_imag[i] = mult_diff1[i] >>> 8;
        end
    end

    // 출력 레지스터 및 tw_cnt 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out   <= 0;
            tw_cnt      <= 0;
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= 0;
                output_imag_add[i]  <= 0;
                output_real_diff[i] <= 0;
                output_imag_diff[i] <= 0;
            end
        end else begin
            if (valid_in) begin
                for (int i = 0; i < 16; i++) begin
                    output_real_add[i]  <= rd_add_real[i];
                    output_imag_add[i]  <= rd_add_imag[i];
                    output_real_diff[i] <= rd_diff_real[i];
                    output_imag_diff[i] <= rd_diff_imag[i];
                end
                tw_cnt <= tw_cnt + 4'd1;
            end
            valid_out <= valid_in;
        end
    end

endmodule

