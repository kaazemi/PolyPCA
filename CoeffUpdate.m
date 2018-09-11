function [A,gA] = CoeffUpdate(y,A,X,opts)
gA = -(y*X'- A*(X*X'));
switch opts.CoeffsUpdate
    case 'GD'
        switch opts.GradientStep
            case 'fixed'
                A = A - opts.etaA.*gA;
            case {'Adam','ADAM'}
                A = A - opts.DeltaA;
        end
    case 'LS'
        
        A = y*X'/(X*X');                                        % perform least squares to obtain coefficients
end
end