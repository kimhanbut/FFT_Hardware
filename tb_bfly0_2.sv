
`timescale 1ns/1ps

module tb_butterfly02;

    logic clk;
    logic rstn;
    logic valid_in;

    logic signed [12:0] input_real_a[0:15];
    logic signed [12:0] input_imag_a[0:15];
    logic signed [12:0] input_real_b[0:15];
    logic signed [12:0] input_imag_b[0:15];

    logic valid_out;
    logic signed [22:0] output_real_add[0:15];
    logic signed [22:0] output_imag_add[0:15];
    logic signed [22:0] output_real_diff[0:15];
    logic signed [22:0] output_imag_diff[0:15];

    butterfly02 dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .input_real_a(input_real_a),
        .input_imag_a(input_imag_a),
        .input_real_b(input_real_b),
        .input_imag_b(input_imag_b),
        .valid_out(valid_out),
        .output_real_add(output_real_add),
        .output_imag_add(output_imag_add),
        .output_real_diff(output_real_diff),
        .output_imag_diff(output_imag_diff)
    );

    // 클럭 생성 (10ns 주기)
    initial clk = 0;
    always #5 clk = ~clk;

    int cycle_count;

    initial begin
        rstn = 0;
        valid_in = 0;
        cycle_count = 0;

        for (int i=0; i<16; i++) begin
            input_real_a[i] = 0;
            input_imag_a[i] = 0;
            input_real_b[i] = 0;
            input_imag_b[i] = 0;
        end

        #20;
        rstn = 1;

        @(posedge clk);

        // 첫 4 클럭 동안 valid_in=1, 매 싸이클 입력 변화
        for (int i = 0; i < 4; i++) begin
            valid_in = 1;
            for (int j = 0; j < 16; j++) begin
                input_real_a[j] = i*16 + j;     // 싸이클 번호에 따라 값 변화
                input_imag_a[j] = 0;
                input_real_b[j] = (i*16 + j)*2;
                input_imag_b[j] = 0;
            end
            @(posedge clk);
        end

        // 4 클럭 쉬기 (valid_in=0)
        valid_in = 0;
        for (int i=0; i<4; i++) begin
            @(posedge clk);
        end

        // 뒤 4 클럭 동안 valid_in=1, 매 싸이클 입력 변화 (다른 값)
        for (int i = 4; i < 8; i++) begin
            valid_in = 1;
            for (int j = 0; j < 16; j++) begin
                input_real_a[j] = i*16 + j;
                input_imag_a[j] = 0;
                input_real_b[j] = (i*16 + j)*2;
                input_imag_b[j] = 0;
            end
            @(posedge clk);
        end

        valid_in = 0;

        // 100 클럭 대기 후 종료
        for (int i=0; i<100; i++) @(posedge clk);

        $finish;
    end

    // 출력 모니터링
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Time %0t ns: valid_out=%b", $time, valid_out);
            for (int i=0; i<16; i++) begin
                $display("  idx %0d: out_real_add=%0d, out_imag_add=%0d, out_real_diff=%0d, out_imag_diff=%0d",
                    i,
                    output_real_add[i],
                    output_imag_add[i],
                    output_real_diff[i],
                    output_imag_diff[i]
                );
            end
        end
    end

endmodule
