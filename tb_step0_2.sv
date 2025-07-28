`timescale 1ns/1ps

module tb_step0_2;

  // Parameters
  parameter DATA_WIDTH_IN  = 13;
  parameter DATA_WIDTH_OUT = 13;
  parameter CLK_PERIOD = 10;

  // DUT signals
  logic clk, rstn, din_valid;
  logic signed [DATA_WIDTH_IN-1:0] din_add_r [0:15];
  logic signed [DATA_WIDTH_IN-1:0] din_add_i [0:15];
  logic signed [DATA_WIDTH_IN-1:0] din_sub_r [0:15];
  logic signed [DATA_WIDTH_IN-1:0] din_sub_i [0:15];

  logic signed [DATA_WIDTH_OUT-1:0] dout_add_r [0:15];
  logic signed [DATA_WIDTH_OUT-1:0] dout_add_i [0:15];
  logic signed [DATA_WIDTH_OUT-1:0] dout_sub_r [0:15];
  logic signed [DATA_WIDTH_OUT-1:0] dout_sub_i [0:15];
  logic valid_out;

  // Instantiate the DUT
  step0_2 dut (
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .din_add_r(din_add_r),
    .din_add_i(din_add_i),
    .din_sub_r(din_sub_r),
    .din_sub_i(din_sub_i),
    .dout_add_r(dout_add_r),
    .dout_add_i(dout_add_i),
    .dout_sub_r(dout_sub_r),
    .dout_sub_i(dout_sub_i),
    .valid_out(valid_out)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Stimulus
  initial begin
    rstn = 0;
    din_valid = 0;
    #(3*CLK_PERIOD);
    rstn = 1;
    #(2*CLK_PERIOD);

    // Inject 40 cycles of data (arbitrary stimulus)
    repeat (40) begin
      din_valid = 1;
      for (int i = 0; i < 16; i++) begin
        din_add_r[i] = i;
        din_add_i[i] = i + 20;
        din_sub_r[i] = 100 - i;
        din_sub_i[i] = 50 - i;
      end
      #(CLK_PERIOD);
    end

    din_valid = 0;
    #(100*CLK_PERIOD);
    $finish;
  end

endmodule
