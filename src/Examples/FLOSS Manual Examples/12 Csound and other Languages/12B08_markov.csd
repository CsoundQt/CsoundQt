;; [returns a number]
getVersion()
;; [returns the numeric result of the evaluation]
compileOrc(orchestra_code)
evalCode(orchestra_code)
readScore(score_lines)
setControlChannel(channel_name,number)
;; [returns a number representing the channel value]
getControlChannel(channel_name)
message(text)
;; [returns a number]
getSr()
;; [returns a number]
getKsmps()
;; [returns a number]
getNchnls()
# [returns 1 if Csound is playing, 0 if not]
isPlaying()