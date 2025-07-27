// pre_bfly02_generator.sv
// Description: Sequentially multiplies 512 complex inputs with twiddle factors from twf_0_rom

module pre_bfly02_generator (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [12:0] bfly02_tmp_real_in,
    input  logic signed [12:0] bfly02_tmp_imag_in,
    output logic         valid_out,
    output logic signed [22:0] pre_bfly02_real_out,
    output logic signed [22:0] pre_bfly02_imag_out
);

    logic [8:0] twf_addr;         // 0 to 511
    logic [3:0] twf_idx;          // 0 to 15
    logic [8:0] twf_base_addr;    // {twf_addr[8:4], 4'b0}
    logic signed [8:0] twf_re[15:0];
    logic signed [8:0] twf_im[15:0];
    logic signed [12:0] bfly02_real_data [15:0];
    logic signed [12:0] bfly02_imag_data [15:0];
    logic valid_reg;

    // twiddle ROM instance (8x64 = 512 twiddles)
    twf_0_rom u_twf_rom (
        .clk(clk),
        .rstn(rstn),
        .address(twf_base_addr),
        .twf_re(twf_re),
        .twf_im(twf_im)
    );

    // Address counter
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            twf_addr <= 0;
        end else if (valid_in) begin
            twf_addr <= twf_addr + 1;
        end
    end

    assign twf_base_addr = {twf_addr[8:4], 4'b0};
    assign twf_idx = twf_addr[3:0];

    // Registers to pass 1 sample into butterfly02_fixed as 16 replicated values
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            bfly02_real_data[i] = bfly02_tmp_real_in;
            bfly02_imag_data[i] = bfly02_tmp_imag_in;
        end
    end

    logic signed [22:0] out_re_all [15:0];
    logic signed [22:0] out_im_all [15:0];

    // Butterfly02 multiplication unit
    butterfly02_fixed u_bfly02_mult (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .bfly02_tmp_real(bfly02_real_data),
        .bfly02_tmp_imag(bfly02_imag_data),
        .twf_re(twf_re),
        .twf_im(twf_im),
        .valid_out(valid_out),
        .out_re(out_re_all),
        .out_im(out_im_all)
    );

    assign pre_bfly02_real_out = out_re_all[twf_idx];
    assign pre_bfly02_imag_out = out_im_all[twf_idx];

endmodule
