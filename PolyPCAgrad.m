function gs = PolyPCAgrad(s,x,A,E,Exponents,opts)
    switch opts.algorithm                                   % choose the gradient type based on the chosen norm
        case 'l2_Poly_PCA'                                  % backprojected error signal gets calculated first
            EbackProj = A'* E;
        case 'l1_Poly_PCA'
            EbackProj = A'* sign(E);
    end
    dp = dpenalty(s,opts.penalty,opts.p);                       % gradient of the penalty function on innovations
    %dpx= dpenalty(x,opts.penalty,opts.p);
    dx = dX2dx(x,Exponents);                                    % gradient of the monomials in latents
    gx = gradx(dx,EbackProj) ;%+ opts.lambdaX.*dpx;             % overall gradient with respect to the latents
    gs = fliplr(filter(1,opts.theta,fliplr(gx),[],2)) + opts.lambda.*dp;  % overall gradient with respect to innovations
end

