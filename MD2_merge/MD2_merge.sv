`timescale 1ns/1ps

module step2_2(
	input logic clk,
	input logic rstn,
	input logic din_valid,
	input logic signed [12:0] din_i [0:15],
	input logic signed [12:0] din_q [0:15],
	input logic signed [4:0] index_1_re,
	input logic signed [4:0] index_1_im,
	input logic signed [4:0] index_2_re,
	input logic signed [4:0] index_2_im,

	output logic signed [12:0] dout_i [0:511],
	output logic signed [12:0] dout_q [0:511]
);

logic signed [13:0] bf20_dout_i [0:15];
logic signed [13:0] bf20_dout_q [0:15];


logic signed [15:0] bf21_dout_i [0:15];
logic signed [15:0] bf21_dout_q [0:15];

logic signed [12:0] bf22_dout_i [0:15];
logic signed [12:0] bf22_dout_q [0:15];

logic bf21_valid;
logic bf22_valid;
logic reorder_en;

// Butterfly20
butterfly20 BF_20 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(din_valid),
        .input_real(din_i),
        .input_imag(din_q),
        .valid_out(bf21_valid),
        .output_real(bf20_dout_i),
        .output_imag(bf20_dout_q)
);

// Butterfly21
butterfly21 BF_21 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bf21_valid),
        .input_real(bf20_dout_i),
        .input_imag(bf20_dout_q),
        .valid_out(bf22_valid),
        .output_real(bf21_dout_i),
        .output_imag(bf21_dout_q)
);

// Butterfly22
butterfly22 BF_22 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bf22_valid),
        .input_real(bf21_dout_i),
        .input_imag(bf21_dout_q),
	.index_1_re(index_1_re),
	.index_1_im(index_1_im),
	.index_2_re(index_2_re),
	.index_2_im(index_2_im),
        .valid_out(reorder_en),
        .output_real(bf22_dout_i),
        .output_imag(bf22_dout_q)
);

reorder u_reorder_i (
	.clk(clk),
	.rstn(rstn),
	.din(bf22_dout_i),
	.di_en(reorder_en),
	.dout(dout_i)
);

reorder u_reorder_q (
	.clk(clk),
	.rstn(rstn),
	.din(bf22_dout_q),
	.di_en(reorder_en),
	.dout(dout_q)
);

endmodule
