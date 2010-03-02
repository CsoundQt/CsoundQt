<CsoundSynthesizer>
<CsOptions>
--midi-key=4 --midi-velocity=5 -+max_str_len=8192
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1.0

;Jacob Joaquin
;March 1, 2010
;jacobjoaquin@gmail.com
;csound.noisepages.com

; Tune Instruments
# define TUNE # 264.99816498389697 #  ; 440 * 3 ^ (-6 / 13)

; Instruments
# define MIDI_Synth     # 1 #
# define Echo           # 2 #
# define Capture_Events # 100 #
# define Playback       # 200 #
# define Record         # 201 #
# define Clear          # 202 #
# define Init           # 500 #

; F-Tables
# define T_Sine # 1 #  ; Sine wave

; Sine wave
gitemp ftgen $T_Sine, 0, 2 ^ 16, 10, 1

gScore = ""
gkrecord init 0
gkoffset init 0
gkcounter init 0

instr $MIDI_Synth
    ; MIDI input
    inote_play = p4                  ; Note number
    ivelocity = p5                   ; Velocity
    ivelocity = ivelocity / 127      ; Normalize velocity
    kgate madsr 0.005, 1, 1, 0.25  ; MIDI envelope
    
    ; Frequency
    ifreq = $TUNE * 3 ^ ((inote_play - 60) / 13)

    ; FM Synth
    a1 foscil kgate * ivelocity, ifreq, 1, 2, 6 * ivelocity, $T_Sine    
    
    ; Outputs
    a1 = a1 * 0.5
    outs a1, a1
    chnmix a1, "Send"
    

    ; Send event info to $Capture_Event    
    klisten init 1      ; Listen for release time
    kflag release       ; Track release
    kdur timeinsts
    ktime times 
    
    if (klisten == 1 && kflag == 1 && gkrecord == 1) then
        event "i", $Capture_Events, 0, 1, ktime - gkoffset, kdur, inote_play, ivelocity * 127
        
        ; Stop listening
        klisten = 0
    endif
    
endin

instr $Echo
    iamp = p4        ; Amplitude
    itime = p5       ; Time of delay
    ifb = p6         ; Delay feedback amount
    iroom_size = p7  ; Size of room, for reverb
    idamp = p8       ; High frequency dampening of reverb
    
    ; Receive send signal from MIDI_Synth
    a0 chnget "Send"
    
    ; Effects
    adelay delayr itime
    delayw a0 + adelay * ifb    
    al, ar freeverb adelay, adelay, 0.1, 0.2
    
    ; Outputs
    outs al * iamp, ar * iamp    
    chnclear "Send"

endin

instr $Capture_Events
    istart = p4
    idur = p5
    inote = p6
    ivelocity = p7
    
    prints "captured -- i 1 %f %f %d %f\n", istart, idur, inote, \
           ivelocity
    Sline sprintf "i 1 %f %f %d %f\n", istart, \
            idur, inote, ivelocity
    fprints "captured.sco", Sline
    gScore strcat gScore, Sline
    gkcounter = gkcounter + 1
    Snum sprintfk "%i", gkcounter
    outvalue "numnotes", Snum
    turnoff
endin

instr $Playback
    S1 = gScore
linesleft:
    ipos strindex S1, "\n"
    if ipos == -1 igoto nomorelines
    Sline strsub S1, 0, ipos
    Stext strcat "playing -- ", Sline
    prints Stext
    prints "\n"
    scoreline_i Sline
    S1 strsub S1, ipos + 1
    igoto linesleft
nomorelines:
endin

instr $Record
    gkrecord = p4
    gkoffset times
    Srecording = ""
    if p4 == 1 then
        Srecording = "Recording"
    endif
    outvalue "recording", Srecording
endin

instr $Clear
    gkrecord init 0
    gkcounter init 0
    gScore = ""
    prints "Memory cleared."
    turnoff
endin

instr $Init
    outvalue "numnotes", "0"
    outvalue "recording", ""
endin

</CsInstruments>
<CsScore>
; Instruments
# define MIDI_Synth     # 1 #
# define Echo           # 2 #
# define Capture_Events # 100 #
# define Init           # 500 #

; Turn on echo effects
i $Echo 0 10000 1 0.333 0.333 0.2 0.2
i $Init 0 0.1

</CsScore>
</CsoundSynthesizer>


<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 767 231 339 346
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {56934, 58538, 65535}
ioButton {219, 247} {100, 30} event 1.000000 "button1" "Clear memory" "/" i202 0 1
ioButton {78, 300} {170, 30} event 1.000000 "button1" "Play events" "/" i200 0 -3600
ioButton {15, 247} {100, 30} event 1.000000 "button1" "Start Record" "/" i201 0 0.1 1
ioButton {117, 247} {100, 30} event 1.000000 "button1" "Pause Record" "/" i201 0 0.1 0
ioText {232, 221} {80, 25} display 5.000000 0.00100 "numnotes" center "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 5
ioText {15, 198} {203, 45} display 0.000000 0.00100 "recording" left "Lucida Grande" 20 {49920, 8192, 0} {65280, 65280, 65280} background border 
ioText {221, 198} {102, 24} label 0.000000 0.00100 "" center "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Number recorded
ioText {24, 6} {292, 35} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border MIDI Recorder
ioText {15, 47} {308, 134} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {59648, 58368, 65280} background border This file can record incoming MIDI notes or realtime score events from the Live Event Panels, both to memory and to a csd file called "captured.sco". The file will be created in the current directory, so if you haven't saved this example, it can be created anywhere...
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="1200" y="349" width="445" height="314">i 1 0 0.255419 61 64.000000 
 </EventPanel>