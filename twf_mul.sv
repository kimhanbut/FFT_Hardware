module twiddle_mul (
    input  logic signed [13:0] data_re_in [15:0],
    input  logic signed [13:0] data_im_in [15:0],
    input  logic signed  [8:0] twf_re_in  [15:0],
    input  logic signed  [8:0] twf_im_in  [15:0],

    output logic signed [22:0] data_re_out [15:0],
    output logic signed [22:0] data_im_out [15:0]
);

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            // 복소수 곱셈: (a+jb)*(c+jd) = (ac - bd) + j(ad + bc)
            data_re_out[i] = data_re_in[i] * twf_re_in[i] - data_im_in[i] * twf_im_in[i];
            data_im_out[i] = data_re_in[i] * twf_im_in[i] + data_im_in[i] * twf_re_in[i];
        end
    end

endmodule
