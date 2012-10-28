#!/usr/bin/env python

from random import random,randint

index=q.getDocument("pluck.csd")
if index < 0:
    q.loadDocument("pluck.csd")
count=q.getChannelValue("count",index)
  

span=q.getChannelValue("span",index)
maxrise=q.getChannelValue("rise",index)
maxdecay=1-q.getChannelValue("decay",index)  # so it looks more like a tail of the envvelope- slider position 75% -> maxdecay=25%
print span, count, maxrise,maxdecay

score=""
for i in range(0,int(count)):
	begin =random()*span
	dur = random()*5+0.5
	amp = randint(-30,-10)
	freq = randint(50,800)
	rise = random()*maxrise
	decay = random()*maxdecay 
	line = "i 1 %.4f %.4f %d %d %.4f %.4f\n" % (begin, dur, amp,freq,rise,decay)
	score+=line

q.setSco(score,index)
q.play(index)





