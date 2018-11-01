function [gs,dLA,opts] = PolyPCAgrad(s,x,A,E,Exponents,opts)
    switch opts.objective                                   % choose the gradient type based on the chosen norm
        case {'l2_Poly_PCA','Convex','convex'}              % backprojected error signal gets calculated first
            EbackProj = A'* opts.ProjectionMtx * (E).^(opts.ObjectivePenaltyNorm-1);
        case 'l1_Poly_PCA'
            EbackProj = A'* opts.ProjectionMtx * sign(E);
    end
    dp = dpenalty(s,opts.p);                                    % gradient of the penalty function on innovations
    %dpx= dpenalty(x,opts.penalty,opts.p);
    dx = dX2dx(x,Exponents);                                    % gradient of the monomials in latents
    gx = gradx(dx,EbackProj) ;%+ opts.lambdaX.*dpx;             % overall gradient with respect to the latents
%     gx(:,opts.TruncateIndices) = 0;
    if opts.Lifting
        [dLx,dLA,opts] = dLiftingPenalty(A,x,Exponents,opts);
    else
        dLx = 0; dLA = 0;
    end
    gx = gx+dLx+opts.lambdaX*x;
    gs = fliplr(filter(1,opts.theta,fliplr(gx),[],2)) + opts.lambda*dp;  % overall gradient with respect to innovations
end

