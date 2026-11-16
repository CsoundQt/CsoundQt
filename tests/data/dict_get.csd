<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>

/*

  # Example file for dict_get

  ## dict_get

    kvalue dict_get idict, "key" [, kdefault=0]


  Get the value at a given key. For string values, an empty string
  is returned when the key is not found. For int values, a default 
  value given by the user is returned when the key is not found.
  
*/

ksmps = 64
nchnls = 2
0dbfs = 1

instr 1
  ; create a local dict, mapping strings to numbers
  idict dict_new "sf"
  dict_free idict
    
  ; set key a key:value pair
  dict_set idict, "bar", 123

  ; retrieve teh value
  kbar dict_get idict, "bar"
  
  ; get a non-existent key, will output the default
  kfoo dict_get idict, "foo", -1 

  printf ">>>> bar: %f,  foo: %f \n", 1, kbar, kfoo 

  ; now create another dict, mapping strings to strings
  idict2 dict_new "ss"
  
  dict_set idict2, "baz", "bazvalue"
  dict_set idict2, "hoo", "hoovalue"
  
  Sbaz dict_get idict2, "baz"
  Shoo dict_get idict2, "hoo"

  printf ">>>> baz: %s,  hoo: %s \n", 1, Sbaz, Shoo 

  turnoff
endin


instr 2
  ;; set and get 
  if timeinstk() > 1 kgoto perf    ;; this starts at 1
  
  imaxcnt = 100
  idict dict_new "ss"

  kcnt = 0
  while kcnt < imaxcnt do
    Skey sprintfk "key_%d", kcnt
    Svalue sprintfk "value_%d", kcnt 
    dict_set idict, Skey, Svalue 
    kcnt += 1 
  od 
  
perf:
  kcnt = 0
  while kcnt < imaxcnt do 
    Skey  sprintfk "key_%d", kcnt
    ; the same for get, the key can change at k-time
    Svalue dict_get idict, Skey
    printf "key: %s,  value: %s \n", kcnt, Skey, Svalue 
    kcnt += 1
  od 
endin
  
instr 3
  /*
  
  dict_iter
  
  xkey, xvalue, kidx dict_iter ihandle [,kreset=1]
  
  kidx: holds the number of pairs yielded since last reset. It 
        is set to -1 when iteration has stopped 
        (in this case, xkey and xvalue are invalid and should not
        be used)
  kreset = 0  -> after iterating over all pairs iteration stops
                 In this mode, iteration happens at most once
           1  -> iteration starts over every k-cycle
           2  -> iteration restarts after stopping   
  */
  
  kt timeinstk 
  if kt > 1 kgoto perf 
  
  idict dict_new "sf"
  dict_set idict, "foo", 1
  dict_set idict, "bar", 2
  dict_set idict, "baz", 15
  dict_set idict, "bee", 9
  
perf:
  ; iterate with a while loop
  kidx = 0
  while kidx < dict_size(idict) - 1 do 
    Skey, kvalue, kidx dict_iter idict 
    printf "while) %s -> %f \n", kidx+kt*1000, Skey, kvalue
  od   

  ; the same but with goto
loop:
  Skey, kvalue, kidx dict_iter idict
  if kidx == -1 goto _exit
  printf "loop) %s -> %f \n", kidx+kt*1000, Skey, kvalue
  kgoto loop
_exit:
endin

instr 4
  ; test deleting a key
  ; ~~~~~~~~~~~~~~~~~~~

  idict dict_new "ss"
  
  ; set a key:value pair
  dict_set idict, "foo", "foovalue"

  ; get the value, print it
  Sfoo dict_get idict, "foo"
  printf "key: foo  value: %s \n", 1, Sfoo

  dict_del idict, "foo"

  ; now check that the pair is gone
  Sfoo dict_get idict, "foo"
  if(strlen(Sfoo)==0) then 
    printf "key does not exist \n", 1
  endif
  
  turnoff
endin

   
instr 5
  ; dicts can be passed between instruments
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if timeinstk() > 1 goto perf

  ; create a dict which survives this note
  idict1 dict_new "sf", 1

  ; set some initial values once 
  dict_set idict1, "foo", 1
  dict_set idict1, "bar", 2

  ; launch instr 6, which will outlive this note, pass idict as p4
  event "i", "midifydict", 0, p3+1, idict1 

perf:
  kfoo dict_get idict1, "foo"
  printk2 kfoo

endin

instr modifydict
  ; here we modify instr 5's dictionary
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ; the dict was created by instr 5
  idict = p4

  kfoo line 0, p3-1, 10
  dict_set idict, "foo", kfoo 

  dict_free idict, 1 ; 1 = free dict when note ends
endin

instr 7
  ; it is possible to create a new dict and set initial
  ; values at once. This is only executed at i-time
  idict dict_new "sf", 0, "foo", 10, "bar", 20, "baz", 30
  kbaz dict_get idict, "baz"
  kbar dict_get idict, "bar"
  kxx dict_get idict, "xx", 99
  printf "baz: %f  bar: %f  xx: %f \n", 1, kbaz, kbar, kxx 
  turnoff
endin

instr 8
  ; get all the keys as an array
  idict1 dict_new "sf", 0, "keyA", 1, "keyB", 2, "keyC", 3
  SKeys[] dict_query idict1, "keys"
  printarray SKeys

  idict2 dict_new "if", 0, 1,100, 10,1000, 2,200
  kKeys[] dict_query idict2, "keys"
  printarray kKeys, 1, "%.0f"

  ; get values as an array
  idict3 dict_new "is", 0, 10, "foo", 20, "bar", 30, "baz"
  Svals[] dict_query idict3, "values"
  printarray Svals

  kVals[] dict_query idict2, "values"
  printarray kVals

  turnoff
endin

; One convenient use of dicts is to pass arguments to an instr
instr 100
  ; create our communication dict, set initial values
  idict dict_new "sf", "amp", 0.1, "freq", 1000
  ; the launched instr will last longer, so will have to deal with
  ; this dict ceasing to exist
  event_i "i", 101, 0, p3+1, idict

  ; now we can control the synth with the dict
  dict_set idict, "freq", linseg:k(440, p3, 455)

  a0 oscili 0.1, 440
  outch 1, a0 
endin
  
; a variation on dict_get where we either get the value corresponding to a key,
; or the last value, if the dict does not exist
opcode dict_receive, k,iSi 
  idict, Skey, ival0 xin
  klast init ival0
  if (dict_size(idict) > 0 ) then
    kval dict_get idict, Skey, ival0
    klast = kval
  else 
    kval = klast 
  endif 
  xout kval 
endop

instr 101
  idict = p4
  ; get the value for a given key. when the dict does not exist, just
  ; outputs the last value
  kamp dict_receive idict, "amp", 0.1 
  kfreq dict_receive idict, "freq", 1000
  a0 oscili kamp, kfreq 
  outch 2, a0
endin

instr 200
  idict dict_new "str:any", "foo", "fooval", "bar", 10
  dict_print idict
  Sfoo dict_get idict, "foo"
  kbar dict_get idict, "bar"
  printf "foo=%s, bar=%f \n", 1, Sfoo, kbar
  dict_set idict, "baz", 0.5
  ibaz dict_get idict, "baz"
  Smoo = "moo!"
  dict_set idict, "moo", Smoo
  printf "baz=%f,  moo=%s \n", 1, ibaz, Smoo
  turnoff
endin  

</CsInstruments>
<CsScore>
; i 1 0 0.01
; i 2 0 0.01
; i 8 0 0.1
; i 100 0 10
i 200 0 1
f 0 1
</CsScore>
</CsoundSynthesizer>
