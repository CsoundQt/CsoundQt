"""
loopology.py  RWD 09-20121
By Richard Dobson and Andres Cabrera
A mini musical automaton.
The heart of this "composition" is a 5-line loop
excluding the line which actually writes the note.
"""
from time import sleep

q.loadDocument("loopology.csd")
q.play()
sleep(0.3)
q.loadDocument("loopology.py")


time = 0.0
duration = 0.2
tempo = 110.0
velocity = 100

pitch = 48
interval = 5
range = 23
enddur = 60
note  = 0

sco = ''
while time < enddur :
    sco +="i 1 %f %f %f %f\n"%(time *60/tempo,duration,pitch + note, velocity)
    note += interval
    note %= range
    time += duration
    tempo += 0.025
    if ((int(time * 5) % 20)) == 0 :
        interval += 1
    q.refresh()

q.sendEvent(sco)
print "done."
