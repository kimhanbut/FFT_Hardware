module tb_butterfly01;

    // 기본 신호
    logic clk, rstn, valid_in;
    logic [8:0] base_input_idx;

    // 입력 버퍼
    logic signed [9:0] input_real_a [15:0];
    logic signed [9:0] input_imag_a [15:0];
    logic signed [9:0] input_real_b [15:0];
    logic signed [9:0] input_imag_b [15:0];

    // 출력 버퍼
    logic valid_out;
    logic signed [12:0] output_real_a [15:0];
    logic signed [12:0] output_imag_a [15:0];
    logic signed [12:0] output_real_b [15:0];
    logic signed [12:0] output_imag_b [15:0];

    // DUT 인스턴스
    butterfly01 dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .base_input_idx(base_input_idx),
        .input_real_a(input_real_a),
        .input_imag_a(input_imag_a),
        .input_real_b(input_real_b),
        .input_imag_b(input_imag_b),
        .valid_out(valid_out),
        .output_real_a(output_real_a),
        .output_imag_a(output_imag_a),
        .output_real_b(output_real_b),
        .output_imag_b(output_imag_b)
    );

    // 클럭 생성
    always #5 clk = ~clk;

    // 전체 입력 데이터 (512포인트)
    logic signed [9:0] full_real_a [0:511];
    logic signed [9:0] full_imag_a [0:511];
    logic signed [9:0] full_real_b [0:511];
    logic signed [9:0] full_imag_b [0:511];

    // 루프 변수
    int i, blk;
    int input_total = 512;
    real radians;

    initial begin
        // 초기화
        clk = 0;
        rstn = 0;
        valid_in = 0;
        base_input_idx = 0;

        // 리셋 해제
        #20 rstn = 1;

        // 다양한 입력값 생성
        for (i = 0; i < input_total; i++) begin
            // real_a: 0~511
            full_real_a[i] = i;

            // imag_a: sin 곡선
            radians = 2.0 * 3.141592 * i / 64.0;
            full_imag_a[i] = $rtoi($sin(radians) * 511.0);

            // real_b: -256 ~ +255
            full_real_b[i] = (i < 256) ? i - 256 : 255 - i;

            // imag_b: 작은 랜덤 노이즈
            full_imag_b[i] = $urandom_range(-16, 16);
        end

        // 입력 공급 및 출력 감시 병렬 실행
        fork
            // 입력 공급
            begin
                for (blk = 0; blk < input_total / 16; blk++) begin
                    @(negedge clk);
                    valid_in = 1;
                    base_input_idx = blk * 16;

                    for (i = 0; i < 16; i++) begin
                        int idx = blk * 16 + i;
                        input_real_a[i] = full_real_a[idx];
                        input_imag_a[i] = full_imag_a[idx];
                        input_real_b[i] = full_real_b[idx];
                        input_imag_b[i] = full_imag_b[idx];
                    end

                    @(negedge clk);
                    valid_in = 0;
                end
            end

            // 출력 감시
            begin
                int out_count = 0;
                forever begin
                    @(posedge clk);
                    if (valid_out) begin
                        $display("=== Output #%0d (base_input_idx = %0d) ===", out_count, base_input_idx);
                        for (i = 0; i < 16; i++) begin
                            $display("SUM  [%0d] = %0d + j%0d | DIFF [%0d] = %0d + j%0d",
                                i, output_real_a[i], output_imag_a[i],
                                i, output_real_b[i], output_imag_b[i]
                            );
                        end
                        out_count++;
                        if (out_count == input_total / 16) begin
                            $display("✅ 모든 출력 완료 (%0d 세트)", out_count);
                            $finish;
                        end
                    end
                end
            end
        join
    end
endmodule

