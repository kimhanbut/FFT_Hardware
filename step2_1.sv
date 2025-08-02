`timescale 1ns / 1ps

module step2_1 (
    input logic               clk,
    input logic               rstn,
    input logic               din_valid,
    input logic signed [13:0] din_r[0:15],
    input logic signed [13:0] din_i[0:15],

    output logic              dout_valid,
    output logic signed [15:0] dout_r[0:15],
    output logic signed [15:0] dout_i[0:15]
);

    // 내부 신호
    logic       bfly_ctrl;
    logic [5:0] valid_cnt;
    logic       local_valid;
    logic local_valid_d1, local_valid_d2, local_valid_d3, local_valid_d4;

    assign dout_valid = local_valid_d4;

    // valid_cnt: 입력이 들어오면 32클럭 동안 local_valid 유지
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt   <= 0;
            local_valid <= 0;
        end else begin
            if (din_valid && valid_cnt == 0)
                valid_cnt <= 32;
            else if (valid_cnt > 0)
                valid_cnt <= valid_cnt - 1;

            local_valid <= (valid_cnt > 0);
        end
    end

    // local_valid → 4클럭 딜레이 → dout_valid
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            local_valid_d1 <= 0;
            local_valid_d2 <= 0;
            local_valid_d3 <= 0;
            local_valid_d4 <= 0;
        end else begin
            local_valid_d1 <= local_valid;
            local_valid_d2 <= local_valid_d1;
            local_valid_d3 <= local_valid_d2;
            local_valid_d4 <= local_valid_d3;
        end
    end

    // bfly_ctrl: 항상 butterfly 활성화
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            bfly_ctrl <= 0;
        else
            bfly_ctrl <= 1;  // reset 해제 이후 항상 1
    end
    // Butterfly 모듈 인스턴스
    butterfly21 BF_21 (
        .clk         (clk),
        .rstn        (rstn),
        .valid_in    (bfly_ctrl),      // 항상 1
        .input_real  (din_r),
        .input_imag  (din_i),
        .valid_out   (),               // 사용하지 않음
        .output_real (dout_r),
        .output_imag (dout_i)
    );

endmodule
