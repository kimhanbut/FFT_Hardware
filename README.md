# Radix 2² 기반 512 Fixed-Point FFT 하드웨어설계
<img width="1000" src="https://github.com/user-attachments/assets/19bb2e17-0a7d-48be-873d-beb99b2c52a8" />

---

<br>
<br>

## 1. 개요

- FFT 연산을 하드웨어로 진행하는 IP 설계 프로젝트입니다
- 4명이 한 조를 이루어 진행한 팀 프로젝트입니다
- 하드웨어 기반이므로 Fixed point로 진행되었고, Radix 2 연산 모듈 두개를 이용하여 연산하는 형태입니다.
- butterfly연산과 twiddle factor연산 및 floating point 연산만큼의 정확도 보장을 위해 CBFP(Convergent Block Floating Point)모듈이 추가된 구조입니다.
---
<br>


## 2. 역할

- Top module merge
- CBFP module design
- Butterfly operation design
- Sub module verification
---
<br>


## 3. Floating Point와 Fixed Point

- 하드웨어 내부적으로 floating point 연산을 하는 것은 불가능합니다.
- 각 module 입, 출력 부분 마다 bit 수를 조절하며 rounding, saturation, CBFP등의 비트 관리가 필수적입니다.
- 아래는 floating point fft와 CBFP를 적용하지 않는 fixed point fft의 연산결과입니다.
<img width="800" src="https://github.com/user-attachments/assets/ff5a70ff-cf03-46bd-9b08-3a9752a0a099" />

- 이렇듯 hardware연산에서 floating point 연산의 정확도에 근접하기 위해서는 CBFP와 같은 연산이 필수적입니다.
- 아래는 CBFP 적용 전과 이후의 SQNR그래프입니다.
<img width="800" src="https://github.com/user-attachments/assets/ee4c4cf3-31a8-44ff-a3e6-0942c6cdb2e5" />

---
<br>


## 4. 시스템 구성도
<br>
<img width="400" src="https://github.com/user-attachments/assets/e9272d1f-6fa2-4220-8b6d-801749385b6a" />

###### FFT Top module block diagram
- 초기 9bit 입력이 실, 허수부에 16개씩 병렬적으로 입력됩니다.
- 즉, 512개 입력은 32clk 동안 들어오게 됩니다.
- 출력은 13bit로 512개 data가 동시에 출력됩니다.
---
<br>

<img width="1000" src="https://github.com/user-attachments/assets/21ebcd15-2fae-4e9b-a089-b63b003fd8e9" />


###### Sub-module block diagram
- 입력이 16개씩 병렬적으로 들어오게 되고, 첫번째 butterfly 연산은 258개 data를 덧, 뺄셈 하므로 shfit regisgter가 필수적입니다.
- 이후 butterfly 연산도 1clk 16개씩 들어오기 때문에 128개씩 두번 연산으로 인해 128크기의 shift 레지스터가 하나 필요합니다.
- 128개씩 연산을 두번 해야 하므로 256개 데이터를 저장해줄 shift regisgter도 하나 필요합니다.
- 이후 연산 구조는 butterfly1_2까지 동일한 구조를 가집니다.

---
<br>

<img width="1000" src="https://github.com/user-attachments/assets/6937dcf3-b569-40a1-8bfc-4df0e0d52ad2" />


###### Timing Diagram
- butterfly12 이후부터는 1클럭 마다 한번의 butterfly연산이 진행되므로 shift register가 필요 없어집니다.
- 병렬적으로 들어오는 16개 데이터를 순서대로 병렬 연산하고 출력하게 됩니다.

---
<br>

- **step0**
<img width="600" src="https://github.com/user-attachments/assets/d8de862c-e9d3-4167-9418-ab23fd4064ed" />

    - 들어오는 값에 대해 덧셈과 뺄셈 연산을 진행합니다.
    - Twiddle factor를 곱한 뒤 결과를 출력합니다. Twiddle factor = [1, 1, 1, -j]

<br>

- **step1**
<img width="600" src="https://github.com/user-attachments/assets/3c8feb4f-b365-424a-a8c2-4c30b937c41c" />

    - 들어오는 값에 대해 덧셈과 뺄셈 연산을 진행합니다.
    - Twiddle factor를 곱한 뒤 결과를 출력합니다. Twiddle factor = [1, 1, 1, -1i, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]
<br>

- **step2**
<img width="600" src="https://github.com/user-attachments/assets/4a425ce8-db84-4ee7-8291-c7003a4daa49" />

    - 들어오는 값에 대해 덧셈과 뺄셈 연산을 진행합니다.
    - Twiddle factor를 곱한 뒤 결과를 출력합니다.
    - 이 경우 twiddle factor는 512 point에 대해 각각 다른 값이 배정되므로 ROM의 형태로 저장하여 연산을 진행합니다.
---
<br>


- **CBFP**
    - 일정 단위로 block으로 판단한 뒤 연산을 진행합니다.
    <img width="600" src="https://github.com/user-attachments/assets/c5431c34-1bf0-45ed-ad1b-3586b3a1a192" />

    - block 내부의 각 값에 대하여, signbit 갯수를 셉니다.
    <img width="600" src="https://github.com/user-attachments/assets/26049084-b671-452d-bb49-87c5724ad3ce" />

    - block 내부에서 count한 signbit 갯수 중 최솟값을 찾아냅니다.
    - 실수와 허수 중 더 작은 최솟값을 기준으로 right shift합니다.
---
<br>




## 5. 검증 결과
<br>

<img width="1000" src="https://github.com/user-attachments/assets/c2ab0fd5-2c80-407c-9f7d-76f46da239b4" />

##### Clock Latency
- Clock latency는 90으로 나왔습니다.
<br>

#### 5-1. COS 입력에 대한 검증 결과
<img width="800" src="https://github.com/user-attachments/assets/9fb02833-7c49-486d-9d84-97e9c67ca5a6" />
<img width="800" src="https://github.com/user-attachments/assets/b620ed31-2e85-4d87-9b12-dea93743260a" />
<img width="800" src="https://github.com/user-attachments/assets/489e3b6d-9ae1-4af7-9ed9-30e0cd809c96" />
<img width="800" src="https://github.com/user-attachments/assets/99e765b4-157a-4ef6-a955-797627ce5295" />
<img width="800" src="https://github.com/user-attachments/assets/7c36fe81-91f0-413b-a93b-cb31f24f4fe9" />
<img width="800" src="https://github.com/user-attachments/assets/e2a1094c-6c54-4eae-971a-af642a9677ae" />
<img width="800" src="https://github.com/user-attachments/assets/f31289d0-1c7e-487d-a59f-cecc0fed17cb" />
<img width="800" src="https://github.com/user-attachments/assets/77157ebc-e6d8-4b06-890b-10b0a7a4823e" />

---
<br>

#### 5-2. Random 입력에 대한 검증 결과


---
<br>

## 6. Trouble Shooting


>---
>#### 문제 인식
>
>- UART 모듈과 PC간 통신 도중 Python에서 받은 data에 misalignment 문제가 발생
>
>#### 원인 분석
>
>- UART FIFO의 TX packet에 header를 추가 및 python에서 확인하는 방법 시도
>- UART TX packet을 받으면 python에서 ACK신호를 보내서 handshake시도
>
>→ 두 방법 모두 실패 →하드웨어에서 보내는 TX 자체에 문제가 있다고 판단
>
>- Baud rate를 계산해본 결과 9600의 baud rate는 12 Byte 전송에만 12ms 소요 → 전송중에 FIFO 내부 데이터가 갱신될 가능성 높다고 판단 → 신뢰성 보장 X
>
>#### 해결 방법
>
>- 간단히 baud rate를 115200으로 증가시킴 → 12 Byte 전송에 1ms 소요 → 전송중 내부 데이터 갱신 확률 대폭 감소 + header 추가로 신뢰성 증가
>---

<br>

## 개발 일정 및 진행 상황
>---
> **7/25 진행사항**
> - step0_0 simulation, verification
> - bfly0_1 design
> - twf_m0 rom, multiplyer design(verification X)
> - CBFP design(verification X)
> ---
> **7/26 진행사항**
> - step0_1 disign complete, (rough verification)
> ---
> **7/27 진행사항 및 유의사항**
> - step간 merge시에 butterfly output이 그 step이 내보내는 butterfly control signal(다음 단의 din_valid)보다 한 클럭 delay 되어있음에 유의  
>   즉, butterfly control signal을 1clk delay 시켜서 사용해야 함
> - butterfly_2 design complete(rough verification)
> - cbfp revision(error 아직 있음)
> ---
> **7/28 진행사항**
> - step0, step1 오류 확인 및 수정
> - butterfly_2 design complete, cbfp re-design(block unit operation is not applied)
> - cbfp revision
> ---
> **7/29 진행사항**
> - step0, step1 오류 확인 및 수정완료(main brench 내 모든 module 최신화->shift reg 변경이 그 사유)
> - cbfp design complete, merge with former module
> - step0~step2 merge complete(timing problem is not yet solved)
> - step1_0 design(verification error detected)
> - **necessray verification** -> module0 top(with golden)
> ---
