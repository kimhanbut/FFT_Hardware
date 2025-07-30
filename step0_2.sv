`timescale 1ns/1ps

module step0_2(
	input logic clk,
	input logic rstn,
	input logic din_valid,
	input logic signed [8:0] din_i [0:15],
	input logic signed [8:0] din_q [0:15],
	output logic signed [22:0] dout_add_r [0:15],
	output logic signed [22:0] dout_add_i [0:15],
	output logic signed [22:0] dout_sub_r [0:15],
	output logic signed [22:0] dout_sub_i [0:15]
);

logic signed [8:0] shifted_bf00_input_i[0:15];
logic signed [8:0] shifted_bf00_input_q[0:15];

logic signed [9:0] bf00_dout_add_i[0:15];
logic signed [9:0] bf00_dout_add_q[0:15];
logic signed [9:0] bf00_dout_sub_i[0:15];
logic signed [9:0] bf00_dout_sub_q[0:15];

logic signed [9:0] bf01_din_add_i[0:15];
logic signed [9:0] bf01_din_add_q[0:15];
logic signed [9:0] bf01_din_sub_i[0:15];
logic signed [9:0] bf01_din_sub_q[0:15];

logic signed [12:0] bf01_dout_add_i[0:15];
logic signed [12:0] bf01_dout_add_q[0:15];
logic signed [12:0] bf01_dout_sub_i[0:15];
logic signed [12:0] bf01_dout_sub_q[0:15];

logic signed [12:0] bf02_din_add_i[0:15];
logic signed [12:0] bf02_din_add_q[0:15];
logic signed [12:0] bf02_din_sub_i[0:15];
logic signed [12:0] bf02_din_sub_q[0:15];

//logic signed [22:0] bf02_dout_add_i[0:15];
//logic signed [22:0] bf02_dout_add_q[0:15];
//logic signed [22:0] bf02_dout_sub_i[0:15];
//logic signed [22:0] bf02_dout_sub_q[0:15];

//muxed input

//between BF0 and BF1
logic signed [9:0] muxed_sr_128_input_i[0:15];
logic signed [9:0] muxed_sr_128_input_q[0:15];
logic signed [9:0] muxed_sr_256_output_i[0:15];
logic signed [9:0] muxed_sr_256_output_q[0:15];

//between BF1 and BF2
logic signed [12:0] muxed_sr_64_input_i[0:15];
logic signed [12:0] muxed_sr_64_input_q[0:15];
logic signed [12:0] muxed_sr_128_output_i[0:15];
logic signed [12:0] muxed_sr_128_output_q[0:15];


logic bf00_val;
logic bf01_val;
logic bf02_val;

// 1clk delayed bf00_val
logic delayed_bf00_val;

// 2clk delayed bf01_val
logic delayed_bf01_val;

logic bf00_sr_valid;
logic bf01_sr_valid;

// input 256 size Shift Register
shift_reg #(
        .DATA_WIDTH(9),
        .SIZE(16),
        .IN_SIZE(16)
    ) SR_IN_256 (
        .clk(clk),
        .rstn(rstn),
	.din_valid(din_valid),
        .din_i(din_i),
        .din_q(din_q),
        .dout_i(shifted_bf00_input_i),
        .dout_q(shifted_bf00_input_q),
        .bufly_enable(bf00_val)
);


// BF0, BF1 256 size Shift Register
shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(16),
        .IN_SIZE(16)
    ) SR_01_256 (
        .clk(clk),
        .rstn(rstn),
	.din_valid(bf00_sr_valid),
        .din_i(bf00_dout_sub_i),
        .din_q(bf00_dout_sub_q),
        .dout_i(muxed_sr_256_output_i),
        .dout_q(muxed_sr_256_output_q),
        .bufly_enable()
);

// BF0, BF1 128 size Shift Register
shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_01_128 (
        .clk(clk),
        .rstn(rstn),
	.din_valid(bf00_sr_valid),
        .din_i(muxed_sr_128_input_i),
        .din_q(muxed_sr_128_input_q),
        .dout_i(bf01_din_add_i),
        .dout_q(bf01_din_add_q),
        .bufly_enable(bf01_val)
);

// BF1, BF2 128 size Shift Register
shift_reg #(
        .DATA_WIDTH(13),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_12_128 (
        .clk(clk),
        .rstn(rstn),
	.din_valid(bf01_sr_valid),
        .din_i(bf01_dout_sub_i),
        .din_q(bf01_dout_sub_q),
        .dout_i(muxed_sr_128_output_i),
        .dout_q(muxed_sr_128_output_q),
        .bufly_enable()
);

// BF1, BF2 64 size Shift Register
shift_reg #(
        .DATA_WIDTH(13),
        .SIZE(4),
        .IN_SIZE(16)
    ) SR_12_64 (
        .clk(clk),
        .rstn(rstn),
	.din_valid(bf01_sr_valid),
        .din_i(muxed_sr_64_input_i),
        .din_q(muxed_sr_64_input_q),
        .dout_i(bf02_din_add_i),
        .dout_q(bf02_din_add_q),
        .bufly_enable(bf02_val)
);

// Butterfly00
butterfly00 BF_00 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bf00_val),
        .input_sr_real(shifted_bf00_input_i),
        .input_sr_imag(shifted_bf00_input_q),
        .input_org_real(din_i),
        .input_org_imag(din_q),
        .valid_out(delayed_bf00_val),
        .output_add_real(bf00_dout_add_i),
        .output_add_imag(bf00_dout_add_q),
        .output_sub_real(bf00_dout_sub_i),
        .output_sub_imag(bf00_dout_sub_q),
	.SR_valid(bf00_sr_valid)
);

// Butterfly01
butterfly01 BF_01 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bf01_val),
        .input_real_a(bf01_din_add_i),
        .input_imag_a(bf01_din_add_q),
        .input_real_b(bf01_din_sub_i),
        .input_imag_b(bf01_din_sub_q),
        .valid_out(delayed_bf01_val),
        .output_real_add(bf01_dout_add_i),
        .output_imag_add(bf01_dout_add_q),
        .output_real_diff(bf01_dout_sub_i),
        .output_imag_diff(bf01_dout_sub_q),
	.SR_valid(bf01_sr_valid)
);

// Butterfly02
butterfly02 BF_02 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bf02_val),
        .input_real_a(bf02_din_add_i),
        .input_imag_a(bf02_din_add_q),
        .input_real_b(bf02_din_sub_i),
        .input_imag_b(bf02_din_sub_q),
        .valid_out(),
        .output_real_add(dout_add_r),
        .output_imag_add(dout_add_i),
        .output_real_diff(dout_sub_r),
        .output_imag_diff(dout_sub_i)
);


always_comb begin
    for (int i = 0; i < 16; i++) begin

	muxed_sr_128_input_i[i] = (delayed_bf00_val) ? bf00_dout_add_i[i] : muxed_sr_256_output_i[i];
        muxed_sr_128_input_q[i] = (delayed_bf00_val) ? bf00_dout_add_q[i] : muxed_sr_256_output_q[i];
        muxed_sr_64_input_i[i] = (delayed_bf01_val) ? bf01_dout_add_i[i] : muxed_sr_128_output_i[i];
        muxed_sr_64_input_q[i] = (delayed_bf01_val) ? bf01_dout_add_q[i] : muxed_sr_128_output_q[i];


        bf01_din_sub_i[i] = (delayed_bf00_val) ? muxed_sr_128_input_i[i] : muxed_sr_256_output_i[i];
        bf01_din_sub_q[i] = (delayed_bf00_val) ? muxed_sr_128_input_q[i] : muxed_sr_256_output_q[i];
        bf02_din_sub_i[i] = (delayed_bf01_val) ? muxed_sr_64_input_i[i] : muxed_sr_128_output_i[i];
        bf02_din_sub_q[i] = (delayed_bf01_val) ? muxed_sr_64_input_q[i] : muxed_sr_128_output_q[i];
        
    end
end

endmodule
