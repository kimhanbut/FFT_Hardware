
`timescale 1ns/1ps

module cbfp_mag_detect #(
  parameter DATA_WIDTH = 23,   // 입력 비트 폭 (signed)
  parameter MAG_WIDTH  = 5     // 출력: leading 0 or 1 count index (0~22)
)(
  input  logic signed [DATA_WIDTH-1:0] din [0:15],
  output logic        [MAG_WIDTH-1:0]  mag_out [0:15]
);

  genvar i;
  generate
    for (i = 0; i < 16; i++) begin : MSB_COUNT
      logic [DATA_WIDTH-2:0] val; // 부호 비트 제외한 22비트
      logic sign;

      always_comb begin
        val  = din[i][DATA_WIDTH-2:0];
        sign = din[i][DATA_WIDTH-1];

        mag_out[i] =
          // 양수 (leading-zero count)
          (!sign && (val[21: 0] == 22'h000000)) ? 5'd22 :
          (!sign && (val[21: 1] == 21'h000000)) ? 5'd21 :
          (!sign && (val[21: 2] == 20'h00000 )) ? 5'd20 :
          (!sign && (val[21: 3] == 19'h0000  )) ? 5'd19 :
          (!sign && (val[21: 4] == 18'h0000  )) ? 5'd18 :
          (!sign && (val[21: 5] == 17'h0000  )) ? 5'd17 :
          (!sign && (val[21: 6] == 16'h0000  )) ? 5'd16 :
          (!sign && (val[21: 7] == 15'h0000  )) ? 5'd15 :
          (!sign && (val[21: 8] == 14'h0000  )) ? 5'd14 :
          (!sign && (val[21: 9] == 13'h0000  )) ? 5'd13 :
          (!sign && (val[21:10] == 12'h000   )) ? 5'd12 :
          (!sign && (val[21:11] == 11'h000   )) ? 5'd11 :
          (!sign && (val[21:12] == 10'h000   )) ? 5'd10 :
          (!sign && (val[21:13] ==  9'h000   )) ? 5'd9  :
          (!sign && (val[21:14] ==  8'h00    )) ? 5'd8  :
          (!sign && (val[21:15] ==  7'h00    )) ? 5'd7  :
          (!sign && (val[21:16] ==  6'h00    )) ? 5'd6  :
          (!sign && (val[21:17] ==  5'h00    )) ? 5'd5  :
          (!sign && (val[21:18] ==  4'h0     )) ? 5'd4  :
          (!sign && (val[21:19] ==  3'h0     )) ? 5'd3  :
          (!sign && (val[21:20] ==  2'h0     )) ? 5'd2  :
          (!sign && (val[21:21] ==  1'h0     )) ? 5'd1  :

          // 음수 (leading-one count)
          (sign && (val[21: 0] == 22'h3FFFFF)) ? 5'd22 :
          (sign && (val[21: 1] == 21'h1FFFFF)) ? 5'd21 :
          (sign && (val[21: 2] == 20'hFFFFF )) ? 5'd20 :
          (sign && (val[21: 3] == 19'h7FFFF )) ? 5'd19 :
          (sign && (val[21: 4] == 18'h3FFFF )) ? 5'd18 :
          (sign && (val[21: 5] == 17'h1FFFF )) ? 5'd17 :
          (sign && (val[21: 6] == 16'hFFFF )) ? 5'd16 :
          (sign && (val[21: 7] == 15'h7FFF )) ? 5'd15 :
          (sign && (val[21: 8] == 14'h3FFF )) ? 5'd14 :
          (sign && (val[21: 9] == 13'h1FFF )) ? 5'd13 :
          (sign && (val[21:10] == 12'hFFF )) ? 5'd12 :
          (sign && (val[21:11] == 11'h7FF )) ? 5'd11 :
          (sign && (val[21:12] == 10'h3FF )) ? 5'd10 :
          (sign && (val[21:13] ==  9'h1FF )) ? 5'd9  :
          (sign && (val[21:14] ==  8'hFF )) ? 5'd8  :
          (sign && (val[21:15] ==  7'h7F )) ? 5'd7  :
          (sign && (val[21:16] ==  6'h3F )) ? 5'd6  :
          (sign && (val[21:17] ==  5'h1F )) ? 5'd5  :
          (sign && (val[21:18] ==  4'hF  )) ? 5'd4  :
          (sign && (val[21:19] ==  3'h7  )) ? 5'd3  :
          (sign && (val[21:20] ==  2'h3  )) ? 5'd2  :
          (sign && (val[21:21] ==  1'h1  )) ? 5'd1  :

          5'd0; // fallback
      end
    end
  endgenerate

endmodule
