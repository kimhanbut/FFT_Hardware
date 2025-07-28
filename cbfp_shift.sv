`timescale 1ns/1ps

module cbfp_shift #(
  parameter IN_WIDTH    = 23,
  parameter OUT_WIDTH   = 11,   // 11bit 출력 (signed)
  parameter SHIFT_WIDTH = 5     // shift amount: 0~31
)(
  input  logic signed [IN_WIDTH-1:0] in_real [0:15],
  input  logic signed [IN_WIDTH-1:0] in_imag [0:15],
  input  logic [SHIFT_WIDTH-1:0] shift_amt_re,
  input  logic [SHIFT_WIDTH-1:0] shift_amt_im,

  output logic signed [OUT_WIDTH-1:0] out_real [0:15],
  output logic signed [OUT_WIDTH-1:0] out_imag [0:15]
);

  // local constants for saturation
  localparam signed [OUT_WIDTH-1:0] MAX_VAL =  (1 <<< (OUT_WIDTH-1)) - 1;  // +1023
  localparam signed [OUT_WIDTH-1:0] MIN_VAL = -(1 <<< (OUT_WIDTH-1));     // -1024

  logic signed [IN_WIDTH-1:0] shifted_r [0:15];
  logic signed [IN_WIDTH-1:0] shifted_i [0:15];

  function automatic signed [OUT_WIDTH-1:0] saturate(input signed [IN_WIDTH-1:0] val);
    if (val > MAX_VAL)
      return MAX_VAL;
    else if (val < MIN_VAL)
      return MIN_VAL;
    else
      return val[OUT_WIDTH-1:0];  // truncate safely
  endfunction

  always_comb begin
    for (int i = 0; i < 16; i++) begin
      // --- Real shift ---
      if (shift_amt_re > 12)
        shifted_r[i] = in_real[i] <<< (shift_amt_re - 12);
      else
        shifted_r[i] = in_real[i] >>> (12 - shift_amt_re);

      // --- Imag shift ---
      if (shift_amt_im > 12)
        shifted_i[i] = in_imag[i] <<< (shift_amt_im - 12);
      else
        shifted_i[i] = in_imag[i] >>> (12 - shift_amt_im);

      // --- Saturation ---
      out_real[i] = saturate(shifted_r[i]);
      out_imag[i] = saturate(shifted_i[i]);
    end
  end

endmodule
