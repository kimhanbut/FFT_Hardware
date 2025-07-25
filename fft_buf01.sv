module butterfly01 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,

    input  logic [8:0]   base_input_idx,

    input  logic signed [9:0] input_real_a [15:0],
    input  logic signed [9:0] input_imag_a [15:0],
    input  logic signed [9:0] input_real_b [15:0],
    input  logic signed [9:0] input_imag_b [15:0],

    output logic         valid_out,
    output logic signed [12:0] output_real_a [15:0],
    output logic signed [12:0] output_imag_a [15:0],
    output logic signed [12:0] output_real_b [15:0],
    output logic signed [12:0] output_imag_b [15:0]
);

    // Twiddle ROM (2.8 fixed-point)
    logic signed [9:0] tw_real_rom [7:0] = '{256, 256, 256,   0, 256, 181, 256, -181};
    logic signed [9:0] tw_imag_rom [7:0] = '{  0,   0,   0, -256,   0, -181,   0, -181};

    // 내부 결과
    logic signed [12:0] tw_sum_real [15:0], tw_sum_imag [15:0];
    logic signed [12:0] tw_diff_real [15:0], tw_diff_imag [15:0];

    // 복소수 곱 함수
    function automatic void complex_mult (
        input  logic signed [10:0] ar, ai,
        input  logic signed [9:0]  wr, wi,
        output logic signed [12:0] pr, pi
    );
        logic signed [20:0] mr0, mr1, mr2, mr3;
        begin
            mr0 = ar * wr;
            mr1 = ai * wi;
            mr2 = ar * wi;
            mr3 = ai * wr;
            pr = (mr0 - mr1) >>> 8;
            pi = (mr2 + mr3) >>> 8;
        end
    endfunction

    // combinational 계산 → flip-flop으로 이동 (루프 변수 제거)
    logic signed [10:0] sum_r [15:0], sum_i [15:0];
    logic signed [10:0] diff_r [15:0], diff_i [15:0];

    logic signed [9:0] wr, wi;

    always_comb begin
        int tw_idx;
        tw_idx = base_input_idx >> 6;
        wr = tw_real_rom[tw_idx];
        wi = tw_imag_rom[tw_idx];

        for (int j = 0; j < 16; j++) begin
            sum_r[j] = input_real_a[j] + input_real_b[j];
            sum_i[j] = input_imag_a[j] + input_imag_b[j];
            diff_r[j] = input_real_a[j] - input_real_b[j];
            diff_i[j] = input_imag_a[j] - input_imag_b[j];
        end
    end

    // 계산 결과 저장
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 0;
            for (int j = 0; j < 16; j++) begin
                output_real_a[j] <= 0;
                output_imag_a[j] <= 0;
                output_real_b[j] <= 0;
                output_imag_b[j] <= 0;
            end
        end else begin
            valid_out <= valid_in;
            for (int j = 0; j < 16; j++) begin
                complex_mult(sum_r[j], sum_i[j], wr, wi, tw_sum_real[j], tw_sum_imag[j]);
                complex_mult(diff_r[j], diff_i[j], wr, wi, tw_diff_real[j], tw_diff_imag[j]);

                output_real_a[j] <= tw_sum_real[j];
                output_imag_a[j] <= tw_sum_imag[j];
                output_real_b[j] <= tw_diff_real[j];
                output_imag_b[j] <= tw_diff_imag[j];
            end
        end
    end

endmodule

