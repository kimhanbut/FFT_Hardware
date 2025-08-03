`timescale 1ns / 1ps

module twiddle_mul #(
    parameter IN_DATA_W = 14,
    parameter OUT_DATA_W = 23,
    parameter DATA_SIZE = 16
) (
    input logic signed [IN_DATA_W -1:0] data_re_in[0:DATA_SIZE-1],
    input logic signed [IN_DATA_W -1:0] data_im_in[0: DATA_SIZE-1],
    input logic signed [ 8:0] twf_re_in [0: DATA_SIZE - 1],
    input logic signed [ 8:0] twf_im_in [0: DATA_SIZE -1],

    output logic signed [OUT_DATA_W - 1:0] data_re_out[0: DATA_SIZE -1],
    output logic signed [OUT_DATA_W - 1:0] data_im_out[0: DATA_SIZE -1]
);

    always_comb begin
        for (int i = 0; i < DATA_SIZE; i++) begin
            // 복소수 곱셈: (a+jb)*(c+jd) = (ac - bd) + j(ad + bc)
            data_re_out[i] = data_re_in[i] * twf_re_in[i] - data_im_in[i] * twf_im_in[i];
            data_im_out[i] = data_re_in[i] * twf_im_in[i] + data_im_in[i] * twf_re_in[i];
        end
    end

endmodule
