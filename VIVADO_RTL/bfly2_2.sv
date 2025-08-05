`timescale 1ns / 1ps

module butterfly22 (
    input  logic             clk,
    input  logic             rstn,
    input  logic             valid_in,
    input  logic signed [14:0] input_real[0:15], 
    input  logic signed [14:0] input_imag[0:15],
    input  logic     [4:0]  shift_index_1[0:15],
    input  logic     [4:0]  shift_index_2[0:15],

    output logic             valid_out,
    output logic signed [12:0] output_real [0:15],
    output logic signed [12:0] output_imag [0:15]
);
    integer j;
    logic valid_in_d1;
    // 내부 신호
    logic  [5:0] index_sum [0:15];
    logic  [5:0] index_sum_reg [0:15];


    logic signed [15:0] sum_r [0:7], sum_i [0:7];
    logic signed [15:0] diff_r[0:7], diff_i[0:7];

    logic signed [15:0] bfly22_tmp_r[0:15];
    logic signed [15:0] bfly22_tmp_i[0:15];

    logic signed [15:0] sat_tmp_r[0:15];
    logic signed [15:0] sat_tmp_i[0:15];

    logic signed [12:0] shifted_r[0:15];
    logic signed [12:0] shifted_i[0:15];

    // Index 합 계산 (combinational)
    always_comb begin
      for(int i=0; i< 16;i++) begin
        index_sum[i] = shift_index_1[i] + shift_index_2[i];
      end
    end
    int idx;
    // 덧셈/뺄셈 수행 (combinational)
    always_comb begin
        for (j = 0; j < 8; j++) begin
            idx = j*2;
            sum_r[j]  = input_real[idx] + input_real[idx+1];
            sum_i[j]  = input_imag[idx] + input_imag[idx+1];
            diff_r[j] = input_real[idx] - input_real[idx+1];
            diff_i[j] = input_imag[idx] - input_imag[idx+1];
        end

   for (j = 0; j<16; j++) begin
      if ( j%2 == 0 ) begin
               bfly22_tmp_r[j] = sum_r[j/2];
               bfly22_tmp_i[j] = sum_i[j/2];
      end else begin
               bfly22_tmp_r[j] = diff_r[j/2];
               bfly22_tmp_i[j] = diff_i[j/2];
           end
        end
    end



        // saturation 처리
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
          for (int i = 0 ; i<16 ; i++) begin
          index_sum_reg[i] <= 0;
          end
        end else begin
          for (int i = 0 ; i<16 ; i++) begin
          index_sum_reg[i] <= index_sum[i];
          end          
        end
    end



    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i< 16;i++) begin
               sat_tmp_r[i] <=0;
               sat_tmp_i[i] <=0;
            end
        end else begin
            for (int i =0; i<16; i++) begin
                // saturation 처리 
                sat_tmp_r[i]  <= (bfly22_tmp_r[i]  >  32767) ?  32767 :
                                 (bfly22_tmp_r[i]  < -32768) ? -32768 : bfly22_tmp_r[i];
                sat_tmp_i[i]  <= (bfly22_tmp_i[i]  >  32767) ?  32767 :
                                 (bfly22_tmp_i[i]  < -32768) ? -32768 : bfly22_tmp_i[i];
            end
        end
    end


always_comb begin
    for (int i = 0; i < 16; i++) begin
        if (index_sum_reg[i] >= 6'd23) begin
            shifted_r[i] = 13'sd0;
        end else if (index_sum_reg[i] >= 6'sd9) begin
            shifted_r[i] = sat_tmp_r[i] >>> (index_sum_reg[i] - 6'sd9);  // 나눗셈
            shifted_i[i] = sat_tmp_i[i] >>> (index_sum_reg[i] - 6'sd9);
        end else begin
            shifted_r[i] = sat_tmp_r[i] <<< (6'sd9 - index_sum_reg[i]); // 곱셈
            shifted_i[i] = sat_tmp_i[i] <<< (6'sd9 - index_sum_reg[i]);
        end
    end
end


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 1'b0;
       valid_in_d1 <= 1'b0;
            for (int i = 0; i < 16; i++) begin
                output_real[i] <= 13'sd0;
                output_imag[i] <= 13'sd0;
            end
        end else begin
       valid_in_d1 <= valid_in;
            valid_out <= valid_in_d1;

            for (int i = 0; i < 16; i++) begin
                output_real[i]   <= shifted_r[i];
                output_imag[i]   <= shifted_i[i];
            end
        end
    end

endmodule


