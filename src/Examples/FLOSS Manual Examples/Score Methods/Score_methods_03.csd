<CsoundSynthesizer>
<CsInstruments>
;example by tito latini

instr 1
  prints "amp = %f, freq = %f\n", p4, p5;
endin

</CsInstruments>
<CsScore bin="perl cs_sco_rand.pl">

i1  0  .01  rand()   [200 + rand(30)]
i1  +  .    rand()   [400 + rand(80)]
i1  +  .    rand()   [600 + rand(160)]
;; SEED 123
i1  +  .    rand()   [750 + rand(200)]
i1  +  .    rand()   [210 + rand(20)]
e

</CsScore>
</CsoundSynthesizer>

# cs_sco_rand.pl
my ($in, $out) = @ARGV;
open(EXT, "<", $in);
open(SCO, ">", $out);

while (<EXT>) {
  s/SEED\s+(\d+)/srand($1);$&/e;
  s/rand\(\d*\)/eval $&/ge;
  print SCO;
}
