<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  1
0dbfs    = 1

zakinit 9, 1    ; zak space with the 9 channel B-format second order

opcode  ambi_encode, 0, aikk
asnd,iorder,kaz,kel     xin
kaz = $M_PI*kaz/180
kel = $M_PI*kel/180
kcos_el = cos(kel)
ksin_el = sin(kel)
kcos_az = cos(kaz)
ksin_az = sin(kaz)

        zawm    asnd,0                                                  ; W
        zawm    kcos_el*ksin_az*asnd,1          ; Y      = Y(1,-1)
        zawm    ksin_el*asnd,2                          ; Z      = Y(1,0)
        zawm    kcos_el*kcos_az*asnd,3          ; X      = Y(1,1)

        if              iorder < 2 goto      end

i2      = sqrt(3)/2
kcos_el_p2 = kcos_el*kcos_el
ksin_el_p2 = ksin_el*ksin_el
kcos_2az = cos(2*kaz)
ksin_2az = sin(2*kaz)
kcos_2el = cos(2*kel)
ksin_2el = sin(2*kel)

        zawm i2*kcos_el_p2*ksin_2az*asnd,4      ; V = Y(2,-2)
        zawm i2*ksin_2el*ksin_az*asnd,5         ; S = Y(2,-1)
        zawm .5*(3*ksin_el_p2 - 1)*asnd,6               ; R = Y(2,0)
        zawm i2*ksin_2el*kcos_az*asnd,7         ; S = Y(2,1)
        zawm i2*kcos_el_p2*kcos_2az*asnd,8      ; U = Y(2,2)
end:

endop

; decoding of order iorder for 1 speaker at position iaz,iel,idist
opcode  ambi_decode1, a, iii
iorder,iaz,iel  xin
iaz = $M_PI*iaz/180
iel = $M_PI*iel/180
a0=zar(0)
        if      iorder > 0 goto c0
aout = a0
        goto    end
c0:
a1=zar(1)
a2=zar(2)
a3=zar(3)
icos_el = cos(iel)
isin_el = sin(iel)
icos_az = cos(iaz)
isin_az = sin(iaz)
i1      =       icos_el*isin_az                 ; Y      = Y(1,-1)
i2      =       isin_el                                 ; Z      = Y(1,0)
i3      =       icos_el*icos_az                 ; X      = Y(1,1)
        if iorder > 1 goto c1
aout    =       (1/2)*(a0 + i1*a1 + i2*a2 + i3*a3)
        goto end
c1:
a4=zar(4)
a5=zar(5)
a6=zar(6)
a7=zar(7)
a8=zar(8)

ic2     = sqrt(3)/2

icos_el_p2 = icos_el*icos_el
isin_el_p2 = isin_el*isin_el
icos_2az = cos(2*iaz)
isin_2az = sin(2*iaz)
icos_2el = cos(2*iel)
isin_2el = sin(2*iel)

i4 = ic2*icos_el_p2*isin_2az    ; V = Y(2,-2)
i5      = ic2*isin_2el*isin_az          ; S = Y(2,-1)
i6 = .5*(3*isin_el_p2 - 1)              ; R = Y(2,0)
i7 = ic2*isin_2el*icos_az               ; S = Y(2,1)
i8 = ic2*icos_el_p2*icos_2az    ; U = Y(2,2)

aout = (1/9)*(a0 + 3*i1*a1 + 3*i2*a2 + 3*i3*a3 + 5*i4*a4 + \
              5*i5*a5 + 5*i6*a6 + 5*i7*a7 + 5*i8*a8)

end:
                xout                    aout
endop

; overloaded opcode for decoding of order iorder
; speaker positions in function table ifn
opcode  ambi_decode,    a,ii
iorder,ifn xin
 xout ambi_decode1(iorder,table(1,ifn),table(2,ifn))
endop
opcode  ambi_decode,    aa,ii
iorder,ifn xin
 xout ambi_decode1(iorder,table(1,ifn),table(2,ifn)),
      ambi_decode1(iorder,table(3,ifn),table(4,ifn))
endop
opcode  ambi_decode,    aaa,ii
iorder,ifn xin
xout ambi_decode1(iorder,table(1,ifn),table(2,ifn)),
     ambi_decode1(iorder,table(3,ifn),table(4,ifn)),
     ambi_decode1(iorder,table(5,ifn),table(6,ifn))
endop

instr 1
asnd    init            1
;kdist  init            1
kaz             invalue "az"
kel             invalue "el"

            ambi_encode asnd,2,kaz,kel

ao1,ao2,ao3     ambi_decode     2,17
                outvalue "sp1", downsamp(ao1)
                outvalue "sp2", downsamp(ao2)
                outvalue "sp3", downsamp(ao3)
                zacl    0,8
endin

</CsInstruments>
<CsScore>
;f1 0 1024 10 1
f17 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0
i1 0 100
</CsScore>
</CsoundSynthesizer>
;example by martin neukom