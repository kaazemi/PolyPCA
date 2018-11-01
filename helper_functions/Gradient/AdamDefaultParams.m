function opts = AdamDefaultParams(opts)
switch lower(opts.GradientStep)
    case 'adam'
        opts.Adam.beta1 = 0.9;
        opts.Adam.beta2 = 0.999;
        opts.Adam.m = 1e-3*ones(opts.params.d,opts.params.T);
        opts.Adam.v = 1e-3*ones(opts.params.d,opts.params.T);
        opts.Adam.alpha = 1e-3;
        opts.Adam.epsilon = 1e-8;
        opts.Adam.mhat = zeros(opts.params.d,opts.params.T);
        opts.Adam.vhat = zeros(opts.params.d,opts.params.T);
        opts.DeltaS = 0;

        opts.Adam.Coeffs.beta1 = 0.9;
        opts.Adam.Coeffs.beta2 = 0.999;
        opts.Adam.Coeffs.m = 1e-3*ones(opts.params.n,opts.params.ToKeep);
        opts.Adam.Coeffs.v = 1e-3*ones(opts.params.n,opts.params.ToKeep);
        opts.Adam.Coeffs.alpha = 1e-3;
        opts.Adam.Coeffs.epsilon = 1e-8;
        opts.Adam.Coeffs.mhat = zeros(opts.params.n,opts.params.ToKeep);
        opts.Adam.Coeffs.vhat = zeros(opts.params.n,opts.params.ToKeep);
        opts.DeltaA = 0;
    case 'fixed'
        opts.etaS = init(1e0,'etaS',opts);                                % initial step size for backtracking latents
        opts.etaA = init(1e-3*ones(opts.params.n,opts.params.ToKeep),'etaA',opts);      % initial step size for backtracking coefficients
end


end
