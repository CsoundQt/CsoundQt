new alloc for instr 1:
instr 1:  iMyVar = 1.000
 i   1 time     0.10000:     1.00000
This string is updated just at init-time: kMyVar = 0
This string is updated at k-time: kMyVar = 1
 i   1 time     0.20000:     2.00000
This string is updated just at init-time: kMyVar = 0
This string is updated at k-time: kMyVar = 2
 i   1 time     0.30000:     3.00000
This string is updated just at init-time: kMyVar = 0
This string is updated at k-time: kMyVar = 3
 B  0.000 ..  1.000 T  1.000 TT  1.000 M:  0.20000  0.20000
new alloc for instr 2:
instr 2:  iMyVar = 101.000
 i   2 time     1.10000:   101.00000
This string is updated just at init-time: kMyVar = 100
This string is updated at k-time: kMyVar = 101
 i   2 time     1.20000:   102.00000
This string is updated just at init-time: kMyVar = 100
This string is updated at k-time: kMyVar = 102
 i   2 time     1.30000:   103.00000
This string is updated just at init-time: kMyVar = 100
This string is updated at k-time: kMyVar = 103
B  1.000 ..  1.300 T  1.300 TT  1.300 M:  0.29998  0.29998