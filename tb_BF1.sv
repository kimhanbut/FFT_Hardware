module tb_butterfly01;
    logic clk, rstn, valid_in;
    logic signed [9:0] input_real_a [15:0];
    logic signed [9:0] input_imag_a [15:0];
    logic signed [9:0] input_real_b [15:0];
    logic signed [9:0] input_imag_b [15:0];

    logic valid_out;
    logic signed [12:0] output_real_add [15:0];
    logic signed [12:0] output_imag_add [15:0];
    logic signed [12:0] output_real_diff [15:0];
    logic signed [12:0] output_imag_diff [15:0];

    // DUT 인스턴스
    butterfly01 dut (
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

    // Clock 생성
    always #5 clk = ~clk;

    task init_inputs();
        for (int i = 0; i < 16; i++) begin
            input_real_a[i] = 2*i;
            input_imag_a[i] = 3*i;
            input_real_b[i] = 19 - i;
            input_imag_b[i] = 18-i;
        end
    endtask

    initial begin
        clk = 0;
        rstn = 0;
        valid_in = 0;
        init_inputs();

        #12;
        rstn = 1;
        #10;

        // 16회 입력 valid_in
        
        valid_in = 1;
        #80;
	valid_in = 0;
	#80;
	valid_in = 1;
	#80;
	
        

        valid_in = 0;

        // 출력 관찰 시간
        #100;

        $display("---- 출력 확인 ----");
        for (int i = 0; i < 16; i++) begin
            $display("ADD[%0d]: %0d + j%0d, DIFF[%0d]: %0d + j%0d",
                i,
                output_real_add[i], output_imag_add[i],
                i,
                output_real_diff[i], output_imag_diff[i]
            );
        end

        $finish;
    end
endmodule
