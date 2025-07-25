`timescale 1ns/1ps

module cbfp_shift #(
  parameter IN_WIDTH  = 23,
  parameter OUT_WIDTH = 13,
  parameter SHIFT_WIDTH = 5  // up to shift 0~31
)(
  input  logic signed [IN_WIDTH-1:0] in_real [15:0],
  input  logic signed [IN_WIDTH-1:0] in_imag [15:0],
  input  logic [SHIFT_WIDTH-1:0] shift_amt_re,
  input  logic [SHIFT_WIDTH-1:0] shift_amt_im,

  output logic signed [OUT_WIDTH-1:0] out_real [15:0],
  output logic signed [OUT_WIDTH-1:0] out_imag [15:0]
);

  // 내부 변수
  logic signed [IN_WIDTH-1:0] shifted_r [15:0];
  logic signed [IN_WIDTH-1:0] shifted_i [15:0];

  // shift 연산
  always_comb begin
    for (int i = 0; i < 16; i++) begin
      shifted_r[i] = in_real[i] >>> shift_amt_re;
      shifted_i[i] = in_imag[i] >>> shift_amt_im;
    end
  end

  // saturation logic
  localparam signed [OUT_WIDTH-1:0] MAX_VAL =  (1 <<< (OUT_WIDTH-1)) - 1;  // +2047
  localparam signed [OUT_WIDTH-1:0] MIN_VAL = -(1 <<< (OUT_WIDTH-1));     // -2048

  always_comb begin
    for (int i = 0; i < 16; i++) begin
      // Real part saturation
      if (shifted_r[i] > MAX_VAL)
        out_real[i] = MAX_VAL;
      else if (shifted_r[i] < MIN_VAL)
        out_real[i] = MIN_VAL;
      else
        out_real[i] = shifted_r[i][OUT_WIDTH-1:0];

      // Imag part saturation
      if (shifted_i[i] > MAX_VAL)
        out_imag[i] = MAX_VAL;
      else if (shifted_i[i] < MIN_VAL)
        out_imag[i] = MIN_VAL;
      else
        out_imag[i] = shifted_i[i][OUT_WIDTH-1:0];
    end
  end

endmodule
