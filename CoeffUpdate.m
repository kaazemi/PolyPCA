function [A,gA] = CoeffUpdate(y,A,dLA,X,opts)
% X = X(:,opts.MPSubset);
gA = -opts.ProjectionMtx*(y*X'- A*(X*X'+opts.lambdaA*eye(opts.ToKeep)))+dLA;
switch opts.CoeffsUpdate
    case {'GD','gd'}
        switch lower(opts.GradientStep)
            case 'fixed'
                A = A - opts.etaA.*gA;
            case 'adam'
                A = A - opts.DeltaA;
        end
    case {'LS','ls'}
        A = y*X'/(X*X'+opts.lambdaA*eye(opts.ToKeep));        % perform least squares to obtain coefficients
end
end