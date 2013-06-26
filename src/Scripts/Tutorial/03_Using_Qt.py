# 03_Csound_Interaction.py

import time # to get the sleep function
q.loadDocument("basic.csd")
q.play()

time.sleep(1) # wait one second (while csd is running
q.stop() # Then stop the running csd
# The csd stops, even though it should have lasted 10 seconds.

# Now we open and move to this document
q.loadDocument("03_Csound_Interaction.py")
# Then we wait a bit
time.sleep(1)

# And now we play a document which is open on another tab 
doc = q.getDocument("basic.csd")
q.play(doc)
time.sleep(0.2)
q.stop(doc)

