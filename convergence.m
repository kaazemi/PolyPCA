function [converged, nmse] = convergence(y,E,iter)
%% Checks for convergence of the gradient descent
% Stops if 1000 iterations reached or nmse < 0.1 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% y: data to be fit
% E: current residue (error)
% iter: current iteration
% Outputs:
% nmse: normalized mean squared error
% converged: convergence flag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nmse = norm(E,'fro')/norm(y,'fro');
converged = nmse < 0.001 || iter == 1001; %||...
%norm(etaX*dx,'fro')/norm(Xold(1:end-1,:),'fro') < 0.001;
end
