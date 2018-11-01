opts.sigma_min = 0.01;                                                 
opts.params.maxIter = init(5e2-1,'maxIter',opts);       % maximum algorithm iterations
opts.iter = 1;                                   % Gradient descent iteration
opts.pos = 0;                                    % position of the displayed message in fprintf
opts.converged = false;                          % convergence flag
opts.nmse_prev = Inf;                            % initial normalized mean squared error
opts.params.colors = linspace(1,opts.params.T,opts.params.T);              % temporal colormap
if isfield(opts.params,'fs')
    opts.params.colors = opts.params.colors/opts.params.fs;
end

opts.params.nmse_history = nan(1,opts.params.maxIter+1);
opts.params.objective_history = opts.params.nmse_history;