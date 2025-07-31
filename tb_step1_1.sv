`timescale 1ns / 1ps

module tb_step1_1;

    logic clk, rstn, din_valid;
    logic signed [11:0] din_add_r [0:15];
    logic signed [11:0] din_add_i [0:15];
    logic signed [11:0] din_sub_r [0:15];
    logic signed [11:0] din_sub_i [0:15];

    logic signed [14:0] dout_add_r [0:15];
    logic signed [14:0] dout_add_i [0:15];
    logic signed [14:0] dout_sub_r [0:15];
    logic signed [14:0] dout_sub_i [0:15];

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    step1_1 dut (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_add_r(din_add_r),
        .din_add_i(din_add_i),
        .din_sub_r(din_sub_r),
        .din_sub_i(din_sub_i),
        .dout_add_r(dout_add_r),
        .dout_add_i(dout_add_i),
        .dout_sub_r(dout_sub_r),
        .dout_sub_i(dout_sub_i)
    );

    // Test sequence
    initial begin
        clk = 0;
        rstn = 0;
        din_valid = 0;
        repeat (3) @(posedge clk);
        rstn = 1;

        // 32 cycles of input
        for (int cycle = 0; cycle < 32; cycle++) begin
            @(posedge clk);
            din_valid = 1;
            for (int i = 0; i < 16; i++) begin
                din_add_r[i] = $random % 4096 - 2048;
                din_add_i[i] = $random % 4096 - 2048;
                din_sub_r[i] = $random % 4096 - 2048;
                din_sub_i[i] = $random % 4096 - 2048;
            end
        end

        // Stop input
        @(posedge clk);
        din_valid = 0;

        // Wait for any final outputs
        repeat (20) @(posedge clk);
        $finish;
    end

    // Output monitor
    always_ff @(posedge clk) begin
        if (dut.bfly_ctrl_delay) begin
            $display("\n[CLK %0t] Output (butterfly11):", $time);
            for (int i = 0; i < 16; i++) begin
                $display("  ADD[%0d] = %0d + j%0d | SUB[%0d] = %0d + j%0d",
                    i, dout_add_r[i], dout_add_i[i],
                    i, dout_sub_r[i], dout_sub_i[i]
                );
            end
        end
    end

endmodule
