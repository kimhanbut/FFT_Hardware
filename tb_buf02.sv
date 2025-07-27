`timescale 1ns/1ps

module pre_bfly02_generator_tb;

    logic clk;
    logic rstn;
    logic valid_in;
    logic signed [13:0] bfly02_tmp_real_in;
    logic signed [13:0] bfly02_tmp_imag_in;
    logic valid_out;
    logic signed [22:0] pre_bfly02_real_out;
    logic signed [22:0] pre_bfly02_imag_out;

    int input_cnt = 0;
    int output_cnt = 0;

    // Instantiate DUT
    pre_bfly02_generator dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .bfly02_tmp_real_in(bfly02_tmp_real_in),
        .bfly02_tmp_imag_in(bfly02_tmp_imag_in),
        .valid_out(valid_out),
        .pre_bfly02_real_out(pre_bfly02_real_out),
        .pre_bfly02_imag_out(pre_bfly02_imag_out)
    );

    // Clock generation: 100MHz
    always #5 clk = ~clk;

    // Input stimulus
    initial begin
        clk = 0;
        rstn = 0;
        valid_in = 0;
        bfly02_tmp_real_in = 14'sd0;
        bfly02_tmp_imag_in = 14'sd0;

        // Global reset
        repeat (4) @(negedge clk);
        rstn = 1;

        // Apply 512 complex inputs
        for (int i = 0; i < 512; i++) begin
            @(negedge clk);
            valid_in = 1;
            bfly02_tmp_real_in = 14'sd100 + i;
            bfly02_tmp_imag_in = -14'sd50 + i;
            input_cnt++;
        end

        // Deassert input
        @(negedge clk);
        valid_in = 0;

        // Wait for pipeline to flush
        repeat (40) @(negedge clk);

        $display("=== Simulation Done ===");
        $display("Input count  = %0d", input_cnt);
        $display("Output count = %0d", output_cnt);
        $finish;
    end

    // Output monitor
    always_ff @(posedge clk) begin
        if (valid_out) begin
            output_cnt++;
            $display("[OUT #%0d @ %0t ns] Real = %0d, Imag = %0d",
                     output_cnt, $time, pre_bfly02_real_out, pre_bfly02_imag_out);
        end
    end

endmodule
