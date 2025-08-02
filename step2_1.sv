`timescale 1ns / 1ps

module step2_1 (
    input logic               clk,
    input logic               rstn,
    input logic               din_valid,
    input logic signed [13:0] din_r[0:15],
    input logic signed [13:0] din_i[0:15],

    output logic dout_valid,  // 출력 15bit
    output logic signed [15:0] dout_r[0:15],  // 출력 15bit
    output logic signed [15:0] dout_i[0:15]

);



    logic bfly_ctrl, bfly_ctrl_delay;

    logic [5:0] valid_cnt;
    logic       local_valid;
    logic local_valid_d1, local_valid_d2, local_valid_d3, local_valid_d4;

    assign dout_valid = local_valid_d4;

    // 32 clk 짜리 valid
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt <= 0;
            local_valid <= 0;
            bfly_ctrl_delay <= 0;
        end else begin
            if (din_valid && valid_cnt == 0) begin
                valid_cnt <= 32;
            end else if (valid_cnt > 0) begin
                valid_cnt <= valid_cnt - 1;
            end
            local_valid <= (valid_cnt > 0);
            bfly_ctrl_delay <= bfly_ctrl;
        end
    end


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            local_valid_d1 <= 1'b0;
            local_valid_d2 <= 1'b0;
	    local_valid_d3 <= 1'b0;
	    local_valid_d4 <= 1'b0;
        end else begin
            local_valid_d1 <= local_valid;
            local_valid_d2 <= local_valid_d1;
            local_valid_d3 <= local_valid_d2;
            local_valid_d4 <= local_valid_d3;
        end
    end




    butterfly21 BF_21 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bfly_ctrl),  // 입력 유효 신호
        .input_real(din_r),  // [0:15] 12bit signed
        .input_imag(din_i),

        .valid_out  (),  // 출력 유효 신호
        .output_real(dout_r),  // [0:15] 14bit signed
        .output_imag(dout_i)
    );


    // Input Mux Control

endmodule