d = .03; x = 0; v = 0;  Table[a = f[x]; v += a; 
v += RandomReal[{-.1, .1}]; v *= (1 - d);   x += v, {400}];