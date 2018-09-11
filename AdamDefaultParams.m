function opts = AdamDefaultParams(opts)
opts.Adam.beta1 = 0.9;
opts.Adam.beta2 = 0.999;
opts.Adam.m = 1e-3;
opts.Adam.v = 1e-3;
opts.Adam.alpha = 0.001;
opts.Adam.epsilon = 1e-8;
opts.Adam.mhat = 0;
opts.Adam.vhat = 0;
opts.DeltaS = 0;

opts.Adam.Coeffs.beta1 = 0.9;
opts.Adam.Coeffs.beta2 = 0.999;
opts.Adam.Coeffs.m = 1e-3;
opts.Adam.Coeffs.v = 1e-3;
opts.Adam.Coeffs.alpha = 0.001;
opts.Adam.Coeffs.epsilon = 1e-8;
opts.Adam.Coeffs.mhat = 0;
opts.Adam.Coeffs.vhat = 0;
opts.DeltaA = 0;

end