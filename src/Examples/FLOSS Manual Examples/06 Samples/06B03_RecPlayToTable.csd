opcode playBuffer, a, ik
 ift, kplay  xin
 setksmps  1 ;k=a here in this UDO
 kndx init 0 ;initialize index
 if kplay == 1 then
  aRead table a(kndx), ift
  kndx = (kndx+1) % ftlen(ift)
 endif
 xout aRead
endop