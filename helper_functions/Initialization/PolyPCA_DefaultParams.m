function [opts,y,params] = PolyPCA_DefaultParams(y,d,maxDeg,opts)
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
opts.params.d = d;

opts.SolverAlgorithm = 'vgd';                    % 'vgd' Vanilla Gradient Descent
                                                 % 'power' Power iterations
                                                 % 'ADMM'                                                 
opts.objective = 'l2_Poly_PCA';                  % 'l2_Poly_PCA' minimizes the frobenius norm of error,
                                                 % 'l1_Poly_PCA' minimizes the l1 norm of the error matrix
                                                 % 'sum_rank_1'
                                                 % 'KL_Poly_PCA' minimizes the KL divergence
                                                 % 'Convex'
                                                 % 'ALS'
opts.ObjectivePenaltyNorm = 2;
opts.Flags.postProcess = init(true,'Preprocess',opts);   % PostProcess the latents oer iteration
switch lower(opts.objective)
    case 'convex'
        opts.params.AdditiveFormulation.sigmaMin = 100;
        opts.Flags.postProcess = false;
    case 'sum_rank_1'
        if mod(maxDeg,2) == 0  
            maxDeg = maxDeg+1;
        end
end


opts.params.maxDeg = maxDeg;
opts.params.ToKeep = nchoosek(d+maxDeg,d);              % number of monomials of order <= maxDeg in d variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data preprocessing using PCA and Delayed Embedding %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess data by PCA or other linear transforms to reduce dimensionality
opts.Flags.Preprocess = init(false,'Preprocess',opts); % Preprocess the data
opts.var2Keep = 99.9;
[y,opts,params] = preprocess(y,opts,params); 
[opts.params.n,opts.params.T] = size(y);

opts.ProjectUp = init(true,'ProjectUp',opts); % Preprocess the data
params.ProjectionRatio = 20;
InitializeMinimaxParams;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% opts.Q = eye(opts.params.n);
[params.Exponents,params.iExponents,params.Elocs] ...
    =  sortPoly(opts.params.d,opts.params.maxDeg);               % sorts all the exponents in monomials or order <= maxDeg in d variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lifting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Lifting = init(false,'Lifting',opts);         % Should the solver lift?
InitializeLiftingParams;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Other Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InitializeSolverParams;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Temporal Dynamics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temporal latent dyanmics can be modeled as a linear autoregressive model
% of arbitrary order, usually an AR(1) suffices for enforcing continuity or sparse innovations
opts.Flags.Dynamics = init(true,'Dynamics',opts);
InitializeDynamics;

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
if opts.Flags.postProcess; opts.CoeffsUpdate = 'LS';end
switch lower(opts.SolverAlgorithm)
    case 'power'
        opts.CoeffsUpdate = 'LS';
end

opts.Flags.ClipGradient = ...                    % Clipping gradient to avoid large changes
    init(false,'ClipGradient',opts);             % Warning: Changing this to true could hurt the convergence, use with caution
opts.params.ClipRatio = 10;

opts.Flags.AddSaddleNoise = ...                  % Decide if you want to add noise to avoid saddle point
    init(false,'AddSaddleNoise',opts);           % Warning: Adding too much noise to the gradients could hurt the convergence
                                                 % In our experiments stationary points are ALMOST NEVER saddle points
                                                 % however adding a small amount of noise never hurts
if opts.Flags.AddSaddleNoise                     
    opts.params.saddleSigma = ...                % standard deviation of noise added to gradients to escape saddle points
    init(1e-4,'saddleSigma',opts);
else
    opts.params.saddleSigma = 0;
end
opts.Flags.SaddleSigmaUpdate = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Regularization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.lambda = init(1e3,'lambda',opts)/opts.params.T;        % regularization coefficient on the spikes (s_t's)
opts.lambdaX = 0/opts.params.T;                                           % regularization coefficient on the latents (x_t's)
opts.lambdaA = init(1e3,'lambdaA',opts)/opts.params.n;      % regularization coefficient on polynomial coefficient
opts.penalty = 'lp'; opts.p = 2;                 % regularization norm on the spikes, e.g. l2 corresponds to Gaussian AR model on the latents

if opts.lambdaA > 0 
    opts.Flags.postProcess = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.initialization_type = ... 
        init('random','initialization',opts);    % initialization for the solution                                                 
                                                 % 'PCA'      : PCA
                                                 % 'spherical': For limit cycles and data with periodic behavior
                                                 % 'random'   : random initialization
                                                 % 'ROTPCA'   : rotation of PC components to lie on the polynomial manifold
                                                 % 'ROOTGPCA' : k'th root + Generalized Principal Component Analysis
                                                 % 'EMPCA'    : PCA on delayed embedded PC of data    
if strcmpi(opts.initialization_type,'empca')
opts.delay = init(20,'delay',opts);              %  Delay value used in EMPCA initialization embedding step of the PC components (in samples).
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Show Solver Parameters for quick verification %%%%%%%%%%%%%%%%%%%%%%%%%
ShowMessages;

end

%%%%%%%%%%%%%%%%%%%%%% Helper function to overwrite default options with user inputs %%%%%%%%%%%%%%%%%%

