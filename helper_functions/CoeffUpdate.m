function [A,gA] = CoeffUpdate(y,A,dLA,X,opts)
% X = X(:,opts.MPSubset);
gA = 0;
switch lower(opts.CoeffsUpdate)
    case 'gd'
        gA = -opts.ProjectionMtx*(y*X'- A*(X*X'+opts.lambdaA*eye(opts.params.ToKeep)))+dLA;
        switch lower(opts.GradientStep)
            case 'fixed'
                A = A - opts.etaA.*gA;
            case 'adam'
                A = A - opts.DeltaA;
        end
    case 'ls'
        A = y*X'/(X*X'+opts.lambdaA*eye(opts.params.ToKeep));        % perform least squares to obtain coefficients
end
end