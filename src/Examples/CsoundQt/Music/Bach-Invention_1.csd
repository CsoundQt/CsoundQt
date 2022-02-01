; By Jacob Joachim (and Bach...)
; Requires Python and PythonScore
; https://github.com/jacobjoaquin/csd/tree/master/demo/pysco

<CsoundSynthesizer>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1.0

instr 1
    itail = 0.01
    p3 = p3 + itail
    idur = p3
    iamp = p4
    ifreq = p5

    kenv linseg 0, 0.001, 1, 0.25, 0.4, 2, 0.1, 0, 0.1
    kenvgate linseg, 1, idur - itail, 1, itail, 0, 0, 0
    kenv = kenv * kenvgate

    a1 vco2 1, ifreq * 2, 0 
    a2 vco2 1, ifreq, 2, 0.6 + birnd(0.1)

    ival1 = 7000 + rnd(3000)
    ival2 = 7000 + rnd(3000)
    kenv2 expseg 16000 + rnd(2000), 2, ival1, 4, 2000, 0, 2000
    kenv3 expseg 16000 + rnd(2000), 2, ival2, 4, 2000, 0, 2000

    amix = a1 * 0.4 + a2 + 0.6
    amix = amix * kenv * iamp

    afilter1 moogladder amix, kenv2, 0.4 + rnd(0.1)
    afilter2 moogladder amix, kenv3, 0.4 + rnd(0.1)
    ;afilter1 moogvcf2 amix, kenv2, 0.5 + rnd(0.1)
    ;afilter2 moogvcf2 amix, kenv3, 0.5 + rnd(0.1)

    outs afilter1, afilter2

    chnmix afilter1, "left"
    chnmix afilter2, "right"
endin

instr 2
    iamp = p4
    idelay_left = p5
    idelay_right = p6
    iroom_size = p7
    iHFDamp = p8

    a1 chnget "left"
    a2 chnget "right"

    a1 delay a1, idelay_left
    a2 delay a2, idelay_right

    a1, a2 freeverb a2, a1, iroom_size, iHFDamp
    outs a1 * iamp, a2 * iamp

    chnclear "left"
    chnclear "right"
endin

instr 3
    prints "\nMeasure %d\n", p4
endin

</CsInstruments>
<CsScore bin="python">
"""Invention No. 1 by Johann Sebastian Bach (1685-1750) BWV 772

Source:
http://www.mutopiaproject.org/cgibin/piece-info.cgi?id=40

Sheet music from www.MutopiaProject.org * Free to download, with
the freedom to distribute, modify and perform.  Typeset using
www.LilyPond.org by Jeff Covey. Copyright (C) 2008.  Reference:
Mutopia-2008/06/15-40.

Licensed under the Creative Commons Attribution-ShareAlike 3.0
(Unported) License, for details see:
http://creativecommons.org/licenses/by-sa/3.0/

Ported to Csound PythonScore by Jacob Joaquin 2013.

"""

from csd.pysco import PythonScore
from random import random

def info():
    print "\033[0;31m" + ('=' * 72) + "\033[1;33m"
    print __doc__
    print "\033[0;31m" + ('=' * 72) + "\033[0m"

def pch_split(pch):
    '''Splits a pitch-class value into an octave and pitch.'''

    octave, note = "{0:.2f}".format(pch).split('.')
    return int(octave), int(note.zfill(2))
    
def transpose_pch(pch, halfstep):
    '''Transposes a pitch-class value by halfsteps.'''

    octave, note = pch_split(pch)
    note += halfstep

    if note < 0:
        octave = octave - abs(int(note + 1)) / 12 - 1
    else:
        octave += int(note / 12.0)

    note = int(note) % 12
    return octave + note * 0.01
    
def mordent(halfstep, instr, start, dur, pch):
    '''Ornaments a note with a mordent.

    Generates multiple score instrument events using a baroque
    style mordent.

    Args:
        halfstep: Half steps away from root note.
        instr: Score instrument to play
        start: Start time.
        dur: Duration.
        pch: Pitch of root note in pitch-class notation.

    '''

    d = dur * 0.125
    instr(start, d, pch)
    instr(start + d, d, transpose_pch(pch, halfstep))
    instr(start + d * 2, dur * 0.75, pch)

def trill(halfstep, div, instr, start, dur, pch):
    '''Ornaments a note with a trill.

    Generates multiple score instrument events using a trill.

    Args:
        halfstep: Half steps away from root note.
        div: Number of divisions of the written note duration.
        instr: Score instrument to play
        start: Start time.
        dur: Duration.
        pch: Pitch of root note in pitch-class notation.

    '''

    d = dur / float(div)
    for i in xrange(0, div, 2):
        with score.cue(start):
            instr(d * i, d, transpose_pch(pch, halfstep))
            instr(d * (i + 1), d, pch)

def measure(t):
    '''Allows PythonScore to use 4/4 time in measures.'''

    beats = (t - 1) * 4.0
    score.i(3, beats, 1, t)
    return score.cue(beats)

def varied_tempo_map(minimum, maximum):
    '''Generates a varied tempo map.

    This creates a tempo "t" score event with randomly changing tempos
    specified by minimum and maximum.

    Args:
        minimum: Minimum tempo BPM.
        maximum: Maximum tempo in BPM.

    '''

    L = ["t"]
    counter = 0
    while counter < 88:
        L.append(str(counter))
        L.append(str(minimum + random() * (maximum - minimum))) 
        counter += random() * 3.0 + 1.0
    score.write(" ".join(L))

def increment(inc=0.06):
    '''Floating point increment generator.'''

    offset = 0;
    while True:
        yield offset
        offset += inc

def wellpch(pch):
    '''Well-tempered pitch-class to frequency converter.'

    The source of the ratios:
        http://www.larips.com/

    '''

    ratios = [5.9, 3.9, 2, 3.9, -2, 7.8, 2, 3.9, 3.9, 0, 3.9, 0]
    octave, note = pch_split(pch)
    pitch = 415 * 2 ** (((octave - 8) * 12 + (note - 9)) / 12.0)
    return pitch * 2 ** (ratios[int(note)] / 1200.0)

def harpsichord(start, dur, pitch):
    '''Interface for Csound orchestra harpsichord instrument.'''

    score.i(1, start, dur, 0.5, wellpch(pitch))

def reverb(dur, amp, delay_left, delay_right, room_size, damp):
    '''Interface for Csound orchesta reverb instrument.'''

    score.i(2, 0, dur, amp, delay_left, delay_right, room_size, damp)

info()
score = PythonScore()
top = harpsichord
bottom = harpsichord
reverb(90, 2.333, 0.0223, 0.0213, 0.4, 0.3)
varied_tempo_map(80, 85)

with measure(1):
    top(0.25, 0.25, 8.00)
    top(0.50, 0.25, 8.02)
    top(0.75, 0.25, 8.04)
    top(1.00, 0.25, 8.05)
    top(1.25, 0.25, 8.02)
    top(1.50, 0.25, 8.04)
    top(1.75, 0.25, 8.00)
    top(2.00, 0.5, 8.07)
    top(2.50, 0.5, 9.00)
    mordent(-2, top, 3.00, 0.5, 8.11)
    top(3.50, 0.5, 9.00)

    bottom(2.25, 0.25, 7.00)
    bottom(2.50, 0.25, 7.02)
    bottom(2.75, 0.25, 7.04)
    bottom(3.00, 0.25, 7.05)
    bottom(3.25, 0.25, 7.02)
    bottom(3.50, 0.25, 7.04)
    bottom(3.75, 0.25, 7.00)

with measure(2):
    top(0.00, 0.25, 9.02)
    top(0.25, 0.25, 8.07)
    top(0.50, 0.25, 8.09)
    top(0.75, 0.25, 8.11)
    top(1.00, 0.25, 9.00)
    top(1.25, 0.25, 8.09)
    top(1.50, 0.25, 8.11)
    top(1.75, 0.25, 8.07)
    top(2.00, 0.5, 9.02)
    top(2.50, 0.5, 9.07)
    mordent(-1, top, 3.00, 0.5, 9.05)
    top(3.50, 0.5, 9.07)

    bottom(0.00, 0.5, 7.07)
    bottom(0.50, 0.5, 6.07)
    bottom(2.25, 0.25, 7.07)
    bottom(2.50, 0.25, 7.09)
    bottom(2.75, 0.25, 7.11)
    bottom(3.00, 0.25, 8.00)
    bottom(3.25, 0.25, 7.09)
    bottom(3.50, 0.25, 7.11)
    bottom(3.75, 0.25, 7.07)

with measure(3):
    top(0.00, 0.25, 9.04)
    top(0.25, 0.25, 9.09)
    top(0.50, 0.25, 9.07)
    top(0.75, 0.25, 9.05)
    top(1.00, 0.25, 9.04)
    top(1.25, 0.25, 9.07)
    top(1.50, 0.25, 9.05)
    top(1.75, 0.25, 9.09)
    top(2.00, 0.25, 9.07)
    top(2.25, 0.25, 9.05)
    top(2.50, 0.25, 9.04)
    top(2.75, 0.25, 9.02)
    top(3.00, 0.25, 9.00)
    top(3.25, 0.25, 9.04)
    top(3.50, 0.25, 9.02)
    top(3.75, 0.25, 9.05)

    bottom(0.00, 0.5, 8.00)
    bottom(0.50, 0.5, 7.11)
    bottom(1.00, 0.5, 8.00)
    bottom(1.50, 0.5, 8.02)
    bottom(2.00, 0.5, 8.04)
    bottom(2.50, 0.5, 7.07)
    bottom(3.00, 0.5, 7.09)
    bottom(3.50, 0.5, 7.11)

with measure(4):
    top(0.00, 0.25, 9.04)
    top(0.25, 0.25, 9.02)
    top(0.50, 0.25, 9.00)
    top(0.75, 0.25, 8.11)
    top(1.00, 0.25, 8.09)
    top(1.25, 0.25, 9.00)
    top(1.50, 0.25, 8.11)
    top(1.75, 0.25, 9.02)
    top(2.00, 0.25, 9.00)
    top(2.25, 0.25, 8.11)
    top(2.50, 0.25, 8.09)
    top(2.75, 0.25, 8.07)
    top(3.00, 0.25, 8.06)
    top(3.25, 0.25, 8.09)
    top(3.50, 0.25, 8.07)
    top(3.75, 0.25, 8.11)

    bottom(0.00, 0.5, 8.00)
    bottom(0.50, 0.5, 7.04)
    bottom(1.00, 0.5, 7.06)
    bottom(1.50, 0.5, 7.07)
    bottom(2.00, 0.5, 7.09)
    bottom(2.50, 0.5, 7.11)
    bottom(3.00, 1.25, 8.00)

with measure(5):
    top(0.00, 0.5, 8.09)
    top(0.50, 0.5, 8.02)
    trill(2, 10, top, 1.00, 0.75, 9.00)
    top(1.75, 0.25, 9.02)
    top(2.00, 0.25, 8.11)
    top(2.25, 0.25, 8.09)
    top(2.50, 0.25, 8.07)
    top(2.75, 0.25, 8.06)
    top(3.00, 0.25, 8.04)
    top(3.25, 0.25, 8.07)
    top(3.50, 0.25, 8.06)
    top(3.75, 0.25, 8.09)

    bottom(0.25, 0.25, 7.02)
    bottom(0.50, 0.25, 7.04)
    bottom(0.75, 0.25, 7.06)
    bottom(1.00, 0.25, 7.07)
    bottom(1.25, 0.25, 7.04)
    bottom(1.50, 0.25, 7.06)
    bottom(1.75, 0.25, 7.02)
    bottom(2.00, 0.5, 7.07)
    bottom(2.50, 0.5, 6.11)
    bottom(3.00, 0.5, 7.00)
    bottom(3.50, 0.5, 7.02)

with measure(6):
    top(0.00, 0.25, 8.07)
    top(0.25, 0.25, 8.11)
    top(0.50, 0.25, 8.09)
    top(0.75, 0.25, 9.00)
    top(1.00, 0.25, 8.11)
    top(1.25, 0.25, 9.02)
    top(1.50, 0.25, 9.00)
    top(1.75, 0.25, 9.04)
    top(2.00, 0.25, 9.02)
    top(2.25, 0.125, 8.11)
    top(2.375, 0.125, 9.00)
    top(2.50, 0.25, 9.02)
    top(2.75, 0.25, 9.07)
    mordent(-2, top, 3.00, 0.5, 8.11)
    top(3.50, 0.25, 8.09)
    top(3.75, 0.25, 8.07)

    bottom(0.00, 0.5, 7.04)
    bottom(0.50, 0.5, 7.06)
    bottom(1.00, 0.5, 7.07)
    bottom(1.50, 0.5, 7.04)
    bottom(2.00, 0.75, 6.11)
    bottom(2.75, 0.25, 7.00)
    bottom(3.00, 0.5, 7.02)
    bottom(3.50, 0.5, 6.02)

with measure(7):
    top(0.00, 0.5, 8.07)
    top(2.25, 0.25, 8.07)
    top(2.50, 0.25, 8.09)
    top(2.75, 0.25, 8.11)
    top(3.00, 0.25, 9.00)
    top(3.25, 0.25, 8.09)
    top(3.50, 0.25, 8.11)
    top(3.75, 0.25, 8.07)

    bottom(0.25, 0.25, 6.07)
    bottom(0.50, 0.25, 6.09)
    bottom(0.75, 0.25, 6.11)
    bottom(1.00, 0.25, 7.00)
    bottom(1.25, 0.25, 6.09)
    bottom(1.50, 0.25, 6.11)
    bottom(1.75, 0.25, 6.07)
    bottom(2.00, 0.5, 7.02)
    bottom(2.50, 0.5, 7.07)
    bottom(3.00, 0.5, 7.06)
    bottom(3.50, 0.5, 7.07)

with measure(8):
    mordent(-2, top, 0.00, 0.5, 8.06)
    top(2.25, 0.25, 8.09)
    top(2.50, 0.25, 8.11)
    top(2.75, 0.25, 9.00)
    top(3.00, 0.25, 9.02)
    top(3.25, 0.25, 8.11)
    top(3.50, 0.25, 9.00)
    top(3.75, 0.25, 8.09)

    bottom(0.00, 0.25, 7.09)
    bottom(0.25, 0.25, 7.02)
    bottom(0.50, 0.25, 7.04)
    bottom(0.75, 0.25, 7.06)
    bottom(1.00, 0.25, 7.07)
    bottom(1.25, 0.25, 7.04)
    bottom(1.50, 0.25, 7.06)
    bottom(1.75, 0.25, 7.02)
    bottom(2.00, 0.5, 7.09)
    bottom(2.50, 0.5, 8.02)
    bottom(3.00, 0.5, 8.00)
    bottom(3.50, 0.5, 8.02)

with measure(9):
    top(0.00, 0.5, 8.11)
    top(2.25, 0.25, 9.02)
    top(2.50, 0.25, 9.00)
    top(2.75, 0.25, 8.11)
    top(3.00, 0.25, 8.09)
    top(3.25, 0.25, 9.00)
    top(3.50, 0.25, 8.11)
    top(3.75, 0.25, 9.02)

    bottom(0.00, 0.25, 7.07)
    bottom(0.25, 0.25, 8.07)
    bottom(0.50, 0.25, 8.05)
    bottom(0.75, 0.25, 8.04)
    bottom(1.00, 0.25, 8.02)
    bottom(1.25, 0.25, 8.05)
    bottom(1.50, 0.25, 8.04)
    bottom(1.75, 0.25, 8.07)
    bottom(2.00, 0.5, 8.05)
    bottom(2.50, 0.5, 8.04)
    bottom(3.00, 0.5, 8.05)
    bottom(3.50, 0.5, 8.02)

with measure(10):
    top(0.00, 0.5, 9.00)
    top(2.25, 0.25, 9.04)
    top(2.50, 0.25, 9.02)
    top(2.75, 0.25, 9.00)
    top(3.00, 0.25, 8.11)
    top(3.25, 0.25, 9.02)
    top(3.50, 0.25, 9.01)
    top(3.75, 0.25, 9.04)

    bottom(0.00, 0.25, 8.04)
    bottom(0.25, 0.25, 8.09)
    bottom(0.50, 0.25, 8.07)
    bottom(0.75, 0.25, 8.05)
    bottom(1.00, 0.25, 8.04)
    bottom(1.25, 0.25, 8.07)
    bottom(1.50, 0.25, 8.05)
    bottom(1.75, 0.25, 8.09)
    bottom(2.00, 0.5, 8.07)
    bottom(2.50, 0.5, 8.05)
    bottom(3.00, 0.5, 8.07)
    bottom(3.50, 0.5, 8.04)

with measure(11):
    top(0.00, 0.5, 9.02)
    top(0.50, 0.5, 9.01)
    top(1.00, 0.5, 9.02)
    top(1.50, 0.5, 9.04)
    top(2.00, 0.5, 9.05)
    top(2.50, 0.5, 8.09)
    top(3.00, 0.5, 8.11)
    top(3.50, 0.5, 9.01)

    bottom(0.00, 0.25, 8.05)
    bottom(0.25, 0.25, 8.10)
    bottom(0.50, 0.25, 8.09)
    bottom(0.75, 0.25, 8.07)
    bottom(1.00, 0.25, 8.05)
    bottom(1.25, 0.25, 8.09)
    bottom(1.50, 0.25, 8.07)
    bottom(1.75, 0.25, 8.10)
    bottom(2.00, 0.25, 8.09)
    bottom(2.25, 0.25, 8.07)
    bottom(2.50, 0.25, 8.05)
    bottom(2.75, 0.25, 8.04)
    bottom(3.00, 0.25, 8.02)
    bottom(3.25, 0.25, 8.05)
    bottom(3.50, 0.25, 8.04)
    bottom(3.75, 0.25, 8.07)

with measure(12):
    top(0.00, 0.5, 9.02)
    top(0.50, 0.5, 8.06)
    top(1.00, 0.5, 8.08)
    top(1.50, 0.5, 8.09)
    top(2.00, 0.5, 8.11)
    top(2.50, 0.5, 9.00)
    top(3.00, 1.25, 9.02)

    bottom(0.00, 0.25, 8.05)
    bottom(0.25, 0.25, 8.04)
    bottom(0.50, 0.25, 8.02)
    bottom(0.75, 0.25, 8.00)
    bottom(1.00, 0.25, 7.11)
    bottom(1.25, 0.25, 8.02)
    bottom(1.50, 0.25, 8.00)
    bottom(1.75, 0.25, 8.04)
    bottom(2.00, 0.25, 8.02)
    bottom(2.25, 0.25, 8.00)
    bottom(2.50, 0.25, 7.11)
    bottom(2.75, 0.25, 7.09)
    bottom(3.00, 0.25, 7.08)
    bottom(3.25, 0.25, 7.11)
    bottom(3.50, 0.25, 7.09)
    bottom(3.75, 0.25, 8.00)

with measure(13):
    top(0.25, 0.25, 8.04)
    top(0.50, 0.25, 8.06)
    top(0.75, 0.25, 8.08)
    top(1.00, 0.25, 8.09)
    top(1.25, 0.25, 8.06)
    top(1.50, 0.25, 8.08)
    top(1.75, 0.25, 8.04)
    top(2.00, 0.25, 9.04)
    top(2.25, 0.25, 9.02)
    top(2.50, 0.25, 9.00)
    top(2.75, 0.25, 9.04)
    top(3.00, 0.25, 9.02)
    top(3.25, 0.25, 9.00)
    top(3.50, 0.25, 8.11)
    top(3.75, 0.25, 9.02)
   
    bottom(0.00, 0.5, 7.11)
    bottom(0.50, 0.5, 7.04)
    trill(2, 8, bottom, 1.00, 0.75, 8.02)
    bottom(1.75, 0.25, 8.04)
    bottom(2.00, 0.25, 8.00)
    bottom(2.25, 0.25, 7.11)
    bottom(2.50, 0.25, 7.09)
    bottom(2.75, 0.25, 7.07)
    bottom(3.00, 0.25, 7.06)
    bottom(3.25, 0.25, 7.09)
    bottom(3.50, 0.25, 7.08)
    bottom(3.75, 0.25, 7.11)

with measure(14):
    top(0.00, 0.25, 9.00)
    top(0.25, 0.25, 9.09)
    top(0.50, 0.25, 9.08)
    top(0.75, 0.25, 9.11)
    top(1.00, 0.25, 9.09)
    top(1.25, 0.25, 9.04)
    top(1.50, 0.25, 9.05)
    top(1.75, 0.25, 9.02)
    top(2.00, 0.25, 8.08)
    top(2.25, 0.25, 9.05)
    top(2.50, 0.25, 9.04)
    top(2.75, 0.25, 9.02)
    top(3.00, 0.5, 9.00)
    top(3.50, 0.25, 8.11)
    top(3.75, 0.25, 8.09)

    bottom(0.00, 0.25, 7.09)
    bottom(0.25, 0.25, 8.00)
    bottom(0.50, 0.25, 7.11)
    bottom(0.75, 0.25, 8.02)
    bottom(1.00, 0.25, 8.00)
    bottom(1.25, 0.25, 8.04)
    bottom(1.50, 0.25, 8.02)
    bottom(1.75, 0.25, 8.05)
    bottom(2.00, 0.5, 8.04)
    bottom(2.50, 0.5, 7.09)
    bottom(3.00, 0.5, 8.04)
    bottom(3.50, 0.5, 7.04)

with measure(15):
    top(0.00, 0.25, 8.09)
    top(0.25, 0.25, 9.09)
    top(0.50, 0.25, 9.07)
    top(0.75, 0.25, 9.05)
    top(1.00, 0.25, 9.04)
    top(1.25, 0.25, 9.07)
    top(1.50, 0.25, 9.05)
    top(1.75, 0.25, 9.09)
    top(2.00, 2.25, 9.07)

    bottom(0.00, 0.5, 7.09)
    bottom(0.50, 0.5, 6.09)
    bottom(2.25, 0.25, 8.04)
    bottom(2.50, 0.25, 8.02)
    bottom(2.75, 0.25, 8.00)
    bottom(3.00, 0.25, 7.11)
    bottom(3.25, 0.25, 8.02)
    bottom(3.50, 0.25, 8.01)
    bottom(3.75, 0.25, 8.04)

with measure(16):
    top(0.25, 0.25, 9.04)
    top(0.50, 0.25, 9.05)
    top(0.75, 0.25, 9.07)
    top(1.00, 0.25, 9.09)
    top(1.25, 0.25, 9.05)
    top(1.50, 0.25, 9.07)
    top(1.75, 0.25, 9.04)
    top(2.00, 2.25, 9.05)

    bottom(0.00, 2.25, 8.02)
    bottom(2.25, 0.25, 7.09)
    bottom(2.50, 0.25, 7.11)
    bottom(2.75, 0.25, 8.00)
    bottom(3.00, 0.25, 8.02)
    bottom(3.25, 0.25, 7.11)
    bottom(3.50, 0.25, 8.00)
    bottom(3.75, 0.25, 7.09)

with measure(17):
    top(0.25, 0.25, 9.07)
    top(0.50, 0.25, 9.05)
    top(0.75, 0.25, 9.04)
    top(1.00, 0.25, 9.02)
    top(1.25, 0.25, 9.05)
    top(1.50, 0.25, 9.04)
    top(1.75, 0.25, 9.07)
    top(2.00, 2.25, 9.05)

    bottom(0.00, 2.25, 7.11)
    bottom(2.25, 0.25, 8.02)
    bottom(2.50, 0.25, 8.00)
    bottom(2.75, 0.25, 7.11)
    bottom(3.00, 0.25, 7.09)
    bottom(3.25, 0.25, 8.00)
    bottom(3.50, 0.25, 7.11)
    bottom(3.75, 0.25, 8.02)

with measure(18):
    top(0.25, 0.25, 9.02)
    top(0.50, 0.25, 9.04)
    top(0.75, 0.25, 9.05)
    top(1.00, 0.25, 9.07)
    top(1.25, 0.25, 9.04)
    top(1.50, 0.25, 9.05)
    top(1.75, 0.25, 9.02)
    top(2.00, 2.25, 9.04)

    bottom(0.00, 2.25, 8.00)
    bottom(2.25, 0.25, 7.07)
    bottom(2.50, 0.25, 7.09)
    bottom(2.75, 0.25, 7.10)
    bottom(3.00, 0.25, 8.00)
    bottom(3.25, 0.25, 7.09)
    bottom(3.50, 0.25, 7.10)
    bottom(3.75, 0.25, 7.07)

with measure(19):
    top(0.25, 0.25, 9.00)
    top(0.50, 0.25, 9.02)
    top(0.75, 0.25, 9.04)
    top(1.00, 0.25, 9.05)
    top(1.25, 0.25, 9.02)
    top(1.50, 0.25, 9.04)
    top(1.75, 0.25, 9.00)
    top(2.00, 0.25, 9.02)
    top(2.25, 0.25, 9.04)
    top(2.50, 0.25, 9.05)
    top(2.75, 0.25, 9.07)
    top(3.00, 0.25, 9.09)
    top(3.25, 0.25, 9.05)
    top(3.50, 0.25, 9.07)
    top(3.75, 0.25, 9.04)

    bottom(0.00, 0.5, 7.09)
    bottom(0.50, 0.5, 7.10)
    bottom(1.00, 0.5, 7.09)
    bottom(1.50, 0.5, 7.07)
    bottom(2.00, 0.5, 7.05)
    bottom(2.50, 0.5, 8.02)
    bottom(3.00, 0.5, 8.00)
    bottom(3.50, 0.5, 7.10)

with measure(20):
    top(0.00, 0.25, 9.05)
    top(0.25, 0.25, 9.07)
    top(0.50, 0.25, 9.09)
    top(0.75, 0.25, 9.11)
    top(1.00, 0.25, 10.00)
    top(1.25, 0.25, 9.09)
    top(1.50, 0.25, 9.11)
    top(1.75, 0.25, 9.07)
    top(2.00, 0.5, 10.00)
    top(2.50, 0.5, 9.07)
    top(3.00, 0.5, 9.04)
    top(3.50, 0.25, 9.02)
    top(3.75, 0.25, 9.00)

    bottom(0.00, 0.5, 7.09)
    bottom(0.50, 0.5, 8.05)
    bottom(1.00, 0.5, 8.04)
    bottom(1.50, 0.5, 8.02)
    bottom(2.00, 0.25, 8.04)
    bottom(2.25, 0.25, 8.02)
    bottom(2.50, 0.25, 8.04)
    bottom(2.75, 0.25, 8.05)
    bottom(3.00, 0.25, 8.07)
    bottom(3.25, 0.25, 8.04)
    bottom(3.50, 0.25, 8.05)
    bottom(3.75, 0.25, 8.02)

with measure(21):
    top(0.00, 0.25, 9.00)
    top(0.25, 0.25, 8.10)
    top(0.50, 0.25, 8.09)
    top(0.75, 0.25, 8.07)
    top(1.00, 0.25, 8.05)
    top(1.25, 0.25, 8.09)
    top(1.50, 0.25, 8.07)
    top(1.75, 0.25, 8.10)
    top(2.00, 0.25, 8.09)
    top(2.25, 0.25, 8.11)
    top(2.50, 0.25, 9.00)
    top(2.75, 0.25, 8.04)
    top(3.00, 0.25, 8.02)
    top(3.25, 0.25, 9.00)
    top(3.50, 0.25, 8.05)
    top(3.75, 0.25, 8.11)

    bottom(0.00, 0.5, 7.04)
    bottom(0.50, 0.5, 7.00)
    bottom(1.00, 0.5, 7.02)
    bottom(1.50, 0.5, 7.04)
    bottom(2.00, 0.25, 7.05)
    bottom(2.25, 0.25, 7.02)
    bottom(2.50, 0.25, 7.04)
    bottom(2.75, 0.25, 7.05)
    bottom(3.00, 0.5, 7.07)
    bottom(3.50, 0.5, 6.07)

with measure(22):
    arp = increment()
    score.p_callback('i', 1, 2, lambda x: arp.next())
    bottom(0, 0.5, 6.00)
    bottom(0, 0.5, 7.00)
    top(0, 0.5, 8.04)
    top(0, 0.5, 8.07)
    top(0, 0.5, 9.00)

score.pmap('i', 1, 2, lambda x: x + random() * 0.05)  # Randomize start time
score.pmap('i', 1, 3, lambda x: x + random() * 0.05)  # Randomize duration
score.pmap('i', 1, 4, lambda x: x * 0.4)              # Lower amplitude
score.end()

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>669</x>
 <y>214</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
