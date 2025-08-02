`timescale 1ns/1ps
module butterfly21 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [13:0] input_real [0:15],  
    input  logic signed [13:0] input_imag [0:15],   
    output logic         valid_out, 
    output logic signed [15:0] output_real[0:15],
    output logic signed [15:0] output_imag[0:15]
);
    
    logic signed [14:0] sum_r[0:3], sum_i[0:3];
    logic signed [14:0] diff_r[0:3], diff_i[0:3];
    logic signed [23:0] mul_r [0:15], mul_i[0:15];
    logic signed [15:0] tmp_r[0:15], tmp_i[0:15];
    logic signed [13:0] sat_sum_r[0:15], sat_sum_i[0:15];
    logic signed [13:0] sat_diff_r[0:15], sat_diff_i[0:15];
    logic signed [9:0] tw_add_real [0:3] = '{256, 256, 256, 181};
    logic signed [9:0] tw_add_imag [0:3] = '{0, 0, 0, -181};
    logic signed [9:0] tw_diff_real[0:3] = '{256, 0, 256, -181};
    logic signed [9:0] tw_diff_imag[0:3] = '{0, -256, 0, -181};
    logic signed [20:0] mult_add [0:15][0:1]; //[i][0] = real, [i][1] = imag
    logic signed [20:0] mult_diff[0:15][0:1];

    logic signed [12:0] rd_add[0:15][0:1];
    logic signed [12:0] rd_diff[0:15][0:1];

    logic [2:0] tw_idx;
    logic [3:0] tw_cnt;
    logic valid_in_d1; 
    // === Combinational butterfly ===
    always_comb begin
        for (int i = 0; i < 2; i++) begin
            sum_r[i] = input_real[i] + input_real[i+2];
            sum_i[i] = input_imag[i] + input_imag[i+2];
            diff_r[i+2] = input_real[i] - input_real[i+2];
            diff_i[i+2] = input_imag[i] - input_imag[i+2];
	    
            sum_r[i+4] = input_real[i+4] + input_real[i+6];
            sum_i[i+4] = input_imag[i+4] + input_imag[i+6];
            diff_r[i+6] = input_real[i+4] - input_real[i+6];
            diff_i[i+6] = input_imag[i+4] - input_imag[i+6];

            sum_r[i+8] = input_real[i+8] + input_real[i+10];
            sum_i[i+8] = input_imag[i+8] + input_imag[i+10];
            diff_r[i+10] = input_real[i+8] - input_real[i+10];
            diff_i[i+10] = input_imag[i+8] - input_imag[i+10];

            sum_r[i+12] = input_real[i+12] + input_real[i+14];
            sum_i[i+12] = input_imag[i+12] + input_imag[i+14];
            diff_r[i+14] = input_real[i+12] - input_real[i+14];
            diff_i[i+14] = input_imag[i+12] - input_imag[i+14];
            
            sat_sum_r[i]  = (sum_r[i]  >  8191) ?  8191 :
                            (sum_r[i]  < -8192) ? -8192 : sum_r[i];

            sat_sum_i[i]  = (sum_i[i]  >  8191) ?  8191 :
                            (sum_i[i]  < -8192) ? -8192 : sum_i[i];

            sat_diff_r[i] = (diff_r[i] >  8191) ?  8191 :
                            (diff_r[i] < -8192) ? -8192 : diff_r[i];

            sat_diff_i[i] = (diff_i[i] >  8191) ?  8191 :
                            (diff_i[i] < -8192) ? -8192 : diff_i[i];
        end
    end

    // === Twiddle 곱 + Truncation & Saturation ===
    always_comb begin
            tw_idx = tw_cnt[3:2];
            for (int i = 0; i < 16; i++) begin
            // A + B 곱
                 mult_add[i][0] = (sat_sum_r[i]  * tw_add_real[tw_idx]) - (sat_sum_i[i]  * tw_add_imag[tw_idx]);
                 mult_add[i][1] = (sat_sum_i[i]  * tw_add_real[tw_idx]) + (sat_sum_r[i]  * tw_add_imag[tw_idx]);

            // A - B 곱
                 mult_diff[i][0] = (sat_diff_r[i] * tw_diff_real[tw_idx]) - (sat_diff_i[i] * tw_diff_imag[tw_idx]);
                 mult_diff[i][1] = (sat_diff_i[i] * tw_diff_real[tw_idx]) + (sat_diff_r[i] * tw_diff_imag[tw_idx]);

            // 정규화
                 rd_add[i][0]  = (mult_add[i][0]  + 128) >>> 8;
                 rd_add[i][1]  = (mult_add[i][1]  + 128) >>> 8;
                 rd_diff[i][0] = (mult_diff[i][0] + 128) >>> 8;
                 rd_diff[i][1] = (mult_diff[i][1] + 128) >>> 8;
            end
    end

    // === 출력 레지스터 ===
    always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_in_d1 <= 0;
        valid_out   <= 0;
        tw_cnt      <= 0;
        for (int i = 0; i < 32; i++) begin
            output_real[i] <= 0;
            output_imag[i] <= 0;
        end
    end else begin
        valid_in_d1 <= valid_in;
        valid_out   <= valid_in_d1;

        if (valid_in_d1) begin
            tw_cnt <= tw_cnt + 1;

            // A + B 출력: 0~15
            for (int i = 0; i < 16; i++) begin
                output_real[i]     <= rd_add[i][0];
                output_imag[i]     <= rd_add[i][1];
            end

            // A - B 출력: 16~31
            for (int i = 0; i < 16; i++) begin
                output_real[i+16]  <= rd_diff[i][0];
                output_imag[i+16]  <= rd_diff[i][1];
            end
        end
    end
end
endmodule