
`timescale 1ns / 1ps

module reorder (
    input  logic             clk,
    input  logic             rstn,
    input  logic signed [12:0] din[0:15], 
    input  logic             di_en,
    output logic signed [12:0] d_out [0:511],
    output logic        valid_out
);
logic [5:0] di_cnt;
logic signed [12:0] dout [0:511];

always_ff @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    di_cnt <= 0;
    valid_out <= 0;
    for (int i = 0; i < 512; i++) begin
      dout[i] <= 0;
      d_out[i] <= 0;
    end
  end else if (di_en) begin
    case (di_cnt)
      5'd0: begin
        dout[0]   <= din[0];
        dout[256] <= din[1];
        dout[128] <= din[2];
        dout[384] <= din[3];
        dout[64]  <= din[4];
        dout[320] <= din[5];
        dout[192] <= din[6];
        dout[448] <= din[7];
        dout[32]  <= din[8];
        dout[288] <= din[9];
        dout[160] <= din[10];
        dout[416] <= din[11];
        dout[96]  <= din[12];
        dout[352] <= din[13];
        dout[224] <= din[14];
        dout[480] <= din[15];
      end
      5'd1: begin
        dout[16]  <= din[0];
        dout[272] <= din[1];
        dout[144] <= din[2];
        dout[400] <= din[3];
        dout[80]  <= din[4];
        dout[336] <= din[5];
        dout[208] <= din[6];
        dout[464] <= din[7];
        dout[48]  <= din[8];
        dout[304] <= din[9];
        dout[176] <= din[10];
        dout[432] <= din[11];
        dout[112] <= din[12];
        dout[368] <= din[13];
        dout[240] <= din[14];
        dout[496] <= din[15];
      end
5'd2: begin
  dout[8]   <= din[0];
  dout[264] <= din[1];
  dout[136] <= din[2];
  dout[392] <= din[3];
  dout[72]  <= din[4];
  dout[328] <= din[5];
  dout[200] <= din[6];
  dout[456] <= din[7];
  dout[40]  <= din[8];
  dout[296] <= din[9];
  dout[168] <= din[10];
  dout[424] <= din[11];
  dout[104] <= din[12];
  dout[360] <= din[13];
  dout[232] <= din[14];
  dout[488] <= din[15];
end
      
5'd3: begin
  dout[24]  <= din[0];
  dout[280] <= din[1];
  dout[152] <= din[2];
  dout[408] <= din[3];
  dout[88]  <= din[4];
  dout[344] <= din[5];
  dout[216] <= din[6];
  dout[472] <= din[7];
  dout[56]  <= din[8];
  dout[312] <= din[9];
  dout[184] <= din[10];
  dout[440] <= din[11];
  dout[120] <= din[12];
  dout[376] <= din[13];
  dout[248] <= din[14];
  dout[504] <= din[15];
end

5'd4: begin
  dout[4]   <= din[0];
  dout[260] <= din[1];
  dout[132] <= din[2];
  dout[388] <= din[3];
  dout[68]  <= din[4];
  dout[324] <= din[5];
  dout[196] <= din[6];
  dout[452] <= din[7];
  dout[36]  <= din[8];
  dout[292] <= din[9];
  dout[164] <= din[10];
  dout[420] <= din[11];
  dout[100] <= din[12];
  dout[356] <= din[13];
  dout[228] <= din[14];
  dout[484] <= din[15];
end

5'd5: begin
  dout[20]  <= din[0];
  dout[276] <= din[1];
  dout[148] <= din[2];
  dout[404] <= din[3];
  dout[84]  <= din[4];
  dout[340] <= din[5];
  dout[212] <= din[6];
  dout[468] <= din[7];
  dout[52]  <= din[8];
  dout[308] <= din[9];
  dout[180] <= din[10];
  dout[436] <= din[11];
  dout[116] <= din[12];
  dout[372] <= din[13];
  dout[244] <= din[14];
  dout[500] <= din[15];
end

5'd6: begin
  dout[12]  <= din[0];
  dout[268] <= din[1];
  dout[140] <= din[2];
  dout[396] <= din[3];
  dout[76]  <= din[4];
  dout[332] <= din[5];
  dout[204] <= din[6];
  dout[460] <= din[7];
  dout[44]  <= din[8];
  dout[300] <= din[9];
  dout[172] <= din[10];
  dout[428] <= din[11];
  dout[108] <= din[12];
  dout[364] <= din[13];
  dout[236] <= din[14];
  dout[492] <= din[15];
end
5'd7: begin
  dout[28]  <= din[0];
  dout[284] <= din[1];
  dout[156] <= din[2];
  dout[412] <= din[3];
  dout[92]  <= din[4];
  dout[348] <= din[5];
  dout[220] <= din[6];
  dout[476] <= din[7];
  dout[60]  <= din[8];
  dout[316] <= din[9];
  dout[188] <= din[10];
  dout[444] <= din[11];
  dout[124] <= din[12];
  dout[380] <= din[13];
  dout[252] <= din[14];
  dout[508] <= din[15];
end
5'd8: begin
  dout[2]   <= din[0];
  dout[258] <= din[1];
  dout[130] <= din[2];
  dout[386] <= din[3];
  dout[66]  <= din[4];
  dout[322] <= din[5];
  dout[194] <= din[6];
  dout[450] <= din[7];
  dout[34]  <= din[8];
  dout[290] <= din[9];
  dout[162] <= din[10];
  dout[418] <= din[11];
  dout[98]  <= din[12];
  dout[354] <= din[13];
  dout[226] <= din[14];
  dout[482] <= din[15];
end
5'd9: begin
  dout[18]  <= din[0];
  dout[274] <= din[1];
  dout[146] <= din[2];
  dout[402] <= din[3];
  dout[82]  <= din[4];
  dout[338] <= din[5];
  dout[210] <= din[6];
  dout[466] <= din[7];
  dout[50]  <= din[8];
  dout[306] <= din[9];
  dout[178] <= din[10];
  dout[434] <= din[11];
  dout[114] <= din[12];
  dout[370] <= din[13];
  dout[242] <= din[14];
  dout[498] <= din[15];
end
5'd10: begin
  dout[10]  <= din[0];
  dout[266] <= din[1];
  dout[138] <= din[2];
  dout[394] <= din[3];
  dout[74]  <= din[4];
  dout[330] <= din[5];
  dout[202] <= din[6];
  dout[458] <= din[7];
  dout[42]  <= din[8];
  dout[298] <= din[9];
  dout[170] <= din[10];
  dout[426] <= din[11];
  dout[106] <= din[12];
  dout[362] <= din[13];
  dout[234] <= din[14];
  dout[490] <= din[15];
end

5'd11: begin
  dout[26]  <= din[0];
  dout[282] <= din[1];
  dout[154] <= din[2];
  dout[410] <= din[3];
  dout[90]  <= din[4];
  dout[346] <= din[5];
  dout[218] <= din[6];
  dout[474] <= din[7];
  dout[58]  <= din[8];
  dout[314] <= din[9];
  dout[186] <= din[10];
  dout[442] <= din[11];
  dout[122] <= din[12];
  dout[378] <= din[13];
  dout[250] <= din[14];
  dout[506] <= din[15];
end

5'd12: begin
  dout[6]   <= din[0];
  dout[262] <= din[1];
  dout[134] <= din[2];
  dout[390] <= din[3];
  dout[70]  <= din[4];
  dout[326] <= din[5];
  dout[198] <= din[6];
  dout[454] <= din[7];
  dout[38]  <= din[8];
  dout[294] <= din[9];
  dout[166] <= din[10];
  dout[422] <= din[11];
  dout[102] <= din[12];
  dout[358] <= din[13];
  dout[230] <= din[14];
  dout[486] <= din[15];
end

5'd13: begin
  dout[22]  <= din[0];
  dout[278] <= din[1];
  dout[150] <= din[2];
  dout[406] <= din[3];
  dout[86]  <= din[4];
  dout[342] <= din[5];
  dout[214] <= din[6];
  dout[470] <= din[7];
  dout[54]  <= din[8];
  dout[310] <= din[9];
  dout[182] <= din[10];
  dout[438] <= din[11];
  dout[118] <= din[12];
  dout[374] <= din[13];
  dout[246] <= din[14];
  dout[502] <= din[15];
end

5'd14: begin
  dout[14]  <= din[0];
  dout[270] <= din[1];
  dout[142] <= din[2];
  dout[398] <= din[3];
  dout[78]  <= din[4];
  dout[334] <= din[5];
  dout[206] <= din[6];
  dout[462] <= din[7];
  dout[46]  <= din[8];
  dout[302] <= din[9];
  dout[174] <= din[10];
  dout[430] <= din[11];
  dout[110] <= din[12];
  dout[366] <= din[13];
  dout[238] <= din[14];
  dout[494] <= din[15];
end

5'd15: begin
  dout[30]  <= din[0];
  dout[286] <= din[1];
  dout[158] <= din[2];
  dout[414] <= din[3];
  dout[94]  <= din[4];
  dout[350] <= din[5];
  dout[222] <= din[6];
  dout[478] <= din[7];
  dout[62]  <= din[8];
  dout[318] <= din[9];
  dout[190] <= din[10];
  dout[446] <= din[11];
  dout[126] <= din[12];
  dout[382] <= din[13];
  dout[254] <= din[14];
  dout[510] <= din[15];
end

5'd16: begin
  dout[1]   <= din[0];
  dout[257] <= din[1];
  dout[129] <= din[2];
  dout[385] <= din[3];
  dout[65]  <= din[4];
  dout[321] <= din[5];
  dout[193] <= din[6];
  dout[449] <= din[7];
  dout[33]  <= din[8];
  dout[289] <= din[9];
  dout[161] <= din[10];
  dout[417] <= din[11];
  dout[97]  <= din[12];
  dout[353] <= din[13];
  dout[225] <= din[14];
  dout[481] <= din[15];
end

5'd17: begin
  dout[17]  <= din[0];
  dout[273] <= din[1];
  dout[145] <= din[2];
  dout[401] <= din[3];
  dout[81]  <= din[4];
  dout[337] <= din[5];
  dout[209] <= din[6];
  dout[465] <= din[7];
  dout[49]  <= din[8];
  dout[305] <= din[9];
  dout[177] <= din[10];
  dout[433] <= din[11];
  dout[113] <= din[12];
  dout[369] <= din[13];
  dout[241] <= din[14];
  dout[497] <= din[15];
end

5'd18: begin
  dout[9]   <= din[0];
  dout[265] <= din[1];
  dout[137] <= din[2];
  dout[393] <= din[3];
  dout[73]  <= din[4];
  dout[329] <= din[5];
  dout[201] <= din[6];
  dout[457] <= din[7];
  dout[41]  <= din[8];
  dout[297] <= din[9];
  dout[169] <= din[10];
  dout[425] <= din[11];
  dout[105] <= din[12];
  dout[361] <= din[13];
  dout[233] <= din[14];
  dout[489] <= din[15];
end

5'd19: begin
  dout[25]  <= din[0];
  dout[281] <= din[1];
  dout[153] <= din[2];
  dout[409] <= din[3];
  dout[89]  <= din[4];
  dout[345] <= din[5];
  dout[217] <= din[6];
  dout[473] <= din[7];
  dout[57]  <= din[8];
  dout[313] <= din[9];
  dout[185] <= din[10];
  dout[441] <= din[11];
  dout[121] <= din[12];
  dout[377] <= din[13];
  dout[249] <= din[14];
  dout[505] <= din[15];
end

5'd20: begin
  dout[5]   <= din[0];
  dout[261] <= din[1];
  dout[133] <= din[2];
  dout[389] <= din[3];
  dout[69]  <= din[4];
  dout[325] <= din[5];
  dout[197] <= din[6];
  dout[453] <= din[7];
  dout[37]  <= din[8];
  dout[293] <= din[9];
  dout[165] <= din[10];
  dout[421] <= din[11];
  dout[101] <= din[12];
  dout[357] <= din[13];
  dout[229] <= din[14];
  dout[485] <= din[15];
end

5'd21: begin
  dout[21]  <= din[0];
  dout[277] <= din[1];
  dout[149] <= din[2];
  dout[405] <= din[3];
  dout[85]  <= din[4];
  dout[341] <= din[5];
  dout[213] <= din[6];
  dout[469] <= din[7];
  dout[53]  <= din[8];
  dout[309] <= din[9];
  dout[181] <= din[10];
  dout[437] <= din[11];
  dout[117] <= din[12];
  dout[373] <= din[13];
  dout[245] <= din[14];
  dout[501] <= din[15];
end

5'd22: begin
  dout[13]  <= din[0];
  dout[269] <= din[1];
  dout[141] <= din[2];
  dout[397] <= din[3];
  dout[77]  <= din[4];
  dout[333] <= din[5];
  dout[205] <= din[6];
  dout[461] <= din[7];
  dout[45]  <= din[8];
  dout[301] <= din[9];
  dout[173] <= din[10];
  dout[429] <= din[11];
  dout[109] <= din[12];
  dout[365] <= din[13];
  dout[237] <= din[14];
  dout[493] <= din[15];
end

5'd23: begin
  dout[29]  <= din[0];
  dout[285] <= din[1];
  dout[157] <= din[2];
  dout[413] <= din[3];
  dout[93]  <= din[4];
  dout[349] <= din[5];
  dout[221] <= din[6];
  dout[477] <= din[7];
  dout[61]  <= din[8];
  dout[317] <= din[9];
  dout[189] <= din[10];
  dout[445] <= din[11];
  dout[125] <= din[12];
  dout[381] <= din[13];
  dout[253] <= din[14];
  dout[509] <= din[15];
end

5'd24: begin
  dout[3]   <= din[0];
  dout[259] <= din[1];
  dout[131] <= din[2];
  dout[387] <= din[3];
  dout[67]  <= din[4];
  dout[323] <= din[5];
  dout[195] <= din[6];
  dout[451] <= din[7];
  dout[35]  <= din[8];
  dout[291] <= din[9];
  dout[163] <= din[10];
  dout[419] <= din[11];
  dout[99]  <= din[12];
  dout[355] <= din[13];
  dout[227] <= din[14];
  dout[483] <= din[15];
end

5'd25: begin
  dout[19]  <= din[0];
  dout[275] <= din[1];
  dout[147] <= din[2];
  dout[403] <= din[3];
  dout[83]  <= din[4];
  dout[339] <= din[5];
  dout[211] <= din[6];
  dout[467] <= din[7];
  dout[51]  <= din[8];
  dout[307] <= din[9];
  dout[179] <= din[10];
  dout[435] <= din[11];
  dout[115] <= din[12];
  dout[371] <= din[13];
  dout[243] <= din[14];
  dout[499] <= din[15];
end

5'd26: begin
  dout[11]  <= din[0];
  dout[267] <= din[1];
  dout[139] <= din[2];
  dout[395] <= din[3];
  dout[75]  <= din[4];
  dout[331] <= din[5];
  dout[203] <= din[6];
  dout[459] <= din[7];
  dout[43]  <= din[8];
  dout[299] <= din[9];
  dout[171] <= din[10];
  dout[427] <= din[11];
  dout[107] <= din[12];
  dout[363] <= din[13];
  dout[235] <= din[14];
  dout[491] <= din[15];
end

5'd27: begin
  dout[27]  <= din[0];
  dout[283] <= din[1];
  dout[155] <= din[2];
  dout[411] <= din[3];
  dout[91]  <= din[4];
  dout[347] <= din[5];
  dout[219] <= din[6];
  dout[475] <= din[7];
  dout[59]  <= din[8];
  dout[315] <= din[9];
  dout[187] <= din[10];
  dout[443] <= din[11];
  dout[123] <= din[12];
  dout[379] <= din[13];
  dout[251] <= din[14];
  dout[507] <= din[15];
end

5'd28: begin
  dout[7]   <= din[0];
  dout[263] <= din[1];
  dout[135] <= din[2];
  dout[391] <= din[3];
  dout[71]  <= din[4];
  dout[327] <= din[5];
  dout[199] <= din[6];
  dout[455] <= din[7];
  dout[39]  <= din[8];
  dout[295] <= din[9];
  dout[167] <= din[10];
  dout[423] <= din[11];
  dout[103] <= din[12];
  dout[359] <= din[13];
  dout[231] <= din[14];
  dout[487] <= din[15];
end

5'd29: begin
  dout[23]  <= din[0];
  dout[279] <= din[1];
  dout[151] <= din[2];
  dout[407] <= din[3];
  dout[87]  <= din[4];
  dout[343] <= din[5];
  dout[215] <= din[6];
  dout[471] <= din[7];
  dout[55]  <= din[8];
  dout[311] <= din[9];
  dout[183] <= din[10];
  dout[439] <= din[11];
  dout[119] <= din[12];
  dout[375] <= din[13];
  dout[247] <= din[14];
  dout[503] <= din[15];
end

5'd30: begin
  dout[15]  <= din[0];
  dout[271] <= din[1];
  dout[143] <= din[2];
  dout[399] <= din[3];
  dout[79]  <= din[4];
  dout[335] <= din[5];
  dout[207] <= din[6];
  dout[463] <= din[7];
  dout[47]  <= din[8];
  dout[303] <= din[9];
  dout[175] <= din[10];
  dout[431] <= din[11];
  dout[111] <= din[12];
  dout[367] <= din[13];
  dout[239] <= din[14];
  dout[495] <= din[15];
end

5'd31: begin
  dout[31]  <= din[0];
  dout[287] <= din[1];
  dout[159] <= din[2];
  dout[415] <= din[3];
  dout[95]  <= din[4];
  dout[351] <= din[5];
  dout[223] <= din[6];
  dout[479] <= din[7];
  dout[63]  <= din[8];
  dout[319] <= din[9];
  dout[191] <= din[10];
  dout[447] <= din[11];
  dout[127] <= din[12];
  dout[383] <= din[13];
  dout[255] <= din[14];
  dout[511] <= din[15];
    end

    endcase   
    di_cnt <= di_cnt+1;
    valid_out <= 0;
    end else if (di_cnt == 6'd32) begin
      for (int i = 0; i < 512; i++) begin
   d_out[i] <= dout[i];
      end
      valid_out <= 1;
      di_cnt <= 0;
  end else begin
     valid_out <= 0;     
  end
  end
endmodule
