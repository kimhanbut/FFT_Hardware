
`timescale 1ns / 1ps

module module0 (
    input logic clk,
    input logic rstn,
    input logic din_valid,
    input logic signed [8:0] din_i[0:15],
    input logic signed [8:0] din_q[0:15],
    output logic valid_out,
    output logic signed [10:0] module0_dout_i[0:15], // CBFP 처리 후 최종 정규화된 출력
    output logic signed [10:0] module0_dout_q[0:15],
    output logic [4:0] shift_index1[0:15]
);

    logic signed [22:0] dout_add_r  [0:15];
    logic signed [22:0] dout_add_i  [0:15];
    logic signed [22:0] dout_sub_r  [0:15];
    logic signed [22:0] dout_sub_i  [0:15];

    logic signed [22:0] sr_out_sub_r[0:15];
    logic signed [22:0] sr_out_sub_i[0:15];

    logic signed [22:0] cbfp_in_r[0:15];
    logic signed [22:0] cbfp_in_i[0:15];

    logic        [ 5:0] valid_cnt;
    logic local_valid, valid_for_cbfp;





    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt   <= 0;
            local_valid <= 0;
        end else begin
            if (valid_for_cbfp && valid_cnt == 0) valid_cnt <= 35;
            else if (valid_cnt > 0) valid_cnt <= valid_cnt - 1;
            local_valid <= (valid_cnt > 0);
        end
    end



    step0_2 ALL_STEP (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_i(din_i),
        .din_q(din_q),
        .dout_add_r(dout_add_r),
        .dout_add_i(dout_add_i),
        .dout_sub_r(dout_sub_r),
        .dout_sub_i(dout_sub_i),
        .valid_out(valid_for_cbfp)
    );

    shift_reg #(
        .DATA_WIDTH(23),
        .SIZE(4),
        .IN_SIZE(16)
    ) SR_64 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(valid_for_cbfp | local_valid),
        .din_i(dout_sub_r),
        .din_q(dout_sub_i),
        .dout_i(sr_out_sub_r),
        .dout_q(sr_out_sub_i),
        .bufly_enable()
    );


    cbfp_module0 #(
        .IN_WIDTH   (23),
        .OUT_WIDTH  (11),
        .SHIFT_WIDTH(5),   // to represent 0~31
        .MAG_WIDTH  (5)
    ) CBFP_0 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(valid_for_cbfp | local_valid),  

        .pre_bfly02_real(cbfp_in_r),  // step0_2의 fft 곱셈 결과 입력
        .pre_bfly02_imag(cbfp_in_i),

        .valid_out  (valid_out), //아직 처리 못함 (cbfp 내보내는 로직 내부에서부터 끌어내서 처리해야 될 듯)
        .bfly02_real(module0_dout_i),  // CBFP 처리 후 최종 정규화된 출력
        .bfly02_imag(module0_dout_q),
        .shift_index(shift_index1)
    );

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            cbfp_in_r[i] = (valid_for_cbfp) ? dout_add_r[i] : sr_out_sub_r[i];
            cbfp_in_i[i] = (valid_for_cbfp) ? dout_add_i[i] : sr_out_sub_i[i];
        end
    end



endmodule
