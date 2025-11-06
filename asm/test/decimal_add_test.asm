      ;; This code is 100% position independant
      ORG 0x0000
TEST:
      CCL            ;  5
OP1:
      LDI   0x00     ; 10
OP2:
      DAI   0x00     ; 15 Decimal Add
      ST    RES      ; 18
      CSA            ;  5
      ST    CY       ; 18
      ILD   OP2+1    ; 22
      JNZ   TEST     ; 11 = 104 * 2^17 = 13,631,488 cycles

      ILD   OP1+1
      JNZ   TEST

      LD    TEST  ; Mutate CCL into SCL
      XRI   0x01
      ST    TEST
      ANI   0x01
      JNZ   TEST

      XPPC  P3

RES:  NOP         ; Storage for results
CY:   NOP
