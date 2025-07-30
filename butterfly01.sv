module butterfly01 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [9:0] input_real_a [0:15],
    input  logic signed [9:0] input_imag_a [0:15],
    input  logic signed [9:0] input_real_b [0:15],
    input  logic signed [9:0] input_imag_b [0:15],

    output logic         valid_out,
    output logic signed [12:0] output_real_add  [0:15],
    output logic signed [12:0] output_imag_add  [0:15],
    output logic signed [12:0] output_real_diff [0:15],
    output logic signed [12:0] output_imag_diff [0:15],
    output logic SR_valid
);

logic [5:0] sr_valid_cnt;
logic valid_in_d1;

// SR_valid:다음 SR에 들어가는 din_valid 생성 
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sr_valid_cnt <= 0;
    end else if (valid_in_d1) begin
        sr_valid_cnt <= 9;
    end else if (sr_valid_cnt != 0) begin
        sr_valid_cnt <= sr_valid_cnt - 1;
    end
end

assign SR_valid = (sr_valid_cnt != 0);

// Twiddle factor ROMs (<2.8> fixed-point)
logic signed [9:0] tw_add_real [0:3] = '{256, 256, 256, 181};
logic signed [9:0] tw_add_imag [0:3] = '{0, 0, 0, -181};
logic signed [9:0] tw_diff_real[0:3] = '{256, 0, 256, -181};
logic signed [9:0] tw_diff_imag[0:3] = '{0, -256, 0, -181};

logic signed [10:0] sum_real_reg  [0:15], sum_imag_reg  [0:15];
logic signed [10:0] diff_real_reg [0:15], diff_imag_reg [0:15];

logic signed [20:0] mult_add_i [0:15], mult_add_q [0:15];
logic signed [20:0] mult_diff_i [0:15], mult_diff_q [0:15];

logic signed [12:0] rd_add_real [0:15], rd_add_imag [0:15];
logic signed [12:0] rd_diff_real[0:15], rd_diff_imag[0:15];

logic [3:0] tw_cnt;
logic [1:0] tw_idx;

// input A, B의 합/차 저장 (1-stage pipeline)
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

// Twiddle 곱 계산 (조합 논리)
always_comb begin
    tw_idx = tw_cnt[3:2];
    for (int i = 0; i < 16; i++) begin
        mult_add_i[i]  = (sum_real_reg[i]  * tw_add_real[tw_idx])-(sum_imag_reg[i]  * tw_add_imag[tw_idx]);
        mult_add_q[i]  = (sum_imag_reg[i]  * tw_add_real[tw_idx])+(sum_real_reg[i]  * tw_add_imag[tw_idx]);
        mult_diff_i[i] = (diff_real_reg[i] * tw_diff_real[tw_idx])-(diff_imag_reg[i]  * tw_diff_imag[tw_idx]);
	mult_diff_q[i] = (diff_imag_reg[i] * tw_diff_real[tw_idx])+(diff_real_reg[i] * tw_diff_imag[tw_idx]);

        rd_add_real[i]  = mult_add_i[i]  >>> 8;
        rd_add_imag[i]  = mult_add_q[i]  >>> 8;
        rd_diff_real[i] = mult_diff_i[i] >>> 8;
        rd_diff_imag[i] = mult_diff_q[i] >>> 8;
    end
end




// 출력과 valid 제어
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
        if (valid_in) begin
            for (int i = 0; i < 16; i++) begin
                output_real_add[i]  <= rd_add_real[i];
                output_imag_add[i]  <= rd_add_imag[i];
                output_real_diff[i] <= rd_diff_real[i];
                output_imag_diff[i] <= rd_diff_imag[i];
            end
        end
        if (valid_in_d1) begin
            tw_cnt <= tw_cnt + 4'd1;
        end
        valid_out <= valid_in_d1;
    end
end

endmodule
