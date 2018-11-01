function [x,opts] = postprocess(x,opts)
if opts.Flags.postProcess
    if opts.Lifting
        switch lower(opts.LiftingMethod)
            case {'projection','project'}
                x = x./max(abs(x),[],2);
                C = cov(x(1:opts.params.d,:)');
                [V,~] = eig(C);
                opts.SubspaceCoeffs = V(:,end-opts.TargetLatentDim+1:end)';
                P = opts.SubspaceCoeffs'*opts.SubspaceCoeffs;
                x(1:opts.d,:) = P*x(1:opts.params.d,:);
            case 'penalty'
                sq = sqrtm(pinv(cov(x')));
            switch lower(opts.SolverAlgorithm)
                case 'power'
                x = normr(sq*(x-mean(x,2)));
                otherwise
                x = sq*(x-mean(x,2));
            end
            otherwise 
                error
        end
    else
            x = whiten(x,opts.params.d);
            switch lower(opts.SolverAlgorithm)
                case 'power'
                x = normr(x);
            end
    end
end
    	x(end,:) = 1;                                   % set the constant equal to 1 (avoids a separate gradient step) 
end

function x = whiten(x,d)
x = x-mean(x,2);
C = cov(x');
x(1:d,:) = sqrtm(C(1:d,1:d))\(x(1:d,:));
end