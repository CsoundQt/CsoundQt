
import qutesheet
from Tkinter import *
import sys, subprocess

# get rows already sorted
rows_sorted = qutesheet.rows
print rows_sorted

if sys.platform == 'win32':
    lilypond_exec = ['lilypond.exe']
elif sys.platform == 'darwin':
    lilypond_exec = ['/Applications/LilyPond.app/Contents/Resources/bin/lilypond']
else:               
    lilypond_exec = ['lilypond']
 
#print subprocess.call(lilypond_exec)


# ---
q_options = ["1/4", "1/8", "1/16", "1/32"]
note_names = [ 'c' , 'cis', 'd', 'dis', 'e', 'f', 'fis', 'g', 'gis', 'a', 'ais', 'b' ]

template_text = '''
\version "2.12.3"
\header{
  title = "Score from QuteCsound"
}
'''
def quantize(rows):
    return rows

def split_polyphony(rows):
    polyphony = [[]]
    current = polyphony[0]
    cur_edge = 0
    for r in rows:
        if len(r) > 3 and type(r[2]) !=str and r[2] < cur_edge:
            new_voice = []
            polyphony.append(new_voice)
            current = new_voice
        if len(r) > 3 and type(r[2]) !=str and r[2] + r[3] > cur_edge:
            cur_edge = r[2] + r[3]
        current.append(r)
    return polyphony


def produce_score():
    global rows_sorted
    print "Quantization is", var.get()
    polyphony = split_polyphony(rows_sorted)
    f = open("/Users/acabrera/Desktop/hello.ly", 'w')
    try:
        for voice in polyphony:
            f.write('\nnew poly:\n')
            for r in voice:
                octave = int(r[4])//12 - 3  #Middle C is 2nd octave here
                note_text = note_names[r[4]]
                for i in range(abs(octave)):
                    if octave > 0:
                        note_text.append("'")
                    else:
                        note_text.append(",")
                f.write(note_text + ' ')
    finally:
        f.close()


# GUI -------------
root = Tk()

l = Label(root, text="Quantize to:")
l.grid(row=0)

var = StringVar(root)
var.set(q_options[0]) # initial value

q = apply(OptionMenu, (root, var) + tuple(q_options))
q.grid(row=0, column=1)

button = Button(root, text="Produce Score", fg="black", command=produce_score)
button.grid(row=4, column=0, columnspan=2)

root.mainloop()
