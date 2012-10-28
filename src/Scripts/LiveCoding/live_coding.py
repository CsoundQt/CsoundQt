# Simple live coding demo
# by Andres Cabrera 2012
# This file opens a csd file in a separate tab, runs it and
# sends events to it.

## Load and play the csd file
if (q.getDocument("live_coding.py") == -1):
    q.loadDocument("live_coding.py") # load if not already open

d = q.loadDocument("live_coding.csd")
q.play(d)
q.setDocument(q.getDocument("live_coding.py")) # come back to this document after loading

## To evaluate sections (separated by ##) Use Edit->Evaluate Section

q.sendEvent(d, "i 1 0 1 1000 0.1")

## Define a function to trigger events
import random

def randomLadder(remaining, dur, next = 0):
    freq = random.uniform(220, 880) # a random number between 220 and 880
    amp = 0.2*(remaining/20.0)
    text = "i 1 %f %f %f %f\n"%(next + dur/2, dur, freq, amp)
    
    if remaining > 0:
        text = text + randomLadder(remaining - 1.0, dur*0.9,next + dur)
    return text

q.sendEvent(d,randomLadder(10, 1))
q.sendEvent(d,randomLadder(15, 0.8))
q.sendEvent(d,randomLadder(40, 0.5))

## A different one


q.sendEvent(d,randomLadder(30, 0.9))
q.sendEvent(d,randomLadder(30, 0.899))
q.sendEvent(d,randomLadder(30, 0.898))
q.sendEvent(d,randomLadder(30, 0.897))

## Now your turn...

