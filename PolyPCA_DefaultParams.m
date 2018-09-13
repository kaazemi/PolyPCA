function opts = PolyPCA_DefaultParams(y,d,maxDeg,opts)
% PolyPCA_DefaultParams initializes the parameters required to run Poly-PCA
% Despite it being lengthy and complicated looking most of these are for
% better interface, plotting, and code-writing practice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Basic Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4; opts = []; end
if ~isfield(opts,'params') || ~isfield(opts.params,'rng')
    opts.params.rng = rng;                       % Save the random number generator for future use and demonstrations
else
    rng(opts.params.rng);
end
opts.d = d;
opts.maxDeg = maxDeg;
opts.ToKeep = nchoosek(d+maxDeg,d);              % number of monomials of order <= maxDeg in d variables
[opts.n,opts.T] = size(y);
opts.algorithm = 'l2_Poly_PCA';                  % minimizes the frobenius norm of error,
                                                 % l1_Poly_PCA is work in progress
                                                 % ALS
opts.maxIter = init(1e3-1,'maxIter',opts);       % maximum algorithm iterations
opts.iter = 1;                                   % Gradient descent iteration
opts.pos = 0;                                    % position of the displayed message in fprintf
opts.converged = false;                          % convergence flag
opts.nmse_prev = Inf;                            % initial normalized mean squared error
opts.params.colors = linspace(1,opts.T,opts.T);              % temporal colormap
if isfield(opts.params,'fs')
    opts.params.colors = opts.params.colors/opts.params.fs;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Temporal Dynamics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temporal latent dyanmics can be modeled as a linear autoregressive model
% of arbitrary order, usually an AR(1) suffices for enforcing continuity or sparse innovations

opts.Flags.Dynamics = init(true,'theta',opts);
if opts.Flags.Dynamics || isfield(opts,'theta')
    opts.theta = init([1 -.99],'theta',opts);    % Autoregressive model parameters for the latents: x_t = .99 x_{t-1} + s_t
                                                 % theta = 1 corresponds to no temporal structure.
else
    opts.theta = 1;
end
opts.Flags.ThetaUpdate = false;                                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient Descent Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                 
opts.GradientStep = ...                          % How to update gradient step size: 'Adam' or 'fixed'
    init('fixed','Gradient',opts);
opts = AdamDefaultParams(opts);
opts.CoeffsUpdate = init('LS','CoeffsAlg',opts); % How to update the polynomial coefficients: LS: least squares
                                                 %                                            GD: Gradient Descent
opts.SGD = init(false,'SGDFlag',opts);           % Should the algorithm perform message passing
                                                 % How many measurememts per iteration for message passing
opts.batchSize = ...
    init(floor(opts.n*.5),'batchSize',opts);
opts.SGSubset = 1:opts.n;
if opts.SGD; opts.CoeffsUpdate = 'GD'; end

opts.Flags.ClipGradient = ...                    % Clipping gradient to avoid large changes
    init(false,'ClipGradient',opts);             % Warning: Changing this to true could hurt the convergence, use with caution
opts.ClipRatio = 10;

opts.Flags.AddSaddleNoise = ...                  % Decide if you want to add noise to avoid saddle point
    init(false,'AddSaddleNoise',opts);           % Warning: Adding too much noise to the gradients could hurt the convergence
                                                 % In our experiments stationary points are ALMOST NEVER saddle points
                                                 % however adding a small amount of noise never hurts
if opts.Flags.AddSaddleNoise                     
    opts.saddleSigma = ...                       % standard deviation of noise added to gradients to escape saddle points
    init(5e-1,'saddleSigma',opts);
else
    opts.saddleSigma = 0;
end
opts.Flags.SaddleSigmaUpdate = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Regularization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.lambda0 = init(0,'lambda0',opts);
opts.lambda = opts.lambda0*ones(opts.d+1,opts.T);% regularization coefficient on the spikes (s_t's)
opts.lambdaX = 1e1*ones(opts.d+1,opts.T);        % regularization coefficient on the latents (x_t's)
opts.penalty = 'l2'; opts.p = 2;                 % regularization norm on the spikes, e.g. l2 corresponds to Gaussian AR model on the latents

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.initialization_type = ... 
        init('random','initialization',opts);    % initialization for the solution                                                 
                                                 % 'PCA'     : PCA
                                                 % 'random'  : random initialization
                                                 % 'ROTPCA'  : rotation of PC components to lie on the polynomial manifold
                                                 % 'ROOTGPCA': k'th root + Generalized Principal Component Analysis
                                                 % 'EMPCA'   : PCA on delayed embedded PC of data    
opts.delay = init(20,'delay',opts);              %  Delay value used in EMPCA initialization embedding step of the PC components (in samples).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Show Solver Parameters for quick verification %%%%%%%%%%%%%%%%%%%%%%%%%
PolyPCA_messages('autoregression',opts.theta)
PolyPCA_messages('CoeffsUpdateMethod',opts.CoeffsUpdate)
PolyPCA_messages('SGD',opts.SGD,opts.batchSize)
PolyPCA_messages('StepSize',opts.GradientStep)
PolyPCA_messages('penalty',opts.penalty,opts.lambda0)
PolyPCA_messages('saddle',opts.saddleSigma)

end

%%%%%%%%%%%%%%%%%%%%%% Helper function to overwrite default options with user inputs %%%%%%%%%%%%%%%%%%
function x = init(default,fieldName,optsin)
    if nargin < 3 || ~isfield(optsin,fieldName)
        x = default;
    else
        x = optsin.(fieldName);
    end
end

