`timescale 1ns/1ps

module butterfly02_tb;

    logic clk;
    logic rstn;
    logic valid_in;

    logic signed [12:0] bfly01_real_a [15:0];
    logic signed [12:0] bfly01_imag_a [15:0];
    logic signed [12:0] bfly01_real_b [15:0];
    logic signed [12:0] bfly01_imag_b [15:0];

    logic valid_out;
    logic signed [12:0] bfly02_tmp_real [15:0];
    logic signed [12:0] bfly02_tmp_imag [15:0];
    logic signed [12:0] bfly02_tmp_real_sub [15:0];
    logic signed [12:0] bfly02_tmp_imag_sub [15:0];

    // DUT 인스턴스
    butterfly02 dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .bfly01_real_a(bfly01_real_a),
        .bfly01_imag_a(bfly01_imag_a),
        .bfly01_real_b(bfly01_real_b),
        .bfly01_imag_b(bfly01_imag_b),
        .valid_out(valid_out),
        .bfly02_tmp_real(bfly02_tmp_real),
        .bfly02_tmp_imag(bfly02_tmp_imag),
        .bfly02_tmp_real_sub(bfly02_tmp_real_sub),
        .bfly02_tmp_imag_sub(bfly02_tmp_imag_sub)
    );

    // 클럭 생성
    always #5 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        rstn = 0;
        valid_in = 0;
        #20;

        rstn = 1;
        #10;

        // 테스트 벡터 입력
        valid_in = 1;
        for (int i = 0; i < 16; i++) begin
            // 입력 A = 1000 + j*1000, 입력 B = i + j*i
            bfly01_real_a[i] = 13'sd1000;
            bfly01_imag_a[i] = 13'sd1000;
            bfly01_real_b[i] = i;
            bfly01_imag_b[i] = i;
        end

        #10;
        valid_in = 0;

        // 출력 대기
        #10;

        // 출력 확인
        $display("=== butterfly02 output ===");
        for (int i = 0; i < 16; i++) begin
            $display("[%0d] ADD = %0d + j%0d, SUB = %0d + j%0d",
                i,
                bfly02_tmp_real[i], bfly02_tmp_imag[i],
                bfly02_tmp_real_sub[i], bfly02_tmp_imag_sub[i]
            );
        end

        #20;
        $finish;
    end

endmodule
