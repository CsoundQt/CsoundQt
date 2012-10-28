import csnd

# create empty orchestra and score
orc = ''' sr = 44100
ksmps = 64
nchnls = 2

instr 1
endin
'''

sco = '''
e 3600
'''

# start csound engine
c = csnd.CppSound()
c.setOrchestra(orc)
c.setScore(sco)
c.setCommand("csound -odac -d tmp.orc tmp.sco")
c.exportForPerformance()
c.compile()

c.Stop()
c.Cleanup()

#def update():
    

