`timescale 1ns/1ps

module tb_step0_0;

  // DUT I/O
  logic clk, rstn, din_valid;
  logic [8:0] din_i [0:15];  // 병렬 입력
  logic [8:0] din_q [0:15];
  logic [9:0] dout_add_r [0:15]; // 덧셈 결과
  logic [9:0] dout_add_i [0:15];
  logic [9:0] dout_sub_r [0:15];
  logic [9:0] dout_sub_i [0:15];
  logic       bufly_enable; // count == SIZE일 때 1사이클 high

  int i, j;

  step0_0 DUT(
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .din_i     (din_i),
    .din_q     (din_q),
    .dout_add_r(dout_add_r),
    .dout_add_i(dout_add_i),
    .dout_sub_r(dout_sub_r),
    .dout_sub_i(dout_sub_i)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    clk = 0;
    rstn = 0;
    din_valid = 0;

    // 초기화
    for (i = 0; i < 16; i++) begin
      din_i[i] = 9'd0;
      din_q[i] = 9'd0;
    end

    // 리셋
    #10;
    rstn = 1;
    #10;

    @(negedge clk); // 동기화된 첫 네게티브 엣지에서 시작
    din_valid = 1;
    for (j = 0; j < 32; j++) begin
      for (i = 0; i < 16; i++) begin
        din_i[i] <= i + j * 16;
        din_q[i] <= 100 + i + j * 16;
      end
      
      @(negedge clk);  // 데이터 + valid 함께 유효
    end
    din_valid <= 0;



    // 버퍼 출력 기다림
    #50;

    if (bufly_enable) begin
      $display("=== bufly_enable asserted ===");
      for (i = 0; i < 16; i++) begin
        $display("dout_i[%0d] = %0d, dout_q[%0d] = %0d", i, dout_add_r[i], i, dout_add_i[i]);
      end
    end else begin
      $display("bufly_enable was never high. Check count logic.");
    end

    #50;
    $finish;
  end

endmodule
