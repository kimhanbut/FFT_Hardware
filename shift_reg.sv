`timescale 1ns/1ps

module shift_reg #(
    parameter DATA_WIDTH = 9,
    parameter SIZE = 16,
    parameter IN_SIZE = 16
) (
    input  logic       clk,
    input  logic       rstn,
    input  logic       din_valid,
    input  logic signed [DATA_WIDTH-1:0] din_i [0:IN_SIZE -1],  // 병렬 입력
    input  logic signed [DATA_WIDTH-1:0] din_q [0:IN_SIZE -1],
    output logic signed [DATA_WIDTH-1:0] dout_i [0:IN_SIZE -1], // FIFO 가장 앞의 데이터
    output logic signed [DATA_WIDTH-1:0] dout_q [0:IN_SIZE -1],
    output logic       bufly_enable   // count == SIZE일 때 1사이클 high
);

    // FIFO 버퍼
    logic signed [DATA_WIDTH-1:0] shift_i [0:SIZE-1][0:IN_SIZE-1];
    logic signed [DATA_WIDTH-1:0] shift_q [0:SIZE-1][0:IN_SIZE-1];

    logic [$clog2(SIZE+1)-1:0] count;
    logic bufly_en_reg;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 0;
            bufly_en_reg <= 0;
            for (int i = 0; i < SIZE; i++) begin
                for (int j = 0; j < IN_SIZE; j++) begin
                    shift_i[i][j] <= '0;
                    shift_q[i][j] <= '0;
                end
            end
        end else begin
      bufly_en_reg <= 0;
      count <= 0;

            if (din_valid) begin
                // FIFO shift: 앞으로 당기기
                for (int i = 0; i < SIZE-1; i++) begin
                    for (int j = 0; j < IN_SIZE; j++) begin
                        shift_i[i][j] <= shift_i[i+1][j];
                        shift_q[i][j] <= shift_q[i+1][j];
                    end
                end

                // 새 입력을 맨 마지막에 저장
                for (int j = 0; j < IN_SIZE; j++) begin
                    shift_i[SIZE-1][j] <= din_i[j];
                    shift_q[SIZE-1][j] <= din_q[j];
                end

                // 카운트 증가
		count <= count + 1;
		if(count>=SIZE-1 && count<=(SIZE*2))
         		bufly_en_reg <= 1;

            end
        end
    end

    assign dout_i = shift_i[0];  // FIFO front
    assign dout_q = shift_q[0];
    //assign bufly_enable = (din_valid) ? (count>=16) ? 1 : 0 : 0;
    assign bufly_enable = bufly_en_reg;

endmodule
