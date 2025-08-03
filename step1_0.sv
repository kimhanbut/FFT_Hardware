`timescale 1ns / 1ps

module step1_0 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               din_valid,
    input  logic signed [10:0] din_r [0:15],  // 512개 입력 (Q12)
    input  logic signed [10:0] din_i [0:15],

    output logic 	       dout_valid,
    output logic signed [11:0] dout_add_r[0:15], // A+B
    output logic signed [11:0] dout_add_i[0:15],
    output logic signed [11:0] dout_sub_r[0:15], // A−B
    output logic signed [11:0] dout_sub_i[0:15]
);

    // 앞 32포인트(2clk 값)를 저장하는 shift_reg
    logic signed [10:0] sr_dout_r [0:15];
    logic signed [10:0] sr_dout_i [0:15];

    logic bufly_enable, bufly_enable_dly;


    // 32클럭 유효 valid pulse 생성기
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
	    bufly_enable_dly <=0;
        end else begin
	    bufly_enable_dly <= bufly_enable;
        end
    end

    shift_reg1 #(
        .DATA_WIDTH(11),
        .SIZE(3),
        .IN_SIZE(16)
    ) SR_32 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(din_r),
        .din_q(din_i),
        .dout_i(sr_dout_r),
        .dout_q(sr_dout_i),
        .bufly_enable(bufly_enable) // count == SIZE 일때 1사이클 high
    );

    // 버터플라이 연산 (512포인트 중 A = 저장된 앞, B = 현재 입력)
    butterfly10 #(
        .CLK_CNT(2)
    ) BF_10 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bufly_enable_dly),
        .input_real_a(sr_dout_r),
        .input_imag_a(sr_dout_i),
        .input_real_b(din_r),
        .input_imag_b(din_i),

	.valid_out(dout_valid),
        .output_real_add(dout_add_r),
        .output_imag_add(dout_add_i),
        .output_real_diff(dout_sub_r),
        .output_imag_diff(dout_sub_i)
    );



endmodule
