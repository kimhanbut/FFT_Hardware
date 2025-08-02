`timescale 1ns / 1ps

module cbfp_module1 #(
    parameter IN_WIDTH    = 25,
    parameter OUT_WIDTH   = 12,
    parameter SHIFT_WIDTH = 5,  // to represent 0~31
    parameter MAG_WIDTH   = SHIFT_WIDTH
) (
    input logic clk,
    input logic rstn,
    input logic din_valid, //butterfly의 local valid 받아야 될듯?

    input  logic signed [IN_WIDTH-1:0] pre_bfly12_real [0:15], // step0_2의 fft 곱셈 결과 입력
    input logic signed [IN_WIDTH-1:0] pre_bfly12_imag[0:15],

    output logic valid_out,
    output logic signed [OUT_WIDTH-1:0] bfly12_real [0:15], // CBFP 처리 후 최종 정규화된 출력
    output logic signed [OUT_WIDTH-1:0] bfly12_imag[0:15]
);

    // Intermediate magnitude wires
    logic [MAG_WIDTH-1:0] mag_r0[0:7];
    logic [MAG_WIDTH-1:0] mag_i0[0:7];
    logic [MAG_WIDTH-1:0] mag_r1[0:7];
    logic [MAG_WIDTH-1:0] mag_i1[0:7];


    
    logic signed [IN_WIDTH-1:0] r_upper[0:7];
    logic signed [IN_WIDTH-1:0] r_lower[0:7];
    logic signed [IN_WIDTH-1:0] i_upper[0:7];
    logic signed [IN_WIDTH-1:0] i_lower[0:7];


    logic signed [OUT_WIDTH-1:0] r_upper_cbfp[0:7];
    logic signed [OUT_WIDTH-1:0] r_lower_cbfp[0:7];
    logic signed [OUT_WIDTH-1:0] i_upper_cbfp[0:7];
    logic signed [OUT_WIDTH-1:0] i_lower_cbfp[0:7];

    
    // shift amount
    logic [SHIFT_WIDTH-1:0] min_r0;  
    logic [SHIFT_WIDTH-1:0] min_i0;
    logic [SHIFT_WIDTH-1:0] min_r1;  
    logic [SHIFT_WIDTH-1:0] min_i1;  



    ////////////////////////////////////////////////////////////////////
    ////// Operation Unit upper bit
    ////////////////////////////////////////////////////////////////////
    cbfp_mag_detect1 #(
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_REAL (
        .din(r_upper),
        .mag_out(mag_r0)
    );

    cbfp_mag_detect1 #(
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_IMAG (
        .din(i_upper),
        .mag_out(mag_i0)
    );

    // Minimum detect per block
    cbfp_min_detect1 #(
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_REAL (
        .mag_in (mag_r0),
        .min_mag(min_r0)
    );

    cbfp_min_detect1 #(
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_IMAG (
        .mag_in (mag_i0),
        .min_mag(min_i0)
    );


//=====================Lower bit==========================


    cbfp_mag_detect1 #(
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_REAL1 (
        .din(r_lower),
        .mag_out(mag_r1)
    );

    cbfp_mag_detect1 #(
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_IMAG1 (
        .din(i_lower),
        .mag_out(mag_i1)
    );

    // Minimum detect per block
    cbfp_min_detect1 #(
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_REAL1 (
        .mag_in (mag_r1),
        .min_mag(min_r1)
    );

    cbfp_min_detect1 #(
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_IMAG1 (
        .mag_in (mag_i1),
        .min_mag(min_i1)
    );


    // Shift + saturation 블럭단위(64개 입력 데이터)
    cbfp_shift #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH),
        .SHIFT_WIDTH(SHIFT_WIDTH),
	.DATA_NUM(8)
    ) U_SHIFT0 (
        .in_real(r_upper),
        .in_imag(i_upper),
        .shift_amt_re(min_r0),
        .shift_amt_im(min_i0),
        .out_real(r_upper_cbfp),
        .out_imag(i_upper_cbfp)
    );



    cbfp_shift #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH),
        .SHIFT_WIDTH(SHIFT_WIDTH),
	.DATA_NUM(8)
    ) U_SHIFT1 (
        .in_real(r_lower),
        .in_imag(i_lower),
        .shift_amt_re(min_r1),
        .shift_amt_im(min_i1),
        .out_real(r_lower_cbfp),
        .out_imag(i_lower_cbfp)
    );



    assign bfly12_real = {r_upper_cbfp, r_lower_cbfp};
    assign bfly12_imag = {i_upper_cbfp, i_lower_cbfp};


    always_comb begin
    for (int i = 0; i < 8; i++) begin
        r_upper[i] = pre_bfly12_real[i];
        r_lower[i] = pre_bfly12_real[i+8];
        i_upper[i] = pre_bfly12_real[i];
        i_lower[i] = pre_bfly12_real[i+8];
    end
end





    // valid passthrough (1:1 클럭 매칭)
    assign valid_out = din_valid;

endmodule




