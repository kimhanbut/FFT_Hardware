
`timescale 1ns / 1ps
module butterfly00 #(
    parameter IN_DATA_W  = 9,
    parameter OUT_DATA_W = 10,
    parameter UNIT_SIZE  = 16,
    parameter CLK_CNT    = 16
) (
    input  logic                         clk,
    input  logic                         rstn,
    input  logic                         valid_in,
    input  logic signed [ IN_DATA_W-1:0] input_sr_real  [0:UNIT_SIZE-1],
    input  logic signed [ IN_DATA_W-1:0] input_sr_imag  [0:UNIT_SIZE-1],
    input  logic signed [ IN_DATA_W-1:0] input_org_real [0:UNIT_SIZE-1],
    input  logic signed [ IN_DATA_W-1:0] input_org_imag [0:UNIT_SIZE-1],
    output logic                         valid_out,
    output logic signed [OUT_DATA_W-1:0] output_add_real[0:UNIT_SIZE-1],
    output logic signed [OUT_DATA_W-1:0] output_add_imag[0:UNIT_SIZE-1],
    output logic signed [OUT_DATA_W-1:0] output_sub_real[0:UNIT_SIZE-1],
    output logic signed [OUT_DATA_W-1:0] output_sub_imag[0:UNIT_SIZE-1],
    output logic SR_valid
);

logic [5:0] sr_valid_cnt;
logic apply_minus_j; 

// SR_valid:다음 SR에 들어가는 din_valid 생성 
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) sr_valid_cnt <= 0;
    else if (valid_in)      sr_valid_cnt <= 17;
    else if (sr_valid_cnt != 0) sr_valid_cnt <= sr_valid_cnt - 1;
end

assign SR_valid = (sr_valid_cnt != 0);

logic [3:0] clk_cnt;
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) clk_cnt <= 0;
    else if (valid_in && clk_cnt < CLK_CNT) clk_cnt <= clk_cnt + 1;
end

logic valid_in_d;
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) valid_in_d <= 1'b0;
    else       valid_in_d <= valid_in;
end

assign valid_out = valid_in_d;

// 후반부 clk_cnt에서 -j 곱셈 적용
assign apply_minus_j = (clk_cnt >= (CLK_CNT/2));

logic signed [OUT_DATA_W-1:0] add_real[0:UNIT_SIZE-1], add_imag[0:UNIT_SIZE-1];
logic signed [OUT_DATA_W-1:0] sub_real[0:UNIT_SIZE-1], sub_imag[0:UNIT_SIZE-1];

// butterfly 덧셈/뺄셈 (조합)
always_comb begin
    for (int i = 0; i < CLK_CNT; i++) begin
        add_real[i] = input_sr_real[i] + input_org_real[i];
        add_imag[i] = input_sr_imag[i] + input_org_imag[i];
        sub_real[i] = input_sr_real[i] - input_org_real[i];
        sub_imag[i] = input_sr_imag[i] - input_org_imag[i];
    end
end

// 출력 레지스터, apply_minus_j 적용
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (int i = 0; i < CLK_CNT; i++) begin
            output_add_real[i] <= 0;
            output_add_imag[i] <= 0;
            output_sub_real[i] <= 0;
            output_sub_imag[i] <= 0;
        end
    end else if (valid_in) begin
        for (int i = 0; i < CLK_CNT; i++) begin
            output_add_real[i] <= add_real[i];
            output_add_imag[i] <= add_imag[i];

            if (apply_minus_j) begin
                output_sub_real[i] <= sub_imag[i];
                output_sub_imag[i] <= -sub_real[i];
            end else begin
                output_sub_real[i] <= sub_real[i];
                output_sub_imag[i] <= sub_imag[i];
            end
        end
    end
end

endmodule
