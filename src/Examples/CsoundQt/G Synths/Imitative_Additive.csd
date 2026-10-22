<CsoundSynthesizer>
<CsOptions>
--midi-key   = 4 --midi-velocity-amp = 5 -m128
--env:SSDIR+= ../../SourceMaterials
</CsOptions>
<CsInstruments>
/***Imitative Additive Synthesis***/
; example for CsoundQt
; joachim heintz mar 2011

sr = 44100
ksmps = 64
nchnls = 1
0dbfs = 1

; ============================================================================;
; ============================================================================;
; General values for fourier transformation                   ;
; ============================================================================;
; ============================================================================;

gifftsiz = 1024          ; fft size
giovlap  = gifftsiz / 4  ; overlap
giwinsiz = gifftsiz * 2  ; window size
giwintyp = 1             ; von hann window

giamps    = ftgen(0, 0, gifftsiz/2+1, 2, 0)  ; table for bin amps
giampcpy  = ftgen(0, 0, gifftsiz/2+1, 2, 0)  ; needed for the TabIndxNMax_k opcode
gifreqs   = ftgen(0, 0, gifftsiz/2+1, 2, 0)  ; table for bin freqs
gimaxindc = ftgen(0, 0, gifftsiz/2+1, 2, 0)  ; indices for temporal maxima of giamps
gisine    = ftgen(0, 0, 2^10, 10, 1)
massign 0, 10  ; send all midi key events to instr 10

chn_S "_MBrowse", 1  ; declare string channel

; ============================================================================;
; ============================================================================;
; Functions (user defined opcodes)                        ;
; ============================================================================;
; ============================================================================;

; Opcodes for using strings as arrays
; (see http://www.csounds.com/journal/issue13/StringsAsArrays.html)

opcode StrayGetEl, ii, Sijj
  ; returns the startindex and the endindex (= the first space after the element) for
  ; ielindex in String. if startindex returns -1, the element has not been found
  Stray, ielindx, isepA, isepB xin
  ; Define the separators
  isep1 = (isepA == -1 ? 32 : isepA)
  isep2 = (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
  Sep1  = sprintf("%c", isep1)
  Sep2  = sprintf("%c", isep2)
  ; Initialize some parameters
  ilen = strlen(Stray)
  istartsel = -1  ; startindex for searched element
  iendsel = -1    ; endindex for searched element
  iel = 0         ; actual number of element while searching
  iwarleer = 1
  indx = 0
  if ilen == 0 igoto end  ; don't go into the loop if Stray is empty
loop:
  Snext  = strsub(Stray, indx, indx+1)  ; next sign
  isep1p = strcmp(Snext, Sep1)          ; returns 0 if Snext is sep1
  isep2p = strcmp(Snext, Sep2)          ; 0 if Snext is sep2
  ; Next sign is not sep1 nor sep2
  if isep1p != 0 && isep2p != 0 then
    if iwarleer == 1 then     ; first character after a separator
      if iel == ielindx then  ; if searched element index
        istartsel = indx      ; set it
        iwarleer  = 0
      else            ; if not searched element index
        iel = iel+1   ; increase it
        iwarleer = 0  ; log that it's not a separator
      endif
    endif
    ; Next sign is sep1 or sep2
  else
    if istartsel > -1 then  ; if this is first selector after searched element
      iendsel = indx        ; set iendsel
      igoto end             ; break
    else
      iwarleer = 1
    endif
  endif
  loop_lt indx, 1, ilen, loop
end: xout istartsel, iendsel
endop

opcode StrayLen, i, Sjj
  ; returns the number of elements in Stray. elements are defined by two separators as
  ; ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab).
  ; if just one separator is used, isep2 equals isep1
  Stray, isepA, isepB xin
  ; Define the separators
  isep1 = (isepA == -1 ? 32 : isepA)
  isep2 = (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
  Sep1  = sprintf("%c", isep1)
  Sep2  = sprintf("%c", isep2)
  ; Initialize some parameters
  ilen    = strlen(Stray)
  icount  = 0  ; number of elements
  iwarsep = 1
  indx    = 0
  if ilen == 0 igoto end  ; don't go into the loop if String is empty
loop:
  Snext  = strsub(Stray, indx, indx+1)  ; next sign
  isep1p = strcmp(Snext, Sep1)          ; returns 0 if Snext is sep1
  isep2p = strcmp(Snext, Sep2)          ; 0 if Snext is sep2
  if isep1p == 0 || isep2p == 0 then    ; if sep1 or sep2
    iwarsep = 1                         ; tell the log so
  else                                  ; if not
    if iwarsep == 1 then                ; and has been sep1 or sep2 before
      icount  = icount + 1              ; increase counter
      iwarsep = 0                       ; and tell you are ot sep1 nor sep2
    endif
  endif
  loop_lt indx, 1, ilen, loop
end: xout icount
endop


; Opcodes for table operations

opcode TabMinVal_k(ift:i, iftlen:i):k
  kminval = tab(0, ift)
  kndx    = 1
loop:
  kval    = tab(kndx, ift)
  kmaxval = (kval < kminval ? kval : kminval)
  loop_lt kndx, 1, iftlen, loop
  xout kminval
endop

opcode TabMaxValIndx_k(ift:i, iftlen:i, kstrt:k, kshft:k):(k, k)
  ; returns the maximum value of a function table and its index
  ; ftable, length, startindex, how many values to shift for the next value
  kndx = kstrt
  kresultindx = kstrt
  kresultval = tab(kstrt, ift)  ; first value in the table as comparision
loop:
  kval = tab(kndx, ift)
  if kval > kresultval then
    kresultindx = kndx
    kresultval  = kval
  endif
  loop_lt kndx, kshft, iftlen, loop
  xout kresultval, kresultindx
endop

opcode TabIndxNMax_k(iftsrc:i, isrclen:i, iftcpy:i, iftdest:i, khowmany:k):()
  ; returns the indices of the first khowmany largest values in iftsrc and writes them in
  ; iftdest
  ; bin 0 is omitted (shift value in TabMaxValIndx_k)
  tablecopy iftcpy, iftsrc             ; leave iftsrc (= amp table) untouched
  kmin = TabMinVal_k(iftcpy, isrclen)  ; smallest value in iftsrc
  kwritindx = 0
loop:
  kval, kndx TabMaxValIndx_k iftcpy, isrclen, 1, 1  ; gets index for maximum
  tabw kmin-1, kndx, iftcpy                         ; replace this maximum by kmin-1
  tabw kndx, kwritindx, iftdest                     ; write the index to index table
  loop_lt kwritindx, 1, khowmany, loop
endop


; Miscellaneous

opcode BufPlay1(ifn:i, iskip:i):a
  icps = 1 / (ftlen(ifn) / ftsr(ifn))
  iphs = iskip / (ftlen(ifn) / ftsr(ifn))
  asig = poscil3(1, icps, ifn, iphs)
  xout asig
endop

opcode Stayed(kin:k, ksec:k):k
  ; outputs 1 if kin has not changed since ksec seconds, otherwise outputs 0
  kout   = init(0)
  knumk  = ksec * kr  ; number of control cycles for ksec
  kinit  = init(1)
  kcount = init(0)
  if kinit == 1 then  ; just once, at the beginning
    kprevious = kin
    kinit = 0
  endif
  if kin == kprevious then
    kcount = kcount + 1
  else
    kcount    = 0
    kprevious = kin
  endif
  if kcount > knumk then
    kout = 1
  else
    kout = 0
  endif
  xout kout
endop

opcode ShowLED_a(Soutchan:S, asig:a, kdispfreq:k, kdb:k, kdbrange:k):()
  ; Shows an audio signal in an outvalue channel. You can choose to show the value in dB
  ; or in raw amplitudes.
  ; Soutchan: string with the name of the outvalue channel
  ; asig: audio signal which is to displayed
  ; kdispfreq: refresh frequency (Hz)
  ; kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
  ; kdbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything
  ; from a signal below -36 dB)
  kdispval max_k asig, kdispfreq, 1
  if kdb != 0 then
    kdb  = dbfsamp(kdispval)
    kval = (kdbrange + kdb) / kdbrange
  else
    kval = kdispval
  endif
  outvalue Soutchan, kval
endop

opcode ShowOver_a(Soutchan:S, asig:a, kdispfreq:k, khold:k):()
  ; Shows if the incoming audio signal was more than 1 and stays there for some time
  ; Soutchan: string with the name of the outvalue channel
  ; asig: audio signal which is to displayed
  ; kdispfreq: refresh frequency (Hz)
  ; khold: time in seconds to "hold the red light"
  kon    = init(0)
  ktim   = times()
  kstart = init(0)
  kend   = init(0)
  khold  = (khold < .01 ? .01 : khold)  ; avoiding too short hold times
  kmax max_k asig/0dbfs, kdispfreq, 1
  if kon == 0 && kmax > 1 then
    kstart = ktim
    kend   = kstart + khold
    outvalue Soutchan, kmax
    kon = 1
  endif
  if kon == 1 && ktim > kend then
    outvalue Soutchan, 0
    kon = 0
  endif
endop


; ============================================================================;
; ============================================================================;
; Instrument blocks                               ;
; ============================================================================;
; ============================================================================;

instr 1       ; always on
  turnon 999  ; monitoring the audio output


  ; ============================================================================;
  ; Receiving user input from the widget panel                  ;
  ; ============================================================================;

  ; Input to be analyzed
  Sfiles   = chnget("_MBrowse")  ; selection of sound files
  kinch    = chnget("inch")      ; number of live input channel
  kgain    = chnget("gain")      ; live input gain (dB)
  kselsamp = chnget("sample")    ; 1 = select sample input
  gksampnr = chnget("sampnr")    ; 1, 2, ... for selecting a sample from the sf bank
  keysel   = chnget("keysel")    ; 1=enable selection of sample by computer number keys
  ksellive = chnget("live")      ; 1 = select live input
  kdolive  = chnget("dolive")    ; when button pressed, live input to be analyzed

  ; Analysis parameters
  kpos = chnget("pos")               ; position in buffer (0-1)
  kfast = chnget("fast")             ; how fast to react to position changes (sec)
  kpartsana = chnget("numpartsana")  ; number of strongest partials to analyze
  kmanpos = chnget("manpos")         ; manually selected position
  krandpos = chnget("randpos")       ; random position selected
  krndpos1 = chnget("rndpos1")       ; lower limit for random pointer (0-1)
  krndpos2 = chnget("rndpos2")       ; upper limit for random pointer (0-1)
  khopmove = chnget("hopmove")       ; hop move selected
  khopmvsiz = chnget("hopmovsiz")    ; size of hopping in fractions of the table

  ; Playback parameters
  gkvol = chnget("vol")             ; overall volume (dB)
  gkmaxdur = chnget("maxdur")       ; maximum duration of a note in seconds
  gkhowmany = chnget("numpartspl")  ; how many partials to be played back
  gkshiftpl = chnget("shiftpl")     ; number of strongest partials to skip for playback
  gkrefpch = chnget("refpch")       ; midi note number for playing at original pitch
  ; how many cents to transpose for adjacent semitones on the midi keyboard
  gkstcent = chnget("stcent")
  gkrndfqdv = chnget("rndfqdv")   ; maximal partial random frequency deviation (cent)
  gkrdampdv = chnget("rndampdv")  ; maximal partial random amplitude deviation (dB)
  gkrddurdv = chnget("rnddurdv")  ; maximal partial random duration deviation (%)
  gkatt = chnget("att")           ; attack time (sec)
  gkdec = chnget("dec")           ; decay time (sec)
  gksus = chnget("sus")           ; sustain level (0-1)
  gkrel = chnget("rel")           ; release time (sec)

  ; Print and export
  kprint  = chnget("print")     ; 1 = print current values
  kexp1   = chnget("exp1")      ; export printout
  gSfexp1 = chnget("_Browse1")  ; file for printout export
  kexp2   = chnget("exp2")      ; export amp-freq
  gSfexp2 = chnget("_Browse2")  ; file for amp-freq export
  kexp3   = chnget("exp3")      ; export as tables with multipliers
  gSfexp3 = chnget("_Browse3")  ; file for table multiplier export

  ; Regulating the switch between certain buttons
  ; analysis source
  ksllivnew = changed(ksellive)
  kslsmpnew = changed(kselsamp)
  if kslsmpnew == 1 && kselsamp == 1 then
    chnset(0, "live")
  elseif ksllivnew == 1 && ksellive == 1 then
    chnset(0, "sample")
  endif
  ; pointer method
  kmnposnew = changed(kmanpos)
  krdposnew = changed(krandpos)
  khopmvnew = changed(khopmove)
  if kmnposnew == 1 && kmanpos == 1 then
    chnset(0, "randpos")
    chnset(0, "hopmove")
  elseif krdposnew == 1 && krandpos == 1 then
    chnset(0, "manpos")
    chnset(0, "hopmove")
    knewrdpos = 1
  elseif khopmvnew == 1 && khopmove == 1 then
    chnset(0, "manpos")
    chnset(0, "randpos")
    knewhpmv = 1
  endif

  ; Calculating a new position if random or hopmove selected
  ; if note-on message has been received
  kst, k0, k0, k0 midiin
  if kst == 144 then
    ; calculate new random position if selected
    if krandpos == 1 then
      kpos = random(krndpos1, krndpos2)
      chnset(kpos, "pos")
      knewrdpos = 1
      ; calculate new hop position if selected
    elseif khopmove == 1 then
      kpos = frac(kpos+khopmvsiz)
      kpos = (kpos < 0 ? 1-kpos : kpos)
      chnset(kpos, "pos")
      knewhpmv = 1
    endif
  endif

  ; Enable computer keys for switching
  if keysel == 1 then
    key, k0 sensekey
    keychange = changed(key)
    if keychange == 1 && k0 == 1 then  ; new key down
      if key > 47 && key < 58 then     ; number keys 0-9
        event "i", 3, 0, .1, key
      elseif key == 112 || key == 114 || key == 104 then  ; p/r/h
        event "i", 4, 0, .1, key
      elseif key == 115 || key == 108 then  ; s/l
        event "i", 5, 0, .1, key
      endif
    endif
  endif



  ; ============================================================================;
  ; Setting some basic values                           ;
  ; ============================================================================;

  iftdatlen = ftlen(giamps)     ; length of amp/freq tables
  iftmaxlen = ftlen(gimaxindc)  ; length of maxima table
  kwritten  = init(0)           ; 1 = having written new values in giamps/gifreqs
  kwritliv  = init(0)           ; write the fft-analysis of the live signal ...
  kwritsmp  = init(0)           ; ... or of the selected sample position to the tables


  ; ============================================================================;
  ; Loading input files and calculating pointer position             ;
  ; ============================================================================;

  ; Loading the selected files in function tables 1, 2, ... And storing sf lengths
  inumfils = StrayLen(Sfiles, 124)           ; how many files (separated by '|') to load
  giftsflns = ftgen(0, 0, -inumfils, -2, 0)  ; empty table for sound file lenghths
  iload = 0
load:
  ist, ien StrayGetEl Sfiles, iload, 124
  Sfil  = strsub(Sfiles, ist, ien)
  inoth = ftgen(iload+1, 0, 0, 1, Sfil, 0, 0, 1)  ; storing sf data in table 1, 2, ...
  ilen  = filelen(Sfil)
  tabw_i ilen, iload, giftsflns  ; storing sf lenghts in table giftsflns
  loop_lt iload, 1, inumfils, load

  ; Calculating and showing the position of the pointer
  kthissamp = (gksampnr > inumfils ? inumfils : gksampnr)
  kfilen    = tab(kthissamp-1, giftsflns)
  kpossec   = kpos * kfilen  ; position in sec
  chnset(kpossec, "position")

  ; Showing whenever a new sample has been selected
newfile:
  itable = i(kthissamp)
  ist, ien StrayGetEl Sfiles, itable-1, 124
  Sfil = strsub(Sfiles, ist, ien)
  ilslash = strrindex(Sfil, "/")
  Sname = strsub(Sfil, ilslash+1)
  Showname = sprintf("File selected:\n'%s'", Sname)
  rireturn
  knewtable = changed(kthissamp)
  if knewtable == 1 then
    reinit newfile
    chnset(Showname,   "showname")
    chnset(-kthissamp, "showtab")
  endif



  ; ============================================================================;
  ; Receiving live input                             ;
  ; ============================================================================;

  ain inch kinch
  ain   = ain*ampdb(kgain)
  kdisp = metro(10)
  ShowLED_a  "livein", ain, kdisp, 1, 50
  ShowOver_a "livein_over", ain, kdisp, 1



  ; ============================================================================;
  ; Continuously streaming fft signals from live and from the selected sample ;
  ; ============================================================================;

  ; Streaming the fft live signal
  flive = pvsanal(ain, gifftsiz, giovlap, giwinsiz, giwintyp)
  ; Streaming the fft signal from the selected sample whenever a new position is given
  knewpos = changed(kpos, kthissamp, kslsmpnew, kmnposnew, krdposnew, khopmvnew)
  if knewpos == 1 then
    reinit readsampnew
  endif
readsampnew:
  fsamp = pvstanal(0, 1, 1, kthissamp, 0, 0, i(kpossec), gifftsiz, giovlap, 0)
  rireturn



  ; ============================================================================;
  ; Select input and set variables for writing the tables            ;
  ; ============================================================================;

  ; Set kwritliv=1 in the k-cycle the "dolive" button has been pressed
  if ksellive == 1 then  ; live source must be selected
    klivenew = changed(kdolive)
    if klivenew == 1 && kdolive == 1 then
      kwritliv = 1
    endif

    ; Set writesamp=1 if a new pointer position has been set,
    ; Selector has changed or button has been switched
  elseif kselsamp == 1 then  ; sample source selected
    ; manual position
    if kmanpos == 1 then
      kpstayed = Stayed(kpos, kfast)  ; returns 1 if pos has not changed for kfast seconds
      knewpos  = changed(kpstayed)
      if (knewpos == 1 && kpstayed == 1) || knewtable == 1 || kslsmpnew == 1 then
        kwritsmp = 1
      endif
      ; random position
    elseif knewrdpos == 1 then
      kwritsmp = 1
      ; hop position
    elseif knewhpmv == 1 then
      kwritsmp = 1
    endif
  endif



  ; ============================================================================;
  ; Fill the tables with the current ampltitude/frequency values        ;
  ; ============================================================================;

  ; Initialize counters
  ksmpcnt = init(0)
  klivcnt = init(0)

  ; Live input selected
  if kwritliv == 1 then
    kwritten = pvsftw(flive, giamps, gifreqs)
    if kwritten == 1 then
      klivcnt = klivcnt + 1
      printks " New live values written! (%d)\n", 0, klivcnt
      kwritliv = 0
    endif

    ; Sound file input selected
  elseif kwritsmp == 1 then
    kwritten = pvsftw(fsamp, giamps, gifreqs)
    if kwritten == 1 then
      ksmpcnt = ksmpcnt + 1
      printks " New sample values written (%d)!\n", 0, ksmpcnt
      kwritsmp  = 0
      knewrdpos = 0
      knewhpmv  = 0
    endif
  endif



  ; ================================================================================;
  ; Analyze bin amplitudes and fill index-table if amp/freq-tables have been updated;
  ; ================================================================================;

  if kwritten == 1 then  ; writing via pvsftw has been finished
    TabIndxNMax_k giamps, iftdatlen, giampcpy, gimaxindc, kpartsana
    gkthsnman = kpartsana  ; number of partials in this analysis



    ; ============================================================================;
    ; Print values if desired and if new values available             ;
    ; ============================================================================;

    if kprint == 1 && kwritten == 1 then
      kprntndx = 0
      if kselsamp == 1 then
        Sprint = sprintfk("File '%s' at position %f seconds:\n", Sname, kpossec)
      elseif ksellive == 1 then
        Sprint = sprintfk("%s\n", "Live input:")
      else
        Sprint = ""
      endif
printout:
      ktabindx = tab(kprntndx, gimaxindc)
      kamp = tab(ktabindx, giamps)
      kfreq = tab(ktabindx, gifreqs)
      Snew = sprintfk("%s%.2d) amp = %f, freq = %f, bin = %d\n", Sprint, kprntndx+1, kamp, kfreq, ktabindx)
      Sprint = strcpyk(Snew)
      loop_lt kprntndx, 1, kpartsana, printout
      chnset(Sprint, "values")
      gSexpt1 = strcpyk(Sprint)
    else
      chnset("", "values")
    endif
  endif



  ; ============================================================================;
  ; Export values if desired                          ;
  ; ============================================================================;

  kexp1new = changed(kexp1)
  kexp2new = changed(kexp2)
  kexp3new = changed(kexp3)

  ; Export in the same format as in the widget panel
  if kexp1new == 1 && kexp1 == 1 then
    event "i", 6, 0, .1

    ; Export as raw amp-freq pair per line
  elseif kexp2new == 1 && kexp2 == 1 then
    kexpt2ndx = 0
    if kselsamp == 1 then
      gSexpt2 = sprintfk("Amp-Freq values for file '%s' at position %f seconds:\n", Sname, kpossec)
    elseif ksellive == 1 then
      gSexpt2 = sprintfk("%s\n", "Amp-Freq values for live input:")
    endif
expt2:
    ktabindx = tab(kexpt2ndx, gimaxindc)
    kamp = tab(ktabindx, giamps)
    kfreq = tab(ktabindx, gifreqs)
    Snew = sprintfk("%s%f %f\n", gSexpt2, kamp, kfreq)
    gSexpt2 = strcpyk(Snew)
    loop_lt kexpt2ndx, 1, kpartsana, expt2
    event "i", 7, 0, .1

    ; Export as multipliers in function tables
  elseif kexp3new == 1 && kexp3 == 1 then
    kexpt3cnt = init(0)  ; counter
    kexpt3cnt = kexpt3cnt+1
    ; get reference frequency for frequency multiplier = 1
    ktabindx = tab(0, gimaxindc)
    kfreq0   = tab(ktabindx, gifreqs)  ; frequency corresponding to strongest amplitude
    if kselsamp == 1 then
      Sexpt3 = sprintfk("Amp-Freq multiplier for file '%s' at position %f seconds.\nPitch at frequency multiplier 1 was %f Hz.\n", Sname, kpossec, kfreq0)
    elseif ksellive == 1 then
      Sexpt3 = sprintfk("Amp-Freq multiplier for live input.\nPitch at frequency multiplier 1 was %f Hz.\n", kfreq0)
    endif
    Samptab   = sprintfk("giAmp%d ftgen 0, 0, -%d, -2", kexpt3cnt, kpartsana)
    Sfreqtab  = sprintfk("giFreq%d ftgen 0, 0, -%d, -2", kexpt3cnt, kpartsana)
    kexpt3ndx = 0
expt3:
    ktabindx = tab(kexpt3ndx, gimaxindc)
    kamp = tab(ktabindx, giamps)
    kfreq = tab(ktabindx, gifreqs)
    kfmult = kfreq/kfreq0
    Snewamp = sprintfk("%s, %f", Samptab, kamp)
    Snewfreq = sprintfk("%s, %f", Sfreqtab, kfmult)
    Samptab = strcpyk(Snewamp)
    Sfreqtab = strcpyk(Snewfreq)
    loop_lt kexpt3ndx, 1, kpartsana, expt3
    gSexpt3 = sprintfk("%s%s\n%s\n\n", Sexpt3, Samptab, Sfreqtab)
    event "i", 8, 0, .1
  endif

  kwritten = 0  ; reset kwritten at the end of each k-cycle

endin



; ============================================================================;
; Subinstrument for listening to the selected sample               ;
; ============================================================================;

instr 2
  itab = i(gksampnr)            ; number of ftable (1, 2, ...)
  idur tab_i itab-1, giftsflns  ; get length of sample
  p3   = idur
  aout = poscil3(1, 1/p3, itab)
  out aout*ampdb(gkvol)
endin



; ============================================================================;
; Subinstruments for performing actions by computer keyboard shortcuts    ;
; ============================================================================;

; Make live snapshot and change the sample number
instr 3
  ikey = p4  ; 48-57
  kcyc = timeinstk()
  if ikey == 48 then
    chnset(1, "dolive")
  else
    chnset(ikey-48, "sampnr")
  endif
  if kcyc == 2 then
    chnset(0, "dolive")
    turnoff
  endif
endin

; Change the pointer mode
instr 4
  ikey = p4
  if ikey == 112 then  ; p = manual pointer
    chnset(1, "manpos")
  elseif ikey == 114 then  ; r = random pointer
    chnset(1, "randpos")
  elseif ikey == 104 then  ; h = hop move
    chnset(1, "hopmove")
  endif
  turnoff
endin

; Switch between sample/live mode
instr 5
  ikey = p4
  if ikey == 115 then  ; s = sample as input
    chnset(1, "sample")
  elseif ikey == 108 then  ; l = live input
    chnset(1, "live")
  endif
  turnoff
endin



; ============================================================================;
; Subinstruments for writing values to the export textfile          ;
; ============================================================================;

; Add values in the same format as in the widget panel to the appropriate file
instr 6
  fprints gSfexp1, gSexpt1
  fprints gSfexp1, "%n"
  printf_i "Values written to file '%s'\n", 1, gSfexp1
  turnoff
endin

; Add values as raw amp-freq pairs to the appropriate file
instr 7
  fprints gSfexp2, gSexpt2
  fprints gSfexp2, "%n"
  printf_i "Values written to file '%s'\n", 1, gSfexp2
  turnoff
endin

; Add values as amp-freq multipliers to the appropriate file
instr 8
  fprints gSfexp3, gSexpt3
  printf_i "Values written to file '%s'\n", 1, gSfexp3
  turnoff
endin



; ============================================================================;
; Subinstruments for terminating the sample listening            ;
; ============================================================================;

instr 9
  turnoff2 2, 0, 0
endin



; ============================================================================;
; ============================================================================;
; MIDI-triggered instrument for the additive synthesis            ;
; ============================================================================;
; ============================================================================;

instr 10

  ; ============================================================================;
  ; Receiving basic values                           ;
  ; ============================================================================;

  inote = p4                  ; midi note number
  imidamp = p5                ; midi velocity (0-1)
  insnum = 100 + (inote/100)  ; fractional number to differentiate keys
  irefpch = i(gkrefpch)
  istcent = i(gkstcent)  ; cent difference for each semitone
  icentdif = (inote-irefpch) * istcent
  ihowmany = i(gkhowmany)
  ishift = i(gkshiftpl)
  imax = i(gkthsnman)  ; number of partials analyzed
  ihowmany = (ihowmany+ishift > imax ? imax-ishift : ihowmany)
  imaxdur = i(gkmaxdur)     ; maximum duration for one note (sec)
  irndampdv = i(gkrdampdv)  ; max amp deviation (dB)
  irndfqdv = i(gkrndfqdv)   ; max freq deviation (cent)
  irnddurdv = i(gkrddurdv)  ; max dur deviation (%)
  ivol = i(gkvol)           ; overall volume (dB)
  ; duration of each note (without random deviations)
  idur = i(gkmaxdur)
  idur = (idur < 0.1) ? 0.1 : idur  ; make sure there will not be zero duration



  ; ============================================================================;
  ; Getting the sum of all selected amplitudes for scaling            ;
  ; ============================================================================;

  indx    = ishift
  iampsum = 0
loop1:
  ; bekommt index für stärkste, zweitstärkste usw amp aus gimaxindc
  itabindx tab_i indx, gimaxindc
  iamp     tab_i itabindx, giamps  ; get 1., 2., etc strongest amps
  iampsum = iampsum + iamp
  loop_lt indx, 1, ihowmany+ishift, loop1
  indx = ishift



  ; ============================================================================;
  ; Triggering the instances of the subinstrument for playing the partials   ;
  ; ============================================================================;

loop2:
  ; Amplitudes
  ; get index for ordered amps from gimaxindc
  itabindx tab_i indx, gimaxindc
  iptamp   tab_i itabindx, giamps                    ; get 1., 2., etc strongest amps
  iptamp   = iptamp * imidamp                        ; following midi velocity
  iptdbvar = rnd31(irndampdv, 0)                     ; dB deviation
  iptamp   = ampdb(ivol) * iptamp * ampdb(iptdbvar)  ; resulting amp
  ; Frequencies
  iptfq tab_i itabindx, gifreqs      ; get related freq to selected amp
  iptfq    = cent(icentdif) * iptfq  ; transposed depending on key pressed
  iptfqvar = rnd31(irndfqdv, 0)      ; cent deviation
  iptfq    = iptfq * cent(iptfqvar)
  ; Durations
  ; percent of duration deviation (100=twice,-100=half as long)
  iptdurvar = rnd31(irnddurdv, 0)
  iptdur    = idur * 2^(iptdurvar/100)
  event_i "i", insnum, 0, iptdur, iptamp, iptfq, iampsum  ; call instr 100.nn
  loop_lt indx, 1, ihowmany+ishift, loop2



  ; ============================================================================;
  ; Stopping the instances of the subinstrument if MIDI-key has been raised   ;
  ; ============================================================================;

  krel = release()
  if krel == 1 then
    turnoff2 insnum, 4, 1
  endif
endin



; ============================================================================;
; Subinstrument for playing one partial                    ;
; ============================================================================;

instr 100
  ; Get values from instr 10 and from widgets
  iamp    = p4
  ifreq   = p5
  iampsum = p6
  iatt    = i(gkatt)
  idec    = i(gkdec)
  isus    = i(gksus)
  irel    = i(gkrel)

  ; Play a sine with adsr envelope
  apart = poscil(iamp, ifreq, gisine)
  aenv  = madsr(iatt, idec, isus, irel)
  out apart*aenv/iampsum
endin



; ============================================================================;
; Collecting all outgoing audio and sending it to the meter display      ;
; ============================================================================;

instr 999
  ktrigdisp = metro(10)
  aout = monitor()
  ShowLED_a  "out", aout, ktrigdisp, 1, 48
  ShowOver_a "out_over", aout, ktrigdisp, 2
endin


</CsInstruments>
<CsScore>
i 1 0 36000
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>15</x>
 <y>69</y>
 <width>1350</width>
 <height>659</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>874</x>
  <y>591</y>
  <width>100</width>
  <height>30</height>
  <uuid>{202c13fc-5d88-4826-a232-0e263bb5b119}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>play!</text>
  <image>/</image>
  <eventLine>i 10 0 5 60 .5</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>734</x>
  <y>71</y>
  <width>247</width>
  <height>262</height>
  <uuid>{fe6e4eec-d24b-4130-ac47-0509d6087482}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Analysis Source</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>268</x>
  <y>335</y>
  <width>247</width>
  <height>171</height>
  <uuid>{ef6762d2-df69-49d4-b2de-79768f36a0e9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Analysis Parameters</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>522</x>
  <y>335</y>
  <width>228</width>
  <height>291</height>
  <uuid>{3cfa2bba-4cba-4506-8dd0-a2cf8cba83cc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Playback Parameters</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>335</y>
  <width>225</width>
  <height>147</height>
  <uuid>{cd6f814b-6ee2-4dae-aca2-e003f0930179}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Export Parameters</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>769</x>
  <y>587</y>
  <width>107</width>
  <height>42</height>
  <uuid>{651e302b-ea78-4453-8d18-a8df59faf558}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Play Reference Pitch as test</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>268</x>
  <y>508</y>
  <width>247</width>
  <height>118</height>
  <uuid>{ad09a76a-5d31-4cc9-a269-5668506ed9cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Envelope</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>485</y>
  <width>225</width>
  <height>99</height>
  <uuid>{732add43-b213-4020-acb2-56175ca913dc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Output</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>13</y>
  <width>1299</width>
  <height>49</height>
  <uuid>{9705422d-67f5-4b92-b66a-cdadf1801e9f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>IMITATIVE ADDITIVE SYNTHESIS</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>40</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>221</y>
  <width>255</width>
  <height>460</height>
  <uuid>{d56a8527-e63b-4d47-9cfc-2f4d90bdcb24}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>This instrument lets you analyze a number of partials, ordered by their amplitudes, in any sound snapshot in realtime, and play it back with additive synthesis. You can either use any prerecorded sound, or live input, and switch between these sources.
SAMPLE:
Select a list of audio files. Activate the "Sample" button in the "Analysis Source" section. Select one of them by the number box. (If you activate the "Enable Keys" button, you can also select Samples 1-9 by the number keys.) You will see the waveform of the selected sample in the graph widget.
Choose the number of partials you want to analyze, in the "Analysis Parameters" section, and the position in the soundfile. The "Pointer" option lets you choose the position manually (in the bar below the graph widget). The "Random" option will choose a random position in a range, each time a note has been played. The "Hop Move" option will move gradually through the sound.
LIVE:
Select "Live" as analysis source (key "L"). Whenever you push the "Get Live Snapshot!" button (key = "0"), the current live input is analyzed.
PLAYBACK:
Playback is done via midi. At the refence key, the sound will be played back at the same pitch as analyzed. The "Midi Key Cent Deviation" is the transposition to the next midi key, in cents.
EXPORT:
When the "Print current values" button is activated, the analyzed partials are shown at the right side.  For writing the values to a file, you have three different options: export in the same was the values are shown, as war amplitude-frequency values, or as function tables with amplitudes and frequency multipliers. Whenever the "Now!" button is pressed, the current values are written to the text file selected by the "To..." button.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>65</r>
   <g>65</g>
   <b>65</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>values</objectName>
  <x>995</x>
  <y>119</y>
  <width>312</width>
  <height>502</height>
  <uuid>{104a6eb1-9c4e-4dc2-85c7-a27518fe09b3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>File 'bell.aiff' at position 0.156075 seconds:
01) amp = 0.157462, freq = 883.870605, bin = 21
02) amp = 0.146633, freq = 884.567993, bin = 20
03) amp = 0.135147, freq = 476.610565, bin = 11
04) amp = 0.131553, freq = 372.406586, bin = 9
05) amp = 0.118698, freq = 366.300812, bin = 8
06) amp = 0.086246, freq = 84.113129, bin = 2
07) amp = 0.085053, freq = 501.003845, bin = 10
08) amp = 0.083320, freq = 2447.225098, bin = 57
09) amp = 0.079914, freq = 51.505806, bin = 1
10) amp = 0.079458, freq = 594.384155, bin = 14
11) amp = 0.068787, freq = 484.265411, bin = 12
12) amp = 0.063580, freq = 116.272369, bin = 3
13) amp = 0.057279, freq = 2442.896240, bin = 56
14) amp = 0.056479, freq = 307.501007, bin = 7
15) amp = 0.055476, freq = 255.095337, bin = 6
16) amp = 0.055435, freq = 225.735062, bin = 5
17) amp = 0.050937, freq = 584.701050, bin = 13
18) amp = 0.046534, freq = 1213.459473, bin = 28
19) amp = 0.042123, freq = 1588.513184, bin = 37
20) amp = 0.035536, freq = 876.142334, bin = 22
21) amp = 0.035124, freq = 584.020447, bin = 15
22) amp = 0.033349, freq = 2453.455811, bin = 58
23) amp = 0.030820, freq = 1217.297241, bin = 29
24) amp = 0.025115, freq = 255.966904, bin = 4
25) amp = 0.023024, freq = 1589.229858, bin = 36
26) amp = 0.021252, freq = 1603.028198, bin = 38
27) amp = 0.017921, freq = 733.842896, bin = 19
28) amp = 0.014162, freq = 1993.371704, bin = 46
29) amp = 0.013220, freq = 960.022034, bin = 23
30) amp = 0.013042, freq = 1211.234375, bin = 27
31) amp = 0.010606, freq = 2003.215576, bin = 47
32) amp = 0.010236, freq = 3102.525391, bin = 72
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>65</r>
   <g>65</g>
   <b>65</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>990</x>
  <y>70</y>
  <width>319</width>
  <height>556</height>
  <uuid>{404b0422-2cbd-4c4a-9433-a4e9c805789c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Analysis Values</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>livein</objectName>
  <x>861</x>
  <y>180</y>
  <width>92</width>
  <height>20</height>
  <uuid>{aea96bd2-66c8-46ed-ba64-42a9b473cfbc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>livein</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.25549939</xValue>
  <yValue>0.25549939</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>45</r>
   <g>208</g>
   <b>45</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>livein_over</objectName>
  <x>947</x>
  <y>180</y>
  <width>20</width>
  <height>20</height>
  <uuid>{714f538d-b15d-450f-8243-f731e47cec08}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>livein_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>230</r>
   <g>50</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>gain</objectName>
  <x>861</x>
  <y>205</y>
  <width>80</width>
  <height>20</height>
  <uuid>{a2a3113b-ea7c-4113-8aa5-22318f22d899}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>1.58490566</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>dolive</objectName>
  <x>861</x>
  <y>230</y>
  <width>106</width>
  <height>41</height>
  <uuid>{dacdf18f-bde4-4a64-8973-9285e8c73e68}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Get Live
Snapshot!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>941</x>
  <y>201</y>
  <width>39</width>
  <height>24</height>
  <uuid>{5db562b3-eb02-48d2-9792-3c725a677612}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>sample</objectName>
  <x>738</x>
  <y>114</y>
  <width>104</width>
  <height>30</height>
  <uuid>{c2700f76-0407-44bb-9c6a-6440205a419f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Sample</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>live</objectName>
  <x>863</x>
  <y>115</y>
  <width>104</width>
  <height>30</height>
  <uuid>{4f1cac68-9cfe-4663-8847-2319835a203e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Live</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>862</x>
  <y>149</y>
  <width>62</width>
  <height>26</height>
  <uuid>{e8dc513b-db58-4aaf-97ba-50df3ef532da}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Channel</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>inch</objectName>
  <x>927</x>
  <y>148</y>
  <width>40</width>
  <height>27</height>
  <uuid>{fd2c2663-b818-4bc2-9e3c-933480540979}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>740</x>
  <y>148</y>
  <width>57</width>
  <height>24</height>
  <uuid>{0ee3a50b-51d8-4bc9-813e-f0d565c01f96}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Number</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>sampnr</objectName>
  <x>801</x>
  <y>147</y>
  <width>40</width>
  <height>27</height>
  <uuid>{ccb65c55-41fe-46ef-a983-94752dc3b1d5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b7803</objectName>
  <x>740</x>
  <y>178</y>
  <width>56</width>
  <height>25</height>
  <uuid>{216588f6-fc24-4a02-8159-df22c0689436}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play it</text>
  <image>/</image>
  <eventLine>i 2 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>740</x>
  <y>225</y>
  <width>104</width>
  <height>102</height>
  <uuid>{96551f1f-2888-4e8b-92a5-fe5f40650b1b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>S = Sample Input,
1-9 = Sample Selection,
P/R/H  = Pointer Mode.
L = Live Input,
0 = Snapshot</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>keysel</objectName>
  <x>740</x>
  <y>205</y>
  <width>104</width>
  <height>21</height>
  <uuid>{c546d668-bca5-4c14-a13d-d18c5b844efe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Enable Keys</text>
  <image>/</image>
  <eventLine>i 2 0 1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b7716</objectName>
  <x>797</x>
  <y>178</y>
  <width>47</width>
  <height>25</height>
  <uuid>{1d2f4673-864c-4aa6-a813-6f4b73fe536e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i 9 0 .1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>267</x>
  <y>71</y>
  <width>458</width>
  <height>262</height>
  <uuid>{8cbb0d66-be77-44fb-9fea-1c2d42f85655}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Analysis Source</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_MBrowse</objectName>
  <x>275</x>
  <y>75</y>
  <width>343</width>
  <height>29</height>
  <uuid>{fe1e66fe-4105-4aed-9c04-e06ef3c95aa2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>fox.wav|bell.aiff|BratscheMono.wav|Wood.wav</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_MBrowse</objectName>
  <x>620</x>
  <y>75</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7e9d3773-29f5-4906-91f7-3e35e562dfa6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.wav|bell.aiff|BratscheMono.wav|Wood.wav</stringvalue>
  <text>Select Files</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>pos</objectName>
  <x>272</x>
  <y>242</y>
  <width>450</width>
  <height>40</height>
  <uuid>{a8250334-53f7-4e66-aa18-2b9be5ff9466}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>pos</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.69719168</xValue>
  <yValue>0.69719168</yValue>
  <type>line</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>591</x>
  <y>280</y>
  <width>104</width>
  <height>25</height>
  <uuid>{47aae0f0-46ca-4f1b-a3ba-5923cc3fb761}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Position (sec):</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>position</objectName>
  <x>612</x>
  <y>302</y>
  <width>55</width>
  <height>26</height>
  <uuid>{87aa8561-e21a-4634-9693-ad2680b9d547}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.156</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>showtab</objectName>
  <x>272</x>
  <y>109</y>
  <width>449</width>
  <height>138</height>
  <uuid>{193d6210-1914-4ba1-b1b3-6f813a1eecbb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>showname</objectName>
  <x>274</x>
  <y>282</y>
  <width>172</width>
  <height>50</height>
  <uuid>{b7f9aafe-e4c4-4837-aacf-13c309c3899d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>File selected:
'bell.aiff'</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>248</r>
   <g>248</g>
   <b>54</b>
  </color>
  <bgcolor mode="nobackground">
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>365</y>
  <width>137</width>
  <height>27</height>
  <uuid>{e05fc469-2f58-410b-9806-dc9cb7655d4b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Print current values</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>392</y>
  <width>132</width>
  <height>28</height>
  <uuid>{2a973632-d5ee-4246-ae9f-4db7349afc29}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Export current values</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>887</x>
  <y>393</y>
  <width>48</width>
  <height>26</height>
  <uuid>{7b71257f-6fef-494d-a260-98647d7ffc68}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/Presentation/test/export1.txt</stringvalue>
  <text>To...</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>419</y>
  <width>132</width>
  <height>28</height>
  <uuid>{c453cf7a-dbdd-4bc9-9c96-37d7e39c3a30}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Export as freq-amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse2</objectName>
  <x>886</x>
  <y>419</y>
  <width>48</width>
  <height>26</height>
  <uuid>{5bbf7fad-0c36-4780-a07d-a60f81d40d90}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/Presentation/test/export2.txt</stringvalue>
  <text>To...</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>756</x>
  <y>446</y>
  <width>132</width>
  <height>27</height>
  <uuid>{d574f198-bfad-40b6-b163-c4046e3878bf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Export as table</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse3</objectName>
  <x>886</x>
  <y>447</y>
  <width>48</width>
  <height>25</height>
  <uuid>{709af31e-5c0e-483f-a8e6-d0a51351680e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/Presentation/test/export3.txt</stringvalue>
  <text>To...</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>print</objectName>
  <x>892</x>
  <y>366</y>
  <width>83</width>
  <height>25</height>
  <uuid>{33968315-e837-4af4-bdf2-98480bf44c91}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Print</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>exp1</objectName>
  <x>930</x>
  <y>393</y>
  <width>51</width>
  <height>26</height>
  <uuid>{109e08e0-b1c7-4c4f-a2a2-18469fd6a4bb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Now!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>exp2</objectName>
  <x>929</x>
  <y>420</y>
  <width>52</width>
  <height>25</height>
  <uuid>{6d4111e8-cd9f-4140-9d7f-8dfb008c6564}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Now!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>exp3</objectName>
  <x>929</x>
  <y>447</y>
  <width>52</width>
  <height>25</height>
  <uuid>{7980b3f7-f6bc-4798-8a65-f58642700fb3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Now!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out</objectName>
  <x>767</x>
  <y>516</y>
  <width>172</width>
  <height>28</height>
  <uuid>{dfa0444b-a225-47a5-a1db-3ac7e63f8034}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>45</r>
   <g>208</g>
   <b>45</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out_over</objectName>
  <x>937</x>
  <y>516</y>
  <width>28</width>
  <height>28</height>
  <uuid>{02c1d76c-5c5d-4a11-93b4-21dc54706c90}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>out_over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>230</r>
   <g>50</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>vol</objectName>
  <x>768</x>
  <y>551</y>
  <width>149</width>
  <height>21</height>
  <uuid>{d0dd7c29-31c8-4847-bb6c-7707ff1f3570}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-1.53020134</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>948</x>
  <y>548</y>
  <width>30</width>
  <height>28</height>
  <uuid>{2918f563-dce4-45c5-96e8-07df0b671f27}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>275</x>
  <y>370</y>
  <width>189</width>
  <height>27</height>
  <uuid>{b609249e-e278-4c26-9182-01086a1f20e3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Number of Partials to analyze</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>fast</objectName>
  <x>458</x>
  <y>404</y>
  <width>50</width>
  <height>25</height>
  <uuid>{22a49672-685f-4628-8c6f-6fe2e09a6a9c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>0.1</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>354</x>
  <y>403</y>
  <width>102</width>
  <height>27</height>
  <uuid>{599be8ec-f1b9-434a-b229-1f693270447d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Activation (sec)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>numpartsana</objectName>
  <x>462</x>
  <y>371</y>
  <width>46</width>
  <height>26</height>
  <uuid>{caec7ed3-498b-4458-ac4e-57fac52c4df9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>64</maximum>
  <randomizable group="0">false</randomizable>
  <value>32</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>hopmove</objectName>
  <x>275</x>
  <y>435</y>
  <width>90</width>
  <height>28</height>
  <uuid>{38e30cb8-9e88-4dc9-8d09-b30f75c2e0c4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Hop Move</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>380</x>
  <y>435</y>
  <width>68</width>
  <height>27</height>
  <uuid>{5da20281-4647-40b9-8499-ee43eff43519}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Fraction</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>hopmovsiz</objectName>
  <x>450</x>
  <y>437</y>
  <width>58</width>
  <height>26</height>
  <uuid>{f7598ae6-c54e-438f-94c2-b29d932ee539}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.01000000</resolution>
  <minimum>-1</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>manpos</objectName>
  <x>275</x>
  <y>403</y>
  <width>71</width>
  <height>28</height>
  <uuid>{f8579654-8952-4866-a7cf-c0d757108732}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pointer</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>numpartspl</objectName>
  <x>695</x>
  <y>369</y>
  <width>50</width>
  <height>25</height>
  <uuid>{19be0852-85d9-4ae7-8506-e9b0d40d6dda}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>32</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>refpch</objectName>
  <x>695</x>
  <y>432</y>
  <width>50</width>
  <height>25</height>
  <uuid>{68269bfd-79e9-4749-a934-2187c48d3734}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>60</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>529</x>
  <y>432</y>
  <width>139</width>
  <height>27</height>
  <uuid>{05fccea2-ecb7-4fdc-ae15-062016397ad8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Reference Key (midi)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>stcent</objectName>
  <x>695</x>
  <y>464</y>
  <width>50</width>
  <height>25</height>
  <uuid>{b16b9f6e-73f5-4c22-83a7-c47d8f0a68da}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>100</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>463</y>
  <width>156</width>
  <height>27</height>
  <uuid>{e35d6aaa-3dcb-4e83-882d-0d51db0d867e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Midi Key Cent Deviation</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>369</y>
  <width>167</width>
  <height>27</height>
  <uuid>{c4d885cd-a6ac-413a-b148-b8c7c11d3537}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Number of Partials to play</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>shiftpl</objectName>
  <x>695</x>
  <y>400</y>
  <width>50</width>
  <height>25</height>
  <uuid>{5b84e7d0-0c82-45e2-aca9-f2d1f982970a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>31</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>399</y>
  <width>149</width>
  <height>27</height>
  <uuid>{b4cef0ea-2ef0-4c9d-ade1-702aea738fd8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Playback Partial Offset</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>rndfqdv</objectName>
  <x>695</x>
  <y>528</y>
  <width>50</width>
  <height>25</height>
  <uuid>{d09928e9-5e05-4ba0-bd7d-94f92a0630d4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>527</x>
  <y>518</y>
  <width>167</width>
  <height>40</height>
  <uuid>{8b426732-b781-4659-a813-de60b04656ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Partial Random Frequency  Deviation (Cent)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>rndampdv</objectName>
  <x>695</x>
  <y>560</y>
  <width>50</width>
  <height>25</height>
  <uuid>{34535596-8d50-43f6-908c-58a524740c90}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>527</x>
  <y>552</y>
  <width>162</width>
  <height>39</height>
  <uuid>{32f46896-8772-4e3c-b3d6-730806ad9ca4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Partial Random Amplitude  Deviation (dB)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>rnddurdv</objectName>
  <x>695</x>
  <y>592</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f20eb136-d9d2-4559-9fbc-6c44e6864afa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>527</x>
  <y>586</y>
  <width>158</width>
  <height>41</height>
  <uuid>{40a78d4c-b76c-4fa9-a75a-8baa76abcea9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Partial Random Duration  Deviation (%)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>maxdur</objectName>
  <x>695</x>
  <y>496</y>
  <width>50</width>
  <height>25</height>
  <uuid>{10a57f16-265b-4774-a0d6-26c3c629bf77}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>0.1</minimum>
  <maximum>2000</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>527</x>
  <y>495</y>
  <width>156</width>
  <height>27</height>
  <uuid>{ffe891f4-df20-436c-b300-6ab71182168d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Maximum Duration (sec)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>att</objectName>
  <x>290</x>
  <y>540</y>
  <width>176</width>
  <height>17</height>
  <uuid>{c00e9cc5-61b3-4190-ab37-a0227e181716}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>att</objectName2>
  <xMin>0.01000000</xMin>
  <xMax>0.20000000</xMax>
  <yMin>0.01000000</yMin>
  <yMax>0.20000000</yMax>
  <xValue>0.01755682</xValue>
  <yValue>0.01755682</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>231</r>
   <g>172</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>dec</objectName>
  <x>290</x>
  <y>559</y>
  <width>176</width>
  <height>17</height>
  <uuid>{a2de8382-412c-4b27-a075-1ae824b85ff3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>dec</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.27840909</xValue>
  <yValue>0.27840909</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>231</r>
   <g>172</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>sus</objectName>
  <x>290</x>
  <y>578</y>
  <width>176</width>
  <height>17</height>
  <uuid>{fb32d182-7973-4205-aa3e-eca37b202fc7}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>sus</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.51136364</xValue>
  <yValue>0.51136364</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>231</r>
   <g>172</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>rel</objectName>
  <x>291</x>
  <y>598</y>
  <width>176</width>
  <height>17</height>
  <uuid>{d1e99338-5f53-426a-8a8f-9124b39a69b9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>rel</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.73863636</xValue>
  <yValue>0.73863636</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#32e632</borderColor>
  <color>
   <r>231</r>
   <g>172</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>att</objectName>
  <x>463</x>
  <y>536</y>
  <width>50</width>
  <height>21</height>
  <uuid>{f887d4bf-9249-4736-84e6-71ae3883aae4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.018</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>dec</objectName>
  <x>463</x>
  <y>556</y>
  <width>50</width>
  <height>21</height>
  <uuid>{406da2a0-8ba4-40c0-91a4-09184aba8654}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.278</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>sus</objectName>
  <x>463</x>
  <y>576</y>
  <width>50</width>
  <height>21</height>
  <uuid>{0b43ed62-96ca-47f4-8056-a8459f7e4ece}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.511</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>rel</objectName>
  <x>463</x>
  <y>595</y>
  <width>50</width>
  <height>21</height>
  <uuid>{5439df97-f182-4a18-ac2e-60995d097127}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.739</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>537</y>
  <width>19</width>
  <height>24</height>
  <uuid>{da37e1dc-1232-49cb-a919-4218bd97460a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>556</y>
  <width>19</width>
  <height>24</height>
  <uuid>{e3ad5e24-3b8f-4013-a0d8-a1fac6cb0133}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>575</y>
  <width>19</width>
  <height>24</height>
  <uuid>{4364c297-c8a3-472b-a4f8-14dbc6c5d226}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>593</y>
  <width>19</width>
  <height>24</height>
  <uuid>{f3d92b16-98c4-4c99-98f2-483a79a2314f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>350</x>
  <y>470</y>
  <width>60</width>
  <height>28</height>
  <uuid>{6fdc67be-6b4e-4f62-99ab-fa4ed69aff12}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>between</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>randpos</objectName>
  <x>275</x>
  <y>467</y>
  <width>77</width>
  <height>28</height>
  <uuid>{79f6ce72-902a-4ba6-a0df-fd33b6169a3f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Random</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </color>
  <pressedColor/>
  <borderColor>#717155</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>rndpos1</objectName>
  <x>410</x>
  <y>471</y>
  <width>50</width>
  <height>25</height>
  <uuid>{ddedf240-0604-49f7-9f8c-880d31f26d17}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>0</minimum>
  <maximum>0.99</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>rndpos2</objectName>
  <x>458</x>
  <y>471</y>
  <width>50</width>
  <height>25</height>
  <uuid>{b73dfa9b-7dfb-488c-ab7f-be3d165a31b4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>0.1</minimum>
  <maximum>0.99</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>vol</objectName>
  <x>916</x>
  <y>548</y>
  <width>33</width>
  <height>29</height>
  <uuid>{e4f92c35-0043-4eea-9560-7c55018f479e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>-1.530</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>pos</objectName>
  <x>460</x>
  <y>305</y>
  <width>92</width>
  <height>25</height>
  <uuid>{de3cf7d9-8cc9-47f9-a205-ef243a143424}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>0.00000100</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.697192</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>453</x>
  <y>280</y>
  <width>104</width>
  <height>25</height>
  <uuid>{141519e4-0af6-4486-895a-b8cc5e5e0462}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Position (0-1):</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>71</y>
  <width>255</width>
  <height>150</height>
  <uuid>{b8f46405-6cc4-4b7d-a2da-13890ad2864c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>QUICK START</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>111</y>
  <width>255</width>
  <height>110</height>
  <uuid>{998837f8-1449-4aa2-b0c7-66677e5ba65b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1. Analysis Source = Sample
2. Analysis Parameters = Pointer
3. Export Parameters = Print
4. Select ftable 1 (2, 3, ...)
5. Output = play
6. Click position pointer below ftable</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
