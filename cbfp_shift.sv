`timescale 1ns / 1ps

module cbfp_shift #(
    parameter IN_WIDTH    = 23,
    parameter OUT_WIDTH   = 11,   // 11bit 출력 (signed)
    parameter SHIFT_WIDTH = 5,     // shift amount: 0~31
    parameter DATA_NUM = 16,
    parameter SHIFT_POLE = 12
) (
    input logic signed [IN_WIDTH-1:0] in_real[0:DATA_NUM-1],
    input logic signed [IN_WIDTH-1:0] in_imag[0:DATA_NUM-1],
    input logic [SHIFT_WIDTH-1:0] shift_amt_re,
    input logic [SHIFT_WIDTH-1:0] shift_amt_im,

    output logic signed [OUT_WIDTH-1:0] out_real[0:DATA_NUM-1],
    output logic signed [OUT_WIDTH-1:0] out_imag[0:DATA_NUM-1]
);

    // local constants for saturation
    localparam signed [OUT_WIDTH-1:0] MAX_VAL =  (1 <<< (OUT_WIDTH-1)) - 1;  // +1023
    localparam signed [OUT_WIDTH-1:0] MIN_VAL = -(1 <<< (OUT_WIDTH-1));     // -1024

    logic signed [IN_WIDTH-1:0] shifted_r[0:DATA_NUM-1];
    logic signed [IN_WIDTH-1:0] shifted_i[0:DATA_NUM-1];

    logic [SHIFT_WIDTH-1:0] shift_amt_abs;


    always@(*) begin
	    if(shift_amt_re > shift_amt_im)begin
		    shift_amt_abs = shift_amt_im;
	    end else begin
		    shift_amt_abs = shift_amt_re;
	    end
    end



    function automatic signed [OUT_WIDTH-1:0] saturate(
        input signed [IN_WIDTH-1:0] val);
        if (val > MAX_VAL) return MAX_VAL;
        else if (val < MIN_VAL) return MIN_VAL;
        else return val[OUT_WIDTH-1:0];  // truncate safely
    endfunction

    always_comb begin//여기서 clk_cnt를 받아서 clk_cnt%4 ==0 일때만 shift를 진행하도록 한다면?
        for (int i = 0; i < DATA_NUM; i++) begin
            // --- shift ---
	    if (shift_amt_abs > 12) begin
                shifted_r[i] = in_real[i] <<< (shift_amt_abs - SHIFT_POLE);
                shifted_i[i] = in_imag[i] <<< (shift_amt_abs - SHIFT_POLE);
	end else begin 
		shifted_r[i] = in_real[i] >>> (SHIFT_POLE - shift_amt_abs);
            	shifted_i[i] = in_imag[i] >>> (SHIFT_POLE - shift_amt_abs);
	end


            // --- Saturation ---
            out_real[i] = saturate(shifted_r[i]);
            out_imag[i] = saturate(shifted_i[i]);
        end
    end

endmodule
