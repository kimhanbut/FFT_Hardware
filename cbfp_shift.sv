`timescale 1ns/1ps

module cbfp_shift #(
  parameter IN_WIDTH  = 23,
  parameter OUT_WIDTH = 13,
  parameter SHIFT_WIDTH = 5
)(
  input  logic signed [IN_WIDTH-1:0] in_real [0:15],
  input  logic signed [IN_WIDTH-1:0] in_imag [0:15],
  input  logic [SHIFT_WIDTH-1:0] shift_amt_re,
  input  logic [SHIFT_WIDTH-1:0] shift_amt_im,

  output logic signed [OUT_WIDTH-1:0] out_real [0:15],
  output logic signed [OUT_WIDTH-1:0] out_imag [0:15]
);

  localparam signed [OUT_WIDTH-1:0] MAX_VAL =  (1 <<< (OUT_WIDTH-1)) - 1;
  localparam signed [OUT_WIDTH-1:0] MIN_VAL = -(1 <<< (OUT_WIDTH-1));

  logic signed [IN_WIDTH-1:0] shifted_r [0:15];
  logic signed [IN_WIDTH-1:0] shifted_i [0:15];

  always_comb begin
    for (int i = 0; i < 16; i++) begin
      // ----------- Real part shift ----------------
      if (shift_amt_re > 12)
        shifted_r[i] = (in_real[i] <<< shift_amt_re) >>> 12;
      else
        shifted_r[i] = in_real[i] >>> (12 - shift_amt_re);

      // Saturation for real
      if (shifted_r[i] > MAX_VAL)
        out_real[i] = MAX_VAL;
      else if (shifted_r[i] < MIN_VAL)
        out_real[i] = MIN_VAL;
      else
        out_real[i] = $signed(shifted_r[i]);

      // ----------- Imag part shift ----------------
      if (shift_amt_im > 12)
        shifted_i[i] = (in_imag[i] <<< shift_amt_im) >>> 12;
      else
        shifted_i[i] = in_imag[i] >>> (12 - shift_amt_im);

      // Saturation for imag
      if (shifted_i[i] > MAX_VAL)
        out_imag[i] = MAX_VAL;
      else if (shifted_i[i] < MIN_VAL)
        out_imag[i] = MIN_VAL;
      else
        out_imag[i] = $signed(shifted_i[i]);
    end
  end

endmodule
