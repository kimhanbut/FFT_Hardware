`timescale 1ns / 1ps

module step1_1 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               din_valid,
    input  logic signed [11:0] din_add_r [0:15],  // 입력 12bit
    input  logic signed [11:0] din_sub_r [0:15],
    input  logic signed [11:0] din_add_i [0:15],
    input  logic signed [11:0] din_sub_i [0:15],

    output logic signed [13:0] dout_r[0:15],
    output logic signed [13:0] dout_i[0:15]
);

    logic signed [11:0] sr1_din_i[0:15];
    logic signed [11:0] sr1_din_q[0:15];

    logic signed [11:0] sr2_dout_i[0:15];
    logic signed [11:0] sr2_dout_q[0:15];

    logic signed [11:0] sr1_dout_i[0:15];
    logic signed [11:0] sr1_dout_q[0:15];

    logic signed [11:0] bf_in_i[0:15];
    logic signed [11:0] bf_in_q[0:15];

    logic bfly_ctrl, bfly_ctrl_delay, sr_ctrl, sr_32_out_start;
    logic [4:0] clk_cnt;

    logic [5:0] valid_cnt;
    logic       local_valid;

    // 32 clk 짜리 valid
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt   <= 0;
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

    // 8-point Shift Register
    shift_reg #(
        .DATA_WIDTH(12),
        .SIZE(1),
        .IN_SIZE(16)
    ) SR_16 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(sr1_din_i),
        .din_q(sr1_din_q),
        .dout_i(sr1_dout_i),
        .dout_q(sr1_dout_q),
        .bufly_enable(bfly_ctrl)
    );

    // 16-point Shift Register
    shift_reg #(
        .DATA_WIDTH(12),
        .SIZE(2),
        .IN_SIZE(16)
    ) SR_32 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(din_sub_r),
        .din_q(din_sub_i),
        .dout_i(sr2_dout_i),
        .dout_q(sr2_dout_q),
        .bufly_enable(sr_32_out_start)
    );

    // Butterfly + fac8_0
    butterfly11 BF_11 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(local_valid),
        .input_real_a(sr1_dout_i),
        .input_imag_a(sr1_dout_q),
        .input_real_b(bf_in_i),
        .input_imag_b(bf_in_q),
        .valid_out(), // 사용하지 않음
        .output_real(dout_r),
        .output_imag(dout_i)
    );

    // Clock counter
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 0;
        else if (din_valid | local_valid)
            clk_cnt <= clk_cnt + 1;
        else
            clk_cnt <= clk_cnt;
    end

    // Input Mux Control
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sr1_din_i   <= '{default:0};
            sr1_din_q   <= '{default:0};
            bf_in_i     <= '{default:0};
            bf_in_q     <= '{default:0};
        end else begin
            if (clk_cnt < 2) begin
                sr1_din_i <= din_add_r;
                sr1_din_q <= din_add_i;
                bf_in_i   <= din_add_r;
                bf_in_q   <= din_add_i;
            end else if (clk_cnt >= 2) begin
                sr1_din_i <= sr2_dout_i;
                sr1_din_q <= sr2_dout_q;
                bf_in_i   <= sr2_dout_i;
                bf_in_q   <= sr2_dout_q;
            end else begin
                sr1_din_i <= '{default:0};
                sr1_din_q <= '{default:0};
                bf_in_i   <= '{default:0};
                bf_in_q   <= '{default:0};
            end
        end
    end

endmodule
