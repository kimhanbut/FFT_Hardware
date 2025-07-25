
`timescale 1ns / 1ps

module step0_1 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               din_valid,
    input  logic signed [ 9:0] din_add_r [0:15],
    input  logic signed [ 9:0] din_sub_r [0:15],
    input  logic signed [ 9:0] din_add_i [0:15],
    input  logic signed [ 9:0] din_sub_i [0:15],

    output logic signed [10:0] dout_add_r[0:15],
    output logic signed [10:0] dout_add_i[0:15],
    output logic signed [10:0] dout_sub_r[0:15],
    output logic signed [10:0] dout_sub_i[0:15]
);

    logic signed [9:0] sr16_din_i[0:15];
    logic signed [9:0] sr16_din_q[0:15];
    
    logic signed [9:0] sr16_dout_i[0:15];
    logic signed [9:0] sr16_dout_q[0:15];

    logic signed [9:0] sr8_dout_i[0:15];
    logic signed [9:0] sr8_dout_q[0:15];
    logic signed [9:0] sr_mux_i[0:15];
    logic signed [9:0] sr_mux_q[0:15];
    
    logic bufly_ctrl;
    logic clk_cnt;

    shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_128 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_i(din_add_r),  // 병렬 입력
        .din_q(din_add_i),
        .dout_i(sr16_dout_i),  // FIFO 가장 앞의 데이터
        .dout_q(sr16_dout_q),
        .bufly_enable()
    );


    shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(16),
        .IN_SIZE(16)
    ) SR_256 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_i(din_sub_r),  // 병렬 입력
        .din_q(din_sub_i),
        .dout_i(sr8_dout_i),  // FIFO 가장 앞의 데이터
        .dout_q(sr8_dout_q),
        .bufly_enable()
    );


    butterfly01 BF_1 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(),
        .input_real_a(),  // 입력 A의 실수부
        .input_imag_a(),  // 입력 A의 허수부
        .input_real_b(),  // 입력 B의 실수부
        .input_imag_b(),  // 입력 B의 허수부

        .valid_out(),  // 출력 유효 신호
        .output_real_add(),  // (A + B) × Twiddle 결과 (실수부)
        .output_imag_add(),  // (A + B) × Twiddle 결과 (허수부)
        .output_real_diff(),  // (A - B) × Twiddle 결과 (실수부)
        .output_imag_diff()  // (A - B) × Twiddle 결과 (허수부)
    );



    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            clk_cnt <= 0;
        end else begin
            clk_cnt <= clk_cnt + 1;
        end
    end


    always @(*) begin
        if(clk_cnt>=7 && clk_cnt<16)begin
            sr_mux_i =
            sr_mux_q =
        end
    end




endmodule
