# FFT_Hardware

---
### 7/25 진행사항
- step0_0 simulation, verification
- bfly0_1 design
- twf_m0 rom, multiplyer design(verification X)
- CBFP design(verification X)
---
### 7/26 진행사항
- step0_1 disign complete, (rough verification)
---
### 7/27 진행사항 및 유의사항
- step간 merge시에 butterfly output이 그 step이 내보내는 butterfly control signal(다음 단의 din_valid)보다 한 클럭 delay 되어있음에 유의  
  즉, butterfly control signal을 1clk delay 시켜서 사용해야 함
- butterfly_2 design complete(rough verification)
- cbfp revision(error 아직 있음)
---
### 7/28 진행사항
- step0, step1 오류 확인 및 수정
- butterfly_2 design complete, cbfp re-design(block unit operation is not applied)
- cbfp revision
---
### 7/29 진행사항
- step0, step1 오류 확인 및 수정완료(main brench 내 모든 module 최신화->shift reg 변경이 그 사유)
- cbfp design complete, merge with former module
- step0~step2 merge complete(timing problem is not yet solved)
- step1_0 design(verification error detected)
- **necessray verification** -> module0 top(with golden)
---
### 8/03 프로젝트 완료 소감
- RTL deisgn, verification은 만족스러웠으나 연속적인 동작에서의 요구사항을 만족하지 못함
- FPGA에서 제대로된 값이 나오지 않는 이유는 최신화가 되지 않았기 때문?
- Synthesis는 마지막까지 제대로된 netlist가 산출되지 않았음
