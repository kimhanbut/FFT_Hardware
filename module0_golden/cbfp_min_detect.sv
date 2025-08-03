`timescale 1ns/1ps

module cbfp_min_detect #(
  parameter MAG_WIDTH = 6 // magnitude 값의 비트폭
)(
  input  logic [MAG_WIDTH-1:0] mag_in [0:15], // mag 에서 내보낸 index 데이터
  output logic [MAG_WIDTH-1:0] min_mag 
  // 16개 중 가장 작은 magnitude index -> 해당 블록에서 사용할 shift amount
);

  // Intermediate levels of comparator tree : 16 -> 8 -> 4 -> 2 -> 1 계층 트리
  logic [MAG_WIDTH-1:0] stage1 [7:0]; 
  logic [MAG_WIDTH-1:0] stage2 [3:0];
  logic [MAG_WIDTH-1:0] stage3 [1:0];

  // Stage 1: 16 → 8
  generate
    genvar i;
    for (i = 0; i < 8; i++) begin : STAGE1
      assign stage1[i] = (mag_in[2*i] < mag_in[2*i+1]) ? mag_in[2*i] : mag_in[2*i+1];
      // 2개씩 비교해서 작은 값을 stage1에 저장
    end
  endgenerate

  // Stage 2: 8 → 4
  generate
    for (i = 0; i < 4; i++) begin : STAGE2
      assign stage2[i] = (stage1[2*i] < stage1[2*i+1]) ? stage1[2*i] : stage1[2*i+1];
    end
  endgenerate

  // Stage 3: 4 → 2
  assign stage3[0] = (stage2[0] < stage2[1]) ? stage2[0] : stage2[1];
  assign stage3[1] = (stage2[2] < stage2[3]) ? stage2[2] : stage2[3];

  // Stage 4: 2 → 1
  assign min_mag = (stage3[0] < stage3[1]) ? stage3[0] : stage3[1];
  // 최종적으로 가장 작은 magnitude index를 min_mag에 저장
endmodule
