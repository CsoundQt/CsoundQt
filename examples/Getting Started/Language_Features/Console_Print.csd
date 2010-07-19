/* Getting started.. Console Output

Csound offers opcodes to print out values and strings to the console. This can be done by using one of the opcodes starting with the word "print".

'print ' - displays values at i-rate. See instr 1.

'printf ' - prints various data with formatted output. The usage is quite similar to the C-Language expression "printf". This might sound complicated for beginners, but isn't! There are just a few things to know, and you get a very flexible tool, for formated data-output. See description below, and usage in "instr 2".

'printf_i ' - same like printf, but prints only at init-time

'prints ' - same like printf_i, but %s is not allowed
'printks ' - same at k-rate

'printk ' - prints values from control variables at specific time intervalls (instr 3)
'printk2 ' - prints a new value every time a control variable changes (this can crash with continous changes)

To write the output into a file use:

'fprints ' - similar to 'prints' but prints to a file
'fprintks ' - similar to 'printks' but prints to a file

To write the output into a string-variable use: (instr 4)
'sprintf ' - printf-style formatted output to a string variable
'sprintfk ' - printf-style formatted output to a string variable at k-rate
'puts ' - print a string constant or variable  to the console

Value specifier:
%i - integer number
%f - floating point number
%s - prints a character sting
%e - prints a float in standard form ([-]d.ddd e[+/-]ddd)

Output modification:
%n or \n - new line
%t or \t - write a tab character

For more information concerning the C value specifiers, go into the terminal, and read the C-Programming Languge 'printf' manual page. Type: "man -s3 printf"
Or see:
http://en.wikipedia.org/wiki/Printf#printf_format_placeholders
In the Csound Manual you will also find some information under: printks 
*/
<CsoundSynthesizer>
<CsOptions>
-m0
</CsOptions>
<CsInstruments>

instr 1
print p4
endin

instr 2
iNumber = 21.234512
prints "Here is the number: %i %n", iNumber 	; print as integer and go to next line
prints "Here is the number: %f %n", iNumber	; print as float value
prints "Here is the number: %.3f %n", iNumber	; print with 3 digits after the point
prints "Here is the number: %t %.3f %n", iNumber ;insert a tab
prints "Here is the number: %t %.3f %t %.2f %n ", iNumber, iNumber ; insert to tabs print value, put a tab and again
endin

instr 3
kLine line 0, 2, 100
printk 0.2, kLine
endin


instr 4
Scity = "Hannover"
iPopulation = 516000
Sname sprintf "The name is : '%s' and has around %i inhabitants.", Scity, iPopulation
puts Sname, 1
endin

</CsInstruments>

<CsScore>
f 1 0 1024 10 1

i 1 0 2 9999				; print will printout p4
i 2 2 2
i 3 4 2
i 4 6 2
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>840</x>
 <y>59</y>
 <width>608</width>
 <height>769</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>8</y>
  <width>576</width>
  <height>752</height>
  <uuid>{195541a2-8754-488f-9033-adadea125166}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Csound offers opcodes to print out values and strings to the console. This can be done by using one of the opcodes starting with the word "print".

'print ' - displays values at i-rate. See instr 1.

'printf ' - prints various data with formatted output. The usage is quite similar to the C-Language expression "printf". This might sound complicated for beginners, but isn't! There are just a few things to know, and you get a very flexible tool, for formated data-output. See description below, and usage in "instr 2".

'printf_i ' - same like printf, but prints only at init-time

'prints ' - same like printf_i, but %s is not allowed
'printks ' - same at k-rate

'printk ' - prints values from control variables at specific time intervalls (instr 3)
'printk2 ' - prints a new value every time a control variable changes (this can crash with continous changes)

To write the output into a file use:

'fprints ' - similar to 'prints' but prints to a file
'fprintks ' - similar to 'printks' but prints to a file

To write the output into a string-variable use: (instr 4)
'sprintf ' - printf-style formatted output to a string variable
'sprintfk ' - printf-style formatted output to a string variable at k-rate
'puts ' - print a string constant or variable  to the console

Value specifier:
%i - integer number
%f - floating point number
%s - prints a character sting
%e - prints a float in standard form ([-]d.ddd e[+/-]ddd)

Output modification:
%n or \n - new line
%t or \t - write a tab character

For more information concerning the C value specifiers, go into the terminal, and read the C-Programming Languge 'printf' manual page. Type: "man -s3 printf"
Or see:
http://en.wikipedia.org/wiki/Printf#printf_format_placeholders
In the Csound Manual you find some information under: printks </label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 840 59 608 769
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {65535, 65535, 65535}
ioText {12, 8} {566, 893} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Csound offers opcodes to print out values and strings to the console. This can be done by using one of the opcodes starting with the word "print".Â¬Â¬'print ' - displays values at i-rate. See instr 1.Â¬Â¬'printf ' - prints various data with formatted output. The usage is quite similar to the C-Language expression "printf". This might sound complicated for beginners, but isn't! There are just a few things to know, and you get a very flexible tool, for formated data-output. See description below, and usage in "instr 2".Â¬Â¬'printf_i ' - same like printf, but prints only at init-timeÂ¬Â¬'prints ' - same like printf_i, but %s is not allowedÂ¬'printks ' - same at k-rateÂ¬Â¬'printk ' - prints values from control variables at specific time intervalls (instr 3)Â¬'printk2 ' - prints a new value every time a control variable changes (this can crash with continous changes)Â¬Â¬To write the output into a file use:Â¬Â¬'fprints ' - similar to 'prints' but prints to a fileÂ¬'fprintks ' - similar to 'printks' but prints to a fileÂ¬Â¬To write the output into a string-variable use: (instr 4)Â¬'sprintf ' - printf-style formatted output to a string variableÂ¬'sprintfk ' - printf-style formatted output to a string variable at k-rateÂ¬'puts ' - print a string constant or variable  to the consoleÂ¬Â¬Value specifier:Â¬%i - integer numberÂ¬%f - floating point numberÂ¬%s - prints a character stingÂ¬%e - prints a float in standard form ([-]d.ddd e[+/-]ddd)Â¬Â¬Output modification:Â¬%n or \n - new lineÂ¬%t or \t - write a tab characterÂ¬Â¬For more information concerning the C value specifiers, go into the terminal, and read the C-Programming Languge 'printf' manual page. Type: "man -s3 printf"Â¬Or see:Â¬http://en.wikipedia.org/wiki/Printf#printf_format_placeholdersÂ¬In the Csound Manual you find some information under: printks 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
