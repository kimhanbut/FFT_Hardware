`timescale 1ns / 1ps

module cbfp_module0 #(
    parameter IN_WIDTH    = 23,
    parameter OUT_WIDTH   = 11,
    parameter SHIFT_WIDTH = 5,  // to represent 0~31
    parameter MAG_WIDTH   = SHIFT_WIDTH
) (
    input logic clk,
    input logic rstn,
    input logic din_valid, //butterfly의 local valid 받아야 될듯?

    input  logic signed [IN_WIDTH-1:0] pre_bfly02_real [0:15], // step0_2의 fft 곱셈 결과 입력
    input logic signed [IN_WIDTH-1:0] pre_bfly02_imag[0:15],

    output logic valid_out,
    output logic signed [OUT_WIDTH-1:0] bfly02_real [0:15], // CBFP 처리 후 최종 정규화된 출력
    output logic signed [OUT_WIDTH-1:0] bfly02_imag[0:15],
	output logic [SHIFT_WIDTH-1:0] index1_re[0:15],
	output logic [SHIFT_WIDTH-1:0] index1_im[0:15]
);

    // Intermediate magnitude wires
    logic [MAG_WIDTH-1:0] mag_r[0:15];
    logic [MAG_WIDTH-1:0] mag_i[0:15];
    // === Internal valid window control ===
    logic [5:0] window_cnt;
    logic       valid_window;
    logic [3:0] valid_shift;

    logic [5:0] clk_cnt;

    // shift amount
    logic [SHIFT_WIDTH-1:0] min_re;  //4번 입력 받은 최솟값 중에 하나
    logic [SHIFT_WIDTH-1:0] min_im;

    logic [SHIFT_WIDTH-1:0] arr_min_re[0:3];  //4번 입력 받은 최솟값 중에 하나
    logic [SHIFT_WIDTH-1:0] arr_min_im[0:3];

    logic [SHIFT_WIDTH-1:0] final_min_re;  //최솟값 4개중에 제일 작은 값 -> shift 연산으로 들어감
    logic [SHIFT_WIDTH-1:0] final_min_im;

    logic signed [IN_WIDTH-1:0] sr_out_re[0:15];//shift reg 출력-> shift 연산으로 들어감
    logic signed [IN_WIDTH-1:0] sr_out_im[0:15];
    logic prev_din_valid;
    logic din_valid_rise;



    ////////////////////////////////////////////////////////////////////
    ////// Shift Register
    ///////////////////////////////////////////////////////////////////

    shift_reg #(
        .DATA_WIDTH(IN_WIDTH),
        .SIZE(5),
        .IN_SIZE(16)
    ) SR_64_CBFP (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_i(pre_bfly02_real),
        .din_q(pre_bfly02_imag),
        .dout_i(sr_out_re),
        .dout_q(sr_out_im),
        .bufly_enable()
    );



    ////////////////////////////////////////////////////////////////////
    ////// Operation Unit
    ////////////////////////////////////////////////////////////////////
    cbfp_mag_detect #(///이거는 16개 입력에 대해 바로바로 병렬 처리, 기존과 동일
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_REAL (
        .din(pre_bfly02_real),
        .mag_out(mag_r)
    );

    cbfp_mag_detect #(///이거는 16개 입력에 대해 바로바로 병렬 처리, 기존과 동일
        .DATA_WIDTH(IN_WIDTH),
        .MAG_WIDTH (MAG_WIDTH)
    ) U_MAG_IMAG (
        .din(pre_bfly02_imag),
        .mag_out(mag_i)
    );

    // Minimum detect per block
    cbfp_min_detect #(//여기서 나온 값을 4번 저장하고 그중에 최솟값을 찾음
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_REAL (
        .mag_in (mag_r),
        .min_mag(min_re)
    );

    cbfp_min_detect #(//여기서 나온 값을 4번 저장하고 그중에 최솟값을 찾음
        .MAG_WIDTH(MAG_WIDTH)
    ) U_MIN_IMAG (
        .mag_in (mag_i),
        .min_mag(min_im)
    );


    cbfp_final_min #(
        .WIDTH(5)
    ) FINAL_MIN (
        .clk(clk),
        .rstn(rstn),
        .in_re_min (arr_min_re),
        .in_im_min (arr_min_im),
        .clk_cnt(clk_cnt),
        .out_re_min(final_min_re),
        .out_im_min(final_min_im)
    );

    // Shift + saturation 블럭단위(64개 입력 데이터)
    cbfp_shift #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH),
        .SHIFT_WIDTH(SHIFT_WIDTH),
	    .DATA_NUM(16),
	    .SHIFT_POLE(12)
    ) U_CBFP_SHIFT (
        .in_real(sr_out_re),
        .in_imag(sr_out_im),
        .shift_amt_re(final_min_re),
        .shift_amt_im(final_min_im),
        .out_real(bfly02_real),
        .out_imag(bfly02_imag)
    );




    
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prev_din_valid <= 0;
        end else begin
            prev_din_valid <= din_valid;
        end
    end

    assign din_valid_rise = din_valid & ~prev_din_valid;


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            window_cnt   <= 0;
            valid_window <= 0;
        end else begin
            if (din_valid_rise) begin
                window_cnt   <= 6'd1;
                valid_window <= 1'b1;
            end else if (valid_window) begin
                if (window_cnt == 6'd32) begin
                    valid_window <= 1'b0;
                    window_cnt   <= 0;
                end else begin
                    window_cnt <= window_cnt + 1;
                end
            end
        end
    end


     always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            valid_shift <= 4'b0;
        else
            valid_shift <= {valid_shift[2:0], valid_window};
    end

    assign valid_out = valid_shift[3];  // 4클럭 지연된 valid_window



    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            clk_cnt <= 0;
        end else if (din_valid) begin
            clk_cnt <= clk_cnt + 1;
        end
    end


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 4; i++) begin
                arr_min_re[i] <= 31;  // init to max
                arr_min_im[i] <= 31;
            end
        end else if (din_valid) begin
            arr_min_re[clk_cnt[1:0]] <= min_re;
            arr_min_im[clk_cnt[1:0]] <= min_im;

            if (clk_cnt % 4 == 0) begin

            end
        end
    end
    
	always_ff @(posedge clk or negedge rstn) begin
	    if (!rstn) begin
	        for (int i = 0; i < 16; i++) begin
	            index1_re[i] <= '0;
	            index1_im[i] <= '0;
	        end
	    end else if (din_valid) begin
	        for (int i = 0; i < 16; i++) begin
	            index1_re[i] <= final_min_re;
	            index1_im[i] <= final_min_im;
	        end
	    end
	end



    // valid passthrough (1:1 클럭 매칭)
    
endmodule





module cbfp_final_min #(
    parameter WIDTH = 5
)(
    input  logic              clk,
    input  logic              rstn,
    input  logic [5:0]        clk_cnt,  // 입력 유효 신호
    input  logic [WIDTH-1:0]  in_re_min [0:3],
    input  logic [WIDTH-1:0]  in_im_min [0:3],
    output logic [WIDTH-1:0]  out_re_min,
    output logic [WIDTH-1:0]  out_im_min
);

    // Internal registers to hold final min
    logic [WIDTH-1:0] min_re, min_im;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            min_re <= {WIDTH{1'b1}};  // max
            min_im <= {WIDTH{1'b1}};
        end else if (clk_cnt % 4 ==0) begin
            // Compare 4 values for real
            min_re <= (in_re_min[0] <= in_re_min[1] ? in_re_min[0] : in_re_min[1]) <= 
                      (in_re_min[2] <= in_re_min[3] ? in_re_min[2] : in_re_min[3]) ?
                      (in_re_min[0] <= in_re_min[1] ? in_re_min[0] : in_re_min[1]) :
                      (in_re_min[2] <= in_re_min[3] ? in_re_min[2] : in_re_min[3]);

            // Compare 4 values for imag
            min_im <= (in_im_min[0] <= in_im_min[1] ? in_im_min[0] : in_im_min[1]) <= 
                      (in_im_min[2] <= in_im_min[3] ? in_im_min[2] : in_im_min[3]) ?
                      (in_im_min[0] <= in_im_min[1] ? in_im_min[0] : in_im_min[1]) :
                      (in_im_min[2] <= in_im_min[3] ? in_im_min[2] : in_im_min[3]);
        end
    end

    assign out_re_min = min_re;
    assign out_im_min = min_im;

endmodule
