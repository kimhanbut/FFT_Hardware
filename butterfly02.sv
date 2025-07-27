`timescale 1ns/1ps

module butterfly02 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,

    input  logic signed [12:0] bfly01_real_a [15:0], // from shift_reg
    input  logic signed [12:0] bfly01_imag_a [15:0],
    input  logic signed [12:0] bfly01_real_b [15:0], // from direct input
    input  logic signed [12:0] bfly01_imag_b [15:0],

    output logic         valid_out,
    output logic signed [12:0] bfly02_tmp_real [15:0],
    output logic signed [12:0] bfly02_tmp_imag [15:0],
    output logic signed [12:0] bfly02_tmp_real_sub [15:0],
    output logic signed [12:0] bfly02_tmp_imag_sub [15:0]
);

    localparam signed [12:0] MAX_13B =  13'sd4095;
    localparam signed [12:0] MIN_13B = -13'sd4096;

    logic signed [13:0] add_real [15:0], sub_real [15:0];
    logic signed [13:0] add_imag [15:0], sub_imag [15:0];

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            add_real[i] = bfly01_real_a[i] + bfly01_real_b[i];
            sub_real[i] = bfly01_real_a[i] - bfly01_real_b[i];
            add_imag[i] = bfly01_imag_a[i] + bfly01_imag_b[i];
            sub_imag[i] = bfly01_imag_a[i] - bfly01_imag_b[i];
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 1'b0;
            for (int i = 0; i < 16; i++) begin
                bfly02_tmp_real[i]      <= 13'sd0;
                bfly02_tmp_imag[i]      <= 13'sd0;
                bfly02_tmp_real_sub[i]  <= 13'sd0;
                bfly02_tmp_imag_sub[i]  <= 13'sd0;
            end
        end else begin
            valid_out <= valid_in;
            for (int i = 0; i < 16; i++) begin
                // add result with saturation
                if (add_real[i] > MAX_13B)       bfly02_tmp_real[i]     <= MAX_13B;
                else if (add_real[i] < MIN_13B)  bfly02_tmp_real[i]     <= MIN_13B;
                else                             bfly02_tmp_real[i]     <= add_real[i];

                if (add_imag[i] > MAX_13B)       bfly02_tmp_imag[i]     <= MAX_13B;
                else if (add_imag[i] < MIN_13B)  bfly02_tmp_imag[i]     <= MIN_13B;
                else                             bfly02_tmp_imag[i]     <= add_imag[i];

                // sub result with saturation
                if (sub_real[i] > MAX_13B)       bfly02_tmp_real_sub[i] <= MAX_13B;
                else if (sub_real[i] < MIN_13B)  bfly02_tmp_real_sub[i] <= MIN_13B;
                else                             bfly02_tmp_real_sub[i] <= sub_real[i];

                if (sub_imag[i] > MAX_13B)       bfly02_tmp_imag_sub[i] <= MAX_13B;
                else if (sub_imag[i] < MIN_13B)  bfly02_tmp_imag_sub[i] <= MIN_13B;
                else                             bfly02_tmp_imag_sub[i] <= sub_imag[i];
            end
        end
    end

endmodule
