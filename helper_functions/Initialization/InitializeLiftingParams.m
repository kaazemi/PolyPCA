if opts.Lifting
    opts.LiftingMethod = ...                           % Can either project down or impose a penalty
        init('penalty','LiftingMethod',opts);          % penalty or project
    opts.LiftingPenalty = ...
        init(2,'LiftingPenalty',opts);
    
    opts.LiftingRegularization = 1e2;
    opts.LiftingRegularizationRatio = 1.1;
    opts.TargetLatentDim = ...                         % Effective latent dimesnion
        init(2,'maxIter',opts);
    %     init(floor(opts.params.d-1)/2,'maxIter',opts);      % By Whitney's Embedding Theorem
    if opts.TargetLatentDim <= opts.params.d
        opts.Lifting = false;
    end
    if ~opts.Lifting
        opts.TargetLatentDim = opts.params.d;
    end
    opts.SelColumns  = ...
        sum(params.Exponents(:,opts.TargetLatentDim+1:opts.params.d),2) == 0;
else
    opts.SelColumns = true(opts.params.ToKeep,1);
end