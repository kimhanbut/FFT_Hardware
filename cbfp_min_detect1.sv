
`timescale 1ns/1ps

module cbfp_min_detect1 #(
  parameter MAG_WIDTH = 5,     // magnitude 값의 비트폭
  parameter DATA_NUM  = 8      // 입력 데이터 개수
)(
  input  logic [MAG_WIDTH-1:0] mag_in [0:DATA_NUM-1], // magnitude index 입력
  output logic [MAG_WIDTH-1:0] min_mag                // 최솟값 출력
);

  // Comparator tree: 8 → 4 → 2 → 1
  logic [MAG_WIDTH-1:0] stage1 [3:0];
  logic [MAG_WIDTH-1:0] stage2 [1:0];

  // Stage 1: 8 → 4
  generate
    genvar i;
    for (i = 0; i < 4; i++) begin : STAGE1
      assign stage1[i] = (mag_in[2*i] < mag_in[2*i+1]) ? mag_in[2*i] : mag_in[2*i+1];
    end
  endgenerate

  // Stage 2: 4 → 2
  assign stage2[0] = (stage1[0] < stage1[1]) ? stage1[0] : stage1[1];
  assign stage2[1] = (stage1[2] < stage1[3]) ? stage1[2] : stage1[3];

  // Stage 3: 2 → 1
  assign min_mag = (stage2[0] < stage2[1]) ? stage2[0] : stage2[1];

endmodule
