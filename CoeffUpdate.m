function [A,gA] = CoeffUpdate(yMP,A,X,opts)
gA = -(yMP*X'- A(opts.SGSubset,:)*(X*X'));
switch opts.CoeffsUpdate
    case 'GD'
        switch opts.GradientStep
            case 'fixed'
                A(opts.SGSubset,:) = A(opts.SGSubset,:) - opts.etaA.*gA;
            case {'Adam','ADAM'}
                A(opts.SGSubset,:) = A(opts.SGSubset,:) - opts.DeltaA;
        end
    case 'LS'
        A(opts.SGSubset,:) = yMP*X'/(X*X');        % perform least squares to obtain coefficients
end
end