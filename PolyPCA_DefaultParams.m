function opts = PolyPCA_DefaultParams(y,d,maxDeg,opts)
if nargin < 4; opts = []; end
opts.d = d;
opts.maxDeg = maxDeg;
opts.ToKeep = nchoosek(d+maxDeg,d);              % number of monomials of order <= maxDeg in d variables
[opts.n,opts.T] = size(y);
opts.algorithm = 'l2_Poly_PCA';                  % minimizes the frobenius norm of error,
                                                 % l1_Poly_PCA is work in progress
opts.maxIter = init(999,'maxIter',opts);       % maximum algorithm iterations
opts.theta = init([1 -.99],'theta',opts);      % Autoregressive model parameters for the latents: x_t = .99 x_{t-1} + s_t
                                                 % theta = 1 corresponds to no temporal structure.
opts.etaS = init(1e-3,'etaS',opts);            % learning rate (aka step size) for gradient descent which adaptively changes with a momentum
opts.lambda0 = init(100,'lambda0',opts);
opts.lambda = opts.lambda0*ones(opts.d+1,opts.T);% regularization coefficient on the spikes (s_t's)
opts.penalty = 'l2'; opts.p = 2;                 % regularization norm on the spikes, e.g. l2 corresponds to Gaussian AR model on the latents
opts.c = linspace(1,10,opts.T);                  % temporal colormap
opts.iter = 1;                                   % Gradient descent iteration
opts.pos = 0;                                    % position of the displayed message in fprintf
opts.converged = false;                          % convergence flag
opts.nmse_prev = Inf;                            % initial normalized mean squared error
opts.initialization_type = ... 
        init('PCA','initialization',opts);     % initialization for the solution
                                                 % 'EMPCA'   : PCA on delayed embedded PC of data
                                                 % 'PCA'     : PCA
                                                 % 'random'  : random initialization
                                                 % 'ROTPCA'  : rotation of PC components to lie on the polynomial manifold
                                                 % 'ROOTGPCA': k'th root + Generalized Principal Component Analysis 
opts.saddleSigma =init(0.5,'saddleSigma',opts);% standard deviation of noise added to gradients to escape saddle points
opts.delay = init(20,'delay',opts);            % Delay value used in embedding of the PC components (in samples).

PolyPCA_messages('autoregression',opts.theta)
PolyPCA_messages('penalty',opts.penalty,opts.lambda0)
PolyPCA_messages('saddle',opts.saddleSigma)

end

function x = init(default,fieldName,optsin)
    if nargin < 3 || ~isfield(optsin,fieldName)
        x = default;
    else
        x = optsin.(fieldName);
    end
end

