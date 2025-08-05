`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 18:23:49
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP (
    input clk_p,
    input clk_n,
    input rstn
);


    logic clk, valid_out_cos, asic_valid;
    logic signed [8:0] cos_data[0:15];
    logic signed[8:0] q_in[0:15];
    logic signed[12:0] asic_out_i[0:511], asic_out_q[0:511];
    logic [12:0] out_i[0:15], out_q[0:15];
    logic [5:0] out_cnt;
    logic       out_active;
    logic       start_output;  // 출력 시작용 펄스
    logic       valid_out_16p;  // 16개 유효 출력용



    always_comb begin
        for (int i = 0; i < 16; i++) begin
            q_in[i] = 0;
        end
    end


    logic valid_out_d;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out_d <= 1'b0;
        end else begin
            valid_out_d <= asic_valid;
        end
    end

    assign start_output = (asic_valid && !valid_out_d);  // rising edge detect




    clk_wiz_0 CLK_WIZ (
        // Clock out ports
        .clk_out1(clk),
        .resetn(rstn),
        .clk_in1_p(clk_p),
        .clk_in1_n(clk_n)
    );



    cos_generator COS_GEN (
        .clk(clk),
        .rstn(rstn),
        .valid(valid_out_cos),
        .data_out(cos_data)
    );


    top_module ASIC_TOP (
        .clk(clk),
        .rstn(rstn),
        .din_valid(valid_out_cos),
        .din_i(cos_data),
        .din_q(q_in),
        .valid_out(asic_valid),
        .dout_i(asic_out_i),  // CBFP 처리 후 최종 정규화된 출력
        .dout_q(asic_out_q)
    );






    vio_exam VIO_EX(
        .clk(clk),
        .probe_in0(out_i[0]),
        .probe_in1(out_i[1]),
        .probe_in2(out_i[2]),
        .probe_in3(out_i[3]),
        .probe_in4(out_i[4]),
        .probe_in5(out_i[5]),
        .probe_in6(out_i[6]),
        .probe_in7(out_i[7]),
        .probe_in8(out_i[8]),
        .probe_in9(out_i[9]),
        .probe_in10(out_i[10]),
        .probe_in11(out_i[11]),
        .probe_in12(out_i[12]),
        .probe_in13(out_i[13]),
        .probe_in14(out_i[14]),
        .probe_in15(out_i[15]),
        .probe_in16(out_q[0]),
        .probe_in17(out_q[1]),
        .probe_in18(out_q[2]),
        .probe_in19(out_q[3]),
        .probe_in20(out_q[4]),
        .probe_in21(out_q[5]),
        .probe_in22(out_q[6]),
        .probe_in23(out_q[7]),
        .probe_in24(out_q[8]),
        .probe_in25(out_q[9]),
        .probe_in26(out_q[10]),
        .probe_in27(out_q[11]),
        .probe_in28(out_q[12]),
        .probe_in29(out_q[13]),
        .probe_in30(out_q[14]),
        .probe_in31(out_q[15]),
        .probe_in32(valid_out_16p),
        .probe_out0()
    );



    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_cnt       <= 6'd0;
            out_active    <= 1'b0;
            valid_out_16p <= 1'b0;  //data valid signal
        end else begin
            if (start_output) begin
                out_cnt    <= 6'd0;
                out_active <= 1'b1;
                valid_out_16p <= 1'b1;
            end else if (out_active) begin
                out_cnt <= out_cnt + 1;
                valid_out_16p <= 1'b1;

                if (out_cnt == 6'd31) begin
                    out_active <= 1'b0;
                    valid_out_16p <= 1'b0;
                end
            end else begin
                valid_out_16p <= 1'b0;
            end
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            out_i[i] = asic_out_i[out_cnt*16+i];
            out_q[i] = asic_out_q[out_cnt*16+i];
        end
    end






endmodule
