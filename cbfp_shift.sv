`timescale 1ns/1ps

module cbfp_shift #(
  parameter IN_WIDTH  = 23,
  parameter OUT_WIDTH = 13,
  parameter SHIFT_WIDTH = 5  // shift amount 의 최대 표현 비트수
)(
  input  logic signed [IN_WIDTH-1:0] in_real [15:0],
  input  logic signed [IN_WIDTH-1:0] in_imag [15:0], // pre_bfly02에서 나온 결과값 : CBFP에 입력되는 값
  input  logic [SHIFT_WIDTH-1:0] shift_amt_re, // 쉬프트 얼마나 할지 : shift amount
  input  logic [SHIFT_WIDTH-1:0] shift_amt_im,

  output logic signed [OUT_WIDTH-1:0] out_real [15:0], // shift, saturation 후 출력
  output logic signed [OUT_WIDTH-1:0] out_imag [15:0]
);

  // 내부 변수
  logic signed [IN_WIDTH-1:0] shifted_r [15:0]; // shift 된 값
  logic signed [IN_WIDTH-1:0] shifted_i [15:0];

  // shift 연산
  always_comb begin
    for (int i = 0; i < 16; i++) begin
      shifted_r[i] = in_real[i] >>> shift_amt_re;
      shifted_i[i] = in_imag[i] >>> shift_amt_im;
    end
  end // signed 부호 유지, block 단위 shift_amt 공유 하여 산술 right shift

  // saturation 
  localparam signed [OUT_WIDTH-1:0] MAX_VAL =  (1 <<< (OUT_WIDTH-1)) - 1;  // +4095
  localparam signed [OUT_WIDTH-1:0] MIN_VAL = -(1 <<< (OUT_WIDTH-1));     // -4096

  always_comb begin
    for (int i = 0; i < 16; i++) begin
      // Real part saturation
      if (shifted_r[i] > MAX_VAL)  // shift 한 23비트 signed 값이 +4095를 넘어가면
        out_real[i] = MAX_VAL; // 값이 넘어가면 +4095로 saturation
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
