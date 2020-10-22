d = .01; s = 0; v = 0;  
Table[a = -.3*s; v += a; v += RandomReal[{-1, 1}]; 
v *= (1 - d); s += v, {61}];