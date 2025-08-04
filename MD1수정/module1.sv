`timescale 1ns / 1ps

module module1 (
    input logic clk,
    input logic rstn,
    input logic din_valid,
    input logic signed [10:0] din_i[0:15],
    input logic signed [10:0] din_q[0:15],
    output logic valid_out,
    output logic signed [11:0] module1_dout_i[0:15], // CBFP 처리 후 최종 정규화된 출력
    output logic signed [11:0] module1_dout_q[0:15],
    output logic [4:0] index2_re[0:15],
    output logic [4:0] index2_im[0:15],
);




    logic signed [11:0] bf10_real_a[0:15]; //add
    logic signed [11:0] bf10_imag_a[0:15];
    logic signed [11:0] bf10_real_s[0:15]; //sub
    logic signed [11:0] bf10_imag_s[0:15];

    logic signed [13:0] bf11_real[0:15]; //add
    logic signed [13:0] bf11_imag[0:15];

    logic signed [24:0] bf12_real[0:15]; //add
    logic signed [24:0] bf12_imag[0:15];

    logic signed [11:0] cbfp1_real[0:15];
    logic signed [11:0] cbfp1_imag[0:15];


    logic dout_valid_0, dout_valid_1, dout_valid_bf12;

step1_0 STEP_0(
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .din_r(din_i),
    .din_i(din_q),

    .dout_valid(dout_valid_0),
    .dout_add_r(bf10_real_a), // A+B
    .dout_add_i(bf10_imag_a),
    .dout_sub_r(bf10_real_s), // A−B
    .dout_sub_i(bf10_imag_s)
);


step1_1 STEP_1(
    .clk(clk),
    .rstn(rstn),
    .din_valid(dout_valid_0),
    .din_add_r(bf10_real_a),  // 입력 12bit
    .din_sub_r(bf10_real_s),
    .din_add_i(bf10_imag_a),
    .din_sub_i(bf10_imag_s),

    .dout_valid(dout_valid_1),
    .dout_r(bf11_real), // 출력 15bit
    .dout_i(bf11_imag)
);



butterfly12 BFLY_12(
    .clk(clk),
    .rstn(rstn),
    .valid_in(dout_valid_1),
    .input_real(bf11_real),  //add
    .input_imag(bf11_imag),

    .valid_out(dout_valid_bf12),
    .output_real(bf12_real),
    .output_imag(bf12_imag)
);
//cbfp module is required


cbfp_module1 #(
    .IN_WIDTH(25),
    .OUT_WIDTH(12),
    .SHIFT_WIDTH(5),
    .MAG_WIDTH(5)
) CBFP1 (
    .clk(clk),
    .rstn(rstn),
    .din_valid(dout_valid_bf12),  // butterfly stage의 local valid 사용

    .pre_bfly12_real(bf12_real), // [0:15] 25bit signed input
    .pre_bfly12_imag(bf12_imag),

    .valid_out(valid_out),
    .bfly12_real(module1_dout_i), // [0:15] 12bit signed output
    .bfly12_imag(module1_dout_q),

    .index2_re(index2_re),
    .index2_im(index2_im),
);


endmodule
