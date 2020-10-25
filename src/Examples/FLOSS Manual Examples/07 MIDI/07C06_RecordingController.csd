<CsoundSynthesizer>
<CsOptions>
-odac -dm0
</CsOptions>
<CsInstruments>
sr     = 44100
ksmps  = 8
nchnls = 1
0dbfs  = 1

FLpanel "Record Gesture",500,90,0,0
gkRecord,gihRecord FLbutton "Rec/Stop",1,0,22,100,25,  5, 5,-1
gkPlay,gihPlay  FLbutton "Play",    1,0,22,100,25,110, 5,-1
gksave,ihsave  FLbutton "Save to HD", 1,0,21,100,25,290,5,0,4,0,0
gkload,ihload  FLbutton "Load from HD", 1,0,21,100,25,395,5,0,5,0,0
gkval, gihval  FLslider "Control", 0,1, 0,23, -1,490,25, 5,35
FLpanel_end
FLrun

gidata ftgen 1,0,1048576,-2,0 ; Table for controller data.

opcode RecordController,0,Ki
 kval,ifn        xin
 i_      ftgen   1,0,ftlen(ifn),-2,0             ; erase table
 tableiw i(kval),1,ifn           ; write initial value at index 1.
         ;(Index 0 will be used be storing the complete gesture duration.)
 kndx    init    2         ; Initialise index
 kTime   timeinsts         ; time since this instrument started in seconds
; Write a data event only when the input value changes
if changed(kval)==1 && kndx<=(ftlen(ifn)-2) && kTime>0 then
; Write timestamp to table location defined by current index.
  tablew kTime, kndx, ifn
; Write slider value to table location defined by current index.
  tablew kval, kndx + 1, ifn
; Increment index 2 steps (one for time, one for value).
  kndx   =       kndx + 2
 endif
; sense note release
 krel    release
; if we are in the final k-cycle before the note ends
 if(krel==1) then
; write total gesture duration into the table at index 0
  tablew kTime,0,ifn
 endif
endop

opcode PlaybackController,k,i
 ifn     xin
 ; read first value
; initial controller value read from index 1
 ival    table   1,ifn
; initial value for k-rate output
 kval    init    ival
; Initialise index to first non-zero timestamp
 kndx    init    2
; time in seconds since this note started
 kTime   timeinsts
; first non-zero timestamp
 iTimeStamp      tablei  2,ifn
; initialise k-variable for first non-zero timestamp
 kTimeStamp      init    iTimeStamp
; if we have reached the timestamp value...
 if kTime>=kTimeStamp && kTimeStamp>0 then
; ...Read value from table defined by current index.
  kval   table   kndx+1,ifn
  kTimeStamp     table   kndx+2,ifn              ; Read next timestamp
; Increment index. (Always 2 steps: timestamp and value.)
  kndx   limit   kndx+2, 0, ftlen(ifn)-2
 endif
         xout    kval
endop

; cleaner way to start instruments than using FLbutton built-in mechanism
instr   1
; trigger when button value goes from off to on
 kOnTrig trigger gkRecord,0.5,0
; start instrument with a held note when trigger received
 schedkwhen      kOnTrig,0,0,2,0,-1
; trigger when button value goes from off to on
 kOnTrig trigger gkPlay,0.5,0
; start instrument with a held note when trigger received
 schedkwhen      kOnTrig,0,0,3,0,-1
endin

instr   2       ; Record gesture
 if gkRecord==0 then            ; If record button is deactivated...
  turnoff                       ; ...turn this instrument off.
 endif
; call UDO
         RecordController        gkval,gidata
; Generate a sound.
 kporttime       linseg  0,0.001,0.02
 kval    portk   gkval,kporttime
 asig    poscil  0.2,cpsoct((kval*2)+7)
         out     asig

endin

instr   3       ; Playback recorded gesture
 if gkPlay==0 then                 ; if play button is deactivated...
  turnoff                          ; ...turn this instrument off.
 endif
 kval    PlaybackController      gidata
; send initial value to controller
         FLsetVal_i      i(kval),gihval
; Send values to slider when needed.
         FLsetVal        changed(kval),kval,gihval
 ; Generate a sound.
 kporttime       linseg  0,0.001,0.02
 kval    portk   gkval,kporttime
 asig    poscil  0.2,cpsoct((kval*2)+7)
         out     asig
 ; stop note when end of table reached
 kTime   timeinsts              ; time in seconds since this note began
; read complete gesture duration from index zero
 iRecTime        tablei  0,gidata
; if we have reach complete duration of gesture...
 if kTime>=iRecTime then
; deactivate play button (which will in turn, turn off this note.)
  FLsetVal       1,0,gihPlay
 endif
endin

instr   4       ; save table
 ftsave "ControllerData.txt", 0, gidata
endin

instr   5       ; load table
 ftload "ControllerData.txt", 0, gidata
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy