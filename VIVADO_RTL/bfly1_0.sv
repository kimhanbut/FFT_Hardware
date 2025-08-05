
`timescale 1ns/1ps

module butterfly10 #(
    parameter CLK_CNT = 2
)(
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [10:0] input_real_a [0:15],
    input  logic signed [10:0] input_imag_a [0:15],
    input  logic signed [10:0] input_real_b [0:15],
    input  logic signed [10:0] input_imag_b [0:15],

    output logic         valid_out,
    output logic signed [11:0] output_real_add [0:15],
    output logic signed [11:0] output_imag_add [0:15],
    output logic signed [11:0] output_real_diff [0:15],
    output logic signed [11:0] output_imag_diff [0:15]
);

    // 내부 레지스터
    logic signed [11:0] sum_real [0:15], sum_imag [0:15];
    logic signed [11:0] diff_real[0:15], diff_imag[0:15];

    logic signed [11:0] sat_sum_r[0:15], sat_sum_i[0:15];
    logic signed [11:0] sat_diff_r[0:15], sat_diff_i[0:15];

    logic [5:0] valid_cnt;
    logic 	clk_cnt;
    logic       local_valid;

    assign valid_out = local_valid;



always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_cnt     <= 0;
        valid_cnt   <= 0;
        local_valid <= 0;
    end else begin
        if (valid_in)
            clk_cnt <= clk_cnt + 1;

        if (valid_in && valid_cnt == 0)
            valid_cnt <= 32;
        else if (valid_cnt > 0)
            valid_cnt <= valid_cnt - 1;

        // local_valid는 다음 상태 valid_cnt 기준으로 바로 결정
        if (valid_in && valid_cnt == 0)
            local_valid <= 1;
        else
            local_valid <= (valid_cnt > 1);  // 1보다 클 때만 유지 (다음 클럭 기준)
    end
end
    logic apply_minus_j;
    assign apply_minus_j = (clk_cnt >= (CLK_CNT/2));

    // butterfly 계산
    always_comb begin
	    if(valid_in) begin
        for (int i = 0; i < 16; i++) begin
            sum_real[i]  = input_real_a[i] + input_real_b[i];
            sum_imag[i]  = input_imag_a[i] + input_imag_b[i];
            diff_real[i] = input_real_a[i] - input_real_b[i];
            diff_imag[i] = input_imag_a[i] - input_imag_b[i];

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
    end

    // 출력 레지스터: 1클럭 지연 후 출력
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
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
                        output_real_diff[i] <=  sat_diff_i[i];     // -j 곱
                        output_imag_diff[i] <= -sat_diff_r[i];
                    end else begin
                        output_real_diff[i] <= sat_diff_r[i];      // 그냥 통과
                        output_imag_diff[i] <= sat_diff_i[i];
                    end
                end
            end
        end
    end

endmodule
