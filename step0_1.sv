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

    logic signed [9:0] sr8_din_i[0:15];
    logic signed [9:0] sr8_din_q[0:15];
    
    logic signed [9:0] sr16_dout_i[0:15];
    logic signed [9:0] sr16_dout_q[0:15];

    logic signed [9:0] sr8_dout_i[0:15];
    logic signed [9:0] sr8_dout_q[0:15];
    logic signed [9:0] sr_mux_i[0:15];
    logic signed [9:0] sr_mux_q[0:15];


    logic signed [9:0] bf_in_i[0:15];
    logic signed [9:0] bf_in_q[0:15];
    
    
    logic bufly_ctrl, sr_ctrl, sr_256_out_start;
    logic [4:0] clk_cnt;

    shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_128 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(sr_ctrl),//sr_256에서도 받아야 함
        .din_i(sr8_din_i),  // 병렬 입력
        .din_q(sr8_din_q),
        .dout_i(sr8_dout_i),  // FIFO 가장 앞의 데이터
        .dout_q(sr8_dout_q),
        .bufly_enable(bufly_ctrl)
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
        .dout_i(sr16_dout_i),  
        .dout_q(sr16_dout_q),
        .bufly_enable(sr_256_out_start)// sr_128에 주기 위해 필요함
    );


    butterfly01 BF_1 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bufly_ctrl),
        .input_real_a(sr8_dout_i),  // 입력 A의 실수부-sr
        .input_imag_a(sr8_dout_q),  // 입력 A의 허수부-sr
        .input_real_b(bf_in_i),  // 입력 B의 실수부-direct
        .input_imag_b(bf_in_q),  // 입력 B의 허수부-direct

        .valid_out(),  // 출력 유효 신호
        .output_real_add(dout_add_r),  // (A + B) × Twiddle 결과 (실수부)
        .output_imag_add(dout_add_i),  // (A + B) × Twiddle 결과 (허수부)
        .output_real_diff(dout_sub_r),  // (A - B) × Twiddle 결과 (실수부)
        .output_imag_diff(dout_sub_i)  // (A - B) × Twiddle 결과 (허수부)
    );



    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            clk_cnt <= 0;
        end else begin
            if(din_valid)begin
                clk_cnt<= clk_cnt + 1;
            end else
            clk_cnt <= 0;
        end
    end


    always @(*) begin
        if(clk_cnt<8)begin
            sr_ctrl = din_valid;
            sr8_din_i = din_add_r;
            sr8_din_q = din_add_i;
            bf_in_i = din_add_r;
            bf_in_q = din_add_i;

        end else if (clk_cnt>=8 && clk_cnt<16) begin
            sr_ctrl = sr_256_out_start;
            sr8_din_i = sr16_dout_i;
            sr8_din_q = sr16_dout_q;
            bf_in_i = sr16_dout_i;
            bf_in_q = sr16_dout_q;
        end else clk_cnt = 0;
    end




endmodule
