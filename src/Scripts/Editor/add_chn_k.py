text = q.getOrc()
lines = text.splitlines()
chngets = [ x for x in lines if x.find("chnget") > 0]
channels = [ ch[ch.index('"') + 1:ch.rindex('"')] for ch in chngets]

newlines = [ 'chn_k "%s", 1'%s for s in channels]

newtext = '\n'.join(newlines)
q.insertText(newtext)

print "%i lines inserted"%len(newlines)

#for (i, chn) in enumerate(channels):
    #q.createNewSlider(i*30, 40, chn)
