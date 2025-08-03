

`timescale 1ns/1ps

module module0_tb;
    logic clk, rstn;
    logic din_valid;
    logic signed [8:0] din_i [0:15];
    logic signed [8:0] din_q [0:15];  // 항상 0
    logic valid_out;
    logic signed [10:0] module0_dout_i [0:15];
    logic signed [10:0] module0_dout_q [0:15];

    // 출력 파일 핸들
    integer outfile;

    // DUT 인스턴스
    module0 uut (
        .clk(clk),
        .rstn(rstn),
        .din_valid(din_valid),
        .din_i(din_i),
        .din_q(din_q),
        .valid_out(valid_out),
        .module0_dout_i(module0_dout_i),
        .module0_dout_q(module0_dout_q)
    );

    // 클럭 생성 (10ns 주기)
    always #5 clk = ~clk;

    // 입력 real 데이터 배열 (9비트 signed)
    logic signed [8:0] input_real [0:511];
    logic signed [8:0] input_imag [0:511];

    initial begin
        clk = 0;
        rstn = 0;
        din_valid = 0;

        // 출력 파일 열기
        outfile = $fopen("module0_out.txt", "w");
        if (outfile == 0) begin
            $display("❌ Failed to open output file.");
            $finish;
        end

        // 리셋
        #20 rstn = 1;
        #20 din_valid = 1;

        // 입력값 읽기
        $readmemb("rand_re.txt", input_real);
	$readmemb("rand_im.txt", input_imag);
        $display("First input = %0d", input_real[0]);

        // 512포인트 입력: 16포인트씩 32번 전송
        for (int i = 0; i < 32; i++) begin
            @(negedge clk);
            for (int j = 0; j < 16; j++) begin
                din_i[j] = input_real[i*16 + j];
                din_q[j] = input_imag[i*16 + j];
            end
        end

        @(negedge clk);
        din_valid = 0;

        // 유효 출력 기다리면서 출력 파일에 기록
        repeat (150) begin  // 충분한 클럭 동안 감시
            @(negedge clk);
                for (int k = 0; k < 16; k++) begin
                    $fwrite(outfile, "%0d+j%0d\n", module0_dout_i[k], module0_dout_q[k]);
            end
        end

        $fclose(outfile);
        $display("✅ Output written to module0_out.txt");
        $finish;
    end
endmodule

