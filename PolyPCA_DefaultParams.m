function [opts,y,Exponents,params] = PolyPCA_DefaultParams(y,d,maxDeg,opts)
% PolyPCA_DefaultParams initializes the parameters required to run Poly-PCA
% Despite it being lengthy and complicated looking most of these are for
% better interface, plotting, and code-writing practice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Basic Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4; opts = []; end
addpath(genpath(opts.pwd));
if ~isfield(opts,'rng')
    params.rng = rng;                            % Save the random number generator for future use and demonstrations
else
    rng(opts.rng);
end
params.tfCounter = 0;
opts.d = d;
opts.algorithm = 'l2_Poly_PCA';                  % 'l2_Poly_PCA' minimizes the frobenius norm of error,
                                                 % 'l1_Poly_PCA' minimizes the l1 norm of the error matrix
                                                 % 'sum_rank_1'
                                                 % 'KL_Poly_PCA' minimizes the KL divergence
                                                 % 'Convex'
                                                 % 'ALS'
opts.ObjectivePenaltyNorm = 2;
opts.postProcess = init(true,'Preprocess',opts);   % PostProcess the latents oer iteration
switch lower(opts.algorithm)
    case 'convex'
        opts.sigmaMin = 100;
        opts.postProcess = false;
    case 'sum_rank_1'
        if mod(maxDeg,2) == 0  
            maxDeg = maxDeg+1;
        end
end


opts.maxDeg = maxDeg;
opts.ToKeep = nchoosek(d+maxDeg,d);              % number of monomials of order <= maxDeg in d variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data preprocessing using PCA and Delayed Embedding %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess data by PCA or other linear transforms to reduce dimensionality
opts.Preprocess = init(true,'Preprocess',opts); % Preprocess the data
opts.var2Keep = 99.9;
[y,opts,params] = preprocess(y,opts,params); 
[opts.n,opts.T] = size(y);
opts.ProjectUp = init(true,'ProjectUp',opts); % Preprocess the data
if opts.ProjectUp
    k = 5000;
    opts.LinearTransform = eye(opts.n);
    opts.LinearTransform = [opts.LinearTransform;(randn(opts.n*(k-1),opts.n))];
    opts.LinearTransform = normr(opts.LinearTransform);
    opts.ProjectionMtx = opts.LinearTransform'*opts.LinearTransform;
else
    opts.LinearTransform  = 1;
    opts.ProjectionMtx = 1;
end



% opts.Q = eye(opts.n);
Exponents =  sortPoly(opts.d,opts.maxDeg);         % sorts all the exponents in monomials or order <= maxDeg in d variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lifting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Lifting = init(false,'Lifting',opts);         % Should the solver lift?
opts.LiftingMethod = ...                           % Can either project down or impose a penalty
    init('penalty','LiftingMethod',opts);          % penalty or project
opts.LiftingPenalty = ...
    init(2,'LiftingPenalty',opts);

opts.LiftingRegularization = 1e2;
opts.LiftingRegularizationRatio = 1.1;
opts.TargetLatentDim = ...                         % Effective latent dimesnion
    init(2,'maxIter',opts);
%     init(floor(opts.d-1)/2,'maxIter',opts);      % By Whitney's Embedding Theorem
if opts.TargetLatentDim <= opts.d
   opts.Lifting = false;
end
if ~opts.Lifting
    opts.TargetLatentDim = opts.d;
end
opts.SelColumns  = ...
    sum(Exponents(:,opts.TargetLatentDim+1:opts.d),2) == 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Other Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts.sigma_min = 0.01;                                                 
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

opts.Flags.Dynamics = init(true,'Dynamics',opts);
if opts.Flags.Dynamics || isfield(opts,'theta')
    opts.theta = init([1 -.99],'theta',opts);    % Autoregressive model parameters for the latents: x_t = .99 x_{t-1} + s_t
                                                 % theta = 1 corresponds to no temporal structure.
else
    opts.theta = 1;
end
opts.Flags.ThetaUpdate = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Minimax Formulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
opts.Minimax = init(false,'Minimax',opts);
opts.params.NumSingularValues2Keep = opts.ToKeep;
opts.VMinimax = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient Descent Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                 
opts.GradientStep = ...                          % How to update gradient step size: 'Adam' or 'fixed'
    init('fixed','Gradient',opts);
if opts.Minimax; opts.GradientStep ='fixed'; end % Need to debug this: for some reason adam does not converge well
                                                 % with the Minimax formulation and normalization in preprocessing
                                                 % on at the same time
opts = AdamDefaultParams(opts);
opts.CoeffsUpdate = init('LS','CoeffsAlg',opts); % How to update the polynomial coefficients: LS: least squares
                                                 %                                            GD: Gradient Descent
if opts.Minimax; opts.CoeffsUpdate = 'GD'; end   %
if opts.Lifting; opts.CoeffsUpdate = 'GD'; end   %
if opts.postProcess; opts.CoeffsUpdate = 'LS';end

opts.Flags.ClipGradient = ...                    % Clipping gradient to avoid large changes
    init(false,'ClipGradient',opts);             % Warning: Changing this to true could hurt the convergence, use with caution
opts.ClipRatio = 10;

opts.Flags.AddSaddleNoise = ...                  % Decide if you want to add noise to avoid saddle point
    init(false,'AddSaddleNoise',opts);           % Warning: Adding too much noise to the gradients could hurt the convergence
                                                 % In our experiments stationary points are ALMOST NEVER saddle points
                                                 % however adding a small amount of noise never hurts
if opts.Flags.AddSaddleNoise                     
    opts.saddleSigma = ...                       % standard deviation of noise added to gradients to escape saddle points
    init(1e-4,'saddleSigma',opts);
else
    opts.saddleSigma = 0;
end
opts.Flags.SaddleSigmaUpdate = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Regularization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.lambda0 = init(0,'lambda0',opts);
opts.lambda = opts.lambda0*ones(opts.d+1,opts.T);% regularization coefficient on the spikes (s_t's)
opts.lambdaX = 0*ones(opts.d+1,opts.T);        % regularization coefficient on the latents (x_t's)
opts.lambdaA = init(0,'lambdaA',opts);         % regularization coefficient on polynomial coefficient
% opts.maxCorDirection = normc(randn(opts.d,1));
opts.maxCorDirection = randn(opts.n,opts.d);
opts.penalty = 'lp'; opts.p = 2;                 % regularization norm on the spikes, e.g. l2 corresponds to Gaussian AR model on the latents

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.initialization_type = ... 
        init('random','initialization',opts);    % initialization for the solution                                                 
                                                 % 'PCA'      : PCA
                                                 % 'spherical': For limit cycles and data with periodic behavior
                                                 % 'random'   : random initialization
                                                 % 'ROTPCA'   : rotation of PC components to lie on the polynomial manifold
                                                 % 'ROOTGPCA' : k'th root + Generalized Principal Component Analysis
                                                 % 'EMPCA'    : PCA on delayed embedded PC of data    
opts.delay = init(20,'delay',opts);              %  Delay value used in EMPCA initialization embedding step of the PC components (in samples).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Show Solver Parameters for quick verification %%%%%%%%%%%%%%%%%%%%%%%%%
PolyPCA_messages('start',opts.d,opts.maxDeg,opts.Minimax)
PolyPCA_messages('Preprocess',opts.Preprocess,opts.var2Keep)
PolyPCA_messages('PostProcessing',opts.postProcess)
PolyPCA_messages('ProjectUp',opts.ProjectUp,k*opts.n)
PolyPCA_messages('Lifting',opts.Lifting,opts.TargetLatentDim,opts.d,opts.LiftingMethod)
PolyPCA_messages('autoregression',opts.theta) 
PolyPCA_messages('CoeffsUpdateMethod',opts.CoeffsUpdate)
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

