module butterfly20 (
    input  logic         clk,
    input  logic         rstn,
    input  logic         valid_in,
    input  logic signed [12:0] input_real [0:15],  
    input  logic signed [12:0] input_imag [0:15],   
    output logic         valid_out, 
    output logic signed [13:0] output_real[0:15],
    output logic signed [13:0] output_imag[0:15]
);
    
    logic signed [13:0] sum_r0[0:3], sum_i0[0:3];
    logic signed [13:0] diff_r0[0:3], diff_i0[0:3];
    logic signed [13:0] sum_r1[0:3], sum_i1[0:3];
    logic signed [13:0] diff_r1[0:3], diff_i1 [0:3];
    
    // === Combinational butterfly ===
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            sum_r0[i] = input_real[i] + input_real[i+4];
            sum_i0[i] = input_imag[i] + input_imag[i+4];
            diff_r0[i] = input_real[i] - input_real[i+4];
            diff_i0[i] = input_imag[i] - input_imag[i+4];

            sum_r1[i] = input_real[i+8] + input_real[i+12];
            sum_i1[i] = input_imag[i+8] + input_imag[i+12];
            diff_r1[i] = input_real[i+8] - input_real[i+12];
            diff_i1[i] = input_imag[i+8] - input_imag[i+12];
        end
    end
    
    // === Sequential output logic ===
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 0;
            for (int j = 0; j < 16; j++) begin
                output_real[j]  <= 0;
                output_imag[j]  <= 0;

            end
        end else begin
            valid_out <= valid_in;

            for (int i = 0; i < 4; i++) begin
                // sum0 → output[0~3]
                output_real[i]    <= sum_r0[i];
                output_imag[i]    <= sum_i0[i];

                // diff0 → output[4~7]
                if (i < 2) begin
                    output_real[i+4] <= diff_r0[i];    // 그대로
                    output_imag[i+4] <= diff_i0[i];
                end else begin
                    output_real[i+4] <= diff_i0[i];    // -j 곱: imag → real
                    output_imag[i+4] <= -diff_r0[i];   // real → -imag
                end

                // ------------------------------------------

                // sum1 → output[8~11]
                output_real[i+8]  <= sum_r1[i];
                output_imag[i+8]  <= sum_i1[i];

                // diff1 → output[12~15]
                if (i < 2) begin
                    output_real[i+12] <= diff_r1[i];   // 그대로
                    output_imag[i+12] <= diff_i1[i];
                end else begin
                    output_real[i+12] <= diff_i1[i];   // -j 곱
                    output_imag[i+12] <= -diff_r1[i];
                end
            end
        end
    end
endmodule
