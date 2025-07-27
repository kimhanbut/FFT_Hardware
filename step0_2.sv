`timescale 1ns/1ps

module step0_2 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         din_valid,

    input  logic signed [12:0] din_add_r [15:0],
    input  logic signed [12:0] din_add_i [15:0],
    input  logic signed [12:0] din_sub_r [15:0],
    input  logic signed [12:0] din_sub_i [15:0],

    output logic         valid_out,
    output logic signed [12:0] dout_add_r [15:0],
    output logic signed [12:0] dout_add_i [15:0],
    output logic signed [12:0] dout_sub_r [15:0],
    output logic signed [12:0] dout_sub_i [15:0]
);

    // --- 1. Shift Registers ---
    logic signed [12:0] sr8_din_r [15:0];
    logic signed [12:0] sr8_din_i [15:0];
    logic signed [12:0] sr8_dout_r[15:0];
    logic signed [12:0] sr8_dout_i[15:0];

    logic signed [12:0] sr16_dout_r[15:0];
    logic signed [12:0] sr16_dout_i[15:0];

    logic signed [12:0] bf_in_r [15:0];
    logic signed [12:0] bf_in_i [15:0];

    logic bufly_ctrl, sr_ctrl, sr_256_out_start;
    logic [4:0] clk_cnt;
    logic [5:0] valid_cnt;
    logic       local_valid;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_cnt   <= 0;
            local_valid <= 0;
        end else begin
            if (din_valid && valid_cnt == 0)
                valid_cnt <= 32;
            else if (valid_cnt > 0)
                valid_cnt <= valid_cnt - 1;

            local_valid <= (valid_cnt > 0);
        end
    end

    // 8-point Shift Register (add path)
    shift_reg #(
        .DATA_WIDTH(13),
        .SIZE(4),
        .IN_SIZE(16)
    ) SR_64 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(sr8_din_r),
        .din_q(sr8_din_i),
        .dout_i(sr8_dout_r),
        .dout_q(sr8_dout_i),
        .bufly_enable(bufly_ctrl)
    );

    // 16-point Shift Register (sub path)
    shift_reg #(
        .DATA_WIDTH(13),
        .SIZE(8),
        .IN_SIZE(16)
    ) SR_128 (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid | local_valid),
        .din_i(din_sub_r),
        .din_q(din_sub_i),
        .dout_i(sr16_dout_r),
        .dout_q(sr16_dout_i),
        .bufly_enable(sr_256_out_start)
    );

    // butterfly
    logic signed [12:0] bfly02_add_r [15:0], bfly02_add_i [15:0];
    logic signed [12:0] bfly02_sub_r [15:0], bfly02_sub_i [15:0];

    butterfly02 BF_2 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(bufly_ctrl),
        .bfly01_real_a(sr8_dout_r),
        .bfly01_imag_a(sr8_dout_i),
        .bfly01_real_b(bf_in_r),
        .bfly01_imag_b(bf_in_i),
        .valid_out(),
        .bfly02_tmp_real(bfly02_add_r),
        .bfly02_tmp_imag(bfly02_add_i),
        .bfly02_tmp_real_sub(bfly02_sub_r),
        .bfly02_tmp_imag_sub(bfly02_sub_i)
    );

    // clock counter
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 0;
        else if (din_valid)
            clk_cnt <= clk_cnt + 1;
    end

    // shift control logic
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sr_ctrl   <= 0;
            sr8_din_r <= '{default:0};
            sr8_din_i <= '{default:0};
            bf_in_r   <= '{default:0};
            bf_in_i   <= '{default:0};
        end else begin
            if (clk_cnt < 16) begin
                sr_ctrl   <= din_valid;
                sr8_din_r <= din_add_r;
                sr8_din_i <= din_add_i;
                bf_in_r   <= din_add_r;
                bf_in_i   <= din_add_i;
            end else begin
                sr_ctrl   <= sr_256_out_start;
                sr8_din_r <= sr16_dout_r;
                sr8_din_i <= sr16_dout_i;
                bf_in_r   <= sr16_dout_r;
                bf_in_i   <= sr16_dout_i;
            end
        end
    end

    // Twiddle ROM and complex multiplication
    logic [8:0] twf_addr;
    logic       twf_valid;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            twf_addr  <= 0;
            twf_valid <= 0;
        end else if (bufly_ctrl) begin
            twf_addr  <= twf_addr + 16;
            twf_valid <= 1;
        end else begin
            twf_valid <= 0;
        end
    end

    logic signed [8:0] twf_re [15:0];
    logic signed [8:0] twf_im [15:0];
    generate
        genvar i;
        for (i = 0; i < 16; i++) begin : TW_ROM
            twf_0_rom rom_i (
                .clk(clk), .rstn(rstn),
                .address(twf_addr + i),
                .twf_re(twf_re[i]),
                .twf_im(twf_im[i])
            );
        end
    endgenerate

    // Twiddle multiplication
    logic signed [22:0] pre_add_r [15:0], pre_add_i [15:0];
    logic signed [22:0] pre_sub_r [15:0], pre_sub_i [15:0];

    twiddle_mul u_twiddle_add (
        .data_re_in(bfly02_add_r),
        .data_im_in(bfly02_add_i),
        .twf_re_in(twf_re),
        .twf_im_in(twf_im),
        .data_re_out(pre_add_r),
        .data_im_out(pre_add_i)
    );

    twiddle_mul u_twiddle_sub (
        .data_re_in(bfly02_sub_r),
        .data_im_in(bfly02_sub_i),
        .twf_re_in(twf_re),
        .twf_im_in(twf_im),
        .data_re_out(pre_sub_r),
        .data_im_out(pre_sub_i)
    );

    // CBFP normalization
    cbfp_module0 #(
        .IN_WIDTH(23),
        .OUT_WIDTH(13),
        .SHIFT_WIDTH(5)
    ) u_cbfp_add (
        .clk(clk),
        .rstn(rstn),
        .din_valid(twf_valid),
        .pre_bfly02_real(pre_add_r),
        .pre_bfly02_imag(pre_add_i),
        .valid_out(),
        .bfly02_real(dout_add_r),
        .bfly02_imag(dout_add_i)
    );

    cbfp_module0 #(
        .IN_WIDTH(23),
        .OUT_WIDTH(13),
        .SHIFT_WIDTH(5)
    ) u_cbfp_sub (
        .clk(clk),
        .rstn(rstn),
        .din_valid(twf_valid),
        .pre_bfly02_real(pre_sub_r),
        .pre_bfly02_imag(pre_sub_i),
        .valid_out(valid_out),
        .bfly02_real(dout_sub_r),
        .bfly02_imag(dout_sub_i)
    );

endmodule
