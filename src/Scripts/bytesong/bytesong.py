
# First make sure you execute these lines first to have the 'bytesong'
#function available
import sys,os
sys.path.append(os.getcwd()) # trick to allow importing python files from the current directory

def bytesong(PAT):
    q.loadDocument('bytesong.csd')
    options = '-m0 -odac --omacro:PAT=' + PAT
    q.setOptionsText(options)
    q.stop()
    q.play()
    index = q.getDocument('bytesong.py')
    q.setDocument(index) # GO back to this document
    

def stopsong():
    index = q.getDocument('bytesong.csd')
    q.stop(index)

1/0 # To force stopping here!
#You should now be able to run any of these to enjoy 8-bit glory!


bytesong('kt*((kt>>12|kt>>8)&63&kt>>4)')                         # by viznut

bytesong('(kt*(kt>>5|kt>>8))>>(kt>>16)')                         # by tejeez

bytesong('kt*((kt>>9|kt>>13)&25&kt>>6)')                          # by visy

bytesong('kt*(kt>>11&kt>>8&123&kt>>3)')                           # by tejeez

bytesong('kt*(kt>>((kt>>9|kt>>8))&63&kt>>4)')                     # by visy

bytesong('(kt>>6|kt|kt>>(kt>>16))*10+((kt>>11)&7)')               # by viznut

bytesong('(av>>1)+(av>>4)+kt*(((kt>>16)|(kt>>6))&(69&(kt>>9)))')  # by pyryp

bytesong('kt*5&(kt>>7)|kt*3&(kt*4>>10)')                          # by miiro

bytesong('(kt>>7|kt|kt>>6)*10+4*(kt&kt>>13|kt>>6)')               # by viznut


# And execute the following line to stop the song
stopsong()





