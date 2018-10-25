function converged = convergence(opts)
%% Checks for convergence of the gradient descent
% Stops if maximum iterations reached or nmse < 0.1 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% y: data to be fit
% E: current residue (error)
% iter: current iteration
% Outputs:
% nmse: normalized mean squared error
% converged: convergence flag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
converged = opts.nmse_current < 0.1 || opts.iter == opts.maxIter || opts.explained_var > 99.9;
end
