function opts = AdamDefaultParams(opts)
switch opts.GradientStep
    case {'Adam','ADAM'}
        opts.Adam.beta1 = 0.9;
        opts.Adam.beta2 = 0.999;
        opts.Adam.m = 1e-3;
        opts.Adam.v = 1e-3;
        opts.Adam.alpha = 1e-3;
        opts.Adam.epsilon = 1e-8;
        opts.Adam.mhat = 0;
        opts.Adam.vhat = 0;
        opts.DeltaS = 0;

        opts.Adam.Coeffs.beta1 = 0.9;
        opts.Adam.Coeffs.beta2 = 0.999;
        opts.Adam.Coeffs.m = 1e-3*ones(opts.n,opts.ToKeep);
        opts.Adam.Coeffs.v = 1e-3*ones(opts.n,opts.ToKeep);
        opts.Adam.Coeffs.alpha = 1e-3;
        opts.Adam.Coeffs.epsilon = 1e-8;
        opts.Adam.Coeffs.mhat = zeros(opts.n,opts.ToKeep);
        opts.Adam.Coeffs.vhat = zeros(opts.n,opts.ToKeep);
        opts.DeltaA = 0;
    case 'fixed'
        opts.etaS = init(1e-3,'etaS',opts);      % initial step size for backtracking latents
        opts.etaA = init(1e-3,'etaA',opts);      % initial step size for backtracking coefficients
end


end

function x = init(default,fieldName,optsin)
    if nargin < 3 || ~isfield(optsin,fieldName)
        x = default;
    else
        x = optsin.(fieldName);
    end
end
