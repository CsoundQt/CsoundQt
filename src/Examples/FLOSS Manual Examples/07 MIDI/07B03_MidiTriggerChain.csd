if inote < 48 then
 instrnum = 2
elseif inote < 72 then
 instrnum = 3
else
 instrnum = 4
endif
instrnum = instrnum + ichn/100 + inote/100000