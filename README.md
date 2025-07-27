# FFT_Hardware

---
### 7/25 진행사항
- step0_0 simulation, verification
- bfly0_1 design
- twf_m0 rom, multiplyer design(verification X)
- CBFP design(verification X)
---
### 7/26 진행사항
- step0_1 disign completion, (rough verification)
---
### 7/27 진행사항 및 유의사항
- step간 merge시에 butterfly output이 그 step이 내보내는 butterfly control signal(다음 단의 din_valid)보다 한 클럭 delay 되어있음에 유의  
  즉, butterfly control signal을 1clk delay 시켜서 사용해야 함
