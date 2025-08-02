module index_buffer #(
    parameter DEPTH = 512,
    parameter SHIFT_WIDTH = 5
)(
    input  logic clk,
    input  logic rstn,
    input  logic write_en,
    input  logic [SHIFT_WIDTH-1:0] re_shift_in,
    input  logic [SHIFT_WIDTH-1:0] im_shift_in,
    output logic [SHIFT_WIDTH-1:0] re_shift_out [0:DEPTH-1],
    output logic [SHIFT_WIDTH-1:0] im_shift_out [0:DEPTH-1]
);

    logic [8:0] wr_ptr; // 0~511

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            wr_ptr <= 0;
        end else if (write_en) begin
            for (int i = 0; i < 64; i++) begin
                re_shift_out[wr_ptr + i] <= re_shift_in;
                im_shift_out[wr_ptr + i] <= im_shift_in;
            end
            wr_ptr <= wr_ptr + 64;
        end
    end

endmodule

// cbfp_module0 에서 4clk당 하나의 final_min_re/im 이 나온다. 
// 각 final_min_re/im은 64pt 단위로 적용한다. 64개씩은 똑같은 final_min_re/im을 사용한다는 뜻.
// index1[0:511] 은 8개의 final_min_re/im이 각각 64개씩 적용되므로 총 512개가 된다.

// 따라서 cbfp_module0 에서 4clk마다 final_min_re/im 을 index_buffer에 저장한다.
// 이렇게 저장한 index_buffer가 index1[0:511] 이 된다. 2도 마찬가지다. 