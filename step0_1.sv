
`timescale 1ns / 1ps

module step0_1 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               din_valid,
    input  logic signed [ 9:0] din_add_r [0:15],
    input  logic signed [ 9:0] din_sub_r [0:15],
    input  logic signed [ 9:0] din_add_i [0:15],
    input  logic signed [ 9:0] din_sub_i [0:15],

    output logic signed [12:0] dout_add_r[0:15],
    output logic signed [12:0] dout_add_i[0:15],
    output logic signed [12:0] dout_sub_r[0:15],
    output logic signed [12:0] dout_sub_i[0:15]
);

    logic signed [9:0] sr8_din_i[0:15];
    logic signed [9:0] sr8_din_q[0:15];

    logic signed [9:0] sr16_dout_i[0:15];
    logic signed [9:0] sr16_dout_q[0:15];

    logic signed [9:0] sr8_dout_i[0:15];
    logic signed [9:0] sr8_dout_q[0:15];

    logic signed [9:0] bf_in_i[0:15];
    logic signed [9:0] bf_in_q[0:15];

    logic bfly_ctrl, bfly_ctrl_delay, sr_ctrl, sr_256_out_start;
    logic [4:0] clk_cnt;


logic [5:0] valid_cnt;
logic       local_valid;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_cnt   <= 0;
        local_valid <= 0;
	bfly_ctrl_delay <= 0;
    end else begin
        if (din_valid && valid_cnt == 0)
            valid_cnt <= 32;
        else if (valid_cnt > 0)
            valid_cnt <= valid_cnt - 1;

        local_valid <= (valid_cnt > 0);
	bfly_ctrl_delay <= bfly_ctrl;
    end
end



    // 8-point Shift Register
    shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_128 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(sr8_din_i),
        .din_q(sr8_din_q),
        .dout_i(sr8_dout_i),
        .dout_q(sr8_dout_q),
        .bufly_enable(bfly_ctrl)
    );

    // 16-point Shift Register
    shift_reg #(
        .DATA_WIDTH(10),
        .SIZE(16),
        .IN_SIZE(16)
    ) SR_256 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(din_sub_r),
        .din_q(din_sub_i),
        .dout_i(sr16_dout_i),
        .dout_q(sr16_dout_q),
        .bufly_enable(sr_256_out_start)
    );

    // Butterfly
    butterfly01 BF_1 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bfly_ctrl_delay),
        .input_real_a(sr8_dout_i),
        .input_imag_a(sr8_dout_q),
        .input_real_b(bf_in_i),
        .input_imag_b(bf_in_q),
        .valid_out(),
        .output_real_add(dout_add_r),
        .output_imag_add(dout_add_i),
        .output_real_diff(dout_sub_r),
        .output_imag_diff(dout_sub_i)
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

    // Sequential control to avoid latch
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sr8_din_i   <= '{default:0};
            sr8_din_q   <= '{default:0};
            bf_in_i     <= '{default:0};
            bf_in_q     <= '{default:0};
        end else begin
            if (clk_cnt < 16) begin
                sr8_din_i <= din_add_r;
                sr8_din_q <= din_add_i;
                bf_in_i   <= din_add_r;
                bf_in_q   <= din_add_i;
            end else if (clk_cnt >= 16) begin
                sr8_din_i <= sr16_dout_i;
                sr8_din_q <= sr16_dout_q;
                bf_in_i   <= sr16_dout_i;
                bf_in_q   <= sr16_dout_q;
            end else begin
                sr8_din_i <= '{default:0};
                sr8_din_q <= '{default:0};
                bf_in_i   <= '{default:0};
                bf_in_q   <= '{default:0};
            end
        end
    end

endmodule
