function [n,T,theta,etaS,lambda,penalty,p,c,iter,pos,converged,nmse_prev,initialization_type] = PolyPCA_DefaultParams(y,d)
[n,T] = size(y);
theta = [1 -.99];               % Autoregressive model parameters for the latents: x_t = .99 x_{t-1} + s_t
                                % theta = 1 corresponds to no temporal structure.
etaS = 1e-3;                    % learning rate (aka step size) for gradient descent which adaptively changes with a momentum
lambda = 100*ones(d+1,T);       % regularization coefficient on the spikes (s_t's)
penalty = 'l2'; p = 2;          % regularization norm on the spikes, e.g. l2 corresponds to Gaussian AR model on the latents
c = linspace(1,10,T);           % temporal colormap
iter = 1;                       % Gradient descent iteration
pos = 0;                        % position of the displayed message in fprintf
converged = false;              % convergence flag
nmse_prev = Inf;                % initial normalized mean squared error
initialization_type = 'ROTPCA'; % initialization for the solution
                                % 'EMPCA': PCA on delayed embedded PC of data
                                % 'random': random initialization
                                % 'ROTPCA': rotation of PC components to lie on the polynomial manifold
end

