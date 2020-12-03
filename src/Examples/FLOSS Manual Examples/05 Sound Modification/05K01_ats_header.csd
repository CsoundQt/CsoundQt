<CsoundSynthesizer>
<CsOptions>
-n -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

;Some macros
#define ATS_SR  # 0 #   ;sample rate    (Hz)
#define ATS_FS  # 1 #   ;frame size     (samples)
#define ATS_WS  # 2 #   ;window Size    (samples)
#define ATS_NP  # 3 #   ;number of Partials
#define ATS_NF  # 4 #   ;number of Frames
#define ATS_AM  # 5 #   ;maximum Amplitude
#define ATS_FM  # 6 #   ;maximum Frequency (Hz)
#define ATS_DU  # 7 #   ;duration       (seconds)
#define ATS_TY  # 8 #   ;ATS file Type

instr 1
iats_file=p4
;instr1 just reads the file header and loads its data into several variables
;and prints the result in the Csound prompt.
i_sampling_rate         ATSinfo iats_file,  $ATS_SR
i_frame_size            ATSinfo iats_file,  $ATS_FS
i_window_size           ATSinfo iats_file,  $ATS_WS
i_number_of_partials    ATSinfo iats_file,  $ATS_NP
i_number_of_frames      ATSinfo iats_file,  $ATS_NF
i_max_amp               ATSinfo iats_file,  $ATS_AM
i_max_freq              ATSinfo iats_file,  $ATS_FM
i_duration              ATSinfo iats_file,  $ATS_DU
i_ats_file_type         ATSinfo iats_file,  $ATS_TY

print i_sampling_rate
print i_frame_size
print i_window_size
print i_number_of_partials
print i_number_of_frames
print i_max_amp
print i_max_freq
print i_duration
print i_ats_file_type

endin

</CsInstruments>
<CsScore>
;change to put any ATS file you like
#define ats_file #"basoon-C4.ats"#
;       st      dur     atsfile
i1      0       0       $ats_file
e
</CsScore>
</CsoundSynthesizer>
;Example by Oscar Pablo Di Liscia
