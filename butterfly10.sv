module butterfly10 #(

    parameter CLK_CNT    = 2

) (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [10:0] input_real_a [0:15],  // 입력 A의 실수부, shif reg입력
    input  logic signed [10:0] input_imag_a [0:15],  // 입력 A의 허수부, shif reg입력
    input  logic signed [10:0] input_real_b [0:15],  // 입력 B의 실수부, 직접 입력
    input  logic signed [10:0] input_imag_b [0:15],  // 입력 B의 허수부, 직접 입력

    output logic         valid_out,  // 출력 유효 신호
    output logic signed [11:0] output_real_add [0:15], // (A + B) × Twiddle 결과 (실수부)
    output logic signed [11:0] output_imag_add [0:15], // (A + B) × Twiddle 결과 (허수부)
    output logic signed [11:0] output_real_diff [0:15], // (A - B) × Twiddle 결과 (실수부)
    output logic signed [11:0] output_imag_diff [0:15]  // (A - B) × Twiddle 결과 (허수부)
);

    logic signed [11:0] sum_real [0:15], sum_imag [0:15];
    logic signed [11:0] diff_real[0:15], diff_imag[0:15];

    logic signed [11:0] sat_sum_r[0:15], sat_sum_i[0:15];
    logic signed [11:0] sat_diff_r[0:15], sat_diff_i[0:15];

    // === Combinational butterfly ===
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            // Butterfly sum/diff
            sum_real[i]  = input_real_a[i] + input_real_b[i];
            sum_imag[i]  = input_imag_a[i] + input_imag_b[i];
            diff_real[i] = input_real_a[i] - input_real_b[i];
            diff_imag[i] = input_imag_a[i] - input_imag_b[i];

            // Saturation to 12bit
            sat_sum_r[i]  = (sum_real[i]  >  2047) ?  2047 :
                            (sum_real[i]  < -2048) ? -2048 : sum_real[i];

            sat_sum_i[i]  = (sum_imag[i]  >  2047) ?  2047 :
                            (sum_imag[i]  < -2048) ? -2048 : sum_imag[i];

            sat_diff_r[i] = (diff_real[i] >  2047) ?  2047 :
                            (diff_real[i] < -2048) ? -2048 : diff_real[i];

            sat_diff_i[i] = (diff_imag[i] >  2047) ?  2047 :
                            (diff_imag[i] < -2048) ? -2048 : diff_imag[i];
        end
    end
    // clk count
    logic [1:0] clk_cnt;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) clk_cnt <= 0;
        else if (valid_in && clk_cnt < CLK_CNT) clk_cnt <= clk_cnt + 1;
    end

    logic apply_minus_j;
    assign apply_minus_j = (clk_cnt >= (CLK_CNT/2));

    // === Output register and fac8_0 multiply ===
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
            if (valid_in) begin

                for (int i = 0; i < 16; i++) begin
                        output_real_add[i]  <= sat_sum_r[i];
                        output_imag_add[i]  <= sat_sum_i[i];
                    if (apply_minus_j) begin
                        // Multiply by -j
                        /* output_real_add[i]  <=  sat_sum_i[i];
                        output_imag_add[i]  <= -sat_sum_r[i]; */
                        output_real_diff[i] <=  sat_diff_i[i];
                        output_imag_diff[i] <= -sat_diff_r[i];
                    end else begin
                        // Multiply by +1
                        output_real_diff[i] <= sat_diff_r[i];
                        output_imag_diff[i] <= sat_diff_i[i];
                    end
                end
            end else begin
                for (int i = 0; i < 16; i++) begin
                    output_real_add[i]  <= output_real_add[i];
                    output_imag_add[i]  <= output_imag_add[i];
                    output_real_diff[i] <= output_real_diff[i];
                    output_imag_diff[i] <= output_imag_diff[i];
                end
            end
            valid_out <= valid_in;
        end
    end
endmodule
