SymA = coeffs2sym( A, opts.params.d,opts.params.maxDeg,params.iExponents);
[s,x,X,Sigmax,opts] = PowerLatentUpdate(x,Sigmax,SymA,y,params.Exponents,opts);
A = CoeffUpdate(y,A,dLA,X,opts);
[opts,E] = updatePolyPCAparams(y,E,A,x,s,X,opts);