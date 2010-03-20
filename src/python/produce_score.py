import qutesheet
from Tkinter import *
import tkFileDialog
from math import modf, log10, fmod
import sys, subprocess, shutil, os

image_avail = True
try:
    import Image, ImageTk
except ImportError:
    image_avail = False

# get rows already sorted
rows_sorted = qutesheet.rows

if sys.platform == 'win32':
    lilypond_exec = 'lilypond.exe'
elif sys.platform == 'darwin':
    lilypond_exec = '/Applications/LilyPond.app/Contents/Resources/bin/lilypond'
else:               
    lilypond_exec = '/usr/bin/lilypond'

# ---
q_options = ["1/4", "1/8", "1/16", "1/32"]
time_options = ["4/4", "3/4", "6/8", "5/4"]
num_beats = [4, 3, 6, 5]  # number of beats for the available time_options
note_names_sharp = [ 'c' , 'cis', 'd', 'dis', 'e', 'f', 'fis', 'g', 'gis', 'a', 'ais', 'b' ]
note_names_flat = [ 'c' , 'des', 'd', 'ees', 'e', 'f', 'ges', 'g', 'aes', 'a', 'bes', 'b' ]
note_names = []
acc_options = ['sharps', 'flats']
p4_options = ['MIDI note', 'cps', 'pitch class']

filename = "temp-lilyfile.ly"
root = 0 # root is tk root window

template_text = '''
\\version "2.12.2"
\\header{
  title = <Title comes here>
}
\\score { 
<<
<Notes Come Here>

>>
  } 
'''

def quantize(rows):
    return rows

def split_polyphony(rows):
    polyphony = [[]]
    cur_edges = [0]
    cur_poly = 0
    for r in rows:
        if len(r) > 3 and type(r[2]) !=str and r[2] < cur_edges[cur_poly]:
            for i, e in enumerate(cur_edges):
            # Try to reuse a previous polyphony line if possible 
                if e > r[2]:
                    cur_poly = i
                    break
            if r[2] < cur_edges[cur_poly]:
                new_voice = []
                cur_edges.append(0)
                polyphony.append(new_voice)
                cur_poly = len(polyphony) - 1
        if len(r) > 3 and type(r[2]) !=str and r[2] + r[3] > cur_edges[cur_poly]:
            cur_edges[cur_poly] = r[2] + r[3]
        polyphony[cur_poly].append(r)
    return polyphony


def produce_score():
    global rows_sorted, lilypond_exec, num_beats, template_text, note_names, filename
    quant = q_var.get()
    time = time_var.get()
    beats = num_beats[time_options.index(time_var.get())]
    title = title_var.get()
    p4 = p4_var.get()
    if acc_var.get() == 'sharp':
        note_names = note_names_sharp
    else:
        note_names = note_names_flat
    notes_by_instr = []
    instr_nums = []
    out_text = ''
    for n in range(len(rows_sorted)):
        if (rows_sorted[n][0] != 'i'):
            print "Not i event. Skipping line ", n
            continue
        i_num = rows_sorted[n][1]
        if type(i_num) != str:
            if instr_nums.count(i_num) != 0:
                index = instr_nums.index(i_num)
                notes_by_instr[index].append(rows_sorted[n])
            else:
                instr_rows = [rows_sorted[n]]
                notes_by_instr.append(instr_rows)
                instr_nums.append(i_num)
    for n in range(len(notes_by_instr)):
        staff_name = "instr " + str(instr_nums[n])
        out_text += make_ly_text(notes_by_instr[n], staff_name, quant, time, beats, p4)
    out_text += ''
    complete_text = template_text
    complete_text = complete_text.replace('<Notes Come Here>', out_text)
    complete_text = complete_text.replace('<Title comes here>', '"' + title + '"')
    f = open(filename, 'w')
    try:
        f.write(complete_text)
    finally:
        f.close()
    args = [lilypond_exec, '-fpng', filename]
    p = subprocess.call(args)
    print p
    if p != 0:
        r = Toplevel(root)
        r.title("Error running Lilypond!")
        info_text = "Executable:\n" + lilypond_exec + "\nError!\n"
        info_text += "This script requires lilypond."
        l = Label(r, text=info_text)
        l.grid(row=0)
    t = Toplevel(root)
    t.title("Generated Score");

    save_ly_but = Button(t, text="Save Lilypond", fg="black", command=save_lilypond)
    save_ly_but.grid(row=0)
    save_png_but = Button(t, text="Save PNG", fg="black", command=save_png)
    save_png_but.grid(row=0, column=1)
    if image_avail:
        image_name = filename.replace('.ly', '.png')
        image1 = Image.open(image_name)
        im = ImageTk.PhotoImage(image1)
        label_image = Label(t, image=im)
        label_image.grid(row=1, column=0, columnspan=2)
        if old_label_image is not None:
            old_label_image.destroy()
        old_label_image = label_image
    else:
        l = Label(t, text="ImageTk module not available\nInstalling it will allow preview here.")
        l.grid(row=1, column=0, columnspan=2)
#    print p


def make_ly_text(rows, staff_name, quant, time, num_beats, p4):
    polyphony = split_polyphony(rows)
    ly_notes_text = '\n\\new Staff {<< \\set Staff.instrumentName = \"' + staff_name + ' \"\n \\time ' + time + '\n'
    for voice in polyphony:
        ly_notes_text += '\n{ '
        last_note_time = 0
        clef_changed = False
        for r in voice:
            if type(r[3]) == str or type(r[2]) == str or type(r[4]) == str:
                continue
            if last_note_time < r[2]:
                remaining = r[2] - last_note_time
                while remaining > 0:
                    sil_dur = 1
                    if remaining <= num_beats:
                        if modf(1.0/remaining)[0] != 0:
                            sil_dur = str( int(8 * (1.0/remaining)) ) + "."
                        else:
                            sil_dur = str( int(4 * (1.0/remaining)) )
                        remaining -= num_beats
                        if voice.index(r) == 0:
                            ly_notes_text += 'r' + str(sil_dur) + ' '
                        else:
                            ly_notes_text += 's' + str(sil_dur) + ' '
                    else:
                        ly_notes_text += 's1 ~ '
                        remaining -= num_beats
            p_class = 0
            if p4 == 'pitch class':
                p_class = r[4] + 0.00005
            elif  p4 == 'MIDI note':
                p_class = r[4]//12 + 3 + ((r[4]%12 + 0.00005)/ 100.0)  # Middle C is octave 8. Must add a small offset to avoid floating point rounding errors...
            elif  p4 == 'cps':
                p_class = 69 + (12 *log10(r[4]/440.0)/log10(2))
                p_class = p_class//12 + 3 + ((p_class%12 + 0.00005)/ 100.0)
#            print p_class
            note_num, octave = modf(p_class - 7.0)  # Middle C is 1st octave here
#            print octave, note_num, p_class, modf(p_class - 7.0)
            note_text = ''
            if p_class < 7.05 and not clef_changed:
                note_text += " \\clef F "
                clef_changed = True
            else:
                if p_class > 8.07 and clef_changed:
                    note_text += " \\clef G "
                    clef_changed = False
            note_text += note_names[int(note_num *100)]
            for i in range(int(abs(octave))):
                 if octave > 0:
                        note_text += "'"
                 else:
                        note_text += ","
            dur = r[3]
            beat_start = fmod(r[2], num_beats)
            overshoot = fmod(beat_start + dur, num_beats)
            last_note_time = r[2] + dur
            if overshoot > 0 and overshoot != dur:
                ly_notes_text += note_text + str( int(4 * (1.0/ (num_beats - beat_start))) )
                while overshoot > 0:
                    new_part_dur = overshoot if overshoot < num_beats else num_beats
                    ly_notes_text += ' ~ ' + note_text + str( int(4 * (1.0/ (num_beats - new_part_dur))) )
                    overshoot = overshoot - new_part_dur
            else:
                if modf(1.0/dur)[0] != 0:
                    dur_text = str( int(8 * (1.0/dur)) ) + "."
                else:
                    dur_text = str( int(4 * (1.0/dur)) )
                note_text += dur_text
                ly_notes_text += note_text + ' '
        ly_notes_text += '} \\\\'
    ly_notes_text += '\n>>}'
    return ly_notes_text

def save_lilypond():
    global root, filename
    options = {}
#    options['initialdir'] = 'C:\\'
#    options['mustexist'] = False
    options['parent'] = root
    options['title'] = 'Save lilypond file'
    new_filename = tkFileDialog.asksaveasfilename(**options)

    if new_filename:
        print "save_lilypond() ", new_filename
        shutil.copyfile(filename, new_filename)

def save_png():
    global root, filename
    options = {}
#    options['initialdir'] = 'C:\\'
#    options['mustexist'] = False
    options['parent'] = root
    options['title'] = 'Save png file'
    new_filename = tkFileDialog.asksaveasfilename(**options)

    if new_filename:
        print "save_png() ", new_filename
        shutil.copyfile(filename.replace('.ly', '.png'), new_filename)


# GUI -------------
root = Tk()
root.title("Produce lilypond Score")

l = Label(root, text="Quantize to:")
#l.grid(row=0)
q_var = StringVar(root)
q_var.set(q_options[1]) # initial value
q = apply(OptionMenu, (root, q_var) + tuple(q_options))
#q.grid(row=0, column=1)

l = Label(root, text="Measure Time:")
l.grid(row=1)
time_var = StringVar(root)
time_var.set(time_options[0]) # initial value
time = apply(OptionMenu, (root, time_var) + tuple(time_options))
time.grid(row=1, column=1)

l = Label(root, text="Accidentals")
l.grid(row=2)
acc_var = StringVar(root)
acc_var.set(acc_options[0]) # initial value
acc = apply(OptionMenu, (root, acc_var) + tuple(acc_options))
acc.grid(row=2, column=1)

l = Label(root, text="p4 is:")
l.grid(row=3)
p4_var = StringVar(root)
p4_var.set(p4_options[0]) # initial value
p4 = apply(OptionMenu, (root, p4_var) + tuple(p4_options))
p4.grid(row=3, column=1)

l = Label(root, text="Title")
l.grid(row=4)
title_var = StringVar(root)
titleentry = Entry(root, textvariable=title_var)
titleentry.grid(row=4, column=1)
title_var.set("QuteCsound Score") # initial value

button = Button(root, text="Produce Score", fg="black", command=produce_score)
button.grid(row=9, column=0, columnspan=2)

root.mainloop()

#remove temp files
os.remove(filename)
os.remove(filename.replace('.ly', '.png'))
os.remove(filename.replace('.ly', '.ps'))
