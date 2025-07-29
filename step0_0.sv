
`timescale 1ns/1ps

module step0_0(
   input logic clk,
   input logic rstn,
   input logic din_valid,
   input logic signed [8:0] din_i [0:15],
   input logic signed [8:0] din_q [0:15],
   output logic signed [9:0] dout_add_r [0:15],
   output logic signed [9:0] dout_add_i [0:15],
   output logic signed [9:0] dout_sub_r [0:15],
   output logic signed [9:0] dout_sub_i [0:15]
);

logic signed [8:0] sr_dout_i[0:15];
logic signed [8:0] sr_dout_q[0:15];
logic bufly_ctrl;


shift_reg  #(
    .DATA_WIDTH(9),
    .SIZE (16),
    .IN_SIZE (16)
) SR_512 (
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .din_i (din_i),  // 병렬 입력
    .din_q (din_q),
    .dout_i(sr_dout_i), // FIFO 가장 앞의 데이터
    .dout_q(sr_dout_q),
    .bufly_enable(bufly_ctrl)   // count == SIZE일 때 1사이클 high
);


bf0_parallel #(
    .IN_DATA_W(9),
    .OUT_DATA_W(10),
    .UNIT_SIZE(16),
    .CLK_CNT(16)
)BF_0(
   .clk(clk),
   .rstn(rstn),
   .valid_in(bufly_ctrl),
   .input_sr_real (sr_dout_i),
   .input_sr_imag (sr_dout_q),
   .input_org_real(din_i),
   .input_org_imag(din_q),
   .valid_out(),
   .output_add_real(dout_add_r),
   .output_add_imag(dout_add_i),
   .output_sub_real(dout_sub_r),
   .output_sub_imag(dout_sub_i)
);

endmodule
