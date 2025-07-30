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


logic [5:0] sr_valid_cnt; // 6비트 카운터 (0~63, 32까지 충분)

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sr_valid_cnt <= 0;
    end else if (valid_in) begin
        sr_valid_cnt <= 16;  // valid_out이 1일 때 16로 세팅
    end else if (sr_valid_cnt != 0) begin
        sr_valid_cnt <= sr_valid_cnt - 1;
    end
end

assign SR_valid = (sr_valid_cnt != 0);
    

    logic [3:0] clk_cnt;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) clk_cnt <= 0;
        else if (valid_in && clk_cnt < CLK_CNT) clk_cnt <= clk_cnt + 1;
    end

    logic valid_in_d;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            valid_in_d <= 1'b0;
        else
            valid_in_d <= valid_in;
    end

    assign valid_out = valid_in_d;
    
    logic apply_minus_j = (clk_cnt >= (CLK_CNT/2));


    logic signed [OUT_DATA_W-1:0] add_real[0:UNIT_SIZE-1], add_imag[0:UNIT_SIZE-1];
    logic signed [OUT_DATA_W-1:0] sub_real[0:UNIT_SIZE-1], sub_imag[0:UNIT_SIZE-1];

    always_comb begin
        for (int i = 0; i < CLK_CNT; i++) begin
            add_real[i] = input_sr_real[i] + input_org_real[i];
            add_imag[i] = input_sr_imag[i] + input_org_imag[i];
            sub_real[i] = input_sr_real[i] - input_org_real[i];
            sub_imag[i] = input_sr_imag[i] - input_org_imag[i];
        end
    end

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
