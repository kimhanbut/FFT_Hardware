module shift_reg #(
    parameter DATA_WIDTH = 9,
    parameter DEPTH = 256
)(
    input logic rstn,
    input logic clk,
    input logic din_valid,
    input signed [DATA_WIDTH-1:0] din_i[0:15],
    input signed [DATA_WIDTH-1:0] din_q[0:15],
    output logic signed [DATA_WIDTH-1:0] dout_i[0:15],
    output logic signed [DATA_WIDTH-1:0] dout_q[0:15],
    output logic bufly_enable
);
reg signed [DATA_WIDTH-1:0] buf_re[0:DEPTH-1];
reg signed [DATA_WIDTH-1:0] buf_im[0:DEPTH-1];
integer n;
logic [$clog2(DEPTH/16 + 1)-1:0] count;
logic bufly_en_reg;

// shift buffer
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        count <= 0;
        bufly_en_reg <= 0;
        for (n=0; n<DEPTH; n=n+1) begin
            buf_re[n] <= 0;
            buf_im[n] <= 0;
        end
    end
    else begin
        bufly_en_reg <= 0;
        count <= 0;
        if (din_valid) begin
            for (n = DEPTH/16 -1; n > 0; n = n - 1) begin
                buf_re[n*16+:16] <= buf_re[(n-1)*16+:16];
                buf_im[n*16+:16] <= buf_im[(n-1)*16+:16];
            end
            buf_re[0:15] <= din_i;
            buf_im[0:15] <= din_q;

            count <= count + 1;
            if (count <= (DEPTH/16)-1 && count <= (DEPTH/8)) begin
                bufly_en_reg <= 1;
            end


        end
    end
end

    // 출력은 마지막 16개 값
    assign dout_i = buf_re[DEPTH-16 +: 16];  //base+ : 16  ->> base 부터 16개 만큼
    assign dout_q = buf_im[DEPTH-16 +: 16];

    assign bufly_enable = bufly_en_reg;
endmodule