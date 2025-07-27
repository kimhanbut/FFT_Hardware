`timescale 1ns / 1ps

module step0_1_tb;

    // Clock & Reset
    logic clk;
    logic rstn;

    // DUT I/O
    logic din_valid;
    logic signed [9:0] din_add_r [0:15];
    logic signed [9:0] din_add_i [0:15];
    logic signed [9:0] din_sub_r [0:15];
    logic signed [9:0] din_sub_i [0:15];

    logic signed [12:0] dout_add_r [0:15];
    logic signed [12:0] dout_add_i [0:15];
    logic signed [12:0] dout_sub_r [0:15];
    logic signed [12:0] dout_sub_i [0:15];

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Instantiate DUT
    step0_1 uut (
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

    // Stimulus task
	task apply_inputs(int cycle);
    		for (int i = 0; i < 16; i++) begin
        		din_add_r[i] = i + cycle;
        		din_add_i[i] = i + cycle + 1;
        		din_sub_r[i] = i - cycle;
        		din_sub_i[i] = i - cycle - 1;
    		end
	endtask

    // Simulation
    initial begin
        $display("=== step0_1 Testbench Start ===");
        rstn = 0;
        din_valid = 0;
        #20;
        rstn = 1;
        #10;

        // 16 valid cycles of input
        for (int t = 0; t < 16; t++) begin
            apply_inputs(t);
            din_valid = 1;
            #10;
        end

        // Idle
        din_valid = 0;
        #500;

        // Display some output
        $display("\n=== Final Output ===");
        for (int i = 0; i < 16; i++) begin
            $display("Index %2d | ADD_R: %d, ADD_I: %d | SUB_R: %d, SUB_I: %d", 
                i, dout_add_r[i], dout_add_i[i], dout_sub_r[i], dout_sub_i[i]);
        end

        $finish;
    end

endmodule

