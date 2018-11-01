k = params.ProjectionRatio;
if opts.ProjectUp
    opts.LinearTransform = eye(opts.params.n);
    opts.LinearTransform = [opts.LinearTransform;(randn(opts.params.n*(k-1),opts.params.n))];
    opts.LinearTransform = normr(opts.LinearTransform);
    opts.ProjectionMtx = opts.LinearTransform'*opts.LinearTransform;
else
    opts.LinearTransform  = 1;
    opts.ProjectionMtx = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Minimax Formulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
opts.Minimax = init(false,'Minimax',opts);
if opts.ProjectUp
    opts.Minimax = false;
end
if opts.Minimax
    opts.params.NumSingularValues2Keep = opts.params.ToKeep;
    opts.VMinimax = 1;
end

