`timescale 1ns/1ps

module tb_cbfp_module0;

  parameter IN_WIDTH  = 23;
  parameter OUT_WIDTH = 13;
  parameter SHIFT_WIDTH = 5;

  logic clk, rstn, din_valid;
  logic signed [IN_WIDTH-1:0] pre_bfly02_real [0:15];
  logic signed [IN_WIDTH-1:0] pre_bfly02_imag [0:15];
  logic signed [OUT_WIDTH-1:0] bfly02_real [0:15];
  logic signed [OUT_WIDTH-1:0] bfly02_imag [0:15];
  logic valid_out;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT instantiation
  cbfp_module0 #(
    .IN_WIDTH(IN_WIDTH),
    .OUT_WIDTH(OUT_WIDTH),
    .SHIFT_WIDTH(SHIFT_WIDTH)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .pre_bfly02_real(pre_bfly02_real),
    .pre_bfly02_imag(pre_bfly02_imag),
    .valid_out(valid_out),
    .bfly02_real(bfly02_real),
    .bfly02_imag(bfly02_imag)
  );

  // Stimulus
  initial begin
    rstn = 0;
    din_valid = 0;
    #20;
    rstn = 1;
    #10;

    // Prepare input
    for (int i = 0; i < 16; i++) begin
      pre_bfly02_real[i] = (i < 8) ? 7936 : -7936;  // large positive/negative
      pre_bfly02_imag[i] = (i % 2 == 0) ? 1234 : -5678;
    end

    din_valid = 1;
    #10;
    din_valid = 0;

    // Observe result
    #100;
    $finish;
  end

endmodule
