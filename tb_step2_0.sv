`timescale 1ns/1ps

module tb_step2_0;

    parameter CLK_PERIOD = 10;

    logic clk;
    logic rstn;
    logic din_valid;
    logic signed [12:0] din_r [0:15];
    logic signed [12:0] din_i [0:15];

    logic signed [13:0] dout_add_r[0:15];
    logic signed [13:0] dout_add_i[0:15];
    logic signed [13:0] dout_sub_r[0:15];
    logic signed [13:0] dout_sub_i[0:15];

    // DUT instantiation
    step2_0 dut (
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

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 0;
        rstn = 0;
        din_valid = 0;

        #20;
        rstn = 1;

        // Feed 32 cycles of valid input
        for (int t = 0; t < 32; t++) begin
            din_valid = 1;

            // Generate 16-point signed input data per cycle
            for (int i = 0; i < 16; i++) begin
                // random 9~12bit signed input
                din_r[i] = $random % (1 << 11);
                din_i[i] = $random % (1 << 11);
            end

            #CLK_PERIOD;

            // Display output (check on each cycle)
            $display("\n--- Cycle %0d ---", t);
            for (int k = 0; k < 16; k++) begin
                $display("OUT[%0d] ADD: %d + j%d   | SUB: %d + j%d", 
                    k, dout_add_r[k], dout_add_i[k], dout_sub_r[k], dout_sub_i[k]);
            end
        end

        din_valid = 0;

        // Hold for a few extra cycles
        #100;

        $finish;
    end

endmodule
