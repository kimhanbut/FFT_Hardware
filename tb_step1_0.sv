`timescale 1ns/1ps

module tb_step1_0;

    logic clk, rstn, din_valid;
    logic signed [10:0] din_r [0:15];
    logic signed [10:0] din_i [0:15];

    logic signed [11:0] dout_add_r [0:15];
    logic signed [11:0] dout_add_i [0:15];
    logic signed [11:0] dout_sub_r [0:15];
    logic signed [11:0] dout_sub_i [0:15];

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    step1_0 dut (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_r(din_r),
        .din_i(din_i),
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

        // Send 32 clocks of data (for 512-point input)
        for (int cycle = 0; cycle < 32; cycle++) begin
            @(posedge clk);
            din_valid = 1;
            for (int i = 0; i < 16; i++) begin
                din_r[i] = $random % 1024 - 512; // signed 11-bit range
                din_i[i] = $random % 1024 - 512;
            end
        end

        // Stop input
        @(posedge clk);
        din_valid = 0;

        // Wait for output to finish
        repeat (10) @(posedge clk);
        $finish;
    end

    // Monitor outputs
    always_ff @(posedge clk) begin
        if (dut.bufly_enable) begin
            $display("[CLK %0t] Butterfly10 Output:", $time);
            for (int i = 0; i < 16; i++) begin
                $display("  ADD[%0d] = %0d + j%0d | SUB[%0d] = %0d + j%0d",
                    i, dout_add_r[i], dout_add_i[i],
                    i, dout_sub_r[i], dout_sub_i[i]
                );
            end
            $display("-------------------------------");
        end
    end

endmodule
