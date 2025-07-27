`timescale 1ns/1ps

module cbfp_module0 #(
  parameter IN_WIDTH    = 23,
  parameter OUT_WIDTH   = 13,
  parameter SHIFT_WIDTH = 5,  // to represent 0~31
  parameter MAG_WIDTH   = SHIFT_WIDTH
)(
  input  logic clk,
  input  logic rstn,
  input  logic din_valid,

  input  logic signed [IN_WIDTH-1:0] pre_bfly02_real [0:15], // step0_2의 fft 곱셈 결과 입력
  input  logic signed [IN_WIDTH-1:0] pre_bfly02_imag [0:15],

  output logic         valid_out,
  output logic signed [OUT_WIDTH-1:0] bfly02_real [0:15], // CBFP 처리 후 최종 정규화된 출력
  output logic signed [OUT_WIDTH-1:0] bfly02_imag [0:15]
);

  // Intermediate magnitude wires
  logic [MAG_WIDTH-1:0] mag_r [0:15];
  logic [MAG_WIDTH-1:0] mag_i [0:15];

  // shift amount
  logic [SHIFT_WIDTH-1:0] shift_amt_re;
  logic [SHIFT_WIDTH-1:0] shift_amt_im;

  // Magnitude detection
  cbfp_mag_detect #(
    .DATA_WIDTH(IN_WIDTH),
    .MAG_WIDTH(MAG_WIDTH)
  ) U_MAG_REAL (
    .din(pre_bfly02_real),
    .mag_out(mag_r)
  );

  cbfp_mag_detect #(
    .DATA_WIDTH(IN_WIDTH),
    .MAG_WIDTH(MAG_WIDTH)
  ) U_MAG_IMAG (
    .din(pre_bfly02_imag),
    .mag_out(mag_i)
  );

  // Minimum detect per block
  cbfp_min_detect #(
    .MAG_WIDTH(MAG_WIDTH)
  ) U_MIN_REAL (
    .mag_in(mag_r),
    .min_mag(shift_amt_re)
  );

  cbfp_min_detect #(
    .MAG_WIDTH(MAG_WIDTH)
  ) U_MIN_IMAG (
    .mag_in(mag_i),
    .min_mag(shift_amt_im)
  );

  // Shift + saturation
  cbfp_shift #(
    .IN_WIDTH(IN_WIDTH),
    .OUT_WIDTH(OUT_WIDTH),
    .SHIFT_WIDTH(SHIFT_WIDTH)
  ) U_SHIFT (
    .in_real(pre_bfly02_real),
    .in_imag(pre_bfly02_imag),
    .shift_amt_re(shift_amt_re),
    .shift_amt_im(shift_amt_im),
    .out_real(bfly02_real),
    .out_imag(bfly02_imag)
  );

  // valid passthrough (1:1 클럭 매칭)
  assign valid_out = din_valid;

endmodule
