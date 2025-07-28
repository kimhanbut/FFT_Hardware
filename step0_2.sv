`timescale 1ns/1ps

module step0_2 (
  input  logic clk,
  input  logic rstn,
  input  logic din_valid,

  input  logic signed [12:0] din_add_r [0:15],
  input  logic signed [12:0] din_add_i [0:15],
  input  logic signed [12:0] din_sub_r [0:15],
  input  logic signed [12:0] din_sub_i [0:15],

  output logic valid_out,
  output logic signed [10:0] dout_add_r [0:15],  // ← 11bit
  output logic signed [10:0] dout_add_i [0:15],
  output logic signed [10:0] dout_sub_r [0:15],
  output logic signed [10:0] dout_sub_i [0:15]
);

  // ========================================================
  // 1. Shift Registers
  // ========================================================
  logic signed [12:0] sr64_dout_r [0:15];
  logic signed [12:0] sr64_dout_i [0:15];
  logic signed [12:0] sr128_dout_r [0:15];
  logic signed [12:0] sr128_dout_i [0:15];

  logic bufly_ctrl_add, bufly_ctrl_sub;

  // ADD 경로: 64-point shift
  shift_reg #(
    .DATA_WIDTH(13), .SIZE(4), .IN_SIZE(16)
  ) SR_64 (
    .clk(clk), .rstn(rstn),
    .din_valid(din_valid),
    .din_i(din_add_r), .din_q(din_add_i),
    .dout_i(sr64_dout_r), .dout_q(sr64_dout_i),
    .bufly_enable(bufly_ctrl_add)
  );

  // SUB 경로: 128-point shift
  shift_reg #(
    .DATA_WIDTH(13), .SIZE(8), .IN_SIZE(16)
  ) SR_128 (
    .clk(clk), .rstn(rstn),
    .din_valid(din_valid),
    .din_i(din_sub_r), .din_q(din_sub_i),
    .dout_i(sr128_dout_r), .dout_q(sr128_dout_i),
    .bufly_enable(bufly_ctrl_sub)
  );

  logic valid_bfly;
  assign valid_bfly = bufly_ctrl_sub;

  // ========================================================
  // 2. Butterfly + Twiddle
  // ========================================================
  logic signed [22:0] bfly02_add_r [0:15], bfly02_add_i [0:15];
  logic signed [22:0] bfly02_sub_r [0:15], bfly02_sub_i [0:15];

  butterfly02 u_butterfly02 (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_bfly),
    .input_real_a(sr64_dout_r),
    .input_imag_a(sr64_dout_i),
    .input_real_b(din_add_r),
    .input_imag_b(din_add_i),
    .valid_out(),
    .output_real_add(bfly02_add_r),
    .output_imag_add(bfly02_add_i),
    .output_real_diff(bfly02_sub_r),
    .output_imag_diff(bfly02_sub_i)
  );

  // ========================================================
  // 3. CBFP normalization
  // ========================================================
  logic signed [10:0] cbfp_add_r [0:15], cbfp_add_i [0:15];  // ← 수정: 11bit
  logic signed [10:0] cbfp_sub_r [0:15], cbfp_sub_i [0:15];
  logic valid_cbfp_add, valid_cbfp_sub;

  cbfp_module0 #(.IN_WIDTH(23), .OUT_WIDTH(11)) u_cbfp_add (
    .clk(clk), .rstn(rstn), .din_valid(valid_bfly),
    .pre_bfly02_real(bfly02_add_r),
    .pre_bfly02_imag(bfly02_add_i),
    .valid_out(valid_cbfp_add),
    .bfly02_real(cbfp_add_r),
    .bfly02_imag(cbfp_add_i)
  );

  cbfp_module0 #(.IN_WIDTH(23), .OUT_WIDTH(11)) u_cbfp_sub (
    .clk(clk), .rstn(rstn), .din_valid(valid_bfly),
    .pre_bfly02_real(bfly02_sub_r),
    .pre_bfly02_imag(bfly02_sub_i),
    .valid_out(valid_cbfp_sub),
    .bfly02_real(cbfp_sub_r),
    .bfly02_imag(cbfp_sub_i)
  );

  // ========================================================
  // 4. Output Registers
  // ========================================================
  assign valid_out = valid_cbfp_add & valid_cbfp_sub;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (int i = 0; i < 16; i++) begin
        dout_add_r[i] <= 0;
        dout_add_i[i] <= 0;
        dout_sub_r[i] <= 0;
        dout_sub_i[i] <= 0;
      end
    end else if (valid_out) begin
      for (int i = 0; i < 16; i++) begin
        dout_add_r[i] <= cbfp_add_r[i];
        dout_add_i[i] <= cbfp_add_i[i];
        dout_sub_r[i] <= cbfp_sub_r[i];
        dout_sub_i[i] <= cbfp_sub_i[i];
      end
    end
  end

endmodule
