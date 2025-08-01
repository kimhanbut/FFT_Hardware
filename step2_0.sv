`timescale 1ns / 1ps

module step2_0 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               din_valid,
    input  logic signed [12:0] din_r [0:15], 
    input  logic signed [12:0] din_i [0:15],

    output logic signed [13:0] dout_r[0:15], 
    output logic signed [13:0] dout_i[0:15]
);

    logic local_valid;
    logic [5:0] valid_cnt;

    // 32클럭 유효 valid pulse 생성기
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt   <= 0;
            local_valid <= 0;
        end else begin
            if (din_valid && valid_cnt == 0)
                valid_cnt <= 6'd32;
            else if (valid_cnt > 0)
                valid_cnt <= valid_cnt - 1;

            local_valid <= (valid_cnt > 0);
        end
    end

    butterfly20 BF_20 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(din_valid | local_valid),
        .input_real(din_r),
        .input_imag(din_i),
        .valid_out(), // 사용하지 않음
        .output_real(dout_r),
        .output_imag(dout_i)
    );

endmodule
