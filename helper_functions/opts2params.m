params.pwd = pwd;

%%%%%%%%%%%%%%%%%%% Preprocessing 
params.PreProcess.Flag = opts.Flags.Preprocess;
if opts.Flags.Preprocess
    params.PreProcess.Type = 'PCA';
else
    params.PreProcess.Type = 'svd';
end
params.PreProcess.Variance2Keep = opts.var2Keep;


if opts.Minimax
    params.Minimax.Flag = true;
    params.Minimax.NumberOfSingularValues2Keep = opts.params.NumSingularValues2Keep;
    params.Minimax.ProjectionMatrix = opts.VMinimax;
end

%%%%%%%%%%%%%%%%%%% Objective 
params.Solver.Objective = opts.objective;
params.Solver.ObjectiveNorm = opts.ObjectivePenaltyNorm;

%%%%%%%%%%%%%%%%%%% Project Up
if opts.ProjectUp
    params.Minimax.Flag = true;
    params.Minimax.ProjectionRatio = params.ProjectionRatio;
    params.Minimax.LinearTransform = opts.LinearTransform;
    params.Minimax.ProjectionMatrix = opts.ProjectionMtx;
end
%%%%%%%%%%%%%%%%%%% vgd 
switch lower(opts.SolverAlgorithm)
    case 'vgd'
    params.GradientDescent.Penalty.CoeffPenalty.Type = 'Gaussian ~ l2';
    params.GradientDescent.Penalty.CoeffPenalty.Regularization = opts.lambdaA ;
    params.GradientDescent.Penalty.CoeffPenalty.Value = ...
        opts.lambdaA*norm(A,'fro')^2;
    
    params.GradientDescent.Penalty.LatentInnovationPenalty.Type  = 'Gaussian ~ l2';
    params.GradientDescent.Penalty.LatentInnovationPenalty.Regularization = opts.lambda;
    params.GradientDescent.Penalty.LatentInnovationPenalty.Value = ...
        opts.lambda*norm(s(1:opts.params.d,:),'fro')^2;
    
    params.GradientDescent.Penalty.LatentPenalty.Type = 'Gaussian ~ l2';
    params.GradientDescent.Penalty.LatentPenalty.Regularization = opts.lambdaX;
    params.GradientDescent.Penalty.LatentPenalty.Value = ...
        opts.lambdaX*norm(x(1:opts.params.d,:),'fro')^2;

    
    
    params.GradientDescent.NoisyGradient = opts.Flags.AddSaddleNoise;
    params.GradientDescent.SaddleSigmaUpdate = opts.Flags.SaddleSigmaUpdate;
    params.GradientDescent.SaddleSigma = opts.params.saddleSigma;
    params.GradientDescent.GradientClipping.Flag = opts.Flags.ClipGradient;
    if opts.Flags.ClipGradient
        params.GradientDescent.GradientClipping.Ratio =  opts.params.ClipRatio;
    end
    params.GradientDescent.StepSize.Type = opts.GradientStep;
    
    switch lower(opts.GradientStep)
    case 'adam'
        params.GradientDescent.StepSize.Adam =  opts.Adam;
        params.GradientDescent.StepSize.Adam.DeltaS =  opts.DeltaS;
        params.GradientDescent.StepSize.Adam.DeltaA =  opts.DeltaA;
        opts = rmfield(opts,'Adam');
    case 'fixed'
        params.GradientDescent.StepSize.InnovationStepSize = opts.etaS;
        switch lower(opts.CoeffsUpdate)
            case 'gd'
                params.GradientDescent.StepSize.CoeffsStepSize = opts.etaA;
        end
        opts = rmfield(opts,{'etaS','etaA'});
    end
    case 'power'
        params.PowerMethod.KalmanFilter.InnovationVariance = opts.sigma2;
    case 'admm'
end
    params.Solver.Algorithm = opts.SolverAlgorithm;
    switch lower(opts.CoeffsUpdate)
        case 'ls'
            params.Solver.PolynomialCoeffsUpdateMethod = 'Least Squares';
        case 'gd'
            params.Solver.PolynomialCoeffsUpdateMethod = 'Gradient Descent';
    end
    params.Solver.LatentDimension = opts.params.d;
    params.Solver.Samples = opts.params.T;
    params.Solver.EffectiveNumberOfNeurons = opts.params.n;
    params.Solver.MaximumPolynomialDegree = opts.params.maxDeg;
    params.Solver.MaximumSolverIterations = opts.params.maxIter+1;    
    params.Solver.PrincipalComponents = opts.params.ToKeep;
    


%%%%%%%%%%%%%%%%%%% Lifting 
if opts.Lifting
    params.Lifting.Flag = opts.Lifting;
    params.Lifting.Method = opts.LiftingMethod;
    params.Lifting.Penalty = opts.LiftingPenalty;
    params.Lifting.Regularization = opts.LiftingRegularization;
    params.Lifting.RegularizationRatio = opts.LiftingRegularizationRatio;
    params.Lifting.TargetLatentDimension = opts.TargetLatentDim;
    params.Lifting.SelectedColumns = opts.SelColumns;
end

%%%%%%%%%%%%%%%%%%% Plotting
params.Plot.colors = opts.params.colors;
%%%%%%%%%%%%%%%%%%% Dynamics

params.Dynamics.Flag = opts.Flags.Dynamics;
if opts.Flags.Dynamics
    params.Dynamics.AutoregressiveFilterCoeffs = opts.theta;
    params.Dynamics.UpdateAutoregressiveFilterCoeffs = opts.Flags.ThetaUpdate;
end

%%%%%%%%%%%%%%%%%%% PostProcessing
params.PostProcessing.Flag = opts.Flags.postProcess;
if opts.Flags.postProcess
    params.PostProcessing.Method = 'whitening';
    params.PostProcessing.Constant = opts.Latents(end,1);
end

%%%%%%%%%%%%%%%%%%% Additive Formulation
if strcmpi(opts.objective,'convex')
    params.Solver.AdditiveFormulation.Flag = true;
    params.Solver.AdditiveFormulation.MinimumSingularValue = opts.sigma_min;
end
%%%%%%%%%%%%%%%%%%% Convergence
params.Solver.Convergence.converged = opts.converged;
params.Solver.Convergence.Iteration = opts.iter;
params.Solver.Initialization.Method = opts.initialization_type;
if strcmpi(opts.initialization_type,'empca')
    params.Solver.Initialization.EmbeddingDelay = opts.delay;
end

%%%%%%%%%%%%%%%%%%%
params.PerformaceEvaluation.Residual = E;
params.PerformaceEvaluation.nmse = opts.nmse_current;
params.PerformaceEvaluation.ExplainedVariance = opts.explained_var;

params.PerformaceEvaluation.Control.Objective.ResidualNorm = norm(E,'fro')^2;
params.PerformaceEvaluation.Control.Objective.CoefficientObjective = ...
params.GradientDescent.Penalty.CoeffPenalty.Value;
params.PerformaceEvaluation.Control.Objective.InnovationObjective = ...
params.GradientDescent.Penalty.LatentInnovationPenalty.Value;
params.PerformaceEvaluation.Control.Objective.LatentObjective = ...
    params.GradientDescent.Penalty.LatentPenalty.Value;
%%%%%%%%%%%%%%%%%%%
params.Veronese.Exponents = params.Exponents;
%%%
params.Input.Observations = params.yin;

params = rmfield(params,{'yin','nin','Exponents','iExponents','Elocs','ProjectionRatio','tfCounter'});
opts = rmfield(opts,{'pwd','params','SolverAlgorithm','objective','ObjectivePenaltyNorm'...
                      'Flags','var2Keep','ProjectUp','LinearTransform','ProjectionMtx','Minimax',...
                       'Lifting','SelColumns','sigma_min','iter','pos','converged','theta','sigma2',...
                       'GradientStep','CoeffsUpdate','lambda','lambdaX','lambdaA','penalty','p',...
                       'initialization_type','explained_var','nmse_current','nmse_prev'});

