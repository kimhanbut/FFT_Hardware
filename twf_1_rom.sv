
`timescale 1ns/1ps

module twf_1_rom (
    input  logic         clk,
    input  logic         rstn,
    input  logic  [5:0]  address,           // base address
    output logic signed [8:0] twf_re[0:7], // 16개의 twiddle real
    output logic signed [8:0] twf_im[0:7]  // 16개의 twiddle imag
);

    // Twiddle factor ROM
    logic signed [8:0] twf_m1_re[0:63];
    logic signed [8:0] twf_m1_im[0:63];

    integer i;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < 8; i++) begin
                twf_re[i] <= '0;
                twf_im[i] <= '0;
            end
        end else begin
            for (i = 0; i < 8; i++) begin
                twf_re[i] <= twf_m1_re[address + i];
                twf_im[i] <= twf_m1_im[address + i];
            end
        end
    end

assign twf_m1_re[0] = 128;    assign twf_m1_im[0] = 0;
assign twf_m1_re[1] = 128;    assign twf_m1_im[1] = 0;
assign twf_m1_re[2] = 128;    assign twf_m1_im[2] = 0;
assign twf_m1_re[3] = 128;    assign twf_m1_im[3] = 0;
assign twf_m1_re[4] = 128;    assign twf_m1_im[4] = 0;
assign twf_m1_re[5] = 128;    assign twf_m1_im[5] = 0;
assign twf_m1_re[6] = 128;    assign twf_m1_im[6] = 0;
assign twf_m1_re[7] = 128;    assign twf_m1_im[7] = 0;
assign twf_m1_re[8] = 128;    assign twf_m1_im[8] = 0;
assign twf_m1_re[9] = 118;    assign twf_m1_im[9] = -49;
assign twf_m1_re[10] = 91;    assign twf_m1_im[10] = -91;
assign twf_m1_re[11] = 49;    assign twf_m1_im[11] = -118;
assign twf_m1_re[12] = 0;    assign twf_m1_im[12] = -128;
assign twf_m1_re[13] = -49;    assign twf_m1_im[13] = -118;
assign twf_m1_re[14] = -91;    assign twf_m1_im[14] = -91;
assign twf_m1_re[15] = -118;    assign twf_m1_im[15] = -49;
assign twf_m1_re[16] = 128;    assign twf_m1_im[16] = 0;
assign twf_m1_re[17] = 126;    assign twf_m1_im[17] = -25;
assign twf_m1_re[18] = 118;    assign twf_m1_im[18] = -49;
assign twf_m1_re[19] = 106;    assign twf_m1_im[19] = -71;
assign twf_m1_re[20] = 91;    assign twf_m1_im[20] = -91;
assign twf_m1_re[21] = 71;    assign twf_m1_im[21] = -106;
assign twf_m1_re[22] = 49;    assign twf_m1_im[22] = -118;
assign twf_m1_re[23] = 25;    assign twf_m1_im[23] = -126;
assign twf_m1_re[24] = 128;    assign twf_m1_im[24] = 0;
assign twf_m1_re[25] = 106;    assign twf_m1_im[25] = -71;
assign twf_m1_re[26] = 49;    assign twf_m1_im[26] = -118;
assign twf_m1_re[27] = -25;    assign twf_m1_im[27] = -126;
assign twf_m1_re[28] = -91;    assign twf_m1_im[28] = -91;
assign twf_m1_re[29] = -126;    assign twf_m1_im[29] = -25;
assign twf_m1_re[30] = -118;    assign twf_m1_im[30] = 49;
assign twf_m1_re[31] = -71;    assign twf_m1_im[31] = 106;
assign twf_m1_re[32] = 128;    assign twf_m1_im[32] = 0;
assign twf_m1_re[33] = 127;    assign twf_m1_im[33] = -13;
assign twf_m1_re[34] = 126;    assign twf_m1_im[34] = -25;
assign twf_m1_re[35] = 122;    assign twf_m1_im[35] = -37;
assign twf_m1_re[36] = 118;    assign twf_m1_im[36] = -49;
assign twf_m1_re[37] = 113;    assign twf_m1_im[37] = -60;
assign twf_m1_re[38] = 106;    assign twf_m1_im[38] = -71;
assign twf_m1_re[39] = 99;    assign twf_m1_im[39] = -81;
assign twf_m1_re[40] = 128;    assign twf_m1_im[40] = 0;
assign twf_m1_re[41] = 113;    assign twf_m1_im[41] = -60;
assign twf_m1_re[42] = 71;    assign twf_m1_im[42] = -106;
assign twf_m1_re[43] = 13;    assign twf_m1_im[43] = -127;
assign twf_m1_re[44] = -49;    assign twf_m1_im[44] = -118;
assign twf_m1_re[45] = -99;    assign twf_m1_im[45] = -81;
assign twf_m1_re[46] = -126;    assign twf_m1_im[46] = -25;
assign twf_m1_re[47] = -122;    assign twf_m1_im[47] = 37;
assign twf_m1_re[48] = 128;    assign twf_m1_im[48] = 0;
assign twf_m1_re[49] = 122;    assign twf_m1_im[49] = -37;
assign twf_m1_re[50] = 106;    assign twf_m1_im[50] = -71;
assign twf_m1_re[51] = 81;    assign twf_m1_im[51] = -99;
assign twf_m1_re[52] = 49;    assign twf_m1_im[52] = -118;
assign twf_m1_re[53] = 13;    assign twf_m1_im[53] = -127;
assign twf_m1_re[54] = -25;    assign twf_m1_im[54] = -126;
assign twf_m1_re[55] = -60;    assign twf_m1_im[55] = -113;
assign twf_m1_re[56] = 128;    assign twf_m1_im[56] = 0;
assign twf_m1_re[57] = 99;    assign twf_m1_im[57] = -81;
assign twf_m1_re[58] = 25;    assign twf_m1_im[58] = -126;
assign twf_m1_re[59] = -60;    assign twf_m1_im[59] = -113;
assign twf_m1_re[60] = -118;    assign twf_m1_im[60] = -49;
assign twf_m1_re[61] = -122;    assign twf_m1_im[61] = 37;
assign twf_m1_re[62] = -71;    assign twf_m1_im[62] = 106;
assign twf_m1_re[63] = 13;    assign twf_m1_im[63] = 127;


endmodule
