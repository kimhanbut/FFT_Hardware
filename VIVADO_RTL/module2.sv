`timescale 1ns/1ps

module step2_2(
   input logic clk,
   input logic rstn,
   input logic din_valid,
   input logic signed [11:0] din_i [0:15],
   input logic signed [11:0] din_q [0:15],
   input logic  [4:0] shift_index_1[0:15],
   input logic  [4:0] shift_index_2[0:15],

   output logic valid_out,
   output logic signed [12:0] dout_i [0:511],
   output logic signed [12:0] dout_q [0:511]
);

logic signed [12:0] bf20_dout_i [0:15];
logic signed [12:0] bf20_dout_q [0:15];

logic signed [14:0] bf21_dout_i [0:15];
logic signed [14:0] bf21_dout_q [0:15];

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
   .shift_index_1(shift_index_1),
   .shift_index_2(shift_index_2),
        .valid_out(reorder_en),
        .output_real(bf22_dout_i),
        .output_imag(bf22_dout_q)
);

reorder u_reorder_i (
   .clk(clk),
   .rstn(rstn),
   .din(bf22_dout_i),
   .di_en(reorder_en),
   .d_out(dout_i),
   .valid_out(valid_out)
);

reorder u_reorder_q (
   .clk(clk),
   .rstn(rstn),
   .din(bf22_dout_q),
   .di_en(reorder_en),
   .d_out(dout_q),
   .valid_out()
);

endmodule

