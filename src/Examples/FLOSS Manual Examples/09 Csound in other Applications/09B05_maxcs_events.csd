import PySimpleGUI as sg
%load_ext csoundmagics
cs = ICsound()
orc = """
seed 0
instr 1
 kLine randomi -1,1,1,3
 chnset kLine, "line"
endin
"""
cs.sendCode(orc)
cs.sendScore('i 1 0 -1')

layout = [[sg.Slider(range=(-1,1),
                     orientation='h',
                     key='LINE',
                     resolution=.01)],
          [sg.Text(size=(6,1),
                   key='LINET',
                   text_color='black',
                   background_color='white',
                   justification = 'right',
                   font=('Courier',16,'bold'))]
         ]

window = sg.Window('Csound -> GUI',layout)

while True:
    event, values = window.read(timeout=100)
    if event is None:
        cs.sendScore('i -1 0 1')
        del cs
        break
    window['LINE'].update(cs.channel('line')[0])
    window['LINET'].update('%+.3f' % cs.channel('line')[0])
window.close()