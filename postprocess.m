function [x,opts] = postprocess(x,opts)
if opts.postProcess
    switch opts.LiftingMethod
        case {'Projection','projection','project'}
            x = x./max(abs(x),[],2);
            C = cov(x(1:opts.d,:)');
            [V,~] = eig(C);
            opts.SubspaceCoeffs = V(:,end-opts.TargetLatentDim+1:end)';
            P = opts.SubspaceCoeffs'*opts.SubspaceCoeffs;
            x(1:opts.d,:) = P*x(1:opts.d,:);
        case {'penalty','Penalty'}
            sq = sqrtm(pinv(cov(x')));
            x = sq*x;
        otherwise 
            error
    end
end
    	x(end,:) = 1;                                   % set the constant equal to 1 (avoids a separate gradient step) 
end

function x = whiten(x,d)
x = x-mean(x,2);
C = cov(x');
x(1:d,:) = sqrtm(C(1:d,1:d))\(x(1:d,:));
end