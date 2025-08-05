
`timescale 1ns/1ps

module top_module (
    input logic clk,
    input logic rstn,
    input logic din_valid,
    input logic signed [8:0] din_i[0:15],
    input logic signed [8:0] din_q[0:15],
    output logic valid_out,
    output logic signed [12:0] dout_i[0:511], // CBFP 처리 후 최종 정규화된 출력
    output logic signed [12:0] dout_q[0:511]
);

logic out_valid_module0, out_valid_module1;

logic signed [10:0] module0_dout_i [0:15], module0_dout_q [0:15];
logic signed [11:0] module1_dout_i [0:15], module1_dout_q [0:15];


logic [4:0] shift_index1 [0:15];
logic [4:0] shift_index2 [0:15];


logic  [4:0] shift_index1_dly [0:14][0:15];  // ← 딜레이 15단계까지
logic  [4:0] shift_index2_dly [0:3][0:15];

logic din_valid_dly;
logic [6:0] clk_cnt;  // 0~100까지면 7비트면 충분


module0 MODULE0 (
    .clk                (clk),
    .rstn               (rstn),
    .din_valid          (din_valid),
    .din_i              (din_i),
    .din_q              (din_q),
    .valid_out          (out_valid_module0),
    .module0_dout_i     (module0_dout_i),
    .module0_dout_q     (module0_dout_q),
    .shift_index1       (shift_index1)
);




module1 MODULE1 (
    .clk                (clk),
    .rstn               (rstn),
    .din_valid          (out_valid_module0),
    .din_i              (module0_dout_i),
    .din_q              (module0_dout_q),
    .valid_out          (out_valid_module1),
    .module1_dout_i     (module1_dout_i),
    .module1_dout_q     (module1_dout_q),
    .shift_index2       (shift_index2)   
);




always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (int i = 0; i <= 14; i++) begin  // 변경된 깊이
            for (int j = 0; j < 16; j++) begin
                shift_index1_dly[i][j] <= 5'd0;
            end
        end
        for (int i = 0; i <= 3; i++) begin  // index2도 초기화
            for (int j = 0; j < 16; j++) begin
                shift_index2_dly[i][j] <= 5'd0;
            end
        end
    end else begin
        shift_index1_dly[0] <= shift_index1;
        for (int i = 1; i <= 14; i++) begin
            shift_index1_dly[i] <= shift_index1_dly[i-1];
        end

        shift_index2_dly[0] <= shift_index2;
        for (int i = 1; i <= 3; i++) begin
            shift_index2_dly[i] <= shift_index2_dly[i-1];
        end
    end
end



always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        din_valid_dly <= 1'b0;
        clk_cnt <= 7'd0;
    end else begin
        din_valid_dly <= din_valid;

        // rising edge 감지
        if (din_valid && !din_valid_dly) begin
            clk_cnt <= 7'd1;
        end else if (clk_cnt > 0 && clk_cnt < 7'd100) begin
            clk_cnt <= clk_cnt + 1;
        end
    end
end



step2_2 MODULE2 (
  .clk(clk),
  .rstn(rstn),
  .din_valid(out_valid_module1),
  .din_i(module1_dout_i),
  .din_q(module1_dout_q),
  .shift_index_1(shift_index1_dly[14]),
  .shift_index_2(shift_index2_dly[3]),

  .valid_out(valid_out),
  .dout_i(dout_i),
  .dout_q(dout_q)
);




endmodule


