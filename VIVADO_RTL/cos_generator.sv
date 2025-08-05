module cos_generator (
    input  logic              clk,
    input  logic              rstn,
    output logic              valid,
    output logic signed [8:0] data_out[0:15]
);

    // 카운터 : 0~39 (32클럭 동작 + 8클럭 정지)
    logic [5:0] clk_cnt;

    // ROM 주소 : 0 → 16 → ... → 496 (32클럭 동안 16씩 증가)
    logic [8:0] rom_addr;

    // ROM 출력
    logic signed [8:0] rom_data[0:15];

    // ROM 인스턴스
    cos_rom u_rom (
        .clk (clk),
        .addr(rom_addr),
        .data(rom_data)
    );

    // 카운터 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 6'd0;
        else if (clk_cnt == 6'd39)
            clk_cnt <= 6'd0;
        else
            clk_cnt <= clk_cnt + 6'd1;
    end

    // ROM 주소 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            rom_addr <= 9'd0;
        else if (clk_cnt < 6'd31)  // 0~31번 클럭에서는 주소 증가
            rom_addr <= rom_addr + 9'd16;
        else if (clk_cnt == 6'd39) // 39에서 다시 시작할 준비
            rom_addr <= 9'd0;
    end

    // valid 신호: 0~31 클럭에서만 활성화
    assign valid = (clk_cnt < 6'd32);

    // 출력 제어
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++)
                data_out[i] <= 9'sd0;
        end else if (valid) begin
            for (int i = 0; i < 16; i++)
                data_out[i] <= rom_data[i];
        end else begin
            for (int i = 0; i < 16; i++)
                data_out[i] <= 9'sd0;
        end
    end

endmodule
