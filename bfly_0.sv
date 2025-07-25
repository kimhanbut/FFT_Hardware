`timescale 1ns / 1ps
module bf0_parallel #(
    parameter IN_DATA_W  = 9,
    parameter OUT_DATA_W = 10,
    parameter UNIT_SIZE  = 16,
    parameter CLK_CNT    = 16

) (
    input  logic                         clk,
    input  logic                         rstn,
    input  logic                         valid_in,
    input  logic signed [ IN_DATA_W-1:0] input_sr_real  [UNIT_SIZE-1:0],
    input  logic signed [ IN_DATA_W-1:0] input_sr_imag  [UNIT_SIZE-1:0],
    input  logic signed [ IN_DATA_W-1:0] input_org_real [UNIT_SIZE-1:0],
    input  logic signed [ IN_DATA_W-1:0] input_org_imag [UNIT_SIZE-1:0],
    output logic                         valid_out,
    output logic signed [OUT_DATA_W-1:0] output_add_real[UNIT_SIZE-1:0],
    output logic signed [OUT_DATA_W-1:0] output_add_imag[UNIT_SIZE-1:0],
    output logic signed [OUT_DATA_W-1:0] output_sub_real[UNIT_SIZE-1:0],
    output logic signed [OUT_DATA_W-1:0] output_sub_imag[UNIT_SIZE-1:0]
);

    // ========================
    // 1. 입력 레지스터 선언
    // ========================
    logic signed [IN_DATA_W-1:0] sr_real_reg [UNIT_SIZE-1:0];
    logic signed [IN_DATA_W-1:0] sr_imag_reg [UNIT_SIZE-1:0];
    logic signed [IN_DATA_W-1:0] org_real_reg[UNIT_SIZE-1:0];
    logic signed [IN_DATA_W-1:0] org_imag_reg[UNIT_SIZE-1:0];
    logic                        valid_reg;

    // ========================
    // 2. 입력 래치 (1클럭 지연)
    // ========================
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_reg <= 0;
        end else begin
            valid_reg <= valid_in;
            for (int i = 0; i < CLK_CNT; i++) begin
                sr_real_reg[i]  <= input_sr_real[i];
                sr_imag_reg[i]  <= input_sr_imag[i];
                org_real_reg[i] <= input_org_real[i];
                org_imag_reg[i] <= input_org_imag[i];
            end
        end
    end

    // ========================
    // 3. clk 카운터
    // ========================
    logic [3:0] clk_cnt;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) clk_cnt <= 0;
        else if (valid_reg && clk_cnt < CLK_CNT) clk_cnt <= clk_cnt + 1;
    end

    assign valid_out = (valid_reg && clk_cnt < CLK_CNT);
    wire apply_minus_j = (clk_cnt >= (CLK_CNT/2));

    // ========================
    // 4. 연산 (지연된 입력 기준)
    // ========================
    logic signed [OUT_DATA_W-1:0] add_real[UNIT_SIZE-1:0], add_imag[UNIT_SIZE-1:0];
    logic signed [OUT_DATA_W-1:0] sub_real[UNIT_SIZE-1:0], sub_imag[UNIT_SIZE-1:0];

    always_comb begin
        for (int i = 0; i < CLK_CNT; i++) begin
            add_real[i] = sr_real_reg[i] + org_real_reg[i];
            add_imag[i] = sr_imag_reg[i] + org_imag_reg[i];
            sub_real[i] = sr_real_reg[i] - org_real_reg[i];
            sub_imag[i] = sr_imag_reg[i] - org_imag_reg[i];
        end
    end

    // ========================
    // 5. 출력 레지스터
    // ========================
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < CLK_CNT; i++) begin
                output_add_real[i] <= 0;
                output_add_imag[i] <= 0;
                output_sub_real[i] <= 0;
                output_sub_imag[i] <= 0;
            end
        end else if (valid_reg) begin
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


